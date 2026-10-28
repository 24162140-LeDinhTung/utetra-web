package com.utetra.controller.admin;

import com.utetra.enums.OrderStatus;
import com.utetra.repository.OrderRepository;
import com.utetra.repository.ShopRepository;
import com.utetra.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin/dashboard")
public class AdminDashboardController {

    @Autowired private UserRepository userRepository;
    @Autowired private ShopRepository shopRepository;
    @Autowired private OrderRepository orderRepository;

    @GetMapping
    public String dashboard(Model model) {
        // 1. Đếm tổng số lượng
        long totalUsers = userRepository.count();
        long totalShops = shopRepository.count();
        long totalOrders = orderRepository.count();
        
        // 2. Tính tổng doanh thu thật (Đã trừ phí ship)
        BigDecimal totalRevenue = orderRepository.calculateTotalRevenue(OrderStatus.DELIVERED);
        if (totalRevenue == null) totalRevenue = BigDecimal.ZERO;

        // 3. Lấy dữ liệu biểu đồ thật từ Database
        List<Object[]> monthlyResults = orderRepository.getMonthlyRevenueCurrentYear();
        
        // Tạo Map để gán giá trị cho đủ 12 tháng (tháng nào không có đơn thì bằng 0)
        Map<Integer, BigDecimal> revenueMap = new HashMap<>();
        for (int i = 1; i <= 12; i++) {
            revenueMap.put(i, BigDecimal.ZERO);
        }
        
        // Đổ dữ liệu từ DB vào Map
        for (Object[] row : monthlyResults) {
            Integer month = ((Number) row[0]).intValue();
            BigDecimal revenue = (BigDecimal) row[1];
            revenueMap.put(month, revenue);
        }

        // Chuyển Map thành 2 List để gửi sang JSP vẽ biểu đồ
        List<String> chartLabels = new ArrayList<>();
        List<BigDecimal> chartData = new ArrayList<>();
        for (int i = 1; i <= 12; i++) {
            chartLabels.add("Tháng " + i);
            chartData.add(revenueMap.get(i));
        }

        // Đưa dữ liệu ra View
        model.addAttribute("totalUsers", totalUsers);
        model.addAttribute("totalShops", totalShops);
        model.addAttribute("totalOrders", totalOrders);
        model.addAttribute("totalRevenue", totalRevenue);
        model.addAttribute("chartLabels", chartLabels);
        model.addAttribute("chartData", chartData);

        return "admin/dashboard"; 
    }
}