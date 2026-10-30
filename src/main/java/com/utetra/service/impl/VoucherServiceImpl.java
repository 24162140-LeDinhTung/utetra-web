package com.utetra.service.impl;

import com.utetra.dto.request.voucher.CreateVoucherRequest;
import com.utetra.dto.response.CommerceDtos.VoucherItem;
import com.utetra.entity.Voucher;
import com.utetra.enums.DiscountType;
import com.utetra.exception.custom.ResourceNotFoundException;
import com.utetra.repository.VoucherRepository;
import com.utetra.service.*;
import java.math.BigDecimal;
import java.util.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class VoucherServiceImpl implements VoucherService {
  private final VoucherRepository vouchers;
  private final CommerceAccess access;
  private final org.springframework.context.ApplicationEventPublisher events;

  private Voucher own(Long shop, Long owner, Long id) {
    access.shop(shop, owner);
    return vouchers
        .lockById(id)
        .filter(
            v ->
                !Boolean.TRUE.equals(v.getIsDeleted())
                    && v.getShop() != null
                    && v.getShop().getId().equals(shop))
        .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy voucher của cửa hàng"));
  }

  @Transactional(readOnly = true)
  public List<VoucherItem> list(Long shop, Long owner) {
    access.shop(shop, owner);
    return vouchers.findByShopIdAndIsDeletedFalseOrderByIdDesc(shop).stream()
        .map(this::dto)
        .toList();
  }

  public VoucherItem save(Long shop, Long owner, Long id, CreateVoucherRequest r) {
    if (!r.getStartDate().isBefore(r.getEndDate())
        || r.getDiscountValue().signum() <= 0
        || (r.getDiscountType() == DiscountType.PERCENT
            && r.getDiscountValue().compareTo(BigDecimal.valueOf(100)) > 0)
        || r.getMinOrderAmount() != null && r.getMinOrderAmount().signum() < 0
        || r.getMaxDiscountAmount() != null && r.getMaxDiscountAmount().signum() < 0
        || r.getUsageLimit() != null && r.getUsageLimit() < 1)
      throw new IllegalArgumentException("Thời gian hoặc mức giảm không hợp lệ");
    Voucher v = id == null ? new Voucher() : own(shop, owner, id);
    v.setShop(access.shop(shop, owner));
    if (v.getUsedCount() > 0)
      throw new IllegalArgumentException("Voucher đã được sử dụng; hãy tạo mã mới");
    String code = r.getCode().trim().toUpperCase(Locale.ROOT);
    if (!code.matches("[A-Z0-9_-]{3,50}"))
      throw new IllegalArgumentException("Mã voucher phải có 3–50 ký tự chữ, số, _ hoặc -");
    vouchers
        .findByCode(code)
        .filter(x -> !x.getId().equals(id))
        .ifPresent(
            x -> {
              throw new IllegalArgumentException("Mã voucher đã tồn tại");
            });
    v.setCode(code);
    v.setVoucherType(r.getVoucherType());
    v.setDiscountType(r.getDiscountType());
    v.setDiscountValue(r.getDiscountValue());
    v.setMinOrderAmount(r.getMinOrderAmount() == null ? BigDecimal.ZERO : r.getMinOrderAmount());
    v.setMaxDiscountAmount(r.getMaxDiscountAmount());
    v.setUsageLimit(r.getUsageLimit());
    v.setStartDate(r.getStartDate());
    v.setEndDate(r.getEndDate());
    vouchers.save(v);
    events.publishEvent(new OfferEvents.Changed(shop));
    return dto(v);
  }

  public void delete(Long shop, Long owner, Long id) {
    Voucher v = own(shop, owner, id);
    v.setIsDeleted(true);
    vouchers.save(v);
    events.publishEvent(new OfferEvents.Changed(shop));
  }

  private VoucherItem dto(Voucher v) {
    return new VoucherItem(
        v.getId(),
        v.getCode(),
        v.getVoucherType(),
        v.getDiscountType(),
        v.getDiscountValue(),
        v.getMinOrderAmount(),
        v.getMaxDiscountAmount(),
        v.getUsageLimit(),
        v.getUsedCount(),
        v.getStartDate(),
        v.getEndDate());
  }
}
