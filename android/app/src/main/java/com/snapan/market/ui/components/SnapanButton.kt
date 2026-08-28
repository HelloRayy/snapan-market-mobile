package com.snapan.market.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.snapan.market.ui.theme.DangerRed
import com.snapan.market.ui.theme.DangerRedBorder
import com.snapan.market.ui.theme.InkBlack
import com.snapan.market.ui.theme.KumoBlue
import com.snapan.market.ui.theme.PureWhite
import com.snapan.market.ui.theme.SlateInk

enum class ButtonVariant {
    Primary,
    Secondary,
    Outline,
    Ghost,
    Danger
}

enum class ButtonSize(val height: Dp, val cornerRadius: Dp, val fontSize: Int) {
    Small(36.dp, 8.dp, 12),
    Medium(46.dp, 12.dp, 14),
    Large(52.dp, 26.dp, 15) // Full capsule default for large buttons
}

@Composable
fun SnapanButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    variant: ButtonVariant = ButtonVariant.Primary,
    size: ButtonSize = ButtonSize.Medium,
    customShape: Shape? = null,
    isLoading: Boolean = false,
    enabled: Boolean = true,
    iconLeft: @Composable (() -> Unit)? = null,
    iconRight: @Composable (() -> Unit)? = null,
    fullWidth: Boolean = false
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (isPressed && enabled && !isLoading) 0.97f else 1.0f,
        label = "button_scale"
    )

    val shape = customShape ?: RoundedCornerShape(size.cornerRadius)

    val baseModifier = modifier
        .then(if (fullWidth) Modifier.fillMaxWidth() else Modifier)
        .height(size.height)
        .scale(scale)
        .clip(shape)

    // Exact Cloudflare Kumo UI Primary styling: Inset Bevel Highlight + Gradient + Outer Border + Drop Shadow
    val styledModifier = when (variant) {
        ButtonVariant.Primary -> {
            baseModifier
                .shadow(elevation = 3.dp, shape = shape, spotColor = Color(0x331D64EC), ambientColor = Color(0x20154EC1))
                .background(
                    brush = Brush.verticalGradient(
                        colors = if (isPressed) listOf(Color(0xFF2563EB), Color(0xFF1D64EC))
                        else listOf(Color(0xFF3B82F6), Color(0xFF1D64EC))
                    )
                )
                .border(BorderStroke(1.dp, Color(0xFF154EC1)), shape)
                .drawWithContent {
                    drawContent()
                    // Inset Top 1px Highlight Shadow (rgba(255, 255, 255, 0.35))
                    drawRect(
                        brush = Brush.verticalGradient(
                            colors = listOf(Color(0x59FFFFFF), Color.Transparent),
                            startY = 0f,
                            endY = 3.dp.toPx()
                        ),
                        size = Size(this.size.width, 2.5.dp.toPx())
                    )
                }
        }
        ButtonVariant.Secondary -> {
            baseModifier
                .shadow(elevation = 1.dp, shape = shape, spotColor = Color(0x08000000))
                .background(PureWhite)
                .border(BorderStroke(1.dp, Color(0xFFE5E7EB)), shape)
        }
        ButtonVariant.Outline -> {
            baseModifier
                .background(PureWhite)
                .border(BorderStroke(1.5.dp, KumoBlue), shape)
        }
        ButtonVariant.Ghost -> {
            baseModifier.background(if (isPressed) Color(0xFFF3F4F6) else Color.Transparent)
        }
        ButtonVariant.Danger -> {
            baseModifier
                .background(DangerRed)
                .border(BorderStroke(1.dp, DangerRedBorder), shape)
        }
    }

    val contentColor = when (variant) {
        ButtonVariant.Primary, ButtonVariant.Danger -> PureWhite
        ButtonVariant.Secondary -> InkBlack
        ButtonVariant.Outline -> KumoBlue
        ButtonVariant.Ghost -> SlateInk
    }

    Box(
        modifier = styledModifier
            .clickable(
                interactionSource = interactionSource,
                indication = null,
                enabled = enabled && !isLoading,
                onClick = onClick
            )
            .padding(horizontal = 16.dp),
        contentAlignment = Alignment.Center
    ) {
        if (isLoading) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center
            ) {
                CircularProgressIndicator(
                    modifier = Modifier.size(16.dp),
                    color = contentColor,
                    strokeWidth = 2.dp
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Memproses...",
                    color = contentColor,
                    fontSize = size.fontSize.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        } else {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center
            ) {
                if (iconLeft != null) {
                    iconLeft()
                    Spacer(modifier = Modifier.width(8.dp))
                }
                Text(
                    text = text,
                    color = contentColor,
                    fontSize = size.fontSize.sp,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center
                )
                if (iconRight != null) {
                    Spacer(modifier = Modifier.width(8.dp))
                    iconRight()
                }
            }
        }
    }
}
