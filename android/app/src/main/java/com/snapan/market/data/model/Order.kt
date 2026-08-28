package com.snapan.market.data.model

import kotlinx.serialization.Serializable

@Serializable
data class OrderItem(
    val id: String,
    val productId: String,
    val productName: String,
    val productImage: String,
    val price: Double,
    val quantity: Int
)

@Serializable
data class Order(
    val id: String,
    val userId: String,
    val sellerId: String = "",
    val status: String = "pending", // "pending", "processing", "completed", "cancelled"
    val totalAmount: Double,
    val items: List<OrderItem>,
    val meetingPoint: String = "Gedung PPLG Lantai 2",
    val note: String = "",
    val createdAt: String = ""
)
