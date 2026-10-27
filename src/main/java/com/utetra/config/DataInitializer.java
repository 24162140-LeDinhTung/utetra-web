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
        // 1. Tạo user test (Customer)
        if (userRepository.findByEmail("test@gmail.com").isEmpty()) {
            User user = new User();
            user.setEmail("test@gmail.com");
            user.setPassword(passwordEncoder.encode("123456")); // Password là: 123456
            user.setFullName("Người Dùng Test");
            user.setStatus(UserStatus.ACTIVE); // Kích hoạt sẵn
            user.setEmailVerified(true);

            Role role = roleRepository.findByName(RoleName.ROLE_CUSTOMER)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy Role CUSTOMER"));
            user.getRoles().add(role);

            userRepository.save(user);
            log.info("✅ Đã tạo user test: test@gmail.com / 123456");
        }

        // 2. Tạo tài khoản Admin (Phần C)
        if (userRepository.findByEmail("admin@utetra.com").isEmpty()) {
            User admin = new User();
            admin.setEmail("admin@utetra.com");
            admin.setPassword(passwordEncoder.encode("123456")); // Password là: 123456
            admin.setFullName("Quản Trị Viên");
            admin.setStatus(UserStatus.ACTIVE); 
            admin.setEmailVerified(true);

            Role roleAdmin = roleRepository.findByName(RoleName.ROLE_ADMIN)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy Role ADMIN"));
            admin.getRoles().add(roleAdmin);

            userRepository.save(admin);
            log.info("✅ Đã tạo tài khoản Admin: admin@utetra.com / 123456");
        }
    }
}