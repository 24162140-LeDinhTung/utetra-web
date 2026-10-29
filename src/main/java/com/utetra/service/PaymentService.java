package com.utetra.service;

import com.utetra.enums.PaymentMethod;
import java.util.Map;

public interface PaymentService {
  Map<String, String> start(Long userId, Long orderId, PaymentMethod method, String ip);

  Map<String, String> startVnpayQr(Long userId, Long orderId, String ip);

  Map<String, String> vnpayCallback(Map<String, String> parameters);

  Map<String, String> startSepay(Long userId, Long orderId);

  void sepayCallback(String authorization, Map<String, Object> parameters);

  void momoCallback(Map<String, Object> parameters);
}
