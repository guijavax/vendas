package br.com.entity

import br.com.entity.enums.ShipmentStatus
import jakarta.persistence.*
import java.time.OffsetDateTime

@Entity
@Table(name = "shipments")
data class ShipmentEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "shipment_id")
    var id: Long? = null,

    @Column(name = "order_id", nullable = false)
    var orderId: Long,

    @Column(name = "carrier")
    var carrier: String? = null,

    @Column(name = "tracking_no", unique = true)
    var trackingNo: String? = null,

    @Column(name = "shipped_at")
    var shippedAt: OffsetDateTime? = null,

    @Column(name = "delivered_at")
    var deliveredAt: OffsetDateTime? = null,

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    var status: ShipmentStatus = ShipmentStatus.PENDING
)
