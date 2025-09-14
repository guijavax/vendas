package br.com.entity

import jakarta.persistence.*
import java.time.OffsetDateTime

@Entity
@Table(name = "suppliers")
data class SupplierEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "supplier_id")
    var id: Long? = null,

    @Column(name = "name", nullable = false)
    var name: String,

    @Column(name = "tax_id", unique = true)
    var taxId: String? = null,

    @Column(name = "email", columnDefinition = "citext")
    var email: String? = null,

    @Column(name = "phone")
    var phone: String? = null,

    @Column(name = "created_at", nullable = false)
    var createdAt: OffsetDateTime = OffsetDateTime.now()
)
