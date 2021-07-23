package com.api.vendas.service.db

import com.api.vendas.entity.ClienteEntity
import com.api.vendas.repository.ClienteRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service

@Service
class ClienteDbService {

    @Autowired
    private lateinit var repository: ClienteRepository

    fun saveCliente(entity : ClienteEntity) = repository.save(entity)

    fun buscaCliente() : List<ClienteEntity> {
        val clientes = repository.findAll()
        return if(clientes.isEmpty()) listOf() else clientes
    }
}