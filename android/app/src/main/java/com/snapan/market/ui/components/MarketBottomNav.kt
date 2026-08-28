package com.snapan.market.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ChatBubbleOutline
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.outlined.ChatBubbleOutline
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material3.Divider
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.snapan.market.ui.theme.BrandPrimary
import com.snapan.market.ui.theme.FaintBorder
import com.snapan.market.ui.theme.InkBlack
import com.snapan.market.ui.theme.MutedGray
import com.snapan.market.ui.theme.PureWhite

enum class NavTab {
    Home,
    Search,
    Create,
    Messages,
    Profile
}

@Composable
fun MarketBottomNav(
    currentTab: NavTab,
    onTabSelected: (NavTab) -> Unit,
    onCreatePostClick: () -> Unit,
    modifier: Modifier = Modifier,
    unreadMessagesCount: Int = 0
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(PureWhite)
    ) {
        Divider(color = FaintBorder, thickness = 1.dp)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(60.dp)
                .padding(horizontal = 8.dp),
            horizontalArrangement = Arrangement.SpaceAround,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Home Tab
            NavTabItem(
                label = "Utas",
                selectedIcon = Icons.Filled.Home,
                unselectedIcon = Icons.Outlined.Home,
                isSelected = currentTab == NavTab.Home,
                onClick = { onTabSelected(NavTab.Home) }
            )

            // Search Tab
            NavTabItem(
                label = "Cari",
                selectedIcon = Icons.Filled.Search,
                unselectedIcon = Icons.Outlined.Search,
                isSelected = currentTab == NavTab.Search,
                onClick = { onTabSelected(NavTab.Search) }
            )

            // Center Create Button
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .offset(y = (-4).dp)
                    .shadow(elevation = 4.dp, shape = CircleShape, spotColor = BrandPrimary)
                    .clip(CircleShape)
                    .background(BrandPrimary)
                    .clickable(onClick = onCreatePostClick),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Add,
                    contentDescription = "Buat Utas / Jual",
                    tint = PureWhite,
                    modifier = Modifier.size(24.dp)
                )
            }

            // Messages Tab
            NavTabItem(
                label = "Pesan",
                selectedIcon = Icons.Filled.ChatBubbleOutline,
                unselectedIcon = Icons.Outlined.ChatBubbleOutline,
                isSelected = currentTab == NavTab.Messages,
                badgeCount = unreadMessagesCount,
                onClick = { onTabSelected(NavTab.Messages) }
            )

            // Profile Tab
            NavTabItem(
                label = "Profil",
                selectedIcon = Icons.Filled.Person,
                unselectedIcon = Icons.Outlined.Person,
                isSelected = currentTab == NavTab.Profile,
                onClick = { onTabSelected(NavTab.Profile) }
            )
        }
    }
}

@Composable
private fun NavTabItem(
    label: String,
    selectedIcon: ImageVector,
    unselectedIcon: ImageVector,
    isSelected: Boolean,
    onClick: () -> Unit,
    badgeCount: Int = 0
) {
    val interactionSource = remember { MutableInteractionSource() }
    val color = if (isSelected) InkBlack else MutedGray

    Column(
        modifier = Modifier
            .clickable(
                interactionSource = interactionSource,
                indication = null,
                onClick = onClick
            )
            .padding(horizontal = 12.dp, vertical = 6.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Box(contentAlignment = Alignment.TopEnd) {
            Icon(
                imageVector = if (isSelected) selectedIcon else unselectedIcon,
                contentDescription = label,
                tint = color,
                modifier = Modifier.size(22.dp)
            )
            if (badgeCount > 0) {
                Box(
                    modifier = Modifier
                        .size(8.dp)
                        .offset(x = 2.dp, y = (-2).dp)
                        .clip(CircleShape)
                        .background(BrandPrimary)
                )
            }
        }
        Text(
            text = label,
            color = color,
            fontSize = 11.sp,
            fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal
        )
    }
}
