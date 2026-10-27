package com.utetra.controller.auth;

import org.springframework.stereotype.Controller;
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
}