package br.com.domain.mapper.model

import br.com.domain.mapper.model.enums.PaymentMethod
import br.com.domain.mapper.model.enums.PaymentStatus

import java.math.BigDecimal
import java.time.OffsetDateTime

data class Payment(
    val id: Long?,
    val orderId: Long,
    val method: PaymentMethod,
    val status: PaymentStatus,
    val amount: BigDecimal,
    val paidAt: OffsetDateTime? = null,
    val transactionRef: String? = null
)
