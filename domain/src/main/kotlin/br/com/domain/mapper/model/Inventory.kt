package br.com.domain.mapper.model

data class Inventory(
    val productId: Long,
    val qtyOnHand: Int,
    val reorderLevel: Int = 5,
    val warehouseLocation: String? = null
)

