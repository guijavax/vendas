package br.com.entity

import br.com.entity.enums.PaymentMethodEntity
import br.com.entity.enums.PaymentStatusEntity
import jakarta.persistence.*
import java.math.BigDecimal
import java.time.OffsetDateTime

@Entity
@Table(name = "payments")
data class PaymentEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "payment_id")
    var id: Long? = null,

    @Column(name = "order_id", nullable = false)
    var orderId: Long,

    @Enumerated(EnumType.STRING)
    @Column(name = "method", nullable = false)
    var method: PaymentMethodEntity,

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    var status: PaymentStatusEntity = PaymentStatusEntity.PENDING,

    @Column(name = "amount", nullable = false, precision = 12, scale = 2)
    var amount: BigDecimal,

    @Column(name = "paid_at")
    var paidAt: OffsetDateTime? = null,

    @Column(name = "transaction_ref", unique = true)
    var transactionRef: String? = null
)
