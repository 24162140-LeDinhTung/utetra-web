package com.utetra;

import static org.assertj.core.api.Assertions.assertThat;

import java.sql.Connection;
import java.sql.DriverManager;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.init.ScriptUtils;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

class PartBSeedMigrationTests {
  @Test
  void seedWorksOnFreshDatabase() throws Exception {
    verify(false);
  }

  @Test
  void seedPreservesExistingDataAndDoesNotAssumeIdsOrDuplicateRows() throws Exception {
    verify(true);
  }

  private void verify(boolean existing) throws Exception {
    try (var c = DriverManager.getConnection(
        "jdbc:h2:mem:seed_" + existing + ";MODE=MySQL;NON_KEYWORDS=VALUE", "sa", "")) {
      for (String file : new String[] {"V1__init_user_auth.sql", "V2__seed_roles_and_levels.sql",
          "V3__commerce_part_b.sql", "V4__init_shop_wallet_and_system.sql"}) {
        run(c, file);
      }
      if (existing) {
        try (var s = c.createStatement()) {
          s.executeUpdate("INSERT INTO users(id,email,password,status) VALUES (800,'existing@utetra.test','unchanged','ACTIVE')");
          s.executeUpdate("INSERT INTO shops(id,owner_id,name,slug,status) VALUES (900,800,'Existing shop','existing-shop','ACTIVE')");
          s.executeUpdate("INSERT INTO categories(id,name,slug) VALUES (700,'Existing category','existing-category')");
          s.executeUpdate("INSERT INTO products(id,shop_id,category_id,name,slug,price,stock,status) VALUES (600,900,700,'Existing product','existing-product',12345,17,'ACTIVE')");
        }
      }
      run(c, "V5__seed_part_b_demo_data.sql");
      validate(c);
      long before = scalar(c, "SELECT COUNT(*) FROM products");
      run(c, "V5__seed_part_b_demo_data.sql");
      validate(c);
      assertThat(scalar(c, "SELECT COUNT(*) FROM products")).isEqualTo(before);
      run(c, "V6__seed_wallet_and_withdraw_data.sql");
      assertThat(scalar(c, "SELECT COUNT(*) FROM wallets")).isEqualTo(3);
      assertThat(scalar(c, "SELECT COUNT(*) FROM wallets WHERE balance < 0")).isZero();
      run(c, "V7__link_wallet_income_to_order.sql");
      assertThat(scalar(c, "SELECT COUNT(*) FROM wallet_transactions WHERE order_id IS NOT NULL")).isZero();
      if (existing) {
        assertThat(scalar(c, "SELECT COUNT(*) FROM users WHERE id=800 AND password='unchanged'")).isEqualTo(1);
        assertThat(scalar(c, "SELECT COUNT(*) FROM products WHERE id=600 AND stock=17 AND price=12345")).isEqualTo(1);
      }
    }
  }

  private void validate(Connection c) throws Exception {
    assertThat(scalar(c, "SELECT COUNT(*) FROM users WHERE email LIKE 'partb.%@utetra.test'")).isEqualTo(4);
    assertThat(scalar(c, "SELECT COUNT(*) FROM user_roles ur JOIN users u ON u.id=ur.user_id WHERE u.email LIKE 'partb.%@utetra.test'")).isEqualTo(4);
    assertThat(scalar(c, "SELECT COUNT(*) FROM shops WHERE slug LIKE 'part-b-demo-%' AND status='ACTIVE'")).isEqualTo(3);
    assertThat(scalar(c, "SELECT COUNT(*) FROM (SELECT shop_id FROM products WHERE slug LIKE 'part-b-demo-s%-p%' AND status='ACTIVE' AND stock>0 GROUP BY shop_id HAVING COUNT(*)=12) menus")).isEqualTo(3);
    assertThat(scalar(c, "SELECT COUNT(*) FROM product_attribute_values")).isEqualTo(72);
    assertThat(scalar(c, "SELECT COUNT(*) FROM product_images")).isEqualTo(36);
    assertThat(scalar(c, "SELECT COUNT(*) FROM carts")).isEqualTo(2);
    assertThat(scalar(c, "SELECT COUNT(*) FROM cart_items")).isEqualTo(3);
    assertThat(scalar(c, "SELECT COUNT(*) FROM orders")).isEqualTo(4);
    assertThat(scalar(c, "SELECT COUNT(*) FROM order_items")).isEqualTo(5);
    assertThat(scalar(c, "SELECT COUNT(*) FROM order_status_history")).isEqualTo(14);
    assertThat(scalar(c, "SELECT COUNT(*) FROM payment_transactions")).isEqualTo(4);
    assertThat(scalar(c, "SELECT COUNT(*) FROM vouchers")).isEqualTo(9);
    assertThat(scalar(c, "SELECT COUNT(*) FROM voucher_usages")).isEqualTo(1);
    assertThat(scalar(c, "SELECT COUNT(*) FROM promotion_products")).isEqualTo(6);
    assertThat(scalar(c, "SELECT COUNT(*) FROM product_reviews")).isEqualTo(1);
    assertThat(scalar(c, "SELECT COUNT(*) FROM review_media")).isEqualTo(1);
    assertThat(scalar(c, "SELECT COUNT(*) FROM orders WHERE total_amount <> subtotal-discount_amount+shipping_fee")).isZero();
    assertThat(scalar(c, "SELECT COUNT(*) FROM orders o WHERE o.subtotal <> (SELECT SUM(i.unit_price*i.quantity) FROM order_items i WHERE i.order_id=o.id)")).isZero();
    assertThat(scalar(c, "SELECT COUNT(*) FROM order_items i JOIN orders o ON o.id=i.order_id JOIN products p ON p.id=i.product_id WHERE p.shop_id<>o.shop_id")).isZero();
    assertThat(scalar(c, "SELECT COUNT(*) FROM payment_transactions t JOIN orders o ON o.id=t.order_id WHERE t.status<>o.payment_status OR t.amount<>o.total_amount OR t.provider<>o.payment_method")).isZero();
    assertThat(scalar(c, "SELECT COUNT(*) FROM products p WHERE p.slug LIKE 'part-b-demo-s%-p%' AND (p.stock+p.sold_count<>100 OR p.sold_count<>(SELECT COALESCE(SUM(i.quantity),0) FROM order_items i JOIN orders o ON o.id=i.order_id WHERE i.product_id=p.id AND o.status<>'CANCELLED'))")).isZero();
    assertThat(scalar(c, "SELECT COUNT(*) FROM wallets")).isZero();
    assertThat(scalar(c, "SELECT COUNT(*) FROM wallet_transactions")).isZero();
    assertThat(new ClassPathResource("static/images/part-b-demo.svg").exists()).isTrue();
    try (var s = c.createStatement(); var r = s.executeQuery("SELECT password FROM users WHERE email='partb.customer@utetra.test'")) {
      assertThat(r.next()).isTrue();
      assertThat(new BCryptPasswordEncoder().matches("PartB@123456", r.getString(1))).isTrue();
    }
  }

  private void run(Connection c, String file) {
    ScriptUtils.executeSqlScript(c, new ClassPathResource("db/migration/" + file));
  }

  private long scalar(Connection c, String sql) throws Exception {
    try (var s = c.createStatement(); var r = s.executeQuery(sql)) {
      r.next();
      return r.getLong(1);
    }
  }
}
