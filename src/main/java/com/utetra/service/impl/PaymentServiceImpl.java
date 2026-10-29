package com.utetra.service.impl;

import com.utetra.entity.*;
import com.utetra.enums.*;
import com.utetra.exception.custom.ResourceNotFoundException;
import com.utetra.repository.*;
import com.utetra.service.*;
import com.utetra.util.PaymentSignatures;
import java.math.BigDecimal;
import java.net.http.HttpClient;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestClient;

@Service
@RequiredArgsConstructor
@Transactional
public class PaymentServiceImpl implements PaymentService {
  private final jakarta.persistence.EntityManager entityManager;
  private final OrderRepository orders;
  private final PaymentTransactionRepository transactions;
  private final OrderStatusHistoryRepository histories;
  private final CommerceAccess access;
  private final ApplicationEventPublisher events;
  private final OrderWalletSettlement settlement;

  @Value("${payment.vnpay.tmn-code:}")
  private String tmn;

  @Value("${payment.vnpay.hash-secret:}")
  private String vnpSecret;

  @Value("${payment.vnpay.url:https://sandbox.vnpayment.vn/paymentv2/vpcpay.html}")
  private String vnpUrl;

  @Value("${payment.return-url:http://localhost:8080/customer/payment}")
  private String returnUrl;

  @Value("${payment.momo.partner-code:}")
  private String partner;

  @Value("${payment.momo.access-key:}")
  private String momoAccess;

  @Value("${payment.momo.secret-key:}")
  private String momoSecret;

  @Value("${payment.momo.url:https://test-payment.momo.vn/v2/gateway/api/create}")
  private String momoUrl;

  @Value("${payment.momo.ipn-url:}")
  private String momoIpn;

  private void configured(String... values) {
    if (Arrays.stream(values).anyMatch(s -> s == null || s.isBlank()))
      throw new IllegalStateException("Cổng thanh toán chưa được cấu hình tài khoản sandbox");
  }

  public Map<String, String> start(Long userId, Long orderId, PaymentMethod method, String ip) {
    if (method == PaymentMethod.COD)
      throw new IllegalArgumentException("Đơn COD thanh toán khi nhận hàng");
    Order o =
        orders
            .lockById(orderId)
            .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy đơn"));
    access.order(o, userId);
    if (o.getPaymentMethod() != method
        || o.getStatus() != OrderStatus.NEW
        || o.getPaymentStatus() == PaymentStatus.SUCCESS
        || o.getTotalAmount().signum() <= 0)
      throw new IllegalArgumentException(
          "Đơn không ở trạng thái chờ thanh toán với phương thức này");
    if (method == PaymentMethod.VNPAY) configured(tmn, vnpSecret);
    else configured(partner, momoAccess, momoSecret, momoIpn);
    PaymentTransaction tx =
        transactions
            .findFirstByOrderIdOrderByIdDesc(orderId)
            .filter(t -> t.getStatus() == PaymentStatus.PENDING && t.getQrContent() == null)
            .orElseGet(
                () -> {
                  PaymentTransaction n = new PaymentTransaction();
                  n.setOrder(o);
                  n.setReference("UTE" + UUID.randomUUID().toString().replace("-", ""));
                  n.setProvider(method);
                  n.setAmount(o.getTotalAmount());
                  return transactions.save(n);
                });
    if (tx.getPaymentUrl() != null)
      return Map.of("paymentUrl", tx.getPaymentUrl(), "reference", tx.getReference());
    String url;
    if (method == PaymentMethod.VNPAY) {
      Map<String, String> p = new TreeMap<>();
      ZonedDateTime now = ZonedDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
      DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
      p.put("vnp_Version", "2.1.0");
      p.put("vnp_Command", "pay");
      p.put("vnp_TmnCode", tmn);
      p.put(
          "vnp_Amount",
          tx.getAmount().multiply(BigDecimal.valueOf(100)).toBigIntegerExact().toString());
      p.put("vnp_CurrCode", "VND");
      p.put("vnp_TxnRef", tx.getReference());
      p.put("vnp_OrderInfo", "Thanh toan " + o.getOrderCode());
      p.put("vnp_OrderType", "other");
      p.put("vnp_Locale", "vn");
      p.put("vnp_ReturnUrl", returnUrl + "?localOrderId=" + o.getId());
      p.put("vnp_IpAddr", ip);
      p.put("vnp_CreateDate", now.format(fmt));
      p.put("vnp_ExpireDate", now.plusMinutes(15).format(fmt));
      String query = PaymentSignatures.vnpay(p);
      url =
          vnpUrl
              + "?"
              + query
              + "&vnp_SecureHash="
              + PaymentSignatures.hmac("HmacSHA512", vnpSecret, query);
    } else {
      Map<String, Object> p = new LinkedHashMap<>();
      p.put("partnerCode", partner);
      p.put("accessKey", momoAccess);
      p.put("requestId", tx.getReference());
      p.put("orderId", tx.getReference());
      p.put("amount", tx.getAmount().longValueExact());
      p.put("orderInfo", "Thanh toan " + o.getOrderCode());
      p.put("redirectUrl", returnUrl + "?localOrderId=" + o.getId());
      p.put("ipnUrl", momoIpn);
      p.put("extraData", "");
      p.put("requestType", "captureWallet");
      p.put("autoCapture", true);
      p.put("lang", "vi");
      p.put(
          "signature",
          PaymentSignatures.hmac(
              "HmacSHA256",
              momoSecret,
              PaymentSignatures.momo(
                  p,
                  "accessKey",
                  "amount",
                  "extraData",
                  "ipnUrl",
                  "orderId",
                  "orderInfo",
                  "partnerCode",
                  "redirectUrl",
                  "requestId",
                  "requestType")));
      p.remove("accessKey");
      JdkClientHttpRequestFactory factory =
          new JdkClientHttpRequestFactory(
              HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build());
      factory.setReadTimeout(Duration.ofSeconds(25));
      Map<?, ?> response =
          RestClient.builder()
              .requestFactory(factory)
              .build()
              .post()
              .uri(momoUrl)
              .contentType(org.springframework.http.MediaType.APPLICATION_JSON)
              .body(p)
              .retrieve()
              .body(Map.class);
      if (response == null
          || !"0".equals(String.valueOf(response.get("resultCode")))
          || response.get("payUrl") == null)
        throw new IllegalStateException(
            "MoMo chưa tạo được liên kết thanh toán; kiểm tra cấu hình sandbox");
      url = response.get("payUrl").toString();
      if (!url.startsWith("https://"))
        throw new IllegalStateException("MoMo trả về URL không hợp lệ");
    }
    tx.setPaymentUrl(url);
    transactions.save(tx);
    o.setPaymentStatus(PaymentStatus.PENDING);
    orders.save(o);
    return Map.of("paymentUrl", url, "reference", tx.getReference());
  }

