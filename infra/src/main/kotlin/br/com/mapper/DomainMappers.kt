package br.com.mapper

import br.com.domain.mapper.model.Order
import br.com.domain.mapper.model.OrderItem
import br.com.domain.mapper.model.Product
import br.com.domain.mapper.model.enums.OrderStatus
import br.com.entity.OrderEntity
import br.com.entity.OrderItemEntity
import br.com.entity.OrderItemIdEntity
import br.com.entity.ProductEntity
import br.com.entity.enums.OrderStatusEntity


object DomainMappers {
    fun toDomain(p: ProductEntity) = Product(
        id = p.id,
        sku = p.sku,
        name = p.name,
        categoryId = p.categoryId,
        supplierId = p.supplierId,
        price = p.price,
        cost = p.cost,
        active = p.active,
        createdAt = p.createdAt
    )

    fun toDomain(e: OrderEntity, items: List<OrderItemEntity>): Order {

        var newItems = items.mapIndexed { idx, it ->
            OrderItem(
                productId = it.productId,
                itemNo = idx + 1,
                quantity = it.quantity,
                unitPrice = it.unitPrice,
                discountValue = it.discountValue
            )
        }
        return    Order(
            id = e.id,
            customerId = e.customerId,
            billingAddressId = e.billingAddressId,
            shippingAddressId = e.shippingAddressId,
            orderDate = e.orderDate,
            status = when (e.status) {
                OrderStatusEntity.DRAFT -> OrderStatus.DRAFT
                OrderStatusEntity.PENDING_PAYMENT -> OrderStatus.PENDING_PAYMENT
                OrderStatusEntity.PAID -> OrderStatus.PAID
                OrderStatusEntity.FULFILLED -> OrderStatus.FULFILLED
                OrderStatusEntity.CANCELLED -> OrderStatus.CANCELLED
            },
            notes = e.notes,
            // application/usecase/CreateOrderUseCase.kt
            newItems)
    }




    fun toEntity(o: Order): Pair<OrderEntity, List<OrderItemEntity>> {
        val e = OrderEntity(
            id = o.id,
            customerId = o.customerId,
            billingAddressId = o.billingAddressId,
            shippingAddressId = o.shippingAddressId,
            orderDate = o.orderDate,
            status = when (o.status) {
                OrderStatus.DRAFT -> OrderStatusEntity.DRAFT
                OrderStatus.PENDING_PAYMENT -> OrderStatusEntity.PENDING_PAYMENT
                OrderStatus.PAID -> OrderStatusEntity.PAID
                OrderStatus.FULFILLED -> OrderStatusEntity.FULFILLED
                OrderStatus.CANCELLED -> OrderStatusEntity.CANCELLED
            },
            notes = o.notes
        )

        val items = o.items.map {
            OrderItemEntity(
                id = OrderItemIdEntity(orderId = e.id, itemNo = it.itemNo),
                productId = it.productId,
                quantity = it.quantity,
                unitPrice = it.unitPrice,
                discountValue = it.discountValue
            )
        }
        return e to items
    }
}
