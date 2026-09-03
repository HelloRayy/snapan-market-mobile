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

console.log('🚀 MEMULAI INTEGRATION TEST BACKEND SUPABASE...\n');
console.log(`🔗 Target URL: ${supabaseUrl}`);

if (!supabaseUrl || supabaseUrl.includes('<') || supabaseUrl.includes('placeholder')) {
  console.log('\n❌ EROR: File .env masih berisi URL placeholder.');
  console.log('💡 Harap isi VITE_SUPABASE_URL dan VITE_SUPABASE_ANON_KEY di file .env dengan URL dan Anon Key asli dari Supabase Dashboard terlebih dahulu.\n');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function runTests() {
  let passed = 0;
  let failed = 0;

  async function test(name: string, fn: () => Promise<void>) {
    try {
      process.stdout.write(`⏳ Testing: ${name}... `);
      await fn();
      console.log('✅ PASS');
      passed++;
    } catch (err: any) {
      console.log(`❌ FAIL -> ${err.message || err}`);
      failed++;
    }
  }

  // 1. Test Koneksi Dasar Supabase & Auth
  await test('1. Koneksi Supabase & Auth Ping', async () => {
    const { data, error } = await supabase.auth.getSession();
    if (error) throw error;
  });

  // 2. Test Tabel Profiles
  await test('2. Query Tabel public.profiles', async () => {
    const { data, error } = await supabase.from('profiles').select('id, full_name, role').limit(5);
    if (error) throw error;
  });

  // 3. Test Tabel School Meeting Points & Seed Data
  await test('3. Query public.school_meeting_points (Seed Data SMKN 8)', async () => {
    const { data, error } = await supabase.from('school_meeting_points').select('*');
    if (error) throw error;
    if (!data || data.length === 0) {
      throw new Error('Tabel kosong! Jalankan seed data di schema.sql.');
    }
    console.log(`(Ditemukan ${data.length} titik temu) `);
  });

  // 4. Test Tabel Market Posts
  await test('4. Query public.market_posts (Feed & Jualan)', async () => {
    const { data, error } = await supabase.from('market_posts').select('*').limit(5);
    if (error) throw error;
  });

  // 5. Test Tabel Post Comments
  await test('5. Query public.post_comments (Threaded Comments)', async () => {
    const { data, error } = await supabase.from('post_comments').select('*').limit(5);
    if (error) throw error;
  });

  // 6. Test Tabel Orders
  await test('6. Query public.orders (In-App COD Transactions)', async () => {
    const { data, error } = await supabase.from('orders').select('*').limit(5);
    if (error) throw error;
  });

  // 7. Test Tabel Order Notifications
  await test('7. Query public.order_notifications', async () => {
    const { data, error } = await supabase.from('order_notifications').select('*').limit(5);
    if (error) throw error;
  });

  // 8. Test Tabel User Follows & Post Reposts
  await test('8. Query public.user_follows & post_reposts', async () => {
    const { error: err1 } = await supabase.from('user_follows').select('*').limit(1);
    if (err1) throw err1;
    const { error: err2 } = await supabase.from('post_reposts').select('*').limit(1);
    if (err2) throw err2;
  });

  // 9. Test RPC Function: get_seller_verified_stats
  await test('9. Stored Procedure RPC: get_seller_verified_stats', async () => {
    const { data, error } = await supabase.rpc('get_seller_verified_stats', {
      target_seller_id: '00000000-0000-0000-0000-000000000000'
    });
    if (error) throw error;
    if (typeof data !== 'object') throw new Error('Return data RPC tidak sesuai format JSON');
  });

  // 10. Test Storage Bucket: market-media
  await test('10. Supabase Storage Bucket: market-media (Client Access)', async () => {
    const { data, error } = await supabase.storage.from('market-media').list();
    if (error) throw error;
  });

  console.log('\n========================================');
  console.log(`📊 HASIL TEST: ${passed} Passed | ${failed} Failed`);
  console.log('========================================\n');

  if (failed === 0) {
    console.log('🎉 SEMUA API & DATABASE BACKEND 100% BERFUNGSI SEMPURNA!\n');
  } else {
    console.log('⚠️ Ada beberapa item yang perlu diperbaiki (lihat log FAIL di atas).\n');
  }
}

runTests();
