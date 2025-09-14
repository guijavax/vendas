package br.com.repository

import br.com.entity.*
import org.springframework.data.jpa.repository.JpaRepository

interface Repositories {
    interface ProductJpaRepository : JpaRepository<  ProductEntity, Long>
    interface OrderJpaRepository : JpaRepository<OrderEntity, Long>
    interface OrderItemJpaRepository : JpaRepository<OrderItemEntity, OrderItemId>
    interface CustomerJpaRepository : JpaRepository<CustomerEntity, Long>
}