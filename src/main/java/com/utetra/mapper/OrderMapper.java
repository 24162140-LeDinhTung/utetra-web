package com.utetra.mapper;

import com.utetra.dto.response.order.OrderResponse;
import com.utetra.entity.Order;
import org.mapstruct.Mapping;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface OrderMapper {

    @Mapping(source = "shop.name", target = "shopName")
    OrderResponse toResponse(Order order);
}