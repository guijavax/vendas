package br.com.domain.mapper.model

import java.time.OffsetDateTime

data class Customer(
    val id: Long?,
    val fullName: String,
    val email: String,
    val phone: String? = null,
    val taxId: String? = null,
    val createdAt: OffsetDateTime = OffsetDateTime.now(),
    val updatedAt: OffsetDateTime = OffsetDateTime.now()
)
