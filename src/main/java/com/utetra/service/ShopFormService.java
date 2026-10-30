package com.utetra.service;

import com.utetra.entity.Shop;
import com.utetra.entity.User;
import com.utetra.repository.ShopRepository;
import java.util.ArrayList;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
public class ShopFormService {
  private final ShopService shops;
  private final ShopRepository repository;
  private final StorageService storage;

  @Transactional
  public Shop save(User owner, Long id, String name, String description, MultipartFile avatar, MultipartFile cover) {
    Shop shop = id == null ? null : repository.lockById(id)
        .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy cửa hàng"));
    if (shop != null && (Boolean.TRUE.equals(shop.getIsDeleted()) || !shop.getOwner().getId().equals(owner.getId())))
      throw new AccessDeniedException("Cửa hàng không thuộc bạn");
    if (name == null || name.isBlank() || name.trim().length() > 255)
      throw new IllegalArgumentException("Tên cửa hàng phải có từ 1 đến 255 ký tự");
    if (description != null && description.length() > 500)
      throw new IllegalArgumentException("Mô tả cửa hàng tối đa 500 ký tự");
    for (MultipartFile file : new MultipartFile[]{avatar, cover})
      if (file != null && !file.isEmpty()) CatalogManagementService.validateMedia(file, false);
    var created = new ArrayList<String>();
    TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
      @Override public void afterCompletion(int status) {
        if (status != STATUS_COMMITTED) created.forEach(storage::deleteFile);
      }
    });
    if (shop == null) shop = shops.createShop(owner, name.trim(), description);
    shop.setName(name.trim()); shop.setDescription(description);
    if (avatar != null && !avatar.isEmpty()) {
      String url = storage.uploadFile(avatar, "utetra/shops/" + shop.getId());
      created.add(url); shop.setAvatarUrl(url);
    }
    if (cover != null && !cover.isEmpty()) {
      String url = storage.uploadFile(cover, "utetra/shops/" + shop.getId());
      created.add(url); shop.setCoverUrl(url);
    }
    return repository.save(shop);
  }
}
