package br.com.application.service

import br.com.domain.mapper.model.Product
import br.com.domain.ports.ProductRepository
import br.com.domain.usecase.GetProductUseCase

class GetProductService (private val repo : ProductRepository) : GetProductUseCase {
    override fun findById(id: Long): Product? = repo.findById(id)


}