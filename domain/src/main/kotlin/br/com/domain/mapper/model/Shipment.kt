package br.com.domain.mapper.model

import br.com.domain.mapper.model.enums.ShipmentStatus
import java.time.OffsetDateTime

data class Shipment(
    val id: Long?,
    val orderId: Long,
    val carrier: String?,
    val trackingNo: String?,
    val shippedAt: OffsetDateTime?,
    val deliveredAt: OffsetDateTime?,
    val status: ShipmentStatus
)