  public Map<String, String> startVnpayQr(Long userId, Long orderId, String ip) {
    configured(tmn, vnpSecret);
    Order order = orders.lockById(orderId).orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy đơn"));
    access.order(order, userId);
    if (order.getPaymentMethod() != PaymentMethod.VNPAY || order.getStatus() != OrderStatus.NEW
        || order.getPaymentStatus() == PaymentStatus.SUCCESS || order.getTotalAmount().signum() <= 0)
      throw new IllegalArgumentException("Đơn không còn chờ thanh toán VNPay");
    var now = ZonedDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
    var existing = transactions.findFirstByOrderIdOrderByIdDesc(orderId)
        .filter(t -> t.getStatus() == PaymentStatus.PENDING && t.getQrContent() != null
            && t.getQrExpiresAt() != null && t.getQrExpiresAt().isAfter(now.toLocalDateTime()));
    if (existing.isPresent()) return qrResponse(existing.get());
    PaymentTransaction tx = new PaymentTransaction();
    tx.setOrder(order); tx.setProvider(PaymentMethod.VNPAY); tx.setAmount(order.getTotalAmount());
    tx.setReference("QR" + UUID.randomUUID().toString().replace("-", ""));
    var fmt = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
    Map<String, String> params = new TreeMap<>();
    params.put("vnp_Version", "2.1.1"); params.put("vnp_Command", "genqr");
    params.put("vnp_TmnCode", tmn); params.put("vnp_Amount", tx.getAmount().multiply(BigDecimal.valueOf(100)).toBigIntegerExact().toString());
    params.put("vnp_CurrCode", "VND"); params.put("vnp_TxnRef", tx.getReference());
    params.put("vnp_OrderInfo", "Thanh toan " + order.getOrderCode());
    params.put("vnp_OrderType", "other"); params.put("vnp_Locale", "vn");
    params.put("vnp_ReturnUrl", returnUrl + "?localOrderId=" + orderId);
    params.put("vnp_IpAddr", ip); params.put("vnp_CreateDate", now.format(fmt));
    params.put("vnp_ExpireDate", now.plusMinutes(15).format(fmt));
    String query = PaymentSignatures.vnpay(params);
    String signedUrl = vnpUrl + "?" + query + "&vnp_SecureHash=" + PaymentSignatures.hmac("HmacSHA512", vnpSecret, query);
    Map<?, ?> response;
    try {
      var factory = new JdkClientHttpRequestFactory(HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build());
      factory.setReadTimeout(Duration.ofSeconds(10));
      response = RestClient.builder().requestFactory(factory).build().get().uri(java.net.URI.create(signedUrl))
          .retrieve().body(Map.class);
    } catch (org.springframework.web.client.RestClientException e) {
      throw new IllegalStateException("Chưa tạo được QR từ VNPay. Bạn có thể dùng nút Mở cổng VNPAY hoặc thử lại sau.");
    }
    if (response == null || !"00".equals(response.get("code"))
        || !(response.get("qrcontent") instanceof String content) || content.isBlank() || content.length() > 4096)
      throw new IllegalStateException("VNPay chưa cấp được QR cho giao dịch này. Tài khoản cần hỗ trợ Merchant hosted QR; bạn vẫn có thể mở cổng VNPAY.");
    tx.setQrContent((String) response.get("qrcontent")); tx.setQrExpiresAt(now.plusMinutes(15).toLocalDateTime());
    transactions.save(tx);
    return qrResponse(tx);
  }

