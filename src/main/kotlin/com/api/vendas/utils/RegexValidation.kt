package com.api.vendas.utils


interface RegexValidation {

    companion object {
       const val CPF: String = "[0-9]{3}[.][0-9]{3}[.][0-9]{3}[-][0-9]{2}"
    }
}