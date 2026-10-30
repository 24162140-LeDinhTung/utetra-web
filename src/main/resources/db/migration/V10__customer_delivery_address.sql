-- Optional address, remembered only when an order is delivered.
ALTER TABLE users ADD COLUMN shipping_address TEXT NULL;
