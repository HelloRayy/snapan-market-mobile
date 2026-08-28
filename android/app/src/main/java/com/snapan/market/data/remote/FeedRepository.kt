package com.snapan.market.data.remote

import com.snapan.market.data.model.MarketPostItem
import com.snapan.market.data.model.PostComment
import com.snapan.market.data.model.PostCommentUser
import com.snapan.market.data.model.SellerProfile
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

class FeedRepository {
    private val mockPosts = mutableListOf(
        MarketPostItem(
            id = "post-1",
            postType = "product",
            title = "Buku Paket Pemrograman Web & Perangkat Bergerak",
            description = "Buku paket original kurikulum merdeka kelas XII PPLG. Masih mulus 95% tanpa coretan.",
            seller = SellerProfile(
                id = "seller-1",
                name = "Ahmad Fajar",
                avatar = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150",
                classGroup = "XII PPLG 2",
                isVerified = true,
                username = "ahmadfjr"
            ),
            caption = "WTS Buku Paket Pemrograman Web & Mobile PPLG Kelas 12. Kondisi sangat terawat, siap pakai untuk ujian PJBL semester ini! Bisa COD di kelas XII PPLG 2 atau kantin pas jam istirahat. #PPLG #buku #smkn8",
            price = 45000.0,
            originalPrice = 75000.0,
            category = "Jasa DKV/PPLG",
            images = listOf(
                "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600",
                "https://images.unsplash.com/photo-1512820790803-83ca734da794?w=600"
            ),
            stock = 2,
            locationTag = "Gedung PPLG Lantai 2",
            topicTag = "PPLG",
            isOfficialTopic = true,
            likesCount = 28,
            commentsCount = 7,
            repostsCount = 4,
            timestamp = "15m lalu",
            comments = listOf(
                PostComment(
                    id = "c-1",
                    postId = "post-1",
                    user = PostCommentUser(
                        id = "u-2",
                        name = "Siti Rahma",
                        avatar = "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150",
                        username = "sitirahma",
                        classGroup = "XI PPLG 1"
                    ),
                    content = "Bisa nego 40k ga bang? Nanti istirahat pertama aku samperin ke kelas.",
                    timestamp = "10m lalu",
                    likesCount = 2
                )
            )
        ),
        MarketPostItem(
            id = "post-2",
            postType = "thread",
            seller = SellerProfile(
                id = "seller-2",
                name = "Rizky DKV",
                avatar = "https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150",
                classGroup = "XII DKV 1",
                isVerified = true,
                username = "rizkydkv"
            ),
            caption = "Halo guys! Buat yang butuh desain banner expo sekolah atau merchandise gantungan kunci akrilik buat stand jurusan, open order yaa sampai jumat! DM untuk info harga khusus siswa snapan ✨ #DKV #expo #desain",
            images = listOf(
                "https://images.unsplash.com/photo-1626785774573-4b799315345d?w=600"
            ),
            topicTag = "DKV",
            isOfficialTopic = true,
            likesCount = 45,
            commentsCount = 12,
            repostsCount = 9,
            timestamp = "1j lalu"
        )
    )

    private val _feedState = MutableStateFlow<List<MarketPostItem>>(mockPosts)
    val feedState: Flow<List<MarketPostItem>> = _feedState.asStateFlow()

    suspend fun getFeed(tab: String = "for-you"): List<MarketPostItem> {
        return when (tab) {
            "products" -> _feedState.value.filter { it.postType == "product" }
            "following" -> _feedState.value.take(1)
            else -> _feedState.value
        }
    }

    fun toggleLike(postId: String): MarketPostItem? {
        val currentList = _feedState.value.toMutableList()
        val index = currentList.indexOfFirst { it.id == postId }
        if (index != -1) {
            val item = currentList[index]
            val newIsLiked = !item.isLiked
            val newCount = if (newIsLiked) item.likesCount + 1 else (item.likesCount - 1).coerceAtLeast(0)
            val updated = item.copy(isLiked = newIsLiked, likesCount = newCount)
            currentList[index] = updated
            _feedState.value = currentList
            return updated
        }
        return null
    }

    fun toggleRepost(postId: String): MarketPostItem? {
        val currentList = _feedState.value.toMutableList()
        val index = currentList.indexOfFirst { it.id == postId }
        if (index != -1) {
            val item = currentList[index]
            val newIsReposted = !item.isReposted
            val newCount = if (newIsReposted) item.repostsCount + 1 else (item.repostsCount - 1).coerceAtLeast(0)
            val updated = item.copy(isReposted = newIsReposted, repostsCount = newCount)
            currentList[index] = updated
            _feedState.value = currentList
            return updated
        }
        return null
    }

    fun toggleBookmark(postId: String): Boolean {
        val currentList = _feedState.value.toMutableList()
        val index = currentList.indexOfFirst { it.id == postId }
        if (index != -1) {
            val item = currentList[index]
            val newSaved = !item.isSaved
            currentList[index] = item.copy(isSaved = newSaved)
            _feedState.value = currentList
            return newSaved
        }
        return false
    }

    fun addPost(newPost: MarketPostItem) {
        val current = _feedState.value.toMutableList()
        current.add(0, newPost)
        _feedState.value = current
    }

    fun addComment(postId: String, comment: PostComment) {
        val currentList = _feedState.value.toMutableList()
        val index = currentList.indexOfFirst { it.id == postId }
        if (index != -1) {
            val item = currentList[index]
            val updatedComments = item.comments + comment
            currentList[index] = item.copy(
                comments = updatedComments,
                commentsCount = item.commentsCount + 1
            )
            _feedState.value = currentList
        }
    }
}
