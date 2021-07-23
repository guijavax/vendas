package com.api.vendas.utils

import com.api.vendas.dto.ClienteDTO
import com.api.vendas.entity.ClienteEntity
import com.api.vendas.generic.GenericDTO
import com.api.vendas.generic.GenericEntity

/**
 *
 * @author Guilherme Alves
 */
sealed class GenericConvertModel {
    abstract fun convertToDTO(entity : GenericEntity?) : GenericDTO
    abstract fun convertToEntity(dto : GenericDTO?) : GenericEntity
}


class ConverteClienteModel  : GenericConvertModel() {


    override fun convertToDTO(entity: GenericEntity?) : ClienteDTO{
        val entity = entity as ClienteEntity

        return ClienteDTO(entity.nome, entity?.idade ?: 0, entity.cpf)
    }


    override fun convertToEntity(dto: GenericDTO?) : ClienteEntity{
       val clienteDto = dto as ClienteDTO
        return ClienteEntity(null, dto.nome, dto.idade, dto.cpf)
    }
}

