package br.com.entity


import jakarta.persistence.*
import java.time.OffsetDateTime

@Entity
@Table(
    name = "customers",
    uniqueConstraints = [
        UniqueConstraint(name = "uk_customers_email", columnNames = ["email"]),
        UniqueConstraint(name = "uk_customers_tax_id", columnNames = ["tax_id"])
    ],
    indexes = [Index(name = "idx_customers_created_at", columnList = "created_at")]
)
data class CustomerEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "customer_id")
    open var id: Long? = null,

    @Column(name = "full_name", nullable = false)
    open var fullName: String,

    // citext -> String; manter tipo na coluna
    @Column(name = "email", nullable = false, unique = true, columnDefinition = "citext")
    open var email: String,

    @Column(name = "phone")
    open var phone: String? = null,

    @Column(name = "tax_id", unique = true)
    open var taxId: String? = null,

    @Column(name = "created_at", nullable = false)
    open var createdAt: OffsetDateTime = OffsetDateTime.now(),

    @Column(name = "updated_at", nullable = false)
    open var updatedAt: OffsetDateTime = OffsetDateTime.now()
) {
    @OneToMany(mappedBy = "customer", cascade = [CascadeType.ALL], orphanRemoval = true)
    open var addressEntities: MutableList<AddressEntity> = mutableListOf()
}
