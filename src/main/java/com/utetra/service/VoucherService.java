package com.utetra.service;

import com.utetra.dto.request.voucher.CreateVoucherRequest;
import com.utetra.dto.response.CommerceDtos.VoucherItem;
import java.util.List;

public interface VoucherService {
  List<VoucherItem> list(Long shopId, Long ownerId);

  VoucherItem save(Long shopId, Long ownerId, Long id, CreateVoucherRequest request);

  void delete(Long shopId, Long ownerId, Long id);
}
