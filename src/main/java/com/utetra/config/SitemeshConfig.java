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
            // Decorate HTML only; leave API and WebSocket responses untouched.
            builder
                .addDecoratorPath("/*", "main-decorator.jsp")
                .addDecoratorPath("/auth/*", "auth-decorator.jsp")
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
    // Bắt buộc phải set Order cao nhất để Sitemesh chạy trước Spring Security
    filter.setOrder(Ordered.HIGHEST_PRECEDENCE);
    return filter;
  }
}
