package com.utetra.service;

import com.utetra.entity.*;
import com.utetra.enums.*;
import com.utetra.repository.*;
import java.math.BigDecimal;
import java.util.Set;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Order income is recorded atomically with delivery/payment confirmation. */
@Service
@RequiredArgsConstructor
@Transactional
public class OrderWalletSettlement {
  private final OrderRepository orders;
  private final ShopRepository shops;
  private final WalletRepository wallets;
  private final WalletTransactionRepository ledger;

  public void reconcile(Long orderId) {
    Order order = orders.lockById(orderId).orElseThrow();
    boolean reversed = Set.of(OrderStatus.CANCELLED, OrderStatus.RETURNED, OrderStatus.REFUNDED).contains(order.getStatus());
    var income = ledger.findByOrderIdAndType(orderId, WalletTxType.ORDER_INCOME);
    if (reversed && income.isEmpty()) return;
    boolean eligible = order.getPaymentStatus() == PaymentStatus.SUCCESS
        && (order.getPaymentMethod() != PaymentMethod.COD || order.getStatus() == OrderStatus.DELIVERED);
    if (!reversed && (!eligible || income.isPresent())) return;
    // Shop lock also serializes wallet creation for shops without an existing wallet.
    Shop shop = shops.lockById(order.getShop().getId()).orElseThrow();
    Wallet wallet = wallets.lockByShopId(shop.getId()).orElseGet(() -> {
      Wallet created = new Wallet(); created.setShop(shop); return wallets.saveAndFlush(created);
    });
    if (reversed) {
      if (ledger.findByOrderIdAndType(orderId, WalletTxType.REFUND).isPresent()) return;
      record(wallet, order, income.orElseThrow().getAmount().negate(), WalletTxType.REFUND,
          "Thu hồi doanh thu đơn hủy/trả: ");
    } else {
      BigDecimal amount = order.getTotalAmount().subtract(order.getShippingFee());
      if (amount.signum() < 0) throw new IllegalStateException("Doanh thu đơn hàng không hợp lệ");
      record(wallet, order, amount, WalletTxType.ORDER_INCOME, "Doanh thu đơn: ");
    }
  }

  private void record(Wallet wallet, Order order, BigDecimal amount, WalletTxType type, String note) {
    wallet.setBalance(wallet.getBalance().add(amount));
    wallets.save(wallet);
    WalletTransaction entry = new WalletTransaction();
    entry.setWallet(wallet); entry.setOrderId(order.getId()); entry.setType(type);
    entry.setAmount(amount); entry.setBalanceAfter(wallet.getBalance());
    entry.setDescription(note + order.getOrderCode());
    ledger.saveAndFlush(entry);
  }
}
