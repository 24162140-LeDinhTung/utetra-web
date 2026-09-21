package com.utetra.mapper;

import com.utetra.dto.response.product.ProductResponse;
import com.utetra.entity.Product;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface ProductMapper {

    ProductResponse toResponse(Product product);
}