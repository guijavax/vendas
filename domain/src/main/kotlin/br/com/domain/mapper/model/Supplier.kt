package br.com.domain.mapper.model

import java.time.OffsetDateTime

data class Supplier(
    val id: Long?,
    val name: String,
    val taxId: String? = null,
    val email: String? = null,
    val phone: String? = null,
    val createdAt: OffsetDateTime = OffsetDateTime.now()
)
