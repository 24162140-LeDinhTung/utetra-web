package com.utetra.controller.guest;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
public class HomeController {

    @GetMapping("/")
    public String home() {
        return "guest/home";
    }

    @GetMapping("/products")
    public String productList() {
        return "guest/product-list";
    }

    @GetMapping("/products/{id}")
    public String productDetail(@PathVariable Long id) {
        return "guest/product-detail";
    }
}