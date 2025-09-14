package br.com.entity

import br.com.entity.enums.AddressTypeEntity
import jakarta.persistence.*
import java.time.OffsetDateTime

@Entity
@Table(name = "addresses")
data class AddressEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "address_id")
    open var id: Long? = null,

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "customer_id", nullable = false)
    open var customer: CustomerEntity,

    @Enumerated(EnumType.STRING)
    @Column(name = "kind", nullable = false)
    open var kind: AddressTypeEntity,

    @Column(name = "line1", nullable = false)
    open var line1: String,

    @Column(name = "line2")
    open var line2: String? = null,

    @Column(name = "city", nullable = false)
    open var city: String,

    @Column(name = "state", nullable = false)
    open var state: String,

    @Column(name = "postal_code", nullable = false)
    open var postalCode: String,

    @Column(name = "country", nullable = false)
    open var country: String = "BR",

    @Column(name = "is_default", nullable = false)
    open var isDefault: Boolean = false,

    @Column(name = "created_at", nullable = false)
    open var createdAt: OffsetDateTime = OffsetDateTime.now()
)
