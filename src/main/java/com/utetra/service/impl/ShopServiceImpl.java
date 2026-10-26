package com.utetra.service.impl;

import com.utetra.entity.Shop;
import com.utetra.entity.User;
import com.utetra.enums.ShopStatus;
import com.utetra.repository.ShopRepository;
import com.utetra.service.ShopService;
import com.utetra.service.WalletService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ShopServiceImpl implements ShopService {

    @Autowired
    private ShopRepository shopRepository;

    @Autowired
    private WalletService walletService;

    @Override
    @Transactional
    public Shop createShop(User owner, String name, String description) {
        Shop shop = new Shop();
        shop.setOwner(owner);
        shop.setName(name);
        shop.setDescription(description);
        shop.setStatus(ShopStatus.PENDING);
        // Mặc định gán ShopLevel thấp nhất (cần xử lý thêm ở Service)
        Shop savedShop = shopRepository.save(shop);
        
        // Tạo ví cho shop
        walletService.createWallet(savedShop);
        return savedShop;
    }

    @Override
    public Shop updateShop(Long shopId, String name, String description, String avatarUrl, String coverUrl) {
        Shop shop = getShopById(shopId);
        shop.setName(name);
        shop.setDescription(description);
        if (avatarUrl != null) shop.setAvatarUrl(avatarUrl);
        if (coverUrl != null) shop.setCoverUrl(coverUrl);
        return shopRepository.save(shop);
    }

    @Override
    public Shop getShopById(Long id) {
        return shopRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy cửa hàng với ID: " + id));
    }

    @Override
    public List<Shop> getShopsByOwner(Long ownerId) {
        return shopRepository.findByOwnerIdAndIsDeletedFalse(ownerId);
    }

    @Override
    public Page<Shop> getAllActiveShops(Pageable pageable) {
        return shopRepository.findByStatusAndIsDeletedFalse(ShopStatus.ACTIVE, pageable);
    }

    @Override
    public Page<Shop> getShopsByStatus(ShopStatus status, Pageable pageable) {
        return shopRepository.findByStatusAndIsDeletedFalse(status, pageable);
    }

    @Override
    @Transactional
    public void updateShopStatus(Long shopId, ShopStatus status) {
        Shop shop = getShopById(shopId);
        shop.setStatus(status);
        shopRepository.save(shop);
    }
}