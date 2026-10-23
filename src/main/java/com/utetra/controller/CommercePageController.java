package com.utetra.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class CommercePageController {
  @GetMapping("/customer/cart")
  public String page0() {
    return "customer/cart";
  }

  @GetMapping("/customer/checkout")
  public String page1() {
    return "customer/checkout";
  }

  @GetMapping("/customer/payment")
  public String page2() {
    return "customer/payment";
  }

  @GetMapping("/customer/orders")
  public String page3() {
    return "customer/order-history";
  }

  @GetMapping("/customer/orders/{id}")
  public String page4() {
    return "customer/order-detail";
  }

  @GetMapping("/customer/review")
  public String page5() {
    return "customer/review-form";
  }

  @GetMapping("/vendor/products")
  public String page6() {
    return "vendor/product-list";
  }

  @GetMapping("/vendor/product-form")
  public String page7() {
    return "vendor/product-form";
  }

  @GetMapping("/vendor/orders")
  public String page8() {
    return "vendor/order-list";
  }

  @GetMapping("/vendor/orders/{id}")
  public String page9() {
    return "vendor/order-detail";
  }

  @GetMapping("/vendor/vouchers")
  public String page10() {
    return "vendor/voucher-list";
  }

  @GetMapping("/vendor/promotions")
  public String page11() {
    return "vendor/promotion-list";
  }

  @GetMapping("/admin/categories")
  public String page12() {
    return "admin/category-list";
  }

  @GetMapping("/admin/category-form")
  public String page13() {
    return "admin/category-form";
  }

  @GetMapping("/admin/attributes")
  public String page14() {
    return "admin/attribute-list";
  }

  @GetMapping("/admin/attribute-form")
  public String page15() {
    return "admin/attribute-form";
  }
}
