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
        
        filter.setFilter(new ConfigurableSiteMeshFilter() {
            @Override
            protected void applyCustomConfiguration(SiteMeshFilterBuilder builder) {
                // Sửa lại đường dẫn: CHỈ GIỮ LẠI TÊN FILE, bỏ đi phần /WEB-INF/decorators/
                builder.addDecoratorPath("/*", "main-decorator.jsp")
                       .addDecoratorPath("/auth/*", "auth-decorator.jsp")
                       .addExcludedPath("/static/**")
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