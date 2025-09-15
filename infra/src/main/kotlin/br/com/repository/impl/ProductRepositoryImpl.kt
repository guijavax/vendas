package br.com.repository.impl

import br.com.domain.mapper.model.Product
import br.com.mapper.DomainMappers
import br.com.domain.ports.ProductRepository
import br.com.repository.ProductJpaRepository
import org.springframework.stereotype.Repository

@Repository
class ProductRepositoryImpl(private val repository: ProductJpaRepository) : ProductRepository {
    override fun findById(id: Long) : Product? {

        val entity = repository.findById(id).orElse(null)

        return if (entity != null)
            DomainMappers.toDomain(entity)
                else entity
    }
}