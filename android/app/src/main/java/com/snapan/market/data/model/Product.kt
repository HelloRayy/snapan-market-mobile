package com.snapan.market.data.model

import kotlinx.serialization.Serializable

@Serializable
data class Product(
    val id: String,
    val name: String,
    val slug: String = "",
    val description: String = "",
    val price: Double,
    val originalPrice: Double? = null,
    val stock: Int = 1,
    val rating: Double = 5.0,
    val soldCount: Int = 0,
    val category: String = "Lainnya",
    val images: List<String> = emptyList(),
    val sellerId: String,
    val sellerName: String,
    val isVerifiedSeller: Boolean = false,
    val createdAt: String = ""
)

@Serializable
data class ProductFilter(
    val category: String? = null,
    val minPrice: Double? = null,
    val maxPrice: Double? = null,
    val searchQuery: String? = null,
    val sortBy: String = "latest" // "popular", "latest", "price_low", "price_high"
)