  private Map<String, String> qrResponse(PaymentTransaction tx) {
    return Map.of("qrImage", PaymentQrImage.png(tx.getQrContent()), "reference", tx.getReference(),
        "expiresAt", tx.getQrExpiresAt().atZone(ZoneId.of("Asia/Ho_Chi_Minh")).toInstant().toString(),
        "environment", vnpUrl.contains("sandbox.vnpayment.vn") ? "sandbox" : "live");
  }

  public Map<String, String> vnpayCallback(Map<String, String> p) {
    configured(tmn, vnpSecret);
    if (!PaymentSignatures.matches(
            p.get("vnp_SecureHash"),
            PaymentSignatures.hmac("HmacSHA512", vnpSecret, PaymentSignatures.vnpay(p)))
        || !tmn.equals(p.get("vnp_TmnCode"))) return ack("97", "Invalid signature");
    PaymentTransaction tx = transactions.findByReference(p.get("vnp_TxnRef")).orElse(null);
    if (tx == null || tx.getProvider() != PaymentMethod.VNPAY) return ack("01", "Order not found");
    Order o = orders.lockById(tx.getOrder().getId()).orElseThrow();
    entityManager.refresh(tx);
    BigDecimal amount;
    try {
      amount = new BigDecimal(p.get("vnp_Amount")).divide(BigDecimal.valueOf(100));
    } catch (Exception e) {
      return ack("04", "Invalid amount");
    }
    if (amount.compareTo(tx.getAmount()) != 0) return ack("04", "Invalid amount");
    if (tx.getStatus() != PaymentStatus.PENDING) return ack("02", "Already confirmed");
    complete(
        tx,
        o,
        "00".equals(p.get("vnp_ResponseCode")) && "00".equals(p.get("vnp_TransactionStatus")),
        p.get("vnp_TransactionNo"),
        p.get("vnp_ResponseCode"));
    return ack("00", "Confirm success");
  }

  public void momoCallback(Map<String, Object> p) {
    configured(partner, momoAccess, momoSecret);
    Map<String, Object> signed = new HashMap<>(p);
    signed.put("accessKey", momoAccess);
    String hash =
        PaymentSignatures.hmac(
            "HmacSHA256",
            momoSecret,
            PaymentSignatures.momo(
                signed,
                "accessKey",
                "amount",
                "extraData",
                "message",
                "orderId",
                "orderInfo",
                "orderType",
                "partnerCode",
                "payType",
                "requestId",
                "responseTime",
                "resultCode",
                "transId"));
    if (!partner.equals(p.get("partnerCode"))
        || !PaymentSignatures.matches(Objects.toString(p.get("signature"), null), hash))
      throw new IllegalArgumentException("Chữ ký MoMo không hợp lệ");
    PaymentTransaction tx =
        transactions
            .findByReference(Objects.toString(p.get("orderId"), ""))
            .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy giao dịch"));
    Order o = orders.lockById(tx.getOrder().getId()).orElseThrow();
    entityManager.refresh(tx);
    if (tx.getProvider() != PaymentMethod.MOMO
        || !tx.getReference().equals(p.get("requestId"))
        || new BigDecimal(String.valueOf(p.get("amount"))).compareTo(tx.getAmount()) != 0)
      throw new IllegalArgumentException("Thông tin giao dịch không khớp");
    if (tx.getStatus() != PaymentStatus.PENDING) return;
    String code = String.valueOf(p.get("resultCode"));
    if ("9000".equals(code)) return;
    complete(tx, o, "0".equals(code), String.valueOf(p.get("transId")), code);
  }

  private Map<String, String> ack(String code, String message) {
    return Map.of("RspCode", code, "Message", message);
  }

  private void complete(PaymentTransaction tx, Order o, boolean ok, String gatewayId, String code) {
    tx.setStatus(ok ? PaymentStatus.SUCCESS : PaymentStatus.FAILED);
    tx.setGatewayTransactionId(gatewayId);
    tx.setResultCode(code);
    transactions.save(tx);
    if (o.getPaymentStatus() != PaymentStatus.SUCCESS) o.setPaymentStatus(tx.getStatus());
    if (ok && o.getStatus() == OrderStatus.NEW) o.setStatus(OrderStatus.CONFIRMED);
    orders.save(o);
    settlement.reconcile(o.getId());
    OrderStatusHistory h = new OrderStatusHistory();
    h.setOrder(o);
    h.setStatus(o.getStatus());
    h.setNote(
        ok
            ? (o.getStatus() == OrderStatus.CANCELLED
                ? "Thanh toán đến sau khi hủy: cần đối soát và hoàn tiền qua module ví"
                : "Thanh toán thành công")
            : "Thanh toán thất bại: " + code);
    histories.save(h);
    events.publishEvent(
        new OrderEvents.Changed(
            o.getId(), o.getShop().getId(), o.getStatus().name(), o.getPaymentStatus().name()));
  }
}
