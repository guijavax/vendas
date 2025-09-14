package br.com.entity


import jakarta.persistence.*

@Entity
@Table(name = "categories")
data class CategoryEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "category_id")
    var id: Long? = null,

    @Column(name = "name", nullable = false, unique = true)
    var name: String,

    @Column(name = "parent_id")
    var parentId: Long? = null
)
