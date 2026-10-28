package com.utetra.controller.auth;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/auth")
public class AuthPageController {

    @GetMapping("/login")
    public String loginPage() {
        return "auth/login"; // Trả về file /WEB-INF/views/auth/login.jsp
    }

    @GetMapping("/register")
    public String registerPage() {
        return "auth/register"; // Trả về file /WEB-INF/views/auth/register.jsp
    }

    @GetMapping("/forgot-password")
    public String forgotPasswordPage() {
        return "auth/forgot-password";
    }

    @GetMapping("/reset-password")
    public String resetPasswordPage(
            @RequestParam(required = false) String email,
            org.springframework.ui.Model model) {
        model.addAttribute("email", email != null ? email : "");
        return "auth/reset-password";
    }
}
