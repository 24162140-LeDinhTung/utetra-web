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
}
