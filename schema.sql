-- ========================================================
-- 🗄️ SNAPAN MARKET MOBILE — DATABASE MIGRATION SCRIPT
-- Copy & Paste isi file ini ke Supabase Dashboard -> SQL Editor
-- ========================================================

-- 1. TABEL PROFILES (Ekstensi auth.users)
create table if not exists public.profiles (
  id uuid primary key,
  full_name text not null,
  username text unique,
  avatar_url text,
  class_group text default 'Siswa Snapan',
  is_verified boolean default false,
  role text default 'buyer' check (role in ('buyer', 'seller', 'admin')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Trigger Otomatis saat User Sign Up (Google OAuth / Email)
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, username, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', 'Pengguna Baru'),
    coalesce(new.raw_user_meta_data->>'username', lower(replace(coalesce(new.raw_user_meta_data->>'full_name', 'user'), ' ', ''))),
    coalesce(new.raw_user_meta_data->>'avatar_url', new.raw_user_meta_data->>'picture', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


-- 2. TABEL MARKET POSTS (Postingan Feed Jualan & Utas Sosial)
create table if not exists public.market_posts (
  id uuid default gen_random_uuid() primary key,
  seller_id uuid references public.profiles(id) on delete cascade not null,
  post_type text default 'thread' check (post_type in ('thread', 'product')),
  title text,
  caption text not null,
  description text,
  price numeric default 0 check (price >= 0),
  original_price numeric default 0 check (original_price >= 0),
  category text default 'Umum',
  images text[] default '{}',
  is_video boolean default false,
  stock integer default 1 check (stock >= 0),
  location_tag text default 'SMKN 8',
  topic_tag text,
  is_official_topic boolean default false,
  topic_icon text default 'threads',
  likes_count integer default 0 check (likes_count >= 0),
  comments_count integer default 0 check (comments_count >= 0),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Safe Alter Column untuk tabel market_posts yang sudah terlanjur dibuat versi lama
alter table public.market_posts add column if not exists post_type text default 'thread' check (post_type in ('thread', 'product'));
alter table public.market_posts add column if not exists title text;
alter table public.market_posts add column if not exists description text;
alter table public.market_posts add column if not exists topic_tag text;
alter table public.market_posts add column if not exists is_official_topic boolean default false;
alter table public.market_posts add column if not exists topic_icon text default 'threads';
alter table public.market_posts add column if not exists likes_count integer default 0 check (likes_count >= 0);
alter table public.market_posts add column if not exists comments_count integer default 0 check (comments_count >= 0);


-- 3. TABEL POST LIKES (Suka Postingan Utas/Produk)
create table if not exists public.post_likes (
  post_id uuid references public.market_posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (post_id, user_id)
);


-- 4. TABEL POST COMMENTS (Komentar & Sub-Thread Bersarang)
create table if not exists public.post_comments (
  id uuid default gen_random_uuid() primary key,
  post_id uuid references public.market_posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  parent_comment_id uuid references public.post_comments(id) on delete cascade,
  content text not null,
  images text[] default '{}',
  thread_part integer default 1,
  total_parts integer default 1,
  likes_count integer default 0 check (likes_count >= 0),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Safe Alter Column untuk tabel post_comments versi lama
alter table public.post_comments add column if not exists parent_comment_id uuid references public.post_comments(id) on delete cascade;
alter table public.post_comments add column if not exists images text[] default '{}';
alter table public.post_comments add column if not exists thread_part integer default 1;
alter table public.post_comments add column if not exists total_parts integer default 1;
alter table public.post_comments add column if not exists likes_count integer default 0 check (likes_count >= 0);


-- 5. TABEL COMMENT LIKES (Suka Komentar & Balasan)
create table if not exists public.comment_likes (
  comment_id uuid references public.post_comments(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (comment_id, user_id)
);


-- 6. TABEL CART ITEMS (Keranjang Belanja User)
create table if not exists public.cart_items (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  post_id uuid references public.market_posts(id) on delete cascade not null,
  quantity integer default 1 check (quantity > 0),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique (user_id, post_id)
);


-- 7. TABEL POST BOOKMARKS (Simpan / Markah Postingan)
create table if not exists public.post_bookmarks (
  post_id uuid references public.market_posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (post_id, user_id)
);


-- 8. TABEL NOTIFICATIONS (Notifikasi Sistem & Interaksi Sosial)
create table if not exists public.notifications (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  actor_id uuid references public.profiles(id) on delete cascade,
  type text not null check (type in ('like', 'comment', 'reply', 'order', 'system')),
  title text not null,
  message text not null,
  post_id uuid references public.market_posts(id) on delete cascade,
  is_read boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);


-- ========================================================
-- 🛡️ ROW LEVEL SECURITY (RLS) POLICIES
-- ========================================================
alter table public.profiles enable row level security;
alter table public.market_posts enable row level security;
alter table public.post_likes enable row level security;
alter table public.post_comments enable row level security;
alter table public.comment_likes enable row level security;
alter table public.cart_items enable row level security;
alter table public.post_bookmarks enable row level security;
alter table public.notifications enable row level security;

-- Profiles Policies
drop policy if exists "Profiles viewable by everyone" on public.profiles;
drop policy if exists "Users can update own profile" on public.profiles;
create policy "Profiles viewable by everyone" on public.profiles for select using (true);
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id);

-- Market Posts Policies
drop policy if exists "Market posts viewable by everyone" on public.market_posts;
drop policy if exists "Sellers can insert own posts" on public.market_posts;
drop policy if exists "Sellers can update own posts" on public.market_posts;
drop policy if exists "Sellers can delete own posts" on public.market_posts;
create policy "Market posts viewable by everyone" on public.market_posts for select using (true);
create policy "Sellers can insert own posts" on public.market_posts for insert with check (auth.uid() = seller_id);
create policy "Sellers can update own posts" on public.market_posts for update using (auth.uid() = seller_id);
create policy "Sellers can delete own posts" on public.market_posts for delete using (auth.uid() = seller_id);

-- Post Likes Policies
drop policy if exists "Likes viewable by everyone" on public.post_likes;
drop policy if exists "Users can like posts" on public.post_likes;
drop policy if exists "Users can unlike posts" on public.post_likes;
drop policy if exists "Users can toggle own post like" on public.post_likes;
create policy "Likes viewable by everyone" on public.post_likes for select using (true);
create policy "Users can like posts" on public.post_likes for insert with check (auth.uid() = user_id);
create policy "Users can unlike posts" on public.post_likes for delete using (auth.uid() = user_id);

-- Post Comments Policies
drop policy if exists "Comments viewable by everyone" on public.post_comments;
drop policy if exists "Users can insert comments" on public.post_comments;
drop policy if exists "Users can delete own comments" on public.post_comments;
create policy "Comments viewable by everyone" on public.post_comments for select using (true);
create policy "Users can insert comments" on public.post_comments for insert with check (auth.uid() = user_id);
create policy "Users can delete own comments" on public.post_comments for delete using (auth.uid() = user_id);

-- Comment Likes Policies
drop policy if exists "Comment likes viewable by everyone" on public.comment_likes;
drop policy if exists "Users can toggle own comment like" on public.comment_likes;
create policy "Comment likes viewable by everyone" on public.comment_likes for select using (true);
create policy "Users can toggle own comment like" on public.comment_likes for all using (auth.uid() = user_id);

-- Cart Items Policies
drop policy if exists "Users view own cart" on public.cart_items;
drop policy if exists "Users add to own cart" on public.cart_items;
drop policy if exists "Users modify own cart" on public.cart_items;
drop policy if exists "Users remove from own cart" on public.cart_items;
create policy "Users view own cart" on public.cart_items for select using (auth.uid() = user_id);
create policy "Users add to own cart" on public.cart_items for insert with check (auth.uid() = user_id);
create policy "Users modify own cart" on public.cart_items for update using (auth.uid() = user_id);
create policy "Users remove from own cart" on public.cart_items for delete using (auth.uid() = user_id);

-- Post Bookmarks Policies
drop policy if exists "Users view own bookmarks" on public.post_bookmarks;
drop policy if exists "Users add own bookmark" on public.post_bookmarks;
drop policy if exists "Users remove own bookmark" on public.post_bookmarks;
create policy "Users view own bookmarks" on public.post_bookmarks for select using (auth.uid() = user_id);
create policy "Users add own bookmark" on public.post_bookmarks for insert with check (auth.uid() = user_id);
create policy "Users remove own bookmark" on public.post_bookmarks for delete using (auth.uid() = user_id);

-- Notifications Policies
drop policy if exists "Users view own notifications" on public.notifications;
drop policy if exists "Users update own notifications" on public.notifications;
drop policy if exists "Users delete own notifications" on public.notifications;
drop policy if exists "Authenticated users can create notification" on public.notifications;
create policy "Users view own notifications" on public.notifications for select using (auth.uid() = user_id);
create policy "Users update own notifications" on public.notifications for update using (auth.uid() = user_id);
create policy "Users delete own notifications" on public.notifications for delete using (auth.uid() = user_id);
create policy "Authenticated users can create notification" on public.notifications for insert with check (auth.role() = 'authenticated');


-- ========================================================
-- ⚡ INDEXING UNTUK PERFORMA PENCARIAN & FILTERING
-- ========================================================
create index if not exists idx_market_posts_category on public.market_posts(category);
create index if not exists idx_market_posts_post_type on public.market_posts(post_type);
create index if not exists idx_market_posts_price on public.market_posts(price);
create index if not exists idx_market_posts_created_at on public.market_posts(created_at desc);


-- ========================================================
-- 🛒 IN-APP ORDER SYSTEM (COD TRANSACTIONS SMKN 8)
-- ========================================================

-- 9. ENUM ORDER STATUS (State Machine)
do $$ begin
  create type order_status_enum as enum (
    'pending',     -- Pembeli baru saja membuat pesanan (Menunggu respon penjual)
    'in_cod',      -- Penjual menerima pesanan (Sedang dalam proses COD di sekolah)
    'completed',   -- Serah terima barang & pembayaran selesai (Statistik SAH)
    'cancelled',   -- Dibatalkan oleh pembeli sebelum status in_cod
    'rejected'     -- Ditolak oleh penjual (misal: barang rusak / mendadak habis)
  );
exception when duplicate_object then null;
end $$;


-- 10. TABEL SCHOOL MEETING POINTS (Denah Hotspot COD SMKN 8)
create table if not exists public.school_meeting_points (
  id varchar(50) primary key,
  floor integer not null check (floor in (1, 2, 3)),
  name varchar(100) not null,
  area_category varchar(50) not null,
  description varchar(255),
  coordinates_x float not null,
  coordinates_y float not null,
  is_active boolean not null default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);


-- 11. TABEL ORDERS (Manajemen Pesanan In-App COD)
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_code varchar(24) unique not null,
  buyer_id uuid not null references public.profiles(id) on delete restrict,
  seller_id uuid not null references public.profiles(id) on delete restrict,
  post_id uuid not null references public.market_posts(id) on delete restrict,

  -- Rincian Transaksi
  quantity integer not null default 1 check (quantity > 0),
  unit_price numeric(12, 2) not null check (unit_price >= 0),
  total_price numeric(12, 2) not null check (total_price >= 0),

  -- Titik Temu COD di Sekolah
  meeting_point_id varchar(50) references public.school_meeting_points(id),
  meeting_point_name varchar(100) not null,
  meeting_time_notes varchar(255),
  notes_for_seller text,

  -- Status & Pelacakan Waktu
  status order_status_enum not null default 'pending',
  cancelled_by uuid references public.profiles(id),
  cancel_reason text,
  accepted_at timestamp with time zone,
  completed_at timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,

  -- Aturan Integritas: Tidak Boleh Membeli Produk Sendiri
  constraint check_not_self_buy check (buyer_id != seller_id)
);


-- 12. TABEL ORDER NOTIFICATIONS (Log Notifikasi Realtime Pesanan)
create table if not exists public.order_notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid not null references public.profiles(id) on delete cascade,
  order_id uuid not null references public.orders(id) on delete cascade,
  title varchar(120) not null,
  message text not null,
  type varchar(40) not null,
  is_read boolean not null default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);


-- 13. ALTER MARKET_POSTS: Tambah kolom stok habis & total terjual
alter table public.market_posts add column if not exists is_sold_out boolean not null default false;
alter table public.market_posts add column if not exists total_sold_units integer not null default 0;

-- 14. ALTER PROFILES: Tambah kolom statistik penjualan terverifikasi
alter table public.profiles add column if not exists verified_sales_count integer not null default 0;
alter table public.profiles add column if not exists total_revenue_idr numeric(14, 2) not null default 0.00;


-- ========================================================
-- ⚙️ STORED FUNCTIONS & TRIGGERS (ORDER BUSINESS LOGIC)
-- ========================================================

-- 15. TRIGGER: Auto Stock Reduction & Sold Out saat Order Completed
create or replace function public.fn_handle_order_completed()
returns trigger as $$
begin
  if new.status = 'completed' and old.status != 'completed' then

    -- 1. Catat waktu penyelesaian
    new.completed_at = now();

    -- 2. Kurangi stok barang di market_posts
    update public.market_posts
    set
      stock = greatest(0, stock - new.quantity),
      total_sold_units = total_sold_units + new.quantity,
      is_sold_out = case when (stock - new.quantity) <= 0 then true else is_sold_out end
    where id = new.post_id;

    -- 3. Perbarui Statistik Penjualan Sah di profil penjual
    update public.profiles
    set
      verified_sales_count = verified_sales_count + 1,
      total_revenue_idr = total_revenue_idr + new.total_price
    where id = new.seller_id;

    -- 4. Buat notifikasi transaksi sukses untuk pembeli
    insert into public.order_notifications (recipient_id, order_id, title, message, type)
    values (
      new.buyer_id,
      new.id,
      'Transaksi COD Berhasil! 🎉',
      'Pesanan ' || new.order_code || ' telah diselesaikan. Terima kasih telah berbelanja di Snapan Market!',
      'order_completed'
    );

  end if;

  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists tr_order_completed on public.orders;
create trigger tr_order_completed
  before update on public.orders
  for each row
  execute function public.fn_handle_order_completed();


-- 16. RPC: Anti Double-Buy Checkout (Row-Level Lock FOR UPDATE)
create or replace function public.create_in_app_order(
  p_post_id uuid,
  p_quantity int,
  p_meeting_point_id varchar,
  p_meeting_point_name varchar,
  p_meeting_notes varchar,
  p_buyer_notes text
)
returns json as $$
declare
  v_buyer_id uuid;
  v_seller_id uuid;
  v_price numeric;
  v_current_stock int;
  v_order_code varchar;
  v_order_id uuid;
begin
  -- Ambil ID User yang sedang login
  v_buyer_id := auth.uid();
  if v_buyer_id is null then
    raise exception 'Pengguna tidak terautentikasi.';
  end if;

  -- Kunci baris postingan untuk validasi stok terkini (Mencegah Race Condition)
  select seller_id, price, stock
  into v_seller_id, v_price, v_current_stock
  from public.market_posts
  where id = p_post_id
  for update;

  if not found then
    raise exception 'Produk tidak ditemukan.';
  end if;

  if v_buyer_id = v_seller_id then
    raise exception 'Anda tidak dapat membeli produk Anda sendiri.';
  end if;

  if v_current_stock < p_quantity then
    raise exception 'Stok barang tidak mencukupi (Tersisa % pcs).', v_current_stock;
  end if;

  -- Generate Kode Pesanan Unik: SNAPAN-ORD-XXXXXX
  v_order_code := 'SNAPAN-ORD-' || upper(substring(gen_random_uuid()::text from 1 for 6));

  -- Insert Pesanan Baru
  insert into public.orders (
    order_code, buyer_id, seller_id, post_id,
    quantity, unit_price, total_price,
    meeting_point_id, meeting_point_name, meeting_time_notes,
    notes_for_seller, status
  ) values (
    v_order_code, v_buyer_id, v_seller_id, p_post_id,
    p_quantity, v_price, (v_price * p_quantity),
    p_meeting_point_id, p_meeting_point_name, p_meeting_notes,
    p_buyer_notes, 'pending'
  ) returning id into v_order_id;

  -- Kirim Notifikasi ke Penjual
  insert into public.order_notifications (recipient_id, order_id, title, message, type)
  values (
    v_seller_id,
    v_order_id,
    'Pesanan Baru Masuk! 🛍️',
    'Seseorang ingin membeli produk Anda (' || v_order_code || '). Silakan cek tab Penjualan Masuk.',
    'order_created'
  );

  return json_build_object(
    'success', true,
    'order_id', v_order_id,
    'order_code', v_order_code
  );
end;
$$ language plpgsql volatile security definer;


-- 17. RPC: Seller Verified Sales Stats (Anti-Fraud Query)
create or replace function public.get_seller_verified_stats(target_seller_id uuid)
returns json as $$
declare
  v_sales_count int;
  v_unique_buyers int;
  v_total_revenue numeric;
begin
  select
    count(id),
    count(distinct buyer_id),
    coalesce(sum(total_price), 0)
  into
    v_sales_count,
    v_unique_buyers,
    v_total_revenue
  from public.orders
  where seller_id = target_seller_id and status = 'completed';

  return json_build_object(
    'completed_sales_count', v_sales_count,
    'unique_buyers_count', v_unique_buyers,
    'total_revenue_idr', v_total_revenue
  );
end;
$$ language plpgsql stable security definer;


-- ========================================================
-- 🛡️ RLS POLICIES UNTUK ORDER SYSTEM
-- ========================================================
alter table public.orders enable row level security;
alter table public.school_meeting_points enable row level security;
alter table public.order_notifications enable row level security;

-- School Meeting Points: Publik bisa baca seluruh denah
drop policy if exists "Public read meeting points" on public.school_meeting_points;
create policy "Public read meeting points"
  on public.school_meeting_points for select using (true);

-- Orders: Hanya Pembeli & Penjual yang berhak melihat pesanan
drop policy if exists "Users can read own orders" on public.orders;
create policy "Users can read own orders"
  on public.orders for select to authenticated
  using (auth.uid() = buyer_id or auth.uid() = seller_id);

-- Orders: Hanya Pembeli yang bisa membuat pesanan baru
drop policy if exists "Buyers can insert new order" on public.orders;
create policy "Buyers can insert new order"
  on public.orders for insert to authenticated
  with check (auth.uid() = buyer_id and buyer_id != seller_id);

-- Orders: Update Status Berdasarkan Peran
drop policy if exists "Buyer and Seller can update order status" on public.orders;
create policy "Buyer and Seller can update order status"
  on public.orders for update to authenticated
  using (auth.uid() = buyer_id or auth.uid() = seller_id)
  with check (auth.uid() = buyer_id or auth.uid() = seller_id);

-- Order Notifications: Hanya penerima yang berhak melihat notifikasi
drop policy if exists "Users can read own order notifications" on public.order_notifications;
create policy "Users can read own order notifications"
  on public.order_notifications for select to authenticated
  using (auth.uid() = recipient_id);

-- Order Notifications: Update (mark as read)
drop policy if exists "Users can update own order notifications" on public.order_notifications;
create policy "Users can update own order notifications"
  on public.order_notifications for update to authenticated
  using (auth.uid() = recipient_id);

-- Order Notifications: Insert (system/trigger generated)
drop policy if exists "Authenticated can create order notifications" on public.order_notifications;
create policy "Authenticated can create order notifications"
  on public.order_notifications for insert to authenticated
  with check (auth.role() = 'authenticated');


-- ========================================================
-- ⚡ INDEXING ORDER SYSTEM
-- ========================================================
create index if not exists idx_orders_buyer_id on public.orders(buyer_id);
create index if not exists idx_orders_seller_id on public.orders(seller_id);
create index if not exists idx_orders_post_id on public.orders(post_id);
create index if not exists idx_orders_status on public.orders(status);
create index if not exists idx_orders_created_at on public.orders(created_at desc);
create index if not exists idx_order_notifications_recipient on public.order_notifications(recipient_id);
create index if not exists idx_order_notifications_order on public.order_notifications(order_id);


-- ========================================================
-- 📡 REALTIME PUBLICATION (Push Event In-App)
-- ========================================================
-- Uncomment baris di bawah setelah menjalankan di Supabase SQL Editor:
-- alter publication supabase_realtime add table public.orders;
-- alter publication supabase_realtime add table public.order_notifications;


-- ========================================================
-- 🏫 SEED DATA: TITIK TEMU COD SMKN 8 JAKARTA
-- ========================================================
insert into public.school_meeting_points (id, floor, name, area_category, description, coordinates_x, coordinates_y)
values
  -- Lantai 1
  ('canteen_main',       1, 'Kantin Utama & Pujasera',       'canteen',   'Area meja makan kantin belakang',                35.0, 75.0),
  ('sports_field',       1, 'Lapangan Olahraga Utama',       'sports',    'Depan tiang bendera lapangan tengah',            50.0, 50.0),
  ('gazebo_field',       1, 'Gazebo Pinggir Lapangan',       'lounge',    'Gazebo teduh samping lapangan basket',           68.0, 42.0),
  ('lobby_front',        1, 'Lobby Depan / Pos Satpam',      'corridor',  'Area pintu masuk lobby utama sekolah',           50.0, 90.0),
  ('workshop_otomotif',  1, 'Bengkel Praktik Otomotif',      'workshop',  'Depan ruang alat bengkel TKR/TSM',               20.0, 60.0),
  -- Lantai 2
  ('lab_pplg_1',         2, 'Lab Komputer PPLG 1',           'lab',       'Depan pintu Lab Rekayasa Perangkat Lunak 1',     30.0, 35.0),
  ('lab_pplg_2',         2, 'Lab Komputer PPLG 2',           'lab',       'Depan pintu Lab Rekayasa Perangkat Lunak 2',     45.0, 35.0),
  ('lab_tjkt',           2, 'Lab Jaringan Komputer TJKT',    'lab',       'Area depan rak server Lab Jaringan',             60.0, 35.0),
  ('library_smkn8',      2, 'Perpustakaan Sekolah',          'lounge',    'Area baca depan loker perpustakaan',             75.0, 45.0),
  ('corridor_fl2',       2, 'Koridor Tengah Lantai 2',       'corridor',  'Dekat tangga utama lantai 2',                    50.0, 50.0),
  -- Lantai 3
  ('studio_dkv',         3, 'Studio Desain Komunikasi Visual','lab',      'Depan pintu Lab DKV Multimedia',                 35.0, 30.0),
  ('corridor_fl3',       3, 'Koridor Kelas XII Lantai 3',    'corridor',  'Depan lorong kelas XII PPLG / AKL',              55.0, 30.0)
on conflict (id) do nothing;


-- ========================================================
-- 👥 SOCIAL FEATURES: USER FOLLOWS & POST REPOSTS
-- ========================================================

-- 18. TABEL USER FOLLOWS (Sistem Ikuti / Following Antar Siswa)
create table if not exists public.user_follows (
  follower_id uuid not null references public.profiles(id) on delete cascade,
  following_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (follower_id, following_id),
  constraint check_not_self_follow check (follower_id != following_id)
);


-- 19. TABEL POST REPOSTS (Repost / Bagikan Ulang Postingan)
create table if not exists public.post_reposts (
  post_id uuid not null references public.market_posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (post_id, user_id)
);


-- ========================================================
-- 🛡️ RLS POLICIES: USER FOLLOWS & POST REPOSTS
-- ========================================================
alter table public.user_follows enable row level security;
alter table public.post_reposts enable row level security;

-- User Follows: Publik bisa melihat daftar follow, user login bisa toggle follow
drop policy if exists "Follows viewable by everyone" on public.user_follows;
drop policy if exists "Users can follow others" on public.user_follows;
drop policy if exists "Users can unfollow others" on public.user_follows;
create policy "Follows viewable by everyone" on public.user_follows for select using (true);
create policy "Users can follow others" on public.user_follows for insert with check (auth.uid() = follower_id);
create policy "Users can unfollow others" on public.user_follows for delete using (auth.uid() = follower_id);

-- Post Reposts: Publik bisa melihat repost, user login bisa toggle repost
drop policy if exists "Reposts viewable by everyone" on public.post_reposts;
drop policy if exists "Users can repost" on public.post_reposts;
drop policy if exists "Users can remove repost" on public.post_reposts;
create policy "Reposts viewable by everyone" on public.post_reposts for select using (true);
create policy "Users can repost" on public.post_reposts for insert with check (auth.uid() = user_id);
create policy "Users can remove repost" on public.post_reposts for delete using (auth.uid() = user_id);


-- ========================================================
-- ⚡ INDEXING: SOCIAL FEATURES
-- ========================================================
create index if not exists idx_user_follows_follower on public.user_follows(follower_id);
create index if not exists idx_user_follows_following on public.user_follows(following_id);
create index if not exists idx_post_reposts_post on public.post_reposts(post_id);
create index if not exists idx_post_reposts_user on public.post_reposts(user_id);


-- ========================================================
-- 💬 DIRECT MESSAGING SYSTEM (Obrolan & Pembeli)
-- ========================================================

-- 20. TABEL CONVERSATIONS (Thread Percakapan Antar User)
-- product_id IS NULL  → Tab "Obrolan" (chat santai)
-- product_id IS UUID  → Tab "Pembeli" (inquiry produk jualan)
create table if not exists public.conversations (
  id uuid default gen_random_uuid() primary key,
  participant_one uuid not null references public.profiles(id) on delete cascade,
  participant_two uuid not null references public.profiles(id) on delete cascade,
  product_id uuid references public.market_posts(id) on delete set null,
  last_message text default '',
  last_message_at timestamp with time zone default timezone('utc'::text, now()) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  constraint check_not_self_chat check (participant_one != participant_two)
);


-- 21. TABEL DIRECT MESSAGES (Pesan Individual dalam Percakapan)
create table if not exists public.direct_messages (
  id uuid default gen_random_uuid() primary key,
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  message_text text not null,
  is_read boolean not null default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);


-- ========================================================
-- 🛡️ RLS POLICIES: DIRECT MESSAGES
-- ========================================================
alter table public.conversations enable row level security;
alter table public.direct_messages enable row level security;

-- Conversations: Hanya peserta yang berhak melihat & membuat percakapan
drop policy if exists "Users can view own conversations" on public.conversations;
drop policy if exists "Users can create conversations" on public.conversations;
drop policy if exists "Users can update own conversations" on public.conversations;
create policy "Users can view own conversations"
  on public.conversations for select to authenticated
  using (auth.uid() in (participant_one, participant_two));
create policy "Users can create conversations"
  on public.conversations for insert to authenticated
  with check (auth.uid() in (participant_one, participant_two));
create policy "Users can update own conversations"
  on public.conversations for update to authenticated
  using (auth.uid() in (participant_one, participant_two));

-- Direct Messages: Hanya peserta percakapan yang berhak membaca & mengirim
drop policy if exists "Users can view conversation messages" on public.direct_messages;
drop policy if exists "Users can send messages" on public.direct_messages;
drop policy if exists "Users can update own messages" on public.direct_messages;
drop policy if exists "Users can delete own messages" on public.direct_messages;
create policy "Users can view conversation messages"
  on public.direct_messages for select to authenticated
  using (
    exists (
      select 1 from public.conversations
      where id = direct_messages.conversation_id
        and auth.uid() in (participant_one, participant_two)
    )
  );
create policy "Users can send messages"
  on public.direct_messages for insert to authenticated
  with check (auth.uid() = sender_id);
create policy "Users can update own messages"
  on public.direct_messages for update to authenticated
  using (auth.uid() = sender_id);
create policy "Users can delete own messages"
  on public.direct_messages for delete to authenticated
  using (auth.uid() = sender_id);


-- ========================================================
-- ⚡ INDEXING: DIRECT MESSAGES
-- ========================================================
create index if not exists idx_conversations_participant_one on public.conversations(participant_one);
create index if not exists idx_conversations_participant_two on public.conversations(participant_two);
create index if not exists idx_conversations_last_message_at on public.conversations(last_message_at desc);
create index if not exists idx_direct_messages_conversation on public.direct_messages(conversation_id);
create index if not exists idx_direct_messages_sender on public.direct_messages(sender_id);
create index if not exists idx_direct_messages_created_at on public.direct_messages(created_at asc);
create index if not exists idx_direct_messages_unread on public.direct_messages(conversation_id, is_read) where is_read = false;


-- ========================================================
-- 📡 REALTIME PUBLICATION (DM & Orders Push)
-- ========================================================
-- Safe Idempotent Execution: Abaikan jika tabel sudah terdaftar di publication
do $$ begin alter publication supabase_realtime add table public.orders; exception when duplicate_object or others then null; end $$;
do $$ begin alter publication supabase_realtime add table public.order_notifications; exception when duplicate_object or others then null; end $$;
do $$ begin alter publication supabase_realtime add table public.conversations; exception when duplicate_object or others then null; end $$;
do $$ begin alter publication supabase_realtime add table public.direct_messages; exception when duplicate_object or others then null; end $$;
do $$ begin alter publication supabase_realtime add table public.market_posts; exception when duplicate_object or others then null; end $$;



-- ========================================================
-- 🔍 FULL-TEXT SEARCH: GIN INDEXES (Epic 8 — SearchPage)
-- ========================================================
-- GIN indexes mempercepat pencarian ILIKE & to_tsvector pada teks panjang.
-- Jalankan setelah tabel market_posts & profiles sudah ada.
create extension if not exists pg_trgm;

create index if not exists idx_market_posts_caption_trgm
  on public.market_posts using gin (caption gin_trgm_ops);
create index if not exists idx_market_posts_title_trgm
  on public.market_posts using gin (title gin_trgm_ops);
create index if not exists idx_profiles_username_trgm
  on public.profiles using gin (username gin_trgm_ops);
create index if not exists idx_profiles_fullname_trgm
  on public.profiles using gin (full_name gin_trgm_ops);


-- ========================================================
-- 📦 SUPABASE STORAGE BUCKETS & RLS POLICIES
-- ========================================================
-- Otomatis membuat 3 bucket (Public): market-media, avatars, voice-notes
insert into storage.buckets (id, name, public)
values
  ('market-media', 'market-media', true),
  ('avatars', 'avatars', true),
  ('voice-notes', 'voice-notes', true)
on conflict (id) do update set public = true;

-- Policy Select (Public Access)
drop policy if exists "Public Access market-media" on storage.objects;
create policy "Public Access market-media" on storage.objects for select using (bucket_id = 'market-media');

drop policy if exists "Public Access avatars" on storage.objects;
create policy "Public Access avatars" on storage.objects for select using (bucket_id = 'avatars');

drop policy if exists "Public Access voice-notes" on storage.objects;
create policy "Public Access voice-notes" on storage.objects for select using (bucket_id = 'voice-notes');

-- Policy Insert/Upload (Authenticated Users)
drop policy if exists "Authenticated Upload market-media" on storage.objects;
create policy "Authenticated Upload market-media" on storage.objects for insert to authenticated with check (bucket_id = 'market-media');

drop policy if exists "Authenticated Update market-media" on storage.objects;
create policy "Authenticated Update market-media" on storage.objects for update to authenticated using (bucket_id = 'market-media');

drop policy if exists "Authenticated Delete market-media" on storage.objects;
create policy "Authenticated Delete market-media" on storage.objects for delete to authenticated using (bucket_id = 'market-media');

drop policy if exists "Authenticated Upload avatars" on storage.objects;
create policy "Authenticated Upload avatars" on storage.objects for insert to authenticated with check (bucket_id = 'avatars');

drop policy if exists "Authenticated Update avatars" on storage.objects;
create policy "Authenticated Update avatars" on storage.objects for update to authenticated using (bucket_id = 'avatars');

drop policy if exists "Authenticated Upload voice-notes" on storage.objects;
create policy "Authenticated Upload voice-notes" on storage.objects for insert to authenticated with check (bucket_id = 'voice-notes');


