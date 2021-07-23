package com.api.vendas.facade

import com.api.vendas.dto.ClienteDTO
import com.api.vendas.entity.ClienteEntity
import com.api.vendas.service.db.ClienteDbService
import com.api.vendas.service.kafka.ClienteKafkaService
import com.api.vendas.utils.ConverteClienteModel
import com.api.vendas.utils.GenericConvertModel
import org.springframework.stereotype.Component

@Component
class ClienteFacade(val service : ClienteDbService, val clienteKafka : ClienteKafkaService) {

    private var convertModel : GenericConvertModel? = ConverteClienteModel()

    fun salvaCliente(dto : ClienteDTO) : ClienteDTO? {
        clienteKafka.sendToKafka(dto)
        val entity = convertModel?.convertToEntity(dto) as ClienteEntity
        service.saveCliente(entity)
        return convertModel?.convertToDTO(entity) as ClienteDTO
    }

    fun buscaClientes() : List<ClienteDTO> {
        val clientes = service.buscaCliente()
        val clientesDTO = mutableListOf<ClienteDTO>()
        if(clientes.isNotEmpty()) {
            clientes.forEach{ cliente ->
                clientesDTO.add(convertModel?.convertToDTO(cliente) as ClienteDTO)
            }
            return clientesDTO
        }
        return listOf()
    }
}