package br.com.domain.mapper.model

import br.com.domain.mapper.model.enums.OrderStatus

import java.math.BigDecimal
import java.time.OffsetDateTime

data class OrderItem(
    val productId: Long,
    val itemNo: Int,
    val quantity: Int,
    val unitPrice: BigDecimal,
    val discountValue: BigDecimal = BigDecimal.ZERO
)

data class Order(
    val id: Long?,
    val customerId: Long,
    val billingAddressId: Long?,
    val shippingAddressId: Long?,
    val orderDate: OffsetDateTime = OffsetDateTime.now(),
    val status: OrderStatus = OrderStatus.DRAFT,
    val notes: String? = null,
    val items: List<OrderItem> = emptyList()
)
