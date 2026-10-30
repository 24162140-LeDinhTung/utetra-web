package com.utetra;

import static org.assertj.core.api.Assertions.*;

import java.sql.DriverManager;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.init.ScriptUtils;

class CommerceMigrationTests {
  @Test
  void additiveMigrationCanRunOnFreshAndExistingTables() throws Exception {
    try (var c =
        DriverManager.getConnection(
            "jdbc:h2:mem:migration;MODE=MySQL;NON_KEYWORDS=VALUE", "sa", "")) {
      ScriptUtils.executeSqlScript(c, new ClassPathResource("db/migration/V1__init_user_auth.sql"));
      ScriptUtils.executeSqlScript(
          c, new ClassPathResource("db/migration/V2__seed_roles_and_levels.sql"));
      ScriptUtils.executeSqlScript(
          c, new ClassPathResource("db/migration/V3__commerce_part_b.sql"));
      try (var s = c.createStatement()) {
        s.executeUpdate("INSERT INTO categories(name,slug) VALUES ('test','test')");
      }
      ScriptUtils.executeSqlScript(
          c, new ClassPathResource("db/migration/V3__commerce_part_b.sql"));
      try (var s = c.createStatement();
          var r = s.executeQuery("SELECT COUNT(*) FROM categories")) {
        r.next();
        assertThat(r.getInt(1)).isEqualTo(1);
      }
    }
  }

  @Test
  void customerAddressMigrationPreservesExistingUsersAndAllowsEmptyAddress() throws Exception {
    try (var c = DriverManager.getConnection("jdbc:h2:mem:deliverymigration;MODE=MySQL", "sa", "")) {
      ScriptUtils.executeSqlScript(c, new ClassPathResource("db/migration/V1__init_user_auth.sql"));
      try (var s = c.createStatement()) {
        s.executeUpdate("INSERT INTO users(email,password,status) VALUES ('existing@test.example','hash','ACTIVE')");
      }
      ScriptUtils.executeSqlScript(c, new ClassPathResource("db/migration/V10__customer_delivery_address.sql"));
      try (var s = c.createStatement(); var r = s.executeQuery("SELECT email,shipping_address FROM users")) {
        assertThat(r.next()).isTrue(); assertThat(r.getString(1)).isEqualTo("existing@test.example");
        assertThat(r.getString(2)).isNull();
      }
    }
  }
}
