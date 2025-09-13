package br.com

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class VendasApplication

fun main(args: Array<String>) {
    runApplication<VendasApplication>(*args)
}
