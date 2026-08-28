package com.snapan.market.data.model

import kotlinx.serialization.Serializable

@Serializable
data class SellerProfile(
    val id: String,
    val name: String,
    val avatar: String = "",
    val classGroup: String = "XII PPLG 1",
    val isVerified: Boolean = false,
    val username: String = "user"
)

@Serializable
data class PostCommentUser(
    val id: String,
    val name: String,
    val avatar: String = "",
    val username: String = "user",
    val classGroup: String = "",
    val isVerified: Boolean = false,
    val isAuthor: Boolean = false
)

@Serializable
data class PostComment(
    val id: String,
    val postId: String,
    val user: PostCommentUser,
    val content: String,
    val timestamp: String,
    val likesCount: Int = 0,
    val isLiked: Boolean = false,
    val replies: List<PostComment> = emptyList(),
    val threadPart: Int? = null,
    val totalParts: Int? = null,
    val images: List<String> = emptyList()
)

@Serializable
data class ThreadChainItem(
    val id: String,
    val partNumber: Int,
    val totalParts: Int,
    val caption: String,
    val images: List<String> = emptyList(),
    val timestamp: String? = null,
    val likesCount: Int = 0,
    val commentsCount: Int = 0,
    val isLiked: Boolean = false
)

@Serializable
data class MarketPostItem(
    val id: String,
    val postType: String = "thread", // "thread" or "product"
    val title: String? = null,
    val description: String? = null,
    val seller: SellerProfile,
    val caption: String,
    val price: Double? = null,
    val originalPrice: Double? = null,
    val category: String? = null,
    val images: List<String> = emptyList(),
    val stock: Int? = null,
    val locationTag: String? = null,
    val topicTag: String? = null,
    val isOfficialTopic: Boolean = false,
    val topicIcon: String? = null,
    val likesCount: Int = 0,
    val commentsCount: Int = 0,
    val repostsCount: Int = 0,
    val timestamp: String = "Baru saja",
    val isLiked: Boolean = false,
    val isReposted: Boolean = false,
    val isSaved: Boolean = false,
    val comments: List<PostComment> = emptyList(),
    val threadChain: List<ThreadChainItem> = emptyList(),
    val totalThreadParts: Int? = null
)
