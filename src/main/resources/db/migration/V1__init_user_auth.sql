-- =========================================================
-- V1__init_user_auth.sql
-- Tạo các bảng cho module User + Auth (Thành viên A)
-- =========================================================

-- 1. Bảng users
CREATE TABLE users (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    email               VARCHAR(255) NOT NULL,
    password            VARCHAR(255) NOT NULL,
    full_name           VARCHAR(255),
    phone               VARCHAR(20),
    avatar_url          VARCHAR(500),
    cover_url           VARCHAR(500),
    status              VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    email_verified      BOOLEAN DEFAULT FALSE,
    last_login_at       DATETIME,
    loyalty_points      INT DEFAULT 0,
    user_level_id       BIGINT,

    is_deleted          BOOLEAN DEFAULT FALSE,
    created_at          DATETIME,
    updated_at          DATETIME,

    CONSTRAINT uk_users_email UNIQUE (email)
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);

-- 2. Bảng roles
CREATE TABLE roles (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(50) NOT NULL,
    is_deleted  BOOLEAN DEFAULT FALSE,
    created_at  DATETIME,
    updated_at  DATETIME,

    CONSTRAINT uk_roles_name UNIQUE (name)
);

-- 3. Bảng user_roles
CREATE TABLE user_roles (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT NOT NULL,
    role_id     BIGINT NOT NULL,

    CONSTRAINT fk_user_roles_users FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_user_roles_roles FOREIGN KEY (role_id) REFERENCES roles(id),
    CONSTRAINT uk_user_roles UNIQUE (user_id, role_id)
);

CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);

-- 4. Bảng user_levels
CREATE TABLE user_levels (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    name                VARCHAR(100) NOT NULL,
    min_spent           DECIMAL(15,2) DEFAULT 0,
    discount_percent    INT DEFAULT 0,
    description         VARCHAR(500),

    is_deleted          BOOLEAN DEFAULT FALSE,
    created_at          DATETIME,
    updated_at          DATETIME
);

-- 5. Bảng addresses
CREATE TABLE addresses (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    receiver_name   VARCHAR(255) NOT NULL,
    phone           VARCHAR(20) NOT NULL,
    province        VARCHAR(255),
    district        VARCHAR(255),
    ward            VARCHAR(255),
    detail          VARCHAR(500),
    label           VARCHAR(50),
    is_default      BOOLEAN DEFAULT FALSE,

    is_deleted      BOOLEAN DEFAULT FALSE,
    created_at      DATETIME,
    updated_at      DATETIME,

    CONSTRAINT fk_addresses_users FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX idx_addresses_user_id ON addresses(user_id);

-- 6. Bảng otp_tokens
CREATE TABLE otp_tokens (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT,
    email       VARCHAR(255) NOT NULL,
    code        VARCHAR(10) NOT NULL,
    type        VARCHAR(50) NOT NULL,
    expired_at  DATETIME NOT NULL,
    used        BOOLEAN DEFAULT FALSE,

    is_deleted  BOOLEAN DEFAULT FALSE,
    created_at  DATETIME,
    updated_at  DATETIME
);

CREATE INDEX idx_otp_email_type ON otp_tokens(email, type);

-- 7. Bảng refresh_tokens
CREATE TABLE refresh_tokens (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT NOT NULL,
    token       VARCHAR(500) NOT NULL,
    expired_at  DATETIME NOT NULL,
    revoked     BOOLEAN DEFAULT FALSE,

    is_deleted  BOOLEAN DEFAULT FALSE,
    created_at  DATETIME,
    updated_at  DATETIME,

    CONSTRAINT uk_refresh_tokens_token UNIQUE (token),
    CONSTRAINT fk_refresh_tokens_users FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);