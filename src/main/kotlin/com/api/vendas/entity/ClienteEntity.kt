package com.api.vendas.entity

import com.api.vendas.generic.GenericEntity
import com.api.vendas.utils.RegexValidation
import javax.persistence.*
import javax.validation.constraints.Pattern

@Entity
@Table(name = "cliente")
data class ClienteEntity(

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id : Long? = 0L,

    @Column
    val nome : String? = null,

    @Column
    val idade : Int? = 0,

    @Column
//    @field:Pattern(regexp = RegexValidation.CPF)
    val cpf : String? = null
) : GenericEntity(){
}