package com.utetra.service;

public interface MailService {
    void sendOtpEmail(String to, String otp, String type);
}