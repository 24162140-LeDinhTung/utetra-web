package com.utetra.config;

import org.sitemesh.builder.SiteMeshFilterBuilder;
import org.sitemesh.config.ConfigurableSiteMeshFilter;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;

@Configuration
public class SitemeshConfig {

  @Bean
  public FilterRegistrationBean<ConfigurableSiteMeshFilter> siteMeshFilter() {
    FilterRegistrationBean<ConfigurableSiteMeshFilter> filter = new FilterRegistrationBean<>();

    filter.setFilter(
        new ConfigurableSiteMeshFilter() {
          @Override
          protected void applyCustomConfiguration(SiteMeshFilterBuilder builder) {
            builder
                // 1. Cấu hình riêng cho Vendor và Admin (Phải đặt lên đầu)
                .addDecoratorPath("/vendor/*", "vendor-decorator.jsp")
                .addDecoratorPath("/admin/*", "admin-decorator.jsp")
                
                // 2. Cấu hình cho Auth (Đăng nhập/Đăng ký)
                .addDecoratorPath("/auth/*", "auth-decorator.jsp")
                
                // 3. Cấu hình mặc định cho Khách/Customer (Phải đặt ở dưới cùng)
                .addDecoratorPath("/*", "main-decorator.jsp")
                
                // 4. Loại trừ các đường dẫn không cần giao diện
                .addExcludedPath("/api/*")
                .addExcludedPath("/ws/*")
                .addExcludedPath("/ws-native")
                .addExcludedPath("/WEB-INF/*")
                .addExcludedPath("/static/*")
                .addExcludedPath("/css/**")
                .addExcludedPath("/js/**")
                .addExcludedPath("/images/**")
                .addExcludedPath("/error");
          }
        });

    filter.addUrlPatterns("/*");
    filter.setOrder(Ordered.HIGHEST_PRECEDENCE);
    return filter;
  }
}