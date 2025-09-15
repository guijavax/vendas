package br.com.repository

import br.com.entity.*
import org.springframework.data.jpa.repository.JpaRepository

interface RepositoriesJpa {

    interface OrderJpaRepository : JpaRepository<OrderEntity, Long>
    interface OrderItemJpaRepository : JpaRepository<OrderItemEntity, OrderItemIdEntity>
    interface CustomerJpaRepository : JpaRepository<CustomerEntity, Long>
}