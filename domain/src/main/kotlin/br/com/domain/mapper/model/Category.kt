package br.com.domain.mapper.model

data class Category(
    val id: Long?,
    val name: String,
    val parentId: Long? = null
)
