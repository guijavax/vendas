package br.com.domain.ports

import br.com.domain.mapper.model.Product

interface ProductRepository {

    fun findById(id : Long) : Product?

}