package com.utetra.util;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.*;
import java.util.stream.Collectors;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public final class PaymentSignatures {
  private PaymentSignatures() {}

  public static String hmac(String algorithm, String secret, String data) {
    try {
      Mac mac = Mac.getInstance(algorithm);
      mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), algorithm));
      return HexFormat.of().formatHex(mac.doFinal(data.getBytes(StandardCharsets.UTF_8)));
    } catch (Exception e) {
      throw new IllegalStateException("Không thể ký thanh toán", e);
    }
  }

  public static boolean matches(String actual, String expected) {
    return actual != null
        && MessageDigest.isEqual(
            actual.toLowerCase(Locale.ROOT).getBytes(StandardCharsets.US_ASCII),
            expected.getBytes(StandardCharsets.US_ASCII));
  }

  public static String encode(String s) {
    return URLEncoder.encode(s, StandardCharsets.UTF_8);
  }

  public static String vnpay(Map<String, String> values) {
    return new TreeMap<>(values)
        .entrySet().stream()
            .filter(
                e ->
                    e.getKey().startsWith("vnp_")
                        && !Set.of("vnp_SecureHash", "vnp_SecureHashType").contains(e.getKey())
                        && e.getValue() != null
                        && !e.getValue().isEmpty())
            .map(e -> encode(e.getKey()) + "=" + encode(e.getValue()))
            .collect(Collectors.joining("&"));
  }

  public static String momo(Map<String, ?> values, String... keys) {
    return Arrays.stream(keys)
        .map(k -> k + "=" + Objects.toString(values.get(k), ""))
        .collect(Collectors.joining("&"));
  }
}
