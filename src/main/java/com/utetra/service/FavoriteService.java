package com.utetra.service;

import com.utetra.dto.response.product.ProductFavoriteResponse;
import com.utetra.dto.response.shop.ShopResponse;
import java.util.List;

public interface FavoriteService {
    void toggleFavoriteProduct(Long userId, Long productId);
    List<ProductFavoriteResponse> getFavoriteProducts(Long userId);
    
    void toggleFollowShop(Long userId, Long shopId);
    List<ShopResponse> getFollowedShops(Long userId);
    
    // Hàm mới cho Lịch sử xem
    void logProductView(Long userId, Long productId);
    List<ProductFavoriteResponse> getViewHistory(Long userId);
}