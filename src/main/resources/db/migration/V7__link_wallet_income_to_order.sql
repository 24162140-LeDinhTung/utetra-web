-- Preserve existing wallet entries; new order entries have a durable idempotency key.
ALTER TABLE wallet_transactions ADD COLUMN order_id BIGINT NULL;
ALTER TABLE wallet_transactions ADD CONSTRAINT fk_wallet_tx_order FOREIGN KEY (order_id) REFERENCES orders(id);
ALTER TABLE wallet_transactions ADD CONSTRAINT uk_wallet_order_type UNIQUE (order_id, type);
