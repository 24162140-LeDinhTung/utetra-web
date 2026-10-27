package com.utetra.controller.api;

import com.utetra.entity.Shop;
import com.utetra.enums.ShopStatus;
import com.utetra.service.ShopService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/shops")
public class AdminShopApiController {

    @Autowired
    private ShopService shopService;

    // 1. Lấy danh sách shop theo trạng thái (VD: Đang chờ duyệt - PENDING)
    @GetMapping
    public ResponseEntity<Page<Shop>> getShopsByStatus(
            @RequestParam(defaultValue = "PENDING") ShopStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(shopService.getShopsByStatus(status, PageRequest.of(page, size)));
    }

    // 2. Duyệt hoặc Cấm shop
    @PatchMapping("/{shopId}/status")
    public ResponseEntity<?> updateShopStatus(
            @PathVariable Long shopId,
            @RequestParam ShopStatus status) {
        try {
            shopService.updateShopStatus(shopId, status);
            return ResponseEntity.ok("Cập nhật trạng thái shop thành công");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}