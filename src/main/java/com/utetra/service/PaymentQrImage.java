package com.utetra.service;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.qrcode.QRCodeWriter;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.util.Base64;
import javax.imageio.ImageIO;

public final class PaymentQrImage {
  private PaymentQrImage() {}
  public static String png(String content) {
    try {
      var matrix = new QRCodeWriter().encode(content, BarcodeFormat.QR_CODE, 320, 320);
      var image = new BufferedImage(320, 320, BufferedImage.TYPE_INT_RGB);
      for (int y = 0; y < 320; y++) for (int x = 0; x < 320; x++)
        image.setRGB(x, y, matrix.get(x, y) ? 0x000000 : 0xffffff);
      var bytes = new ByteArrayOutputStream(); ImageIO.write(image, "png", bytes);
      return "data:image/png;base64," + Base64.getEncoder().encodeToString(bytes.toByteArray());
    } catch (Exception e) { throw new IllegalStateException("Không tạo được ảnh QR thanh toán", e); }
  }
}
