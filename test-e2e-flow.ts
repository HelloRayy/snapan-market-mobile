import { createClient } from '@supabase/supabase-js';
import { readFileSync } from 'fs';
import { resolve } from 'path';

// Parse .env manual
const envPath = resolve(process.cwd(), '.env');
const envContent = readFileSync(envPath, 'utf-8');
const env: Record<string, string> = {};
envContent.split('\n').forEach(line => {
  const [key, ...vals] = line.split('=');
  if (key && vals.length) env[key.trim()] = vals.join('=').trim();
});

const supabaseUrl = env['VITE_SUPABASE_URL'] || '';
const supabaseAnonKey = env['VITE_SUPABASE_ANON_KEY'] || '';

if (!supabaseUrl || supabaseUrl.includes('<') || supabaseUrl.includes('placeholder')) {
  console.log('❌ EROR: File .env tidak valid.');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function runE2EFlowTest() {
  console.log('🚀 MEMULAI TES ALUR APLIKASI END-TO-END (FE -> BE INTEGRATION)\n');
  console.log('===============================================================');

  const timestamp = Date.now();
  const sellerEmail = `seller_test_${timestamp}@smkn8.sch.id`;
  const buyerEmail = `buyer_test_${timestamp}@smkn8.sch.id`;
  const defaultPassword = 'TestPassword123!';

  let sellerUser: any = null;
  let buyerUser: any = null;
  let createdPost: any = null;
  let createdOrder: any = null;
  let createdConversation: any = null;

  try {
    // ------------------------------------------------------------------------
    // TAHAP 1: Sign Up / Login (Auth & Profiles)
    // ------------------------------------------------------------------------
    console.log('\n📌 TAHAP 1: Sign Up & Autentikasi Pengguna (Penjual & Pembeli)...');

    // 1A. Sign Up Seller
    const { data: sellerAuth, error: sellerErr } = await supabase.auth.signUp({
      email: sellerEmail,
      password: defaultPassword,
      options: {
        data: {
          full_name: 'Budi Penjual PPLG',
          username: `budi_seller_${timestamp}`,
          class_group: 'XII PPLG 1'
        }
      }
    });

    if (sellerErr) throw new Error(`Gagal Sign Up Seller: ${sellerErr.message}`);
    sellerUser = sellerAuth.user;
    console.log(`  ✅ Seller Terdaftar: ${sellerUser?.email} (ID: ${sellerUser?.id})`);

    // 1B. Sign Up Buyer
    const { data: buyerAuth, error: buyerErr } = await supabase.auth.signUp({
      email: buyerEmail,
      password: defaultPassword,
      options: {
        data: {
          full_name: 'Siti Pembeli DKV',
          username: `siti_buyer_${timestamp}`,
          class_group: 'XI DKV 2'
        }
      }
    });

    if (buyerErr) throw new Error(`Gagal Sign Up Buyer: ${buyerErr.message}`);
    buyerUser = buyerAuth.user;
    console.log(`  ✅ Buyer Terdaftar: ${buyerUser?.email} (ID: ${buyerUser?.id})`);

    // ------------------------------------------------------------------------
    // TAHAP 2: Buat Postingan Jualan / Utas (Market Post oleh Penjual)
    // ------------------------------------------------------------------------
    console.log('\n📌 TAHAP 2: Penjual Login & Membuat Postingan Produk Jualan (Create Market Post)...');

    // Login sebagai Seller agar auth.uid() valid di RLS
    const { error: sellerLoginErr } = await supabase.auth.signInWithPassword({
      email: sellerEmail,
      password: defaultPassword
    });
    if (sellerLoginErr) throw new Error(`Gagal Login Seller: ${sellerLoginErr.message}`);

    const newPostPayload = {
      seller_id: sellerUser.id,
      post_type: 'product',
      title: 'Buku Modul Praktikum PPLG 2026 (Preloved)',
      caption: 'Dijual murah buku modul praktikum PPLG kondisi 95% mulus tanpa coretan! 🚀',
      description: 'Sudah termasuk rangkuman materi React, TypeScript & Supabase lengkap.',
      price: 25000,
      original_price: 35000,
      category: 'Buku',
      stock: 5,
      location_tag: 'Lab PPLG 1',
      topic_tag: 'PPLG',
      is_official_topic: true,
      topic_icon: 'presentation',
      images: ['https://lcwsxldnoqjdfqxqcqja.supabase.co/storage/v1/object/public/market-media/demo-book.jpg']
    };

    const { data: postData, error: postErr } = await supabase
      .from('market_posts')
      .insert(newPostPayload)
      .select()
      .single();

    if (postErr) throw new Error(`Gagal Membuat Postingan Jualan: ${postErr.message}`);
    createdPost = postData;
    console.log(`  ✅ Post Jualan Berhasil Dibuat!`);
    console.log(`     • Judul: "${createdPost.title}"`);
    console.log(`     • Harga: Rp ${createdPost.price.toLocaleString('id-ID')}`);
    console.log(`     • Stok: ${createdPost.stock} pcs | Lokasi: ${createdPost.location_tag}`);

    // ------------------------------------------------------------------------
    // TAHAP 3: Checkout COD & Pemilihan Titik Temu (In-App Order oleh Pembeli)
    // ------------------------------------------------------------------------
    console.log('\n📌 TAHAP 3: Pembeli Login & Melakukan Checkout COD di Titik Temu Sekolah...');

    // Login sebagai Buyer agar auth.uid() valid di RLS
    const { error: buyerLoginErr } = await supabase.auth.signInWithPassword({
      email: buyerEmail,
      password: defaultPassword
    });
    if (buyerLoginErr) throw new Error(`Gagal Login Buyer: ${buyerLoginErr.message}`);

    // Ambil master meeting point (Lab PPLG 1)
    const { data: meetingPoint } = await supabase
      .from('school_meeting_points')
      .select('*')
      .eq('id', 'lab_pplg_1')
      .maybeSingle();

    const meetingPointId = meetingPoint?.id || 'lab_pplg_1';
    const meetingPointName = meetingPoint?.name || 'Lab Komputer PPLG 1';

    const orderCode = 'SNAPAN-ORD-' + Math.random().toString(36).substring(2, 8).toUpperCase();
    const orderPayload = {
      order_code: orderCode,
      buyer_id: buyerUser.id,
      seller_id: sellerUser.id,
      post_id: createdPost.id,
      quantity: 1,
      unit_price: createdPost.price,
      total_price: createdPost.price,
      meeting_point_id: meetingPointId,
      meeting_point_name: meetingPointName,
      meeting_time_notes: 'Jam istirahat kedua (12.00 WIB)',
      notes_for_seller: 'Tolong bawa bukunya ke depan Lab PPLG 1 ya kak',
      status: 'pending'
    };

    const { data: orderData, error: orderErr } = await supabase
      .from('orders')
      .insert(orderPayload)
      .select()
      .single();

    if (orderErr) throw new Error(`Gagal Membuat Pesanan COD: ${orderErr.message}`);
    createdOrder = orderData;
    console.log(`  ✅ Pesanan COD Berhasil Dibuat!`);
    console.log(`     • Kode Order: ${createdOrder.order_code}`);
    console.log(`     • Titik Temu: ${createdOrder.meeting_point_name}`);
    console.log(`     • Total Bayar: Rp ${createdOrder.total_price.toLocaleString('id-ID')}`);
    console.log(`     • Status: ${createdOrder.status.toUpperCase()}`);

    // ------------------------------------------------------------------------
    // TAHAP 4: Kirim Pesan Realtime & Chat Obrolan (Direct Messaging)
    // ------------------------------------------------------------------------
    console.log('\n📌 TAHAP 4: Pembeli & Penjual Berkomunikasi via Direct Messaging (Pesan Realtime)...');

    // 4A. Pembeli Memulai Percakapan (Conversation) terkait Produk
    const { data: convData, error: convErr } = await supabase
      .from('conversations')
      .insert({
        participant_one: buyerUser.id,
        participant_two: sellerUser.id,
        product_id: createdPost.id,
        last_message: 'Halo kak, saya sudah buat order COD untuk buku PPLG!',
        last_message_at: new Date().toISOString()
      })
      .select()
      .single();

    if (convErr) throw new Error(`Gagal Membuat Thread Chat: ${convErr.message}`);
    createdConversation = convData;
    console.log(`  ✅ Thread Percakapan Pembeli-Penjual Terbentuk (ID: ${createdConversation.id})`);

    // 4B. Pembeli Kirim Pesan Pertama
    const { data: msg1, error: msg1Err } = await supabase
      .from('direct_messages')
      .insert({
        conversation_id: createdConversation.id,
        sender_id: buyerUser.id,
        message_text: `Halo kak Budi, pesanan ${createdOrder.order_code} sudah disubmit. Ketemuan jam istirahat di ${meetingPointName} ya!`,
        is_read: false
      })
      .select()
      .single();

    if (msg1Err) throw new Error(`Gagal Kirim Pesan Buyer: ${msg1Err.message}`);
    console.log(`  💬 [Siti (Buyer)]: "${msg1.message_text}"`);

    // 4C. Penjual Login & Membalas Pesan
    await supabase.auth.signInWithPassword({
      email: sellerEmail,
      password: defaultPassword
    });

    const { data: msg2, error: msg2Err } = await supabase
      .from('direct_messages')
      .insert({
        conversation_id: createdConversation.id,
        sender_id: sellerUser.id,
        message_text: `Siap Siti! Buku modul PPLG sudah saya siapkan. Sampai jumpa di depan Lab PPLG 1!`,
        is_read: true
      })
      .select()
      .single();

    if (msg2Err) throw new Error(`Gagal Kirim Pesan Seller: ${msg2Err.message}`);
    console.log(`  💬 [Budi (Seller)]: "${msg2.message_text}"`);

    console.log('\n===============================================================');
    console.log('🎉 HASIL TES ALUR APLIKASI END-TO-END: 100% SUKSES!');
    console.log('===============================================================\n');

  } catch (err: any) {
    console.error(`\n❌ TERJADI EROR PADA ALUR TES: ${err.message || String(err)}`);
    process.exit(1);
  }
}

runE2EFlowTest();
