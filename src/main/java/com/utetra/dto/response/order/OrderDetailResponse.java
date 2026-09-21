package com.utetra.dto.response.order;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class OrderDetailResponse {

    private Long id;
    private String orderCode;
    private Long shopId;
    private String shopName;
    private BigDecimal subtotal;
    private BigDecimal discountAmount;
    private BigDecimal shippingFee;
    private BigDecimal totalAmount;
    private String status;
    private String paymentMethod;
    private String paymentStatus;
    private String shippingAddress;
    private LocalDateTime createdAt;
    private List<Item> items;
    private List<StatusHistoryItem> statusHistory;

    @Getter
    @Setter
    public static class Item {
        private String productName;
        private String productImage;
        private BigDecimal unitPrice;
        private Integer quantity;
        private String selectedAttributes;
    }

    @Getter
    @Setter
    public static class StatusHistoryItem {
        private String status;
        private String note;
        private LocalDateTime createdAt;
    }
}