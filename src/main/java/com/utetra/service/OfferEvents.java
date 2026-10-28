package com.utetra.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Component
@RequiredArgsConstructor
@Slf4j
public class OfferEvents {
  private final SimpMessagingTemplate messaging;
  public record Changed(Long shopId) {}

  @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
  public void changed(Changed event) {
    try {
      messaging.convertAndSend("/topic/shop/" + event.shopId() + "/offers", event);
    } catch (RuntimeException e) {
      log.warn("Cannot publish offer update for shop {}", event.shopId(), e);
    }
  }
}
