package com.utetra.controller.customer;

import com.utetra.dto.response.ApiResponse;
import com.utetra.dto.response.product.ProductFavoriteResponse;
import com.utetra.dto.response.shop.ShopResponse;
import com.utetra.security.UserPrincipal;
import com.utetra.service.FavoriteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/customer")
@RequiredArgsConstructor
public class CustomerFavoriteController {

    private final FavoriteService favoriteService;

    // --- YÊU THÍCH SẢN PHẨM ---
    @PostMapping("/favorites/products/{productId}")
    public ResponseEntity<ApiResponse<Void>> toggleFavorite(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long productId) {
        favoriteService.toggleFavoriteProduct(principal.getId(), productId);
        return ResponseEntity.ok(ApiResponse.success("Thao tác thành công", null));
    }

    @GetMapping("/favorites/products")
    public ResponseEntity<ApiResponse<List<ProductFavoriteResponse>>> getFavorites(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.success(favoriteService.getFavoriteProducts(principal.getId())));
    }

    // --- THEO DÕI SHOP ---
    @PostMapping("/follows/shops/{shopId}")
    public ResponseEntity<ApiResponse<Void>> toggleFollow(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long shopId) {
        favoriteService.toggleFollowShop(principal.getId(), shopId);
        return ResponseEntity.ok(ApiResponse.success("Thao tác thành công", null));
    }

    @GetMapping("/follows/shops")
    public ResponseEntity<ApiResponse<List<ShopResponse>>> getFollowedShops(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.success(favoriteService.getFollowedShops(principal.getId())));
    }

    // --- LỊCH SỬ XEM ---
    @PostMapping("/history/{productId}")
    public ResponseEntity<ApiResponse<Void>> logView(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long productId) {
        if (principal != null) {
            favoriteService.logProductView(principal.getId(), productId);
        }
        return ResponseEntity.ok(ApiResponse.success("Đã lưu lịch sử xem", null));
    }

    @GetMapping("/history")
    public ResponseEntity<ApiResponse<List<ProductFavoriteResponse>>> getHistory(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.success(favoriteService.getViewHistory(principal.getId())));
    }
}