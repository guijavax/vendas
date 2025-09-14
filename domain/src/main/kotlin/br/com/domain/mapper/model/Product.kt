package br.com.domain.mapper.model

import java.math.BigDecimal
import java.time.OffsetDateTime

data class Product(
    val id: Long?,
    val sku: String,
    val name: String,
    val categoryId: Long?,
    val supplierId: Long?,
    val price: BigDecimal,
    val cost: BigDecimal,
    val active: Boolean = true,
    val createdAt: OffsetDateTime = OffsetDateTime.now()
)
