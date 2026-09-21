package com.utetra.mapper;

import com.utetra.dto.response.cart.CartResponse;
import com.utetra.entity.CartItem;
import org.mapstruct.Mapping;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface CartMapper {

    @Mapping(source = "id", target = "cartItemId")
    @Mapping(source = "product.id", target = "productId")
    @Mapping(source = "product.name", target = "productName")
    @Mapping(source = "product.price", target = "unitPrice")
    CartResponse.Item toItemResponse(CartItem cartItem);
}