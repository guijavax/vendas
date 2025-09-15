package br.com.entity

import jakarta.persistence.*
import java.math.BigDecimal
import java.time.OffsetDateTime


@Entity
@Table(name = "products", schema = "sales")
data class ProductEntity(

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "product_id")
    var id: Long? = null,

    @Column(name = "sku", nullable = false, unique = true)
    var sku: String,

    @Column(name = "name", nullable = false)
    var name: String,

    @Column(name = "category_id")
    var categoryId: Long? = null,

    @Column(name = "supplier_id")
    var supplierId: Long? = null,

    @Column(name = "price", nullable = false, precision = 12, scale = 2)
    var price: BigDecimal,

    @Column(name = "cost", nullable = false, precision = 12, scale = 2)
    var cost: BigDecimal,

    @Column(name = "active", nullable = false)
    var active: Boolean = true,

    @Column(name = "created_at", nullable = false)
    var createdAt: OffsetDateTime = OffsetDateTime.now()
)
