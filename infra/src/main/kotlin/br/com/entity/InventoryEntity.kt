package br.com.entity

import jakarta.persistence.*


@Entity
@Table(name = "inventory")
data class InventoryEntity(
    @Id
    @Column(name = "product_id")
    var productId: Long? = null,

    @OneToOne(optional = false, fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "product_id", nullable = false)
    var product: ProductEntity,

    @Column(name = "qty_on_hand", nullable = false)
    var qtyOnHand: Int,

    @Column(name = "reorder_level", nullable = false)
    var reorderLevel: Int = 5,

    @Column(name = "warehouse_location")
    var warehouseLocation: String? = null
)