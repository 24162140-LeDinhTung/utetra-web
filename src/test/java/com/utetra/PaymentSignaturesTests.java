package com.utetra;

import static org.assertj.core.api.Assertions.*;

import com.utetra.util.PaymentSignatures;
import java.util.Map;
import org.junit.jupiter.api.Test;

class PaymentSignaturesTests {
  @Test
  void sha256MatchesKnownIndependentVector() {
    assertThat(
            PaymentSignatures.hmac(
                "HmacSHA256", "key", "The quick brown fox jumps over the lazy dog"))
        .isEqualTo("f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8");
  }

  @Test
  void vnpaySortsEncodesAndExcludesSignatureFields() {
    assertThat(
            PaymentSignatures.vnpay(
                Map.of(
                    "vnp_TxnRef",
                    "abc",
                    "vnp_OrderInfo",
                    "Trà sữa",
                    "vnp_Amount",
                    "100000",
                    "vnp_SecureHash",
                    "excluded",
                    "ignored",
                    "x")))
        .isEqualTo("vnp_Amount=100000&vnp_OrderInfo=Tr%C3%A0+s%E1%BB%AFa&vnp_TxnRef=abc");
  }
}
