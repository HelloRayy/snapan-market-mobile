class OnboardingSlide {
  final int id;
  final String title;
  final String description;
  final String assetPath;
  final bool isSvg;

  const OnboardingSlide({
    required this.id,
    required this.title,
    required this.description,
    required this.assetPath,
    this.isSvg = false,
  });
}

final List<OnboardingSlide> onboardingSlides = [
  const OnboardingSlide(
    id: 0,
    title: 'Pusat Jual Beli Warga SMKN 8 Jakarta',
    description:
        'Mulai dari barang preloved, jajanan lezat kantin, hingga karya buatanmu — tawarkan semua produkmu langsung ke teman & guru di SMKN 8 Jakarta.',
    assetPath: 'assets/onboarding/market-1.png',
  ),
  const OnboardingSlide(
    id: 1,
    title: 'Jual & Kelola Produkmu dengan Mudah',
    description:
        'Unggah foto produk, atur harga, dan terima pesanan langsung dari teman & guru di SMKN 8 Jakarta hanya dalam beberapa langkah.',
    assetPath: 'assets/onboarding/market-2.png',
  ),
  const OnboardingSlide(
    id: 2,
    title: 'Transaksi & COD Praktis di Sekolah',
    description:
        'Ketemuan langsung di sekolah, bayar saat terima barang (COD), atau pesan kantin untuk diambil tanpa perlu antre.',
    assetPath: 'assets/onboarding/market-3.png',
  ),
  const OnboardingSlide(
    id: 3,
    title: 'Siap Menjelajahi Snapan Market!',
    description:
        'Mulai jelajahi dan nikmati pengalaman jual beli online antar warga SMKN 8 yang aman dan praktis.',
    assetPath: 'assets/onboarding/person-login.png',
  ),
];
