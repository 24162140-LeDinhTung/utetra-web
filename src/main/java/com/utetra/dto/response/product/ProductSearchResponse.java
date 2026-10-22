package com.utetra.dto.response.product;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class ProductSearchResponse {

    private List<ProductResponse> items;
    private int page;
    private int size;
    private long totalElements;
    private int totalPages;
}