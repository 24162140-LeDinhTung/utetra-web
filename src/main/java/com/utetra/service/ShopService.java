package com.utetra.service;

import com.utetra.entity.Shop;
import com.utetra.entity.User;
import com.utetra.enums.ShopStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import java.util.List;

public interface ShopService {
    Shop createShop(User owner, String name, String description);
    Shop updateShop(Long shopId, String name, String description, String avatarUrl, String coverUrl);
    Shop getShopById(Long id);
    List<Shop> getShopsByOwner(Long ownerId);
    Page<Shop> getAllActiveShops(Pageable pageable);
    Page<Shop> getShopsByStatus(ShopStatus status, Pageable pageable);
    void updateShopStatus(Long shopId, ShopStatus status);
}