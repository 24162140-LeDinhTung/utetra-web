package com.utetra.dto.response.product;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
public class ProductAttributeResponse {

    private Long attributeId;
    private String attributeName;
    private List<ValueItem> values;

    @Getter
    @Setter
    public static class ValueItem {
        private Long valueId;
        private String value;
        private BigDecimal extraPrice;
    }
}