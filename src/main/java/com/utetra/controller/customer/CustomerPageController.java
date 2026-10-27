package com.utetra.controller.customer;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/customer")
public class CustomerPageController {

    @GetMapping("/profile")
    public String profilePage() {
        return "customer/profile";
    }

    @GetMapping("/favorites")
    public String favoritesPage() {
        return "customer/favorite-products";
    }
    
    @GetMapping("/history")
    public String historyPage() {
        return "customer/view-history";
    }
}