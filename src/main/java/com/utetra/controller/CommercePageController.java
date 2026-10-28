package com.utetra.controller;

import com.utetra.entity.*;
import com.utetra.repository.*;
import com.utetra.service.ShopService;
import com.utetra.service.WalletService; // Thêm import này
import com.utetra.enums.DiscountType;
import com.utetra.enums.PromotionType;
import com.utetra.enums.VoucherType;
import com.utetra.enums.ProductStatus;
import com.utetra.enums.OrderStatus;
import com.utetra.enums.PaymentStatus;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Controller
public class CommercePageController {

  @Autowired private UserRepository userRepository;
  @Autowired private ShopService shopService;
  @Autowired private ProductRepository productRepository;
  @Autowired private CategoryRepository categoryRepository;
  @Autowired private VoucherRepository voucherRepository; 
  @Autowired private PromotionRepository promotionRepository;
  @Autowired private OrderRepository orderRepository;
  @Autowired private OrderItemRepository orderItemRepository;
  
  // Thêm WalletService để xử lý cộng tiền
  @Autowired private WalletService walletService;

  // ... (Các hàm page0 -> page5 giữ nguyên) ...
  @GetMapping("/customer/cart")
  public String page0() { return "customer/cart"; }
  @GetMapping("/customer/checkout")
  public String page1() { return "customer/checkout"; }
  @GetMapping("/customer/payment")
  public String page2() { return "customer/payment"; }
  @GetMapping("/customer/orders")
  public String page3() { return "customer/order-history"; }
  
  @GetMapping("/customer/orders/{id}")
  @org.springframework.transaction.annotation.Transactional(readOnly = true)
  public String page4(@PathVariable Long id, Authentication authentication, Model model) {
      // 1. Kiểm tra đăng nhập
      if (authentication == null || !authentication.isAuthenticated() || authentication.getPrincipal().equals("anonymousUser")) {
          return "redirect:/auth/login";
      }
      
      User customer = userRepository.findByEmail(authentication.getName()).orElse(null);
      if (customer == null) return "redirect:/auth/login";

      // 2. Lấy thông tin đơn hàng
      Order order = orderRepository.findById(id).orElse(null);
      
      // 3. Bảo mật: Khách hàng chỉ được xem đơn của chính mình
      if (order == null || !order.getUser().getId().equals(customer.getId())) {
          return "redirect:/customer/orders"; 
      }

      // 4. Lấy danh sách món trong đơn
      List<OrderItem> items = orderItemRepository.findByOrderId(id);

      // 5. Truyền dữ liệu sang JSP
      model.addAttribute("order", order);
      model.addAttribute("items", items);

      return "customer/order-detail";
  }
  
  @GetMapping("/customer/review")
  public String page5() { return "customer/review-form"; }

  @GetMapping("/vendor/products")
  public String page6(@RequestParam(required = false) Long shopId, Authentication authentication, Model model) {
      if (authentication == null || !authentication.isAuthenticated() || authentication.getPrincipal().equals("anonymousUser")) return "redirect:/auth/login";
      User owner = userRepository.findByEmail(authentication.getName()).orElse(null);
      if (owner == null) return "redirect:/auth/login";
      List<Shop> shops = shopService.getShopsByOwner(owner.getId());
      if (shops.isEmpty()) return "redirect:/vendor/my-shops?error=noShop";
      Long currentShopId = (shopId != null) ? shopId : shops.get(0).getId();
      model.addAttribute("shops", shops);
      model.addAttribute("selectedShopId", currentShopId);
      List<Product> shopProducts = productRepository.findAll().stream()
              .filter(p -> p.getShop().getId().equals(currentShopId) && !p.getIsDeleted()).toList();
      model.addAttribute("products", shopProducts);
      return "vendor/product-list";
  }

  @GetMapping("/vendor/product-form")
  public String page7(@RequestParam Long shopId, @RequestParam(required = false) Long id, Model model) {
      model.addAttribute("categories", categoryRepository.findAll());
      model.addAttribute("shopId", shopId);
      model.addAttribute("product", (id != null) ? productRepository.findById(id).orElse(null) : new Product());
      return "vendor/product-form";
  }

  @PostMapping("/vendor/product-form/save")
  public String saveProduct(@RequestParam(required = false) Long id, @RequestParam Long shopId, @RequestParam String name, @RequestParam BigDecimal price, @RequestParam Integer stock, @RequestParam Long categoryId, @RequestParam(required = false) String description, Authentication authentication) {
      User owner = userRepository.findByEmail(authentication.getName()).orElse(null);
      if (owner == null) return "redirect:/auth/login";
      Shop shop = shopService.getShopById(shopId);
      Category category = categoryRepository.findById(categoryId).orElse(null);
      Product product;
      if (id != null) {
          product = productRepository.findById(id).orElseThrow();
      } else {
          product = new Product();
          product.setShop(shop);
          product.setSoldCount(0);
          product.setIsDeleted(false);
          product.setStatus(ProductStatus.PENDING);
          product.setCreatedAt(LocalDateTime.now());
          product.setSlug(name.toLowerCase().replaceAll("[^a-z0-9]", "-") + "-" + System.currentTimeMillis());
      }
      product.setCategory(category);
      product.setName(name);
      product.setPrice(price);
      product.setStock(stock);
      product.setDescription(description);
      product.setUpdatedAt(LocalDateTime.now());
      productRepository.save(product);
      return "redirect:/vendor/products?shopId=" + shopId;
  }

  @PostMapping("/vendor/product/delete")
  public String deleteProduct(@RequestParam Long id, @RequestParam Long shopId) {
      Product product = productRepository.findById(id).orElse(null);
      if (product != null) { product.setIsDeleted(true); productRepository.save(product); }
      return "redirect:/vendor/products?shopId=" + shopId;
  }

  @GetMapping("/vendor/orders")
  public String page8(@RequestParam(required = false) Long shopId, Authentication authentication, Model model) {
      if (authentication == null || !authentication.isAuthenticated() || authentication.getPrincipal().equals("anonymousUser")) return "redirect:/auth/login";
      User owner = userRepository.findByEmail(authentication.getName()).orElse(null);
      if (owner == null) return "redirect:/auth/login";
      
      List<Shop> shops = shopService.getShopsByOwner(owner.getId());
      if (shops.isEmpty()) return "redirect:/vendor/my-shops?error=noShop";
      
      Long currentShopId = (shopId != null) ? shopId : shops.get(0).getId();
      model.addAttribute("shops", shops);
      model.addAttribute("selectedShopId", currentShopId);

      List<Order> orders = orderRepository.findByShopIdWithUser(currentShopId);
      model.addAttribute("orders", orders);

      return "vendor/order-list";
  }

  //=== SỬA LẠI HÀM PAGE 9 ĐỂ LẤY CHI TIẾT ĐƠN HÀNG ===
  @GetMapping("/vendor/orders/{id}")
  public String page9(@PathVariable Long id, Model model) {
      Order order = orderRepository.findByIdWithUserAndShop(id).orElse(null);
      if (order == null) return "redirect:/vendor/orders";

      List<OrderItem> items = orderItemRepository.findByOrderId(id);
      model.addAttribute("order", order);
      model.addAttribute("items", items);

      OrderStatus nextStatus = null;
      if (order.getStatus() == OrderStatus.NEW) nextStatus = OrderStatus.CONFIRMED;
      else if (order.getStatus() == OrderStatus.CONFIRMED) nextStatus = OrderStatus.PICKED_UP;
      else if (order.getStatus() == OrderStatus.PICKED_UP) nextStatus = OrderStatus.SHIPPING;
      else if (order.getStatus() == OrderStatus.SHIPPING) nextStatus = OrderStatus.DELIVERED;

      model.addAttribute("nextStatus", nextStatus);
      return "vendor/order-detail";
  }

  // === THÊM HÀM XỬ LÝ CẬP NHẬT TRẠNG THÁI ===
  @PostMapping("/vendor/orders/{id}/update-status")
  public String updateOrderStatus(@PathVariable Long id, 
                                  @RequestParam String newStatus,
                                  RedirectAttributes redirectAttributes) {
      Order order = orderRepository.findById(id).orElse(null);
      if (order == null) return "redirect:/vendor/orders";

      OrderStatus current = order.getStatus();
      OrderStatus next = OrderStatus.valueOf(newStatus);

      boolean isValid = false;
      if (current == OrderStatus.NEW && next == OrderStatus.CONFIRMED) isValid = true;
      else if (current == OrderStatus.CONFIRMED && next == OrderStatus.PICKED_UP) isValid = true;
      else if (current == OrderStatus.PICKED_UP && next == OrderStatus.SHIPPING) isValid = true;
      else if (current == OrderStatus.SHIPPING && next == OrderStatus.DELIVERED) isValid = true;

      if (isValid) {
          order.setStatus(next);
          order.setPaymentStatus(PaymentStatus.SUCCESS);
          order.setUpdatedAt(LocalDateTime.now());
          orderRepository.save(order);

          // === BỔ SUNG: CỘNG TIỀN VÀO VÍ KHI ĐƠN HÀNG GIAO THÀNH CÔNG ===
          if (next == OrderStatus.DELIVERED) {
              // Tính doanh thu thực nhận: Tổng tiền - Phí ship
              BigDecimal revenue = order.getTotalAmount().subtract(order.getShippingFee());
              
              // Tránh trường hợp doanh thu âm
              if (revenue.compareTo(BigDecimal.ZERO) < 0) {
                  revenue = BigDecimal.ZERO;
              }

              // Gọi service cộng tiền vào ví của Shop
              walletService.addMoney(order.getShop().getId(), revenue, "Thu nhập từ đơn hàng " + order.getOrderCode());
          }
          // ===============================================================

          redirectAttributes.addFlashAttribute("message", "Cập nhật trạng thái thành công!");
      } else {
          redirectAttributes.addFlashAttribute("error", "Lỗi: Không thể nhảy cóc trạng thái hoặc lùi trạng thái!");
      }

      return "redirect:/vendor/orders/" + id;
  }

  // ... (Các hàm Voucher, Promotion, Admin giữ nguyên) ...
  @GetMapping("/vendor/vouchers")
  public String page10(@RequestParam(required = false) Long shopId, @RequestParam(required = false) Long editId, Authentication authentication, Model model) {
      if (authentication == null || !authentication.isAuthenticated() || authentication.getPrincipal().equals("anonymousUser")) return "redirect:/auth/login";
      User owner = userRepository.findByEmail(authentication.getName()).orElse(null);
      if (owner == null) return "redirect:/auth/login";
      List<Shop> shops = shopService.getShopsByOwner(owner.getId());
      if (shops.isEmpty()) return "redirect:/vendor/my-shops?error=noShop";
      Long currentShopId = (shopId != null) ? shopId : shops.get(0).getId();
      model.addAttribute("shops", shops);
      model.addAttribute("selectedShopId", currentShopId);
      List<Voucher> vouchers = voucherRepository.findAll().stream()
              .filter(v -> v.getShop() != null && v.getShop().getId().equals(currentShopId) && !v.getIsDeleted()).toList();
      model.addAttribute("vouchers", vouchers);
      if (editId != null) { model.addAttribute("editVoucher", voucherRepository.findById(editId).orElse(null)); }
      return "vendor/voucher-list"; 
  }

  @PostMapping("/vendor/voucher/save")
  public String saveVoucher(@RequestParam(required = false) Long id, @RequestParam Long shopId, @RequestParam String code, @RequestParam String voucherType, @RequestParam String discountType, @RequestParam BigDecimal discountValue, @RequestParam(required = false) BigDecimal minOrderAmount, @RequestParam(required = false) BigDecimal maxDiscountAmount, @RequestParam(required = false) Integer usageLimit, @RequestParam String startDate, @RequestParam String endDate) {
      Voucher voucher;
      if (id != null) {
          voucher = voucherRepository.findById(id).orElseThrow();
      } else {
          voucher = new Voucher();
          voucher.setShop(shopService.getShopById(shopId));
          voucher.setUsedCount(0);
          voucher.setIsDeleted(false);
          voucher.setCreatedAt(LocalDateTime.now());
      }
      voucher.setCode(code);
      voucher.setVoucherType(VoucherType.valueOf(voucherType));
      voucher.setDiscountType(DiscountType.valueOf(discountType));
      voucher.setDiscountValue(discountValue);
      voucher.setMinOrderAmount(minOrderAmount != null ? minOrderAmount : BigDecimal.ZERO);
      voucher.setMaxDiscountAmount(maxDiscountAmount);
      voucher.setUsageLimit(usageLimit);
      voucher.setStartDate(LocalDateTime.parse(startDate));
      voucher.setEndDate(LocalDateTime.parse(endDate));
      voucher.setUpdatedAt(LocalDateTime.now());
      voucherRepository.save(voucher);
      return "redirect:/vendor/vouchers?shopId=" + shopId;
  }

  @PostMapping("/vendor/voucher/delete")
  public String deleteVoucher(@RequestParam Long id, @RequestParam Long shopId) {
      Voucher voucher = voucherRepository.findById(id).orElse(null);
      if (voucher != null) { voucher.setIsDeleted(true); voucherRepository.save(voucher); }
      return "redirect:/vendor/vouchers?shopId=" + shopId;
  }

  @GetMapping("/vendor/promotions")
  public String page11(@RequestParam(required = false) Long shopId, @RequestParam(required = false) Long editId, Authentication authentication, Model model) {
      if (authentication == null || !authentication.isAuthenticated() || authentication.getPrincipal().equals("anonymousUser")) return "redirect:/auth/login";
      User owner = userRepository.findByEmail(authentication.getName()).orElse(null);
      if (owner == null) return "redirect:/auth/login";
      List<Shop> shops = shopService.getShopsByOwner(owner.getId());
      if (shops.isEmpty()) return "redirect:/vendor/my-shops?error=noShop";
      Long currentShopId = (shopId != null) ? shopId : shops.get(0).getId();
      model.addAttribute("shops", shops);
      model.addAttribute("selectedShopId", currentShopId);
      List<Promotion> promotions = promotionRepository.findAll().stream()
              .filter(p -> p.getShop() != null && p.getShop().getId().equals(currentShopId) && !p.getIsDeleted()).toList();
      model.addAttribute("promotions", promotions);
      if (editId != null) { model.addAttribute("editPromotion", promotionRepository.findById(editId).orElse(null)); }
      return "vendor/promotion-list"; 
  }

  @PostMapping("/vendor/promotion/save")
  public String savePromotion(@RequestParam(required = false) Long id, @RequestParam Long shopId, @RequestParam String name, @RequestParam String promotionType, @RequestParam String discountType, @RequestParam BigDecimal discountValue, @RequestParam String startDate, @RequestParam String endDate) {
      Promotion promotion;
      if (id != null) {
          promotion = promotionRepository.findById(id).orElseThrow();
      } else {
          promotion = new Promotion();
          promotion.setShop(shopService.getShopById(shopId));
          promotion.setIsDeleted(false);
          promotion.setCreatedAt(LocalDateTime.now());
      }
      promotion.setName(name);
      promotion.setPromotionType(PromotionType.valueOf(promotionType));
      promotion.setDiscountType(DiscountType.valueOf(discountType));
      promotion.setDiscountValue(discountValue);
      promotion.setStartDate(LocalDateTime.parse(startDate));
      promotion.setEndDate(LocalDateTime.parse(endDate));
      promotion.setUpdatedAt(LocalDateTime.now());
      promotionRepository.save(promotion);
      return "redirect:/vendor/promotions?shopId=" + shopId;
  }

  @PostMapping("/vendor/promotion/delete")
  public String deletePromotion(@RequestParam Long id, @RequestParam Long shopId) {
      Promotion promotion = promotionRepository.findById(id).orElse(null);
      if (promotion != null) { promotion.setIsDeleted(true); promotionRepository.save(promotion); }
      return "redirect:/vendor/promotions?shopId=" + shopId;
  }

  @GetMapping("/admin/categories")
  public String page12(Model model) {
      model.addAttribute("categories", categoryRepository.findAll());
      return "admin/category-list";
  }
  @GetMapping("/admin/category-form")
  public String page13(@RequestParam(required = false) Long id, Model model) {
      model.addAttribute("category", (id != null) ? categoryRepository.findById(id).orElse(null) : new Category());
      model.addAttribute("parentCategories", categoryRepository.findAll());
      return "admin/category-form";
  }
  @PostMapping("/admin/category-form/save")
  public String saveCategory(@RequestParam(required = false) Long id, @RequestParam String name) {
      Category category = (id != null) ? categoryRepository.findById(id).orElseThrow() : new Category();
      if (id == null) category.setSlug(name.toLowerCase().replaceAll("[^a-z0-9]", "-") + "-" + System.currentTimeMillis());
      category.setName(name);
      categoryRepository.save(category);
      return "redirect:/admin/categories";
  }
  @PostMapping("/admin/category/delete")
  public String deleteCategory(@RequestParam Long id) {
      try { categoryRepository.deleteById(id); } catch (Exception e) {}
      return "redirect:/admin/categories";
  }
  
  @GetMapping("/admin/attributes")
  public String page14() { return "admin/attribute-list"; }
  @GetMapping("/admin/attribute-form")
  public String page15() { return "admin/attribute-form"; }
}