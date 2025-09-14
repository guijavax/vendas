package br.com.entity

import br.com.entity.enums.OrderStatus
import jakarta.persistence.*
import java.math.BigDecimal
import java.time.OffsetDateTime

@Entity
@Table(name = "orders")
data class OrderEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "order_id")
    var id: Long? = null,

    @Column(name = "customer_id", nullable = false)
    var customerId: Long,

    @Column(name = "billing_address_id")
    var billingAddressId: Long? = null,

    @Column(name = "shipping_address_id")
    var shippingAddressId: Long? = null,

    @Column(name = "order_date", nullable = false)
    var orderDate: OffsetDateTime = OffsetDateTime.now(),

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    var status: OrderStatus = OrderStatus.DRAFT,

    @Column(name = "notes")
    var notes: String? = null,

    @Column(name = "created_at", nullable = false)
    var createdAt: OffsetDateTime = OffsetDateTime.now(),

    @Column(name = "updated_at", nullable = false)
    var updatedAt: OffsetDateTime = OffsetDateTime.now()
)

@Embeddable
data class OrderItemId(
    @Column(name = "order_id") var orderId: Long? = null,
    @Column(name = "item_no") var itemNo: Int? = null
)

@Entity
@Table(name = "order_items")
data class OrderItemEntity(
    @EmbeddedId
    var id: OrderItemId = OrderItemId(),

    @Column(name = "product_id", nullable = false)
    var productId: Long,

    @Column(name = "quantity", nullable = false)
    var quantity: Int,

    @Column(name = "unit_price", nullable = false, precision = 12, scale = 2)
    var unitPrice: BigDecimal,

    @Column(name = "discount_value", nullable = false, precision = 12, scale = 2)
    var discountValue: BigDecimal = BigDecimal.ZERO
)
