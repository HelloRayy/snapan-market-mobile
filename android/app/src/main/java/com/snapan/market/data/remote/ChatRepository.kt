package com.snapan.market.data.remote

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

data class ChatMessage(
    val id: String,
    val text: String,
    val timestamp: String,
    val isFromMe: Boolean
)

data class ConversationItem(
    val threadId: String,
    val partnerName: String,
    val partnerAvatar: String,
    val partnerUsername: String,
    val lastMessage: String,
    val lastTime: String,
    val unreadCount: Int = 0,
    val productTitle: String? = null,
    val productPrice: Double? = null,
    val productImage: String? = null
)

class ChatRepository {
    private val mockConversations = mutableListOf(
        ConversationItem(
            threadId = "conv-1",
            partnerName = "Ahmad Fajar",
            partnerAvatar = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150",
            partnerUsername = "ahmadfjr",
            lastMessage = "Siap kak, nanti ketemu di depan lab PPLG ya pas istirahat",
            lastTime = "10:30",
            unreadCount = 1,
            productTitle = "Buku Paket Pemrograman Web",
            productPrice = 45000.0,
            productImage = "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600"
        ),
        ConversationItem(
            threadId = "conv-2",
            partnerName = "Rizky DKV",
            partnerAvatar = "https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150",
            partnerUsername = "rizkydkv",
            lastMessage = "File desainnya udah gue kirim via email bro",
            lastTime = "Kemarin",
            unreadCount = 0
        )
    )

    private val messagesStore = mutableMapOf<String, MutableList<ChatMessage>>(
        "conv-1" to mutableListOf(
            ChatMessage("m1", "Halo kak, bukunya masih ada?", "10:15", isFromMe = true),
            ChatMessage("m2", "Masih kak! Mau COD kapan?", "10:20", isFromMe = false),
            ChatMessage("m3", "Pas istirahat pertama jam 09:45 bisa?", "10:25", isFromMe = true),
            ChatMessage("m4", "Siap kak, nanti ketemu di depan lab PPLG ya pas istirahat", "10:30", isFromMe = false)
        )
    )

    private val _conversations = MutableStateFlow<List<ConversationItem>>(mockConversations)
    val conversations: Flow<List<ConversationItem>> = _conversations.asStateFlow()

    fun getMessages(threadId: String): List<ChatMessage> {
        return messagesStore[threadId] ?: emptyList()
    }

    fun sendMessage(threadId: String, text: String): ChatMessage {
        val now = java.text.SimpleDateFormat("HH:mm", java.util.Locale.getDefault()).format(java.util.Date())
        val msg = ChatMessage(
            id = "msg-${System.currentTimeMillis()}",
            text = text,
            timestamp = now,
            isFromMe = true
        )
        val list = messagesStore.getOrPut(threadId) { mutableListOf() }
        list.add(msg)
        return msg
    }
}
