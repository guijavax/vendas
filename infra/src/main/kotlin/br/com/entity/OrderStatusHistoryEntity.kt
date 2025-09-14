package br.com.entity

import br.com.entity.enums.OrderStatus
import jakarta.persistence.*
import java.time.OffsetDateTime

@Entity
@Table(name = "order_status_history")
data class OrderStatusHistoryEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "history_id")
    var id: Long? = null,

    @Column(name = "order_id", nullable = false)
    var orderId: Long,

    @Enumerated(EnumType.STRING)
    @Column(name = "old_status")
    var oldStatus: OrderStatus? = null,

    @Enumerated(EnumType.STRING)
    @Column(name = "new_status", nullable = false)
    var newStatus: OrderStatus,

    @Column(name = "changed_at", nullable = false)
    var changedAt: OffsetDateTime = OffsetDateTime.now()
)
