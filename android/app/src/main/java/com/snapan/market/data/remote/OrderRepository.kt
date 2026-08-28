package com.snapan.market.data.remote

import com.snapan.market.data.model.Order
import com.snapan.market.data.model.OrderItem
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

class OrderRepository {
    private val _orders = MutableStateFlow<List<Order>>(emptyList())
    val orders: Flow<List<Order>> = _orders.asStateFlow()

    suspend fun createCodOrder(
        userId: String,
        sellerId: String,
        item: OrderItem,
        meetingPoint: String,
        note: String
    ): Result<Order> {
        val newOrder = Order(
            id = "order-${System.currentTimeMillis()}",
            userId = userId,
            sellerId = sellerId,
            status = "pending",
            totalAmount = item.price * item.quantity,
            items = listOf(item),
            meetingPoint = meetingPoint,
            note = note,
            createdAt = "Baru saja"
        )
        val current = _orders.value.toMutableList()
        current.add(0, newOrder)
        _orders.value = current
        return Result.success(newOrder)
    }
}
