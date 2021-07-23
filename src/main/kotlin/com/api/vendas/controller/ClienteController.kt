package com.api.vendas.controller

import com.api.vendas.dto.ClienteDTO
import com.api.vendas.facade.ClienteFacade
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping(value = ["/cliente"])
class ClienteController(val facade : ClienteFacade) {

    @PostMapping
    fun saveCliente(@RequestBody clienteDTO: ClienteDTO) : ResponseEntity<Any> {
      val clienteResp = facade.salvaCliente(clienteDTO)
        return ResponseEntity.status(HttpStatus.CREATED).body(clienteResp)
    }

    @GetMapping(value = ["/clientes"])
    fun findClientes() : ResponseEntity<Any> {
        return ResponseEntity.ok(facade.buscaClientes())
    }
}