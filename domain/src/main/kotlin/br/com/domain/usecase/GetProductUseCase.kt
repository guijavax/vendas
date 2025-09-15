package br.com.domain.usecase

import br.com.domain.mapper.model.Product

interface GetProductUseCase {

    fun findById(id : Long) : Product?
}