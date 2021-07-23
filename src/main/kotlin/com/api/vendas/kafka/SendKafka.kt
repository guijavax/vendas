package com.api.vendas.kafka

import org.springframework.beans.factory.annotation.Autowired
import org.springframework.kafka.core.KafkaTemplate
import org.springframework.stereotype.Component

@Component
class SendKafka private constructor(){

    @Autowired
    lateinit var template: KafkaTemplate<String, Any>

    fun sendKafka(topic : String, message : Any) {
        template.send(topic, message)
    }
}