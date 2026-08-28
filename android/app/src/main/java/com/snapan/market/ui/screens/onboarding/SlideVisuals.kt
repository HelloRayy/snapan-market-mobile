package com.snapan.market.ui.screens.onboarding

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import coil3.compose.AsyncImage
import coil3.request.ImageRequest
import coil3.request.crossfade

@Composable
fun Slide1Visual(modifier: Modifier = Modifier) {
    val context = LocalContext.current
    Box(
        modifier = modifier
            .fillMaxWidth()
            .aspectRatio(4f / 5f)
            .graphicsLayer(),
        contentAlignment = Alignment.Center
    ) {
        AsyncImage(
            model = ImageRequest.Builder(context)
                .data("file:///android_asset/onboarding/market-1 1.webp")
                .crossfade(false)
                .memoryCacheKey("slide_1_img")
                .build(),
            contentDescription = "Pusat Jual Beli Warga SMKN 8 Semarang",
            contentScale = ContentScale.Fit,
            modifier = Modifier
                .fillMaxSize(0.85f)
                .graphicsLayer()
        )
    }
}

@Composable
fun Slide2Visual(modifier: Modifier = Modifier) {
    val context = LocalContext.current
    Box(
        modifier = modifier
            .fillMaxWidth()
            .aspectRatio(4f / 5f)
            .graphicsLayer(),
        contentAlignment = Alignment.Center
    ) {
        AsyncImage(
            model = ImageRequest.Builder(context)
                .data("file:///android_asset/onboarding/market-2 1.webp")
                .crossfade(false)
                .memoryCacheKey("slide_2_img")
                .build(),
            contentDescription = "Jual & Kelola Produkmu dengan Mudah",
            contentScale = ContentScale.Fit,
            modifier = Modifier
                .fillMaxSize(0.85f)
                .graphicsLayer()
        )
    }
}

@Composable
fun Slide3Visual(modifier: Modifier = Modifier) {
    val context = LocalContext.current
    Box(
        modifier = modifier
            .fillMaxWidth()
            .aspectRatio(4f / 5f)
            .graphicsLayer(),
        contentAlignment = Alignment.Center
    ) {
        AsyncImage(
            model = ImageRequest.Builder(context)
                .data("file:///android_asset/onboarding/market-3 1.webp")
                .crossfade(false)
                .memoryCacheKey("slide_3_img")
                .build(),
            contentDescription = "Transaksi & COD Praktis di Sekolah",
            contentScale = ContentScale.Fit,
            modifier = Modifier
                .fillMaxSize(0.85f)
                .graphicsLayer()
        )
    }
}

@Composable
fun Slide4Visual(modifier: Modifier = Modifier) {
    val context = LocalContext.current
    Box(
        modifier = modifier
            .fillMaxWidth()
            .aspectRatio(4f / 5f)
            .graphicsLayer(),
        contentAlignment = Alignment.Center
    ) {
        AsyncImage(
            model = ImageRequest.Builder(context)
                .data("file:///android_asset/onboarding/market-1 1.webp")
                .crossfade(false)
                .memoryCacheKey("slide_4_img")
                .build(),
            contentDescription = "Siap Menjelajahi Snapan Market!",
            contentScale = ContentScale.Fit,
            modifier = Modifier
                .fillMaxSize(0.85f)
                .graphicsLayer()
        )
    }
}
