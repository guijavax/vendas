package com.api.vendas.dto

import com.api.vendas.generic.GenericDTO

data class ClienteDTO(
    val nome : String? = null,
    val idade: Int = 0,
    val cpf  : String? = null

) : GenericDTO {
}