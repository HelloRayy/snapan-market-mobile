package com.snapan.market.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.snapan.market.ui.components.ButtonSize
import com.snapan.market.ui.components.ButtonVariant
import com.snapan.market.ui.components.SnapanButton
import com.snapan.market.ui.theme.BrandPastel
import com.snapan.market.ui.theme.BrandPrimary
import com.snapan.market.ui.theme.InkBlack
import com.snapan.market.ui.theme.MutedGray
import com.snapan.market.ui.theme.PureWhite

@Composable
fun HelloScreen(
    onResetOnboarding: (() -> Unit)? = null
) {
    var clickCount by remember { mutableStateOf(0) }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(PureWhite),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.padding(24.dp)
        ) {
            // Logo Badge Bulat
            Box(
                modifier = Modifier
                    .size(72.dp)
                    .clip(CircleShape)
                    .background(BrandPastel),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "8",
                    color = BrandPrimary,
                    fontSize = 32.sp,
                    fontWeight = FontWeight.Black
                )
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Teks Hello World Utama
            Text(
                text = "Hello World!",
                fontSize = 28.sp,
                fontWeight = FontWeight.Bold,
                color = InkBlack,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Subtitle
            Text(
                text = "Snapan Market Mobile (Kotlin + Jetpack Compose)",
                fontSize = 14.sp,
                color = MutedGray,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(32.dp))

            // Tombol Interaktif
            SnapanButton(
                text = if (clickCount == 0) "Klik Saya! 🚀" else "Diklik $clickCount Kali ✨",
                onClick = {
                    clickCount++
                },
                variant = ButtonVariant.Primary,
                size = ButtonSize.Large
            )

            Spacer(modifier = Modifier.height(16.dp))

            AnimatedVisibility(
                visible = clickCount > 0,
                enter = fadeIn() + scaleIn(),
                exit = fadeOut() + scaleOut()
            ) {
                Text(
                    text = "Tombol berhasil merespon event klik!",
                    color = BrandPrimary,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold
                )
            }

            if (onResetOnboarding != null) {
                Spacer(modifier = Modifier.height(36.dp))

                SnapanButton(
                    text = "← Kembali ke Onboarding",
                    onClick = onResetOnboarding,
                    variant = ButtonVariant.Secondary,
                    size = ButtonSize.Medium
                )
            }
        }
    }
}
