package com.api.vendas.repository

import com.api.vendas.entity.ClienteEntity
import org.springframework.data.jpa.repository.JpaRepository

interface ClienteRepository : JpaRepository<ClienteEntity, Long> {}