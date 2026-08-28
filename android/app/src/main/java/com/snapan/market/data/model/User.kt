package com.snapan.market.data.model

import kotlinx.serialization.Serializable

@Serializable
data class UserProfile(
    val id: String,
    val fullName: String,
    val username: String,
    val email: String? = null,
    val phone: String? = null,
    val avatarUrl: String = "",
    val classGroup: String = "XII PPLG 1",
    val nisn: String = "",
    val isVerifiedStudent: Boolean = false,
    val bio: String = "",
    val postsCount: Int = 0,
    val followersCount: Int = 0,
    val followingCount: Int = 0
)

@Serializable
data class MeetingPoint(
    val id: String,
    val name: String,
    val floor: String = "Lantai 1",
    val building: String = "Gedung Utama",
    val description: String = ""
)
