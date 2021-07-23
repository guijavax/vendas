package com.api.vendas.service.kafka

import com.api.vendas.kafka.SendKafka
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.kafka.core.KafkaTemplate
import org.springframework.stereotype.Service
import java.util.logging.Logger

@Service
class ClienteKafkaService(val sendKafka: SendKafka) {

    private val logger = LoggerFactory.getLogger(ClienteKafkaService::class.java)

    @Value("\${topico}")
    private lateinit var topico : String


    fun sendToKafka(message: Any) {
        logger.info("Send message -> $message")
        sendKafka.sendKafka(topico, message)
    }
}