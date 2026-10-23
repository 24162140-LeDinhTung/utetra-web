package com.utetra.service;

import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@lombok.extern.slf4j.Slf4j
@Component
@RequiredArgsConstructor
public class OrderEvents {
  private final SimpMessagingTemplate messaging;

  public record Changed(Long orderId, Long shopId, String status, String paymentStatus) {}

  @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
  public void changed(Changed e) {
    Map<String, Object> payload =
        Map.of("orderId", e.orderId(), "status", e.status(), "paymentStatus", e.paymentStatus());
    try {
      messaging.convertAndSend("/topic/order/" + e.orderId() + "/status", (Object) payload);
      messaging.convertAndSend("/topic/shop/" + e.shopId() + "/orders", (Object) payload);
    } catch (RuntimeException ex) {
      log.warn("Order {} committed but realtime delivery failed", e.orderId(), ex);
    }
  }
}
