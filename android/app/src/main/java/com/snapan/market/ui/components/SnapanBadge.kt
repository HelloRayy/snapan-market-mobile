package com.snapan.market.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.snapan.market.ui.theme.BrandPastel
import com.snapan.market.ui.theme.BrandPrimary
import com.snapan.market.ui.theme.PriceAmberBg
import com.snapan.market.ui.theme.PriceAmberText
import com.snapan.market.ui.theme.PureWhite
import com.snapan.market.ui.theme.StockGreenBg
import com.snapan.market.ui.theme.StockGreenText

@Composable
fun VerifiedBadge(
    modifier: Modifier = Modifier,
    size: Int = 16
) {
    Box(
        modifier = modifier
            .size(size.dp)
            .clip(CircleShape)
            .background(BrandPrimary),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            imageVector = Icons.Default.Check,
            contentDescription = "Verified Student",
            tint = PureWhite,
            modifier = Modifier.size((size * 0.7).dp)
        )
    }
}

@Composable
fun PriceBadge(
    priceFormatted: String,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(6.dp))
            .background(PriceAmberBg)
            .padding(horizontal = 8.dp, vertical = 3.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = priceFormatted,
            color = PriceAmberText,
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold
        )
    }
}

@Composable
fun StockBadge(
    stockCount: Int,
    modifier: Modifier = Modifier
) {
    val isAvailable = stockCount > 0
    val bgColor = if (isAvailable) StockGreenBg else Color(0xFFFFE4E6)
    val textColor = if (isAvailable) StockGreenText else Color(0xFFE11D48)
    val label = if (isAvailable) "Sisa $stockCount" else "Habis"

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(6.dp))
            .background(bgColor)
            .padding(horizontal = 8.dp, vertical = 3.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = label,
            color = textColor,
            fontSize = 11.sp,
            fontWeight = FontWeight.SemiBold
        )
    }
}

@Composable
fun CategoryPill(
    label: String,
    modifier: Modifier = Modifier,
    isSelected: Boolean = false,
    onClick: (() -> Unit)? = null
) {
    val bgColor = if (isSelected) BrandPrimary else BrandPastel
    val textColor = if (isSelected) PureWhite else BrandPrimary

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(percent = 50))
            .background(bgColor)
            .padding(horizontal = 12.dp, vertical = 6.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = label,
            color = textColor,
            fontSize = 12.sp,
            fontWeight = FontWeight.SemiBold
        )
    }
}
