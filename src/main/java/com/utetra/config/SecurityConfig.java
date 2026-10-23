package com.utetra.config;

import com.utetra.security.CustomUserDetailsService;
import com.utetra.security.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

  private final CustomUserDetailsService userDetailsService;
  private final JwtAuthenticationFilter jwtAuthenticationFilter;

  @Bean
  public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
  }

  @Bean
  public DaoAuthenticationProvider authenticationProvider() {
    DaoAuthenticationProvider provider = new DaoAuthenticationProvider(userDetailsService);
    provider.setPasswordEncoder(passwordEncoder());
    return provider;
  }

  @Bean
  public AuthenticationManager authenticationManager(AuthenticationConfiguration config)
      throws Exception {
    return config.getAuthenticationManager();
  }

  @Bean
  public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http.csrf(csrf -> csrf.disable())
        .sessionManagement(
            session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
        .authorizeHttpRequests(
            auth ->
                auth
                    // 1. CHO PHÉP TRUY CẬP CÁC TRANG GIAO DIỆN VÀ API CÔNG KHAI
                    .requestMatchers(
                        "/",
                        "/auth/**",
                        "/error",
                        "/favicon.ico", // <-- Thêm dòng này để mở khóa trang chủ và trang đăng nhập
                        "/api/auth/**",
                        "/products",
                        "/products/**",
                        "/api/categories",
                        "/customer/cart",
                        "/customer/checkout",
                        "/customer/orders",
                        "/customer/orders/*",
                        "/customer/payment",
                        "/customer/review",
                        "/vendor/products",
                        "/vendor/product-form",
                        "/vendor/orders",
                        "/vendor/orders/*",
                        "/vendor/vouchers",
                        "/vendor/promotions",
                        "/admin/categories",
                        "/admin/category-form",
                        "/admin/attributes",
                        "/admin/attribute-form",
                        "/ws",
                        "/ws/**",
                        "/ws-native",
                        "/api/payment/vnpay/ipn",
                        "/api/payment/momo/ipn",
                        "/api/products/**",
                        "/api/shops/**",
                        "/api/users/*/public",
                        "/static/**",
                        "/css/**",
                        "/js/**",
                        "/images/**",
                        "/fonts/**",
                        "/WEB-INF/views/**",
                        "/WEB-INF/decorators/**" // <-- Thêm để cho phép load JSP
                        )
                    .permitAll()

                    // 2. PHÂN QUYỀN CHO CÁC API
                    .requestMatchers("/api/payment/vnpay", "/api/payment/momo")
                    .authenticated()
                    .requestMatchers("/api/customer/**")
                    .hasAuthority("ROLE_CUSTOMER")
                    .requestMatchers("/api/vendor/**")
                    .hasAnyAuthority("ROLE_VENDOR", "ROLE_ADMIN")
                    .requestMatchers("/api/admin/**")
                    .hasAuthority("ROLE_ADMIN")

                    // 3. CÁC REQUEST KHÁC PHẢI ĐĂNG NHẬP
                    .anyRequest()
                    .authenticated())
        .authenticationProvider(authenticationProvider())
        .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

    return http.build();
  }
}
