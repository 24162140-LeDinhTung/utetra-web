package com.utetra.exception.custom;

public class VoucherInvalidException extends RuntimeException {
    public VoucherInvalidException(String message) {
        super(message);
    }
}