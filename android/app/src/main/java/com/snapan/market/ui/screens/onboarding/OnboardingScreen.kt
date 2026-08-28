package com.snapan.market.ui.screens.onboarding

import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.snapan.market.ui.components.ButtonSize
import com.snapan.market.ui.components.ButtonVariant
import com.snapan.market.ui.components.SnapanButton
import com.snapan.market.ui.theme.BrandPrimary
import com.snapan.market.ui.theme.FaintBorder
import com.snapan.market.ui.theme.InkBlack
import com.snapan.market.ui.theme.MutedGray
import com.snapan.market.ui.theme.PureWhite
import kotlinx.coroutines.launch

data class OnboardingSlideItem(
    val id: Int,
    val title: String,
    val description: String,
    val type: String // "content" or "auth"
)

private val onboardingSlides = listOf(
    OnboardingSlideItem(
        id = 0,
        title = "Pusat Jual Beli Warga SMKN 8 Semarang",
        description = "Mulai dari barang preloved, jajanan lezat kantin, hingga karya buatanmu — tawarkan semua produkmu langsung ke teman & guru di SMKN 8 Semarang.",
        type = "content"
    ),
    OnboardingSlideItem(
        id = 1,
        title = "Jual & Kelola Produkmu dengan Mudah",
        description = "Unggah foto produk, atur harga, dan terima pesanan langsung dari teman & guru di SMKN 8 Semarang hanya dalam beberapa langkah.",
        type = "content"
    ),
    OnboardingSlideItem(
        id = 2,
        title = "Transaksi & COD Praktis di Sekolah",
        description = "Ketemuan langsung di sekolah, bayar saat terima barang (COD), atau pesan kantin untuk diambil tanpa perlu antre.",
        type = "content"
    ),
    OnboardingSlideItem(
        id = 3,
        title = "Siap Menjelajahi Snapan Market!",
        description = "Mulai jelajahi dan nikmati pengalaman jual beli online antar warga SMKN 8 yang aman dan praktis.",
        type = "content"
    ),
    OnboardingSlideItem(
        id = 4,
        title = "Ayo Buat dan Atur Akun Kamu",
        description = "Masuk atau daftar untuk menikmati pengalaman belanja dan berjualan terbaik.",
        type = "auth"
    )
)

@Composable
fun OnboardingScreen(
    onComplete: () -> Unit,
    modifier: Modifier = Modifier
) {
    val pagerState = rememberPagerState(pageCount = { onboardingSlides.size })
    val coroutineScope = rememberCoroutineScope()
    val isAuthSlide = pagerState.currentPage == 4

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(PureWhite)
    ) {
        Column(
            modifier = Modifier.fillMaxSize()
        ) {
            // Pager Body with beyondViewportPageCount = 4 for 0-latency pre-rendering
            HorizontalPager(
                state = pagerState,
                userScrollEnabled = !isAuthSlide,
                beyondViewportPageCount = 4,
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
                    .graphicsLayer()
            ) { page ->
                when (page) {
                    0 -> SlideContent(
                        slide = onboardingSlides[0],
                        visual = { Slide1Visual() }
                    )
                    1 -> SlideContent(
                        slide = onboardingSlides[1],
                        visual = { Slide2Visual() }
                    )
                    2 -> SlideContent(
                        slide = onboardingSlides[2],
                        visual = { Slide3Visual() }
                    )
                    3 -> SlideContent(
                        slide = onboardingSlides[3],
                        visual = { Slide4Visual() }
                    )
                    4 -> AuthSlideVisual(
                        onBack = {
                            coroutineScope.launch {
                                pagerState.animateScrollToPage(
                                    page = 3,
                                    animationSpec = tween(durationMillis = 300, easing = FastOutSlowInEasing)
                                )
                            }
                        },
                        onSuccess = onComplete
                    )
                }
            }

            // Bottom Navigation Controls (Visible on slides 0 to 3)
            if (!isAuthSlide) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 24.dp, vertical = 20.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    // Dot Indicators (4 dots for content slides 0-3)
                    Row(
                        horizontalArrangement = Arrangement.Center,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        repeat(4) { index ->
                            val isSelected = pagerState.currentPage == index
                            val width by animateDpAsState(
                                targetValue = if (isSelected) 24.dp else 8.dp,
                                animationSpec = tween(durationMillis = 200, easing = FastOutSlowInEasing),
                                label = "dot_width"
                            )
                            Box(
                                modifier = Modifier
                                    .padding(horizontal = 3.5.dp)
                                    .height(8.dp)
                                    .width(width)
                                    .clip(RoundedCornerShape(percent = 50))
                                    .background(if (isSelected) BrandPrimary else FaintBorder)
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(24.dp))

                    if (pagerState.currentPage < 3) {
                        // Slides 0, 1, 2: Lewati (Left) + Lanjutkan (Right)
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(12.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            SnapanButton(
                                text = "Lewati",
                                onClick = {
                                    coroutineScope.launch {
                                        pagerState.animateScrollToPage(
                                            page = 4,
                                            animationSpec = tween(durationMillis = 300, easing = FastOutSlowInEasing)
                                        )
                                    }
                                },
                                variant = ButtonVariant.Secondary,
                                size = ButtonSize.Medium,
                                modifier = Modifier.weight(0.4f)
                            )

                            SnapanButton(
                                text = "Lanjutkan",
                                onClick = {
                                    coroutineScope.launch {
                                        pagerState.animateScrollToPage(
                                            page = pagerState.currentPage + 1,
                                            animationSpec = tween(durationMillis = 300, easing = FastOutSlowInEasing)
                                        )
                                    }
                                },
                                variant = ButtonVariant.Primary,
                                size = ButtonSize.Medium,
                                modifier = Modifier.weight(0.6f),
                                iconRight = {
                                    Icon(
                                        imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                                        contentDescription = null,
                                        tint = PureWhite,
                                        modifier = Modifier.size(16.dp)
                                    )
                                }
                            )
                        }
                    } else {
                        // Slide 3: Full Width "Mulai Sekarang"
                        SnapanButton(
                            text = "Mulai Sekarang",
                            onClick = {
                                coroutineScope.launch {
                                    pagerState.animateScrollToPage(
                                        page = 4,
                                        animationSpec = tween(durationMillis = 300, easing = FastOutSlowInEasing)
                                    )
                                }
                            },
                            variant = ButtonVariant.Primary,
                            size = ButtonSize.Large,
                            fullWidth = true,
                            iconRight = {
                                Icon(
                                    imageVector = Icons.Default.ChevronRight,
                                    contentDescription = null,
                                    tint = PureWhite,
                                    modifier = Modifier.size(20.dp)
                                )
                            }
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun SlideContent(
    slide: OnboardingSlideItem,
    visual: @Composable () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .graphicsLayer()
            .padding(horizontal = 24.dp),
        horizontalAlignment = Alignment.Start,
        verticalArrangement = Arrangement.Center
    ) {
        // Visual Illustration Box (Centered)
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 20.dp),
            contentAlignment = Alignment.Center
        ) {
            visual()
        }

        Spacer(modifier = Modifier.height(8.dp))

        // Title (Rata Kiri)
        Text(
            text = slide.title,
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            color = InkBlack,
            textAlign = TextAlign.Start,
            lineHeight = 28.sp,
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(modifier = Modifier.height(10.dp))

        // Description (Rata Kiri)
        Text(
            text = slide.description,
            fontSize = 14.sp,
            color = MutedGray,
            textAlign = TextAlign.Start,
            lineHeight = 21.sp,
            modifier = Modifier.fillMaxWidth()
        )
    }
}
