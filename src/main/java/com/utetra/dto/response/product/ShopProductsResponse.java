package com.utetra.dto.response.product;

import java.util.List;

public record ShopProductsResponse(
    Long shopId, String shopName, List<ProductResponse> products, long totalProducts) {}
