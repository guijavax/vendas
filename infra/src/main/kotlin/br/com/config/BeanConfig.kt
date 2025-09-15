package br.com.config

import br.com.application.service.GetProductService
import br.com.domain.ports.ProductRepository
import br.com.domain.usecase.GetProductUseCase
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class BeanConfig {

    @Bean
    fun getProductUseCase(repo : ProductRepository) : GetProductUseCase = GetProductService(repo)
}