package com.utetra.service;

import com.utetra.enums.PaymentMethod;
import java.util.Map;

public interface PaymentService {
  Map<String, String> start(Long userId, Long orderId, PaymentMethod method, String ip);

  Map<String, String> vnpayCallback(Map<String, String> parameters);

  void momoCallback(Map<String, Object> parameters);
}
