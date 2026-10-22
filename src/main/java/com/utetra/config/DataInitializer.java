package com.utetra.config;

import com.utetra.entity.Role;
import com.utetra.entity.User;
import com.utetra.enums.RoleName;
import com.utetra.enums.UserStatus;
import com.utetra.repository.RoleRepository;
import com.utetra.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        // Nếu chưa có user test thì mới tạo
        if (userRepository.findByEmail("test@gmail.com").isEmpty()) {
            User user = new User();
            user.setEmail("test@gmail.com");
            user.setPassword(passwordEncoder.encode("123456")); // Password là: 123456
            user.setFullName("Người Dùng Test");
            user.setStatus(UserStatus.ACTIVE); // Kích hoạt sẵn
            user.setEmailVerified(true);

            Role role = roleRepository.findByName(RoleName.ROLE_CUSTOMER)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy Role"));
            user.getRoles().add(role);

            userRepository.save(user);
            log.info("✅ Đã tạo user test: test@gmail.com / 123456");
        }
    }
}