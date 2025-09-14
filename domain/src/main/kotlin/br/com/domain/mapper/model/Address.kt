package br.com.domain.mapper.model

import br.com.domain.mapper.model.enums.AddressType

import java.time.OffsetDateTime

data class Address(
    val id: Long?,
    val customerId: Long,
    val kind: AddressType,
    val line1: String,
    val line2: String? = null,
    val city: String,
    val state: String,
    val postalCode: String,
    val country: String = "BR",
    val isDefault: Boolean = false,
    val createdAt: OffsetDateTime = OffsetDateTime.now()
)
