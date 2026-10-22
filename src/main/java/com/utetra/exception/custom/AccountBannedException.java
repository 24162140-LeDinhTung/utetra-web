package com.utetra.exception.custom;

public class AccountBannedException extends RuntimeException {
    public AccountBannedException(String message) {
        super(message);
    }
}