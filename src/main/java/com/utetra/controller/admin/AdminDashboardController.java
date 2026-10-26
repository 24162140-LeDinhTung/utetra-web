package com.utetra.controller.admin;

import com.utetra.repository.OrderRepository;
import com.utetra.repository.ShopRepository;
import com.utetra.repository.UserRepository;
import com.utetra.enums.ShopStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.math.BigDecimal;

@Controller
@RequestMapping("/admin/dashboard")
public class AdminDashboardController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ShopRepository shopRepository;

    @Autowired
    private OrderRepository orderRepository;

    @GetMapping
    public String dashboard(Model model) {
        // Đếm tổng số lượng
        long totalUsers = userRepository.count();
        long totalShops = shopRepository.count();
        long totalOrders = orderRepository.count();
        
        // Tạm tính tổng doanh thu (Nếu Repository có hàm tính tổng, bạn có thể thay thế)
        // Ở đây tôi đang để ví dụ giả lập doanh thu
        BigDecimal totalRevenue = BigDecimal.valueOf(15000000); // Bạn có thể viết hàm tính tổng thật sau

        // Đưa dữ liệu ra View
        model.addAttribute("totalUsers", totalUsers);
        model.addAttribute("totalShops", totalShops);
        model.addAttribute("totalOrders", totalOrders);
        model.addAttribute("totalRevenue", totalRevenue);

        return "admin/dashboard"; // Trả về file JSP
    }
}