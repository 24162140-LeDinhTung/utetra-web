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
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            
            // XỬ LÝ CHUYỂN HƯỚNG KHI LỖI
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint((request, response, authException) -> {
                    // Chưa đăng nhập -> Về trang Login
                    if (request.getRequestURI().startsWith("/vendor") || request.getRequestURI().startsWith("/admin")) {
                        response.sendRedirect(request.getContextPath() + "/auth/login");
                    } else {
                        response.sendError(401, "Unauthorized");
                    }
                })
                .accessDeniedHandler((request, response, accessDeniedException) -> {
                    // Đã đăng nhập nhưng không đủ quyền (Customer vào Vendor/Admin) -> Chuyển sang trang báo lỗi 403
                    response.sendRedirect(request.getContextPath() + "/error/403");
                })
            )

            .authorizeHttpRequests(auth -> auth
                
                // 1. CÁC TRANG CÔNG KHAI & TÀI NGUYÊN TĨNH
                .requestMatchers(
                    "/", 
                    "/WEB-INF/**",
                    "/test",
                    "/auth/**",
                    "/error",
                    "/error/**", // Mở khóa đường dẫn /error để trang báo lỗi có thể hiển thị
                    "/favicon.ico",
                    "/products", "/products/**",
                    "/shops", "/shops/**",
                    "/ws", "/ws/**", "/ws-native",
                    "/static/**", "/css/**", "/js/**", "/images/**", "/fonts/**"
                ).permitAll()

                // 2. CÁC API CÔNG KHAI
                .requestMatchers(
                    "/api/auth/**",
                    "/api/products/**",
                    "/api/shops/**",
                    "/api/categories/**",
                    "/api/users/*/public",
                    "/api/payment/vnpay/ipn", 
                    "/api/payment/momo/ipn"
                ).permitAll()

                // 3. SIẾT CHẶT QUYỀN TRUY CẬP
                .requestMatchers("/vendor/**", "/api/vendor/**").hasAnyAuthority("ROLE_VENDOR", "ROLE_ADMIN")
                .requestMatchers("/admin/**", "/api/admin/**").hasAuthority("ROLE_ADMIN")
                .requestMatchers("/customer/**", "/api/customer/**").hasAnyAuthority("ROLE_CUSTOMER", "ROLE_VENDOR", "ROLE_ADMIN")
                .requestMatchers("/api/payment/vnpay", "/api/payment/momo").authenticated()

                // 4. CÁC REQUEST KHÁC PHẢI ĐĂNG NHẬP
                .anyRequest().authenticated()
            )
            .authenticationProvider(authenticationProvider())
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}