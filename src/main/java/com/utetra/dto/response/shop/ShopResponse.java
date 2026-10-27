package com.utetra.dto.response.shop;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ShopResponse {
    private Long id;
    private String name;
    private String description;
    private String avatarUrl;
    private String coverUrl;
    private String address;
}