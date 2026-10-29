-- Provider and payment_method are already VARCHAR(50); keep existing migrations intact.
CREATE TABLE sepay_receipts (
    id BIGINT NOT NULL PRIMARY KEY,
    payment_reference VARCHAR(100) NOT NULL
);
