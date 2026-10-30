-- QR attempts use their own reference and retain the original IPN verification flow.
ALTER TABLE payment_transactions ADD COLUMN qr_content TEXT NULL;
ALTER TABLE payment_transactions ADD COLUMN qr_expires_at DATETIME(6) NULL;
