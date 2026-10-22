package com.utetra.service.impl;

import com.utetra.service.MailService;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class MailServiceImpl implements MailService {

    private final JavaMailSender mailSender;

    @Override
    @Async
    public void sendOtpEmail(String to, String otp, String type) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setTo(to);
            helper.setSubject("[UTETra] Mã xác thực của bạn");

            String content = buildOtpContent(otp, type);
            helper.setText(content, true);

            mailSender.send(message);
            log.info("OTP email sent to {} for type {}", to, type);
        } catch (MessagingException e) {
            log.error("Failed to send OTP email to {}: {}", to, e.getMessage());
            throw new RuntimeException("Cannot send OTP email", e);
        }
    }

    private String buildOtpContent(String otp, String type) {
        String action = switch (type) {
            case "REGISTER" -> "kích hoạt tài khoản";
            case "FORGOT_PASSWORD" -> "đặt lại mật khẩu";
            case "CHANGE_EMAIL" -> "thay đổi email";
            default -> "xác thực";
        };

        return """
            <div style="font-family:Arial,sans-serif;max-width:600px;margin:auto;padding:24px;
                        border:1px solid #eee;border-radius:8px;">
                <h2 style="color:#8B4513;">☕ UTETra - Trà sữa ngon mỗi ngày</h2>
                <p>Xin chào,</p>
                <p>Bạn đã yêu cầu <b>%s</b>. Dưới đây là mã OTP của bạn:</p>
                <div style="font-size:32px;font-weight:bold;letter-spacing:8px;
                            color:#8B4513;text-align:center;padding:16px;
                            background:#fafafa;border-radius:8px;margin:16px 0;">
                    %s
                </div>
                <p>Mã có hiệu lực trong <b>5 phút</b>. Vui lòng không chia sẻ mã này với bất kỳ ai.</p>
                <p>Nếu bạn không thực hiện yêu cầu này, hãy bỏ qua email.</p>
                <hr style="border:none;border-top:1px solid #eee;margin:24px 0;">
                <p style="color:#999;font-size:12px;">© 2026 UTETra. All rights reserved.</p>
            </div>
            """.formatted(action, otp);
    }
}