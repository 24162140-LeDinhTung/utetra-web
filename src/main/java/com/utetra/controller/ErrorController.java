package com.utetra.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ErrorController {

    @GetMapping("/error/403")
    public String accessDenied(Model model) {
        model.addAttribute("errorTitle", "Truy cập bị từ chối");
        model.addAttribute("errorMessage", "Người dùng không được phép truy cập vào khu vực này. Vui lòng kiểm tra lại tài khoản của bạn!");
        return "error/403"; // Trả về file /WEB-INF/views/error/403.jsp
    }
}