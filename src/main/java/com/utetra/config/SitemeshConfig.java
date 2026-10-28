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
    FilterRegistrationBean<ConfigurableSiteMeshFilter> bean = new FilterRegistrationBean<>();

    bean.setFilter(
        new ConfigurableSiteMeshFilter() {
          @Override
          protected void applyCustomConfiguration(SiteMeshFilterBuilder builder) {
            builder

                // Các path API/static cũ giữ nguyên
                .addExcludedPath("/api/*")
                .addExcludedPath("/ws/*")
                .addExcludedPath("/ws-native")
                .addExcludedPath("/WEB-INF/*")
                .addExcludedPath("/static/*")
                .addExcludedPath("/css/**")
                .addExcludedPath("/js/**")
                .addExcludedPath("/images/**")
                .addExcludedPath("/error")
                .addExcludedPath("/favicon.ico")   // ⬅️ bonus: hết lỗi NoResourceFoundException

                // ============ 2. GÁN DECORATOR — thứ tự cụ thể → chung ============
                // Rule cụ thể phải đặt trước rule /* để được ưu tiên
                .addDecoratorPath("/vendor/*", "vendor-decorator.jsp")
                .addDecoratorPath("/admin/*", "admin-decorator.jsp")
                .addDecoratorPath("/auth/*", "auth-decorator.jsp")
                .addDecoratorPath("/*", "main-decorator.jsp");
          }
        });

    bean.addUrlPatterns("/*");
    bean.setOrder(Ordered.HIGHEST_PRECEDENCE);
    return bean;
  }
}