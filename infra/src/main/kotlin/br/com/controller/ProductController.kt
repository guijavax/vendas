package br.com.controller

import br.com.domain.mapper.model.Product
import br.com.domain.usecase.GetProductUseCase
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController


@RestController
@RequestMapping("/product")
class ProductController(private val get : GetProductUseCase) {

    @GetMapping("/{id}")
    fun getById(@PathVariable id : String) : ResponseEntity<Product> {
        val product = get.findById(id.toLong()) ?: return ResponseEntity.notFound().build()
        return ResponseEntity.ok(product)
    }
}