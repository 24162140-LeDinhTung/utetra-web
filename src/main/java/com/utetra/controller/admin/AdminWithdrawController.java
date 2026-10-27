package com.utetra.controller.admin;

import com.utetra.entity.WithdrawRequest;
import com.utetra.service.WithdrawService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/admin/withdraw")
public class AdminWithdrawController {

    @Autowired
    private WithdrawService withdrawService;

    // 1. Danh sách yêu cầu chờ duyệt
    @GetMapping
    public String listRequests(Model model) {
        List<WithdrawRequest> requests = withdrawService.getPendingRequests();
        model.addAttribute("requests", requests);
        return "admin/withdraw-list";
    }

    // 2. Duyệt yêu cầu
    @GetMapping("/approve/{id}")
    public String approve(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        try {
            withdrawService.approveWithdraw(id);
            redirectAttributes.addFlashAttribute("message", "Đã duyệt yêu cầu rút tiền!");
        } catch (RuntimeException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/admin/withdraw";
    }

    // 3. Từ chối yêu cầu
    @GetMapping("/reject/{id}")
    public String reject(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        try {
            withdrawService.rejectWithdraw(id);
            redirectAttributes.addFlashAttribute("message", "Đã từ chối yêu cầu và hoàn tiền!");
        } catch (RuntimeException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/admin/withdraw";
    }
}