package com.utetra;

import static org.assertj.core.api.Assertions.*;

import com.utetra.dto.request.cart.*;
import com.utetra.dto.request.order.*;
import com.utetra.dto.request.product.*;
import com.utetra.dto.request.promotion.*;
import com.utetra.dto.request.review.*;
import com.utetra.dto.request.voucher.*;
import com.utetra.dto.response.order.OrderDetailResponse;
import com.utetra.entity.*;
import com.utetra.enums.*;
import com.utetra.repository.*;
import com.utetra.security.JwtProvider;
import com.utetra.service.*;
import com.utetra.util.PaymentSignatures;
import jakarta.persistence.EntityManager;
import java.math.BigDecimal;
import java.net.URI;
import java.net.http.*;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.*;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.transaction.PlatformTransactionManager;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class CommerceIntegrationTests {
  @Autowired UserRepository users;
  @Autowired ShopRepository shops;
  @Autowired CategoryRepository categories;
  @Autowired ProductRepository products;
  @Autowired RoleRepository roles;
  @Autowired ProductService productService;
  @Autowired CartService carts;
  @Autowired OrderService orders;
  @Autowired VoucherService vouchers;
  @Autowired PromotionService promotions;
  @Autowired ReviewService reviews;
  @Autowired PaymentService payments;
  @Autowired CartItemRepository cartItems;
  @Autowired OrderRepository orderRepo;
  @Autowired ProductAttributeRepository attributes;
  @Autowired ProductAttributeValueRepository values;
  @Autowired PaymentTransactionRepository transactions;
  @Autowired OrderStatusHistoryRepository history;
  @Autowired PlatformTransactionManager txManager;
  @Autowired EntityManager em;
  @Autowired JwtProvider jwt;
  @Autowired org.springframework.core.env.ConfigurableEnvironment environment;
  @Autowired PaymentAvailability availability;
  @Autowired OrderQuoteService quotes;
  @Autowired WalletRepository wallets;
  @Autowired WalletTransactionRepository walletLedger;
  @Autowired OrderWalletSettlement settlement;
  @LocalServerPort int port;
  User customer, other, owner;
  Shop shop, shop2;
  Category category, category2;
  Product product;

  @BeforeEach
  void data() {
    customer = user(RoleName.ROLE_CUSTOMER);
    other = user(RoleName.ROLE_CUSTOMER);
    owner = user(RoleName.ROLE_VENDOR);
    shop = shop(owner, "Chi nhánh A");
    shop2 = shop(owner, "Chi nhánh B");
    category = category("Trà sữa");
    category2 = category("Trà trái cây");
    product = product(shop, category, "Trà sữa test", 20);
  }

  User user(RoleName role) {
    User u = new User();
    u.setEmail(UUID.randomUUID() + "@example.test");
    u.setPassword("unused-test-password");
    u.setFullName("Người dùng thử");
    u.setStatus(UserStatus.ACTIVE);
    u.setEmailVerified(true);
    Role r =
        roles
            .findByName(role)
            .orElseGet(
                () -> {
                  Role n = new Role();
                  n.setName(role);
                  return roles.save(n);
                });
    u.setRoles(Set.of(r));
    return users.save(u);
  }

  Shop shop(User owner, String name) {
    Shop s = new Shop();
    s.setOwner(owner);
    s.setName(name);
    s.setStatus(ShopStatus.ACTIVE);
    return shops.save(s);
  }

  Category category(String name) {
    Category c = new Category();
    c.setName(name);
    c.setSlug(UUID.randomUUID().toString());
    return categories.save(c);
  }

  Product product(Shop s, Category c, String name, int stock) {
    Product p = new Product();
    p.setShop(s);
    p.setCategory(c);
    p.setName(name);
    p.setSlug(UUID.randomUUID().toString());
    p.setPrice(BigDecimal.valueOf(30000));
    p.setStock(stock);
    p.setSoldCount(0);
    p.setStatus(ProductStatus.ACTIVE);
    return products.save(p);
  }

  void add(User u, Product p, int qty, String attrs) {
    AddToCartRequest r = new AddToCartRequest();
    r.setProductId(p.getId());
    r.setQuantity(qty);
    r.setSelectedAttributes(attrs);
    carts.addItem(u.getId(), r);
  }

  CreateOrderRequest request(Shop s, PaymentMethod method) {
    CreateOrderRequest r = new CreateOrderRequest();
    r.setShopId(s.getId());
    r.setPaymentMethod(method);
    r.setShippingAddress("Người nhận, 0900000000, số 1 đường thử");
    return r;
  }

  OrderDetailResponse buy(PaymentMethod method) {
    add(customer, product, 2, "{}");
    return orders.createOrder(customer.getId(), request(shop, method));
  }

  void advance(Long id, OrderStatus status) {
    UpdateOrderStatusRequest r = new UpdateOrderStatusRequest();
    r.setStatus(status);
    r.setNote("Cập nhật kiểm thử");
    orders.updateStatus(shop.getId(), owner.getId(), id, r);
  }

  @Test
  void searchCombinesShopCategoryKeywordAndHidesDeletedOrPending() {
    product(shop2, category, "Trà sữa test", 20);
    product(shop, category2, "Trà sữa test", 20);
    Product hidden = product(shop, category, "Trà sữa test", 20);
    hidden.setIsDeleted(true);
    products.save(hidden);
    Product pending = product(shop, category, "Trà sữa test", 20);
    pending.setStatus(ProductStatus.PENDING);
    products.save(pending);
    ProductSearchRequest r = new ProductSearchRequest();
    r.setShopId(shop.getId());
    r.setCategoryId(category.getId());
    r.setKeyword("test");
    assertThat(productService.search(r).getItems())
        .extracting("id")
        .containsExactly(product.getId());
    assertThatThrownBy(() -> productService.getDetail(pending.getId(), null))
        .isInstanceOf(com.utetra.exception.custom.ResourceNotFoundException.class);
  }

  @Test
  void homeGroupsTwelveBestSellersPerShop() {
    for (int i = 0; i < 14; i++) {
      Product p = product(shop, category, "Món " + i, 20);
      p.setSoldCount(i);
      products.save(p);
    }
    product(shop2, category, "Món shop B", 20);
    var groups = productService.getHomeShops(PageRequest.of(0, 100));
    var a = groups.stream().filter(g -> g.shopId().equals(shop.getId())).findFirst().orElseThrow();
    assertThat(a.products()).hasSize(12);
    assertThat(a.products()).allMatch(p -> p.getShopId().equals(shop.getId()));
    assertThat(a.products().getFirst().getSoldCount()).isEqualTo(13);
    assertThat(
            groups.stream()
                .filter(g -> g.shopId().equals(shop2.getId()))
                .findFirst()
                .orElseThrow()
                .products())
        .hasSize(1);
  }

  @Test
  void cartAndOrderEnforceOwnershipAndKeepOtherShop() {
    Product p2 = product(shop2, category, "Khác shop", 30);
    add(customer, product, 2, "{}");
    add(customer, p2, 3, "{}");
    Long line =
        carts.getCart(customer.getId()).stream()
            .filter(c -> c.getShopId().equals(shop.getId()))
            .findFirst()
            .orElseThrow()
            .getItems()
            .getFirst()
            .getCartItemId();
    assertThatThrownBy(() -> carts.removeItem(other.getId(), line))
        .isInstanceOf(AccessDeniedException.class);
    OrderDetailResponse o = orders.createOrder(customer.getId(), request(shop, PaymentMethod.COD));
    assertThat(o.getTotalAmount()).isEqualByComparingTo("75000");
    assertThat(products.findById(product.getId()).orElseThrow().getStock()).isEqualTo(18);
    assertThat(carts.getCart(customer.getId())).hasSize(1);
    assertThat(carts.getCart(customer.getId()).getFirst().getShopId()).isEqualTo(shop2.getId());
    assertThatThrownBy(() -> orders.getDetail(other.getId(), o.getId()))
        .isInstanceOf(AccessDeniedException.class);
    CancelOrderRequest cancel = new CancelOrderRequest();
    cancel.setReason("Đổi ý");
    assertThatThrownBy(() -> orders.cancelOrder(other.getId(), o.getId(), cancel))
        .isInstanceOf(AccessDeniedException.class);
    orders.cancelOrder(customer.getId(), o.getId(), cancel);
    assertThat(products.findById(product.getId()).orElseThrow().getStock()).isEqualTo(20);
    assertThatThrownBy(() -> orders.cancelOrder(customer.getId(), o.getId(), cancel))
        .isInstanceOf(IllegalArgumentException.class);
    assertThat(products.findById(product.getId()).orElseThrow().getStock()).isEqualTo(20);
  }

  @Test
  void vendorCannotEditOtherShopOrMoveAnotherShopOrder() {
    Shop stranger = shop(other, "Khác chủ");
    assertThatThrownBy(
            () ->
                productService.getVendorProducts(
                    stranger.getId(), owner.getId(), PageRequest.of(0, 10)))
        .isInstanceOf(AccessDeniedException.class);
    OrderDetailResponse o = buy(PaymentMethod.COD);
    UpdateOrderStatusRequest r = new UpdateOrderStatusRequest();
    r.setStatus(OrderStatus.PICKED_UP);
    assertThatThrownBy(() -> orders.updateStatus(shop2.getId(), owner.getId(), o.getId(), r))
        .isInstanceOf(AccessDeniedException.class);
    assertThat(
            orders
                .getByShop(shop.getId(), owner.getId(), null, PageRequest.of(0, 10))
                .getTotalElements())
        .isEqualTo(1);
  }

  void options() {
    ProductAttribute a = new ProductAttribute();
    a.setProduct(product);
    a.setName("Size");
    attributes.save(a);
    for (String size : List.of("M", "L")) {
      ProductAttributeValue v = new ProductAttributeValue();
      v.setAttribute(a);
      v.setProduct(product);
      v.setValue(size);
      v.setExtraPrice(size.equals("L") ? BigDecimal.valueOf(5000) : BigDecimal.ZERO);
      values.save(v);
    }
  }

  @Test
  void variantsAreValidatedAndCountAgainstSharedStock() {
    options();
    product.setStock(5);
    products.save(product);
    add(customer, product, 3, "{\"Size\":\"M\"}");
    assertThatThrownBy(() -> add(customer, product, 3, "{\"Size\":\"L\"}"))
        .isInstanceOf(IllegalArgumentException.class);
    add(customer, product, 2, "{\"Size\":\"L\"}");
    assertThat(carts.getCart(customer.getId()).getFirst().getSubtotal())
        .isEqualByComparingTo("160000");
    product.setStock(4);
    products.save(product);
    assertThatThrownBy(() -> orders.createOrder(customer.getId(), request(shop, PaymentMethod.COD)))
        .isInstanceOf(IllegalArgumentException.class);
    assertThat(carts.getCart(customer.getId()).getFirst().getItems()).hasSize(2);
    assertThat(orderRepo.findByUserId(customer.getId(), PageRequest.of(0, 10))).isEmpty();
  }

  @Test
  void concurrentOrdersCannotOversell() throws Exception {
    product.setStock(1);
    products.save(product);
    add(customer, product, 1, "{}");
    add(other, product, 1, "{}");
    ExecutorService pool = Executors.newFixedThreadPool(2);
    CountDownLatch start = new CountDownLatch(1);
    try {
      List<Future<Boolean>> results = new ArrayList<>();
      for (User u : List.of(customer, other))
        results.add(
            pool.submit(
                () -> {
                  start.await();
                  try {
                    orders.createOrder(u.getId(), request(shop, PaymentMethod.COD));
                    return true;
                  } catch (IllegalArgumentException e) {
                    return false;
                  }
                }));
      start.countDown();
      int success = 0;
      for (Future<Boolean> f : results) if (f.get(20, TimeUnit.SECONDS)) success++;
      assertThat(success).isEqualTo(1);
      assertThat(products.findById(product.getId()).orElseThrow().getStock()).isZero();
    } finally {
      pool.shutdownNow();
    }
  }


  @Test
  void voucherIsOncePerCustomerButSharedUntilGlobalLimitAndOffersRefresh() {
    String code = "MULTI" + System.nanoTime();
    var v = voucher(code, VoucherType.PRODUCT);
    v.setDiscountValue(BigDecimal.TEN); v.setUsageLimit(2);
    vouchers.save(shop.getId(), owner.getId(), null, v);
    add(customer, product, 1, "{}");
    assertThat(quotes.offers(customer.getId(), shop.getId())).anyMatch(x -> x.code().equals(code) && x.eligible());
    assertThat(quotes.offers(customer.getId(), shop2.getId())).noneMatch(x -> x.code().equals(code));
    var r = request(shop, PaymentMethod.COD); r.setVoucherCode(code);
    quotes.quote(customer.getId(), r); quotes.quote(customer.getId(), r);
    orders.createOrder(customer.getId(), r);
    add(customer, product, 1, "{}");
    assertThatThrownBy(() -> orders.createOrder(customer.getId(), r)).isInstanceOf(IllegalArgumentException.class);
    assertThat(quotes.offers(customer.getId(), shop.getId())).noneMatch(x -> x.code().equals(code));
    add(other, product, 1, "{}");
    assertThat(quotes.offers(other.getId(), shop.getId())).anyMatch(x -> x.code().equals(code));
    orders.createOrder(other.getId(), r);
    var third = user(RoleName.ROLE_CUSTOMER); add(third, product, 1, "{}");
    assertThatThrownBy(() -> orders.createOrder(third.getId(), r)).isInstanceOf(IllegalArgumentException.class);
    assertThat(quotes.offers(third.getId(), shop.getId())).noneMatch(x -> x.code().equals(code));
  }

  @Test
  void offersReflectEditingDeletionExpiryAndMinimumWithoutRestart() {
    String code = "LIVE" + System.nanoTime();
    var v = voucher(code, VoucherType.PRODUCT); v.setMinOrderAmount(new BigDecimal("50000"));
    var saved = vouchers.save(shop.getId(), owner.getId(), null, v);
    add(customer, product, 1, "{}");
    assertThat(quotes.offers(customer.getId(), shop.getId())).anyMatch(x -> x.code().equals(code) && !x.eligible());
    add(customer, product, 1, "{}");
    assertThat(quotes.offers(customer.getId(), shop.getId())).anyMatch(x -> x.code().equals(code) && x.eligible());
    v.setEndDate(LocalDateTime.now().minusMinutes(1));
    vouchers.save(shop.getId(), owner.getId(), saved.id(), v);
    assertThat(quotes.offers(customer.getId(), shop.getId())).noneMatch(x -> x.code().equals(code));
    v.setEndDate(LocalDateTime.now().plusDays(1)); vouchers.save(shop.getId(), owner.getId(), saved.id(), v);
    vouchers.delete(shop.getId(), owner.getId(), saved.id());
    assertThat(quotes.offers(customer.getId(), shop.getId())).noneMatch(x -> x.code().equals(code));
  }

  CreateVoucherRequest voucher(String code, VoucherType type) {
    CreateVoucherRequest v = new CreateVoucherRequest();
    v.setCode(code);
    v.setVoucherType(type);
    v.setDiscountType(DiscountType.FIXED);
    v.setDiscountValue(BigDecimal.valueOf(500000));
    v.setStartDate(LocalDateTime.now().minusHours(1));
    v.setEndDate(LocalDateTime.now().plusDays(1));
    return v;
  }

  @Test
  void discountsAreCappedAndVoucherCannotCrossShops() {
    String code = "SAVE" + System.nanoTime();
    vouchers.save(shop.getId(), owner.getId(), null, voucher(code, VoucherType.SHIPPING));
    add(customer, product, 1, "{}");
    CreateOrderRequest r = request(shop, PaymentMethod.COD);
    r.setVoucherCode(code);
    var o = orders.createOrder(customer.getId(), r);
    assertThat(o.getShippingFee()).isEqualByComparingTo("0");
    assertThat(o.getTotalAmount()).isEqualByComparingTo("30000");
    Product p2 = product(shop2, category, "Shop khác", 10);
    add(other, p2, 1, "{}");
    CreateOrderRequest wrong = request(shop2, PaymentMethod.COD);
    wrong.setVoucherCode(code);
    assertThatThrownBy(() -> orders.createOrder(other.getId(), wrong))
        .isInstanceOf(IllegalArgumentException.class);
  }

  @Test
  void promotionChangesServerPriceOnlyForItsProducts() {
    CreatePromotionRequest r = new CreatePromotionRequest();
    r.setName("Giảm 10%");
    r.setPromotionType(PromotionType.PERCENT);
    r.setDiscountType(DiscountType.PERCENT);
    r.setDiscountValue(BigDecimal.TEN);
    r.setStartDate(LocalDateTime.now().minusHours(1));
    r.setEndDate(LocalDateTime.now().plusDays(1));
    r.setProductIds(List.of(product.getId()));
    promotions.save(shop.getId(), owner.getId(), null, r);
    add(customer, product, 1, "{}");
    assertThat(carts.getCart(customer.getId()).getFirst().getSubtotal())
        .isEqualByComparingTo("27000");
  }

  @Test
  void reviewRequiresDeliveredPurchaseAndMedia() {
    var o = buy(PaymentMethod.COD);
    CreateReviewRequest r = new CreateReviewRequest();
    r.setOrderId(o.getId());
    r.setProductId(product.getId());
    r.setRating(5);
    r.setComment("Trà sữa thơm ngon, đóng gói cẩn thận và giao đúng món đã chọn.");
    r.setMediaUrls(List.of("https://res.cloudinary.com/test/image/upload/review.jpg"));
    assertThatThrownBy(() -> reviews.create(customer.getId(), r))
        .isInstanceOf(IllegalArgumentException.class);
    advance(o.getId(), OrderStatus.PICKED_UP);
    advance(o.getId(), OrderStatus.SHIPPING);
    advance(o.getId(), OrderStatus.DELIVERED);
    assertThat(reviews.create(customer.getId(), r).getRating()).isEqualTo(5);
    assertThatThrownBy(() -> reviews.create(customer.getId(), r))
        .isInstanceOf(IllegalArgumentException.class);
  }

  Map<String, String> vnpay(String reference, String amount) {
    Map<String, String> p = new HashMap<>();
    p.put("vnp_TxnRef", reference);
    p.put("vnp_TmnCode", "TESTSHOP");
    p.put("vnp_Amount", amount);
    p.put("vnp_ResponseCode", "00");
    p.put("vnp_TransactionStatus", "00");
    p.put("vnp_TransactionNo", "999");
    p.put(
        "vnp_SecureHash",
        PaymentSignatures.hmac("HmacSHA512", "test-vnpay-secret", PaymentSignatures.vnpay(p)));
    return p;
  }

  @Test
  void vnpayRejectsTamperingWrongAmountAndDuplicateCallback() {
    var o = buy(PaymentMethod.VNPAY);
    assertThatThrownBy(
            () -> payments.start(other.getId(), o.getId(), PaymentMethod.VNPAY, "127.0.0.1"))
        .isInstanceOf(AccessDeniedException.class);
    var started = payments.start(customer.getId(), o.getId(), PaymentMethod.VNPAY, "127.0.0.1");
    String ref = started.get("reference");
    assertThat(
            payments
                .start(customer.getId(), o.getId(), PaymentMethod.VNPAY, "127.0.0.1")
                .get("reference"))
        .isEqualTo(ref);
    assertThat(wallets.findByShopId(shop.getId())).isEmpty();
    var bad = vnpay(ref, "7500000");
    bad.put("vnp_Amount", "1");
    assertThat(payments.vnpayCallback(bad).get("RspCode")).isEqualTo("97");
    assertThat(payments.vnpayCallback(vnpay(ref, "1")).get("RspCode")).isEqualTo("04");
    assertThat(payments.vnpayCallback(vnpay(ref, "7500000")).get("RspCode")).isEqualTo("00");
    assertThat(wallets.findByShopId(shop.getId()).orElseThrow().getBalance()).isEqualByComparingTo("60000");
    int count = history.findByOrderId(o.getId()).size();
    assertThat(payments.vnpayCallback(vnpay(ref, "7500000")).get("RspCode")).isEqualTo("02");
    assertThat(history.findByOrderId(o.getId())).hasSize(count);
    assertThat(wallets.findByShopId(shop.getId()).orElseThrow().getBalance()).isEqualByComparingTo("60000");
    advance(o.getId(), OrderStatus.PICKED_UP);
    advance(o.getId(), OrderStatus.SHIPPING);
    advance(o.getId(), OrderStatus.DELIVERED);
    assertThat(wallets.findByShopId(shop.getId()).orElseThrow().getBalance()).isEqualByComparingTo("60000");
  }

  @Test
  void latePaymentDoesNotReopenCancelledOrder() {
    var o = buy(PaymentMethod.VNPAY);
    String ref =
        payments
            .start(customer.getId(), o.getId(), PaymentMethod.VNPAY, "127.0.0.1")
            .get("reference");
    CancelOrderRequest cancel = new CancelOrderRequest();
    cancel.setReason("Hủy trước thanh toán");
    orders.cancelOrder(customer.getId(), o.getId(), cancel);
    payments.vnpayCallback(vnpay(ref, "7500000"));
    var finalOrder = orders.getDetail(customer.getId(), o.getId());
    assertThat(finalOrder.getStatus()).isEqualTo("CANCELLED");
    assertThat(finalOrder.getPaymentStatus()).isEqualTo("SUCCESS");
    assertThat(wallets.findByShopId(shop.getId())).isEmpty();
    assertThat(products.findById(product.getId()).orElseThrow().getStock()).isEqualTo(20);
  }

  HttpResponse<String> get(String path, String token) throws Exception {
    HttpRequest.Builder req = HttpRequest.newBuilder(URI.create("http://localhost:" + port + path));
    if (token != null) req.header("Authorization", "Bearer " + token);
    return HttpClient.newHttpClient().send(req.build(), HttpResponse.BodyHandlers.ofString());
  }

  @Test
  void httpUsesJwtIdentityAndRejectsForeignOrder() throws Exception {
    var o = buy(PaymentMethod.COD);
    String token = jwt.generateAccessToken(other.getId(), other.getEmail());
    assertThat(
            get("/api/customer/orders/" + o.getId() + "?userId=" + customer.getId(), token)
                .statusCode())
        .isEqualTo(403);
    assertThat(get("/api/customer/cart", null).statusCode()).isIn(401, 403);
    var p = get("/api/products?shopId=" + shop.getId(), null);
    assertThat(p.statusCode()).isEqualTo(200);
    assertThat(p.body()).contains("shopId").doesNotContain("<!DOCTYPE");
  }

  @Test
  void jspPagesAndStaticClientAreServed() throws Exception {
    User admin = user(RoleName.ROLE_ADMIN);
    String adminToken = jwt.generateAccessToken(admin.getId(), admin.getEmail());
    for (String path :
        List.of(
            "/",
            "/products",
            "/products/" + product.getId(),
            "/customer/cart",
            "/customer/checkout",
            "/vendor/products",
            "/admin/categories")) {
      var response = get(path, path.startsWith("/customer/") || path.startsWith("/vendor/")
          || path.startsWith("/admin/") ? adminToken : null);
      assertThat(response.statusCode()).as(path + " " + response.body()).isEqualTo(200);
      assertThat(response.body()).contains(path.equals("/") ? "Xem Menu Cửa Hàng" : "id=\"commerce\"");
    }
    assertThat(get("/js/commerce.js", null).statusCode()).isEqualTo(200);
  }

  @Test
  void mergedShopPageUsesActiveCatalogAndRejectsClosedShop() throws Exception {
    options();
    var response = get("/shops/" + shop.getId(), null);
    assertThat(response.statusCode()).isEqualTo(200);
    assertThat(response.body()).contains(product.getName(), "Size");
    category.setIsDeleted(true);
    categories.save(category);
    assertThat(get("/shops/" + shop.getId(), null).body()).doesNotContain(product.getName());
    assertThat(products.countByShopIdAndStatusAndIsDeletedFalse(shop.getId(), ProductStatus.ACTIVE)).isZero();
    shop.setStatus(ShopStatus.CLOSED);
    shops.save(shop);
    assertThat(get("/shops/" + shop.getId(), null).statusCode()).isEqualTo(404);
  }

  @Test
  void inactiveShopsCannotSellAndExistingCartIsPreserved() {
    add(customer, product, 1, "{}");
    for (ShopStatus status : List.of(ShopStatus.PENDING, ShopStatus.BANNED, ShopStatus.CLOSED)) {
      shop.setStatus(status);
      shops.save(shop);
      ProductSearchRequest search = new ProductSearchRequest();
      search.setShopId(shop.getId());
      assertThat(productService.search(search).getItems()).isEmpty();
      assertThat(productService.getHomeShops(PageRequest.of(0, 100)).getContent())
          .noneMatch(s -> s.shopId().equals(shop.getId()));
      assertThatThrownBy(() -> productService.getDetail(product.getId(), null))
          .isInstanceOf(com.utetra.exception.custom.ResourceNotFoundException.class);
      assertThatThrownBy(() -> add(other, product, 1, "{}"))
          .isInstanceOf(IllegalArgumentException.class);
      assertThatThrownBy(() -> orders.createOrder(customer.getId(), request(shop, PaymentMethod.COD)))
          .isInstanceOf(IllegalArgumentException.class);
      assertThat(carts.getCart(customer.getId()).getFirst().getItems().getFirst().getUnavailableReason())
          .isNotBlank();
      assertThat(products.findById(product.getId()).orElseThrow().getStock()).isEqualTo(20);
    }
    shop.setStatus(ShopStatus.ACTIVE);
    shops.save(shop);
    assertThat(orders.createOrder(customer.getId(), request(shop, PaymentMethod.COD)).getStatus())
        .isEqualTo(OrderStatus.CONFIRMED.name());
  }

  @Test
  void browserCookieAuthenticatesProfileAndExpiredSessionRedirects() throws Exception {
    var anonymous = get("/customer/profile", null);
    assertThat(anonymous.statusCode()).isEqualTo(302);
    assertThat(anonymous.headers().firstValue("location").orElseThrow()).endsWith("/auth/login");
    String token = jwt.generateAccessToken(customer.getId(), customer.getEmail());
    var req = HttpRequest.newBuilder(URI.create("http://localhost:" + port + "/customer/profile"))
        .header("Cookie", "accessToken=" + token).build();
    assertThat(HttpClient.newHttpClient().send(req, HttpResponse.BodyHandlers.ofString()).statusCode())
        .isEqualTo(200);
    assertThat(get("/api/customer/profile", null).statusCode()).isEqualTo(401);
    assertThat(get("/api/admin/categories", token).statusCode()).isEqualTo(403);
    assertThat(get("/api/payment/methods", token).body()).contains("COD", "VNPAY", "MOMO")
        .doesNotContain("test-vnpay-secret", "test-momo-secret");
  }

  @Test
  void missingGatewayConfigurationCannotReserveStockOrConsumeCart() {
    add(customer, product, 1, "{}");
    environment.getPropertySources().addFirst(new org.springframework.core.env.MapPropertySource(
        "missing-payment-test", Map.of("payment.vnpay.hash-secret", "", "payment.momo.secret-key", "")));
    try {
      for (PaymentMethod method : List.of(PaymentMethod.VNPAY, PaymentMethod.MOMO)) {
        assertThat(availability.available(method)).isFalse();
        assertThatThrownBy(() -> quotes.quote(customer.getId(), request(shop, method)))
            .isInstanceOf(IllegalStateException.class);
        assertThatThrownBy(() -> orders.createOrder(customer.getId(), request(shop, method)))
            .isInstanceOf(IllegalStateException.class);
      }
      assertThat(products.findById(product.getId()).orElseThrow().getStock()).isEqualTo(20);
      assertThat(carts.getCart(customer.getId()).getFirst().getItems()).hasSize(1);
      assertThat(orders.getByUser(customer.getId(), null, PageRequest.of(0, 10)).getContent()).isEmpty();
      assertThat(orders.createOrder(customer.getId(), request(shop, PaymentMethod.COD)).getStatus())
          .isEqualTo("CONFIRMED");
    } finally {
      environment.getPropertySources().remove("missing-payment-test");
    }
  }

  @Autowired com.utetra.security.OrderSocketAuthorization socketAuthorization;

  @Test
  void momoCallbackChecksAmountSignatureAndIsIdempotent() {
    var o = buy(PaymentMethod.MOMO);
    PaymentTransaction t = new PaymentTransaction();
    t.setOrder(orderRepo.findById(o.getId()).orElseThrow());
    t.setReference("momo-" + UUID.randomUUID());
    t.setProvider(PaymentMethod.MOMO);
    t.setAmount(o.getTotalAmount());
    transactions.save(t);
    Map<String, Object> p = new HashMap<>();
    p.put("partnerCode", "TESTMOMO");
    p.put("orderId", t.getReference());
    p.put("requestId", t.getReference());
    p.put("amount", 75000);
    p.put("extraData", "");
    p.put("message", "Successful.");
    p.put("orderInfo", "Test order");
    p.put("orderType", "momo_wallet");
    p.put("payType", "qr");
    p.put("responseTime", 123456);
    p.put("resultCode", 0);
    p.put("transId", 99999);
    signMomo(p);
    p.put("amount", 1);
    assertThatThrownBy(() -> payments.momoCallback(p)).isInstanceOf(IllegalArgumentException.class);
    signMomo(p);
    assertThatThrownBy(() -> payments.momoCallback(p)).isInstanceOf(IllegalArgumentException.class);
    p.put("amount", 75000);
    signMomo(p);
    payments.momoCallback(p);
    assertThat(wallets.findByShopId(shop.getId()).orElseThrow().getBalance()).isEqualByComparingTo("60000");
    int count = history.findByOrderId(o.getId()).size();
    payments.momoCallback(p);
    assertThat(wallets.findByShopId(shop.getId()).orElseThrow().getBalance()).isEqualByComparingTo("60000");
    assertThat(history.findByOrderId(o.getId())).hasSize(count);
    assertThat(orders.getDetail(customer.getId(), o.getId()).getPaymentStatus())
        .isEqualTo("SUCCESS");
  }

  void signMomo(Map<String, Object> p) {
    Map<String, Object> signed = new HashMap<>(p);
    signed.put("accessKey", "test-access");
    p.put(
        "signature",
        PaymentSignatures.hmac(
            "HmacSHA256",
            "test-momo-secret",
            PaymentSignatures.momo(
                signed,
                "accessKey",
                "amount",
                "extraData",
                "message",
                "orderId",
                "orderInfo",
                "orderType",
                "partnerCode",
                "payType",
                "requestId",
                "responseTime",
                "resultCode",
                "transId")));
  }

  @Test
  void socketRejectsForeignSubscriptionsAndClientPublishedEvents() {
    var o = buy(PaymentMethod.COD);
    assertThatThrownBy(() -> subscribe(other, "/topic/order/" + o.getId() + "/status"))
        .isInstanceOf(AccessDeniedException.class);
    assertThatThrownBy(() -> subscribe(other, "/topic/shop/" + shop.getId() + "/orders"))
        .isInstanceOf(AccessDeniedException.class);
    subscribe(customer, "/topic/order/" + o.getId() + "/status");
    subscribe(owner, "/topic/shop/" + shop.getId() + "/orders");
    var h =
        org.springframework.messaging.simp.stomp.StompHeaderAccessor.create(
            org.springframework.messaging.simp.stomp.StompCommand.SEND);
    h.setDestination("/topic/order/" + o.getId() + "/status");
    var message =
        org.springframework.messaging.support.MessageBuilder.createMessage(
            new byte[0], h.getMessageHeaders());
    assertThatThrownBy(() -> socketAuthorization.preSend(message, null))
        .isInstanceOf(AccessDeniedException.class);
  }

  void subscribe(User user, String destination) {
    var h =
        org.springframework.messaging.simp.stomp.StompHeaderAccessor.create(
            org.springframework.messaging.simp.stomp.StompCommand.SUBSCRIBE);
    h.setDestination(destination);
    var principal = new com.utetra.security.UserPrincipal(user);
    h.setUser(
        new org.springframework.security.authentication.UsernamePasswordAuthenticationToken(
            principal, null, principal.getAuthorities()));
    socketAuthorization.preSend(
        org.springframework.messaging.support.MessageBuilder.createMessage(
            new byte[0], h.getMessageHeaders()),
        null);
  }

  @Test
  void voucherProductCapAndCategoryCycleAreEnforced() {
    String code = "CAP" + System.nanoTime();
    vouchers.save(shop.getId(), owner.getId(), null, voucher(code, VoucherType.PRODUCT));
    add(customer, product, 1, "{}");
    var r = request(shop, PaymentMethod.COD);
    r.setVoucherCode(code);
    var o = orders.createOrder(customer.getId(), r);
    assertThat(o.getTotalAmount()).isEqualByComparingTo("15000");
  }

  @Test
  void menusAndOffersRespectAuthenticatedRoles() throws Exception {
    var customerToken = jwt.generateAccessToken(customer.getId(), customer.getEmail());
    var vendorToken = jwt.generateAccessToken(owner.getId(), owner.getEmail());
    var admin = user(RoleName.ROLE_ADMIN);
    var adminToken = jwt.generateAccessToken(admin.getId(), admin.getEmail());
    assertThat(get("/", null).body()).doesNotContain("href=\"/vendor/products\"", "href=\"/admin/categories\"", "href=\"/customer/cart\"");
    assertThat(get("/", customerToken).body()).contains("href=\"/customer/cart\"")
        .doesNotContain("href=\"/vendor/products\"", "href=\"/admin/categories\"");
    assertThat(get("/", vendorToken).body()).contains("href=\"/vendor/products\"")
        .doesNotContain("href=\"/admin/categories\"");
    assertThat(get("/", adminToken).body()).contains("href=\"/vendor/products\"", "href=\"/admin/categories\"");
    assertThat(get("/api/customer/orders/offers?shopId=" + shop.getId(), null).statusCode()).isEqualTo(401);
    assertThat(get("/api/customer/orders/offers?shopId=" + shop.getId(), customerToken).statusCode()).isEqualTo(200);
    assertThat(get("/api/vendor/shops/" + shop.getId() + "/vouchers", customerToken).statusCode()).isEqualTo(403);
    var foreignVendor = user(RoleName.ROLE_VENDOR);
    var foreignToken = jwt.generateAccessToken(foreignVendor.getId(), foreignVendor.getEmail());
    assertThat(get("/vendor/wallet/shops/" + shop.getId(), foreignToken).statusCode()).isEqualTo(403);
    subscribe(customer, "/topic/shop/" + shop.getId() + "/offers");
    assertThatThrownBy(() -> subscribe(customer, "/topic/shop/999999999/offers"))
        .isInstanceOf(AccessDeniedException.class);
  }

  @Test
  void codCreditsOnlyOnDeliveryAndReversesOnceOnReturn() throws Exception {
    var o = buy(PaymentMethod.COD);
    assertThat(wallets.findByShopId(shop.getId())).isEmpty();
    advance(o.getId(), OrderStatus.PICKED_UP);
    advance(o.getId(), OrderStatus.SHIPPING);
    assertThat(wallets.findByShopId(shop.getId())).isEmpty();
    advance(o.getId(), OrderStatus.DELIVERED);
    assertThat(wallets.findByShopId(shop.getId()).orElseThrow().getBalance()).isEqualByComparingTo("60000");
    var pool = Executors.newFixedThreadPool(2);
    try {
      var first = pool.submit(() -> settlement.reconcile(o.getId()));
      var second = pool.submit(() -> settlement.reconcile(o.getId()));
      first.get(15, TimeUnit.SECONDS); second.get(15, TimeUnit.SECONDS);
    } finally { pool.shutdownNow(); }
    var wallet = wallets.findByShopId(shop.getId()).orElseThrow();
    assertThat(wallet.getBalance()).isEqualByComparingTo("60000");
    assertThat(walletLedger.findByWalletId(wallet.getId())).hasSize(1);
    advance(o.getId(), OrderStatus.RETURNED);
    advance(o.getId(), OrderStatus.REFUNDED);
    settlement.reconcile(o.getId());
    assertThat(wallets.findByShopId(shop.getId()).orElseThrow().getBalance()).isEqualByComparingTo("0");
    assertThat(walletLedger.findByWalletId(wallet.getId())).hasSize(2);
  }

  @Test
  void paidOnlineCancellationRecoversShopIncomeWithoutPretendingGatewayRefund() {
    var o = buy(PaymentMethod.VNPAY);
    var started = payments.start(customer.getId(), o.getId(), PaymentMethod.VNPAY, "127.0.0.1");
    payments.vnpayCallback(vnpay(started.get("reference"), "7500000"));
    var cancel = new CancelOrderRequest(); cancel.setReason("Khách đổi ý");
    orders.cancelOrder(customer.getId(), o.getId(), cancel);
    assertThat(wallets.findByShopId(shop.getId()).orElseThrow().getBalance()).isEqualByComparingTo("0");
    assertThat(orders.getDetail(customer.getId(), o.getId()).getPaymentStatus()).isEqualTo("SUCCESS");
  }

  @Test
  void hostedQrIsSignedCachedScannableAndPaidOnlyByVerifiedIpn() throws Exception {
    var server = com.sun.net.httpserver.HttpServer.create(new java.net.InetSocketAddress("127.0.0.1", 0), 0);
    var captured = new java.util.concurrent.atomic.AtomicReference<Map<String,String>>();
    var calls = new java.util.concurrent.atomic.AtomicInteger();
    String qrContent = "000201" + "1234567890".repeat(16);
    server.createContext("/pay", exchange -> {
      Map<String,String> params = new HashMap<>();
      for (String pair : exchange.getRequestURI().getRawQuery().split("&")) {
        String[] parts = pair.split("=",2);
        params.put(java.net.URLDecoder.decode(parts[0], java.nio.charset.StandardCharsets.UTF_8),
            java.net.URLDecoder.decode(parts[1], java.nio.charset.StandardCharsets.UTF_8));
      }
      captured.set(params); calls.incrementAndGet();
      byte[] body = ("{\"code\":\"00\",\"message\":\"ok\",\"qrcontent\":\"" + qrContent + "\"}").getBytes(java.nio.charset.StandardCharsets.UTF_8);
      exchange.getResponseHeaders().set("Content-Type", "application/json");
      exchange.sendResponseHeaders(200, body.length);exchange.getResponseBody().write(body);exchange.close();
    });
    server.start();
    environment.getPropertySources().addFirst(new org.springframework.core.env.MapPropertySource("qr-test", Map.of("payment.vnpay.url", "http://127.0.0.1:"+server.getAddress().getPort()+"/pay")));
    var implementation = (com.utetra.service.impl.PaymentServiceImpl) org.springframework.test.util.AopTestUtils.getTargetObject(payments);
    var previous = org.springframework.test.util.ReflectionTestUtils.getField(implementation, "vnpUrl");
    org.springframework.test.util.ReflectionTestUtils.setField(implementation, "vnpUrl", environment.getProperty("payment.vnpay.url"));
    try {
      var order = buy(PaymentMethod.VNPAY);
      assertThatThrownBy(() -> payments.startVnpayQr(other.getId(), order.getId(), "127.0.0.1")).isInstanceOf(AccessDeniedException.class);
      assertThat(calls.get()).isZero();
      var qr = payments.startVnpayQr(customer.getId(), order.getId(), "127.0.0.1");
      assertThat(captured.get()).containsEntry("vnp_Command", "genqr").containsEntry("vnp_Amount", "7500000");
      assertThat(captured.get().get("vnp_SecureHash")).isEqualTo(PaymentSignatures.hmac("HmacSHA512", "test-vnpay-secret", PaymentSignatures.vnpay(captured.get())));
      var png = java.util.Base64.getDecoder().decode(qr.get("qrImage").split(",",2)[1]);
      var image = javax.imageio.ImageIO.read(new java.io.ByteArrayInputStream(png));
      int[] pixels = image.getRGB(0,0,image.getWidth(),image.getHeight(),null,0,image.getWidth());
      var bitmap = new com.google.zxing.BinaryBitmap(new com.google.zxing.common.HybridBinarizer(new com.google.zxing.RGBLuminanceSource(image.getWidth(),image.getHeight(),pixels)));
      assertThat(new com.google.zxing.qrcode.QRCodeReader().decode(bitmap).getText()).isEqualTo(qrContent);
      assertThat(payments.startVnpayQr(customer.getId(), order.getId(), "127.0.0.1").get("reference")).isEqualTo(qr.get("reference"));
      assertThat(calls.get()).isEqualTo(1);
      assertThat(orders.getDetail(customer.getId(),order.getId()).getPaymentStatus()).isEqualTo("PENDING");
      assertThat(wallets.findByShopId(shop.getId())).isEmpty();
      var fallback = payments.start(customer.getId(),order.getId(),PaymentMethod.VNPAY,"127.0.0.1");
      assertThat(fallback.get("reference")).isNotEqualTo(qr.get("reference"));
      payments.vnpayCallback(vnpay(qr.get("reference"),"7500000"));
      assertThat(wallets.findByShopId(shop.getId()).orElseThrow().getBalance()).isEqualByComparingTo("60000");
      assertThatThrownBy(() -> payments.startVnpayQr(customer.getId(),order.getId(),"127.0.0.1")).isInstanceOf(IllegalArgumentException.class);
    } finally {
      org.springframework.test.util.ReflectionTestUtils.setField(implementation,"vnpUrl",previous);
      environment.getPropertySources().remove("qr-test");server.stop(0);
    }
  }

  @Test
  void hostedQrRejectionDoesNotInventQrOrChangeOrderPayment() throws Exception {
    var server = com.sun.net.httpserver.HttpServer.create(new java.net.InetSocketAddress("127.0.0.1",0),0);
    server.createContext("/pay", exchange -> {
      byte[] body = "{\"code\":\"02\",\"message\":\"Merchant unavailable\",\"qrcontent\":\"\"}".getBytes();
      exchange.getResponseHeaders().set("Content-Type","application/json");exchange.sendResponseHeaders(200,body.length);exchange.getResponseBody().write(body);exchange.close();
    });server.start();
    var implementation = (com.utetra.service.impl.PaymentServiceImpl) org.springframework.test.util.AopTestUtils.getTargetObject(payments);
    var previous=org.springframework.test.util.ReflectionTestUtils.getField(implementation,"vnpUrl");
    org.springframework.test.util.ReflectionTestUtils.setField(implementation,"vnpUrl","http://127.0.0.1:"+server.getAddress().getPort()+"/pay");
    try {
      var order=buy(PaymentMethod.VNPAY);
      assertThatThrownBy(() -> payments.startVnpayQr(customer.getId(),order.getId(),"127.0.0.1")).isInstanceOf(IllegalStateException.class);
      assertThat(orders.getDetail(customer.getId(),order.getId()).getPaymentStatus()).isEqualTo("PENDING");
      assertThat(transactions.findFirstByOrderIdOrderByIdDesc(order.getId()).orElseThrow().getQrContent()).isNull();
    } finally { org.springframework.test.util.ReflectionTestUtils.setField(implementation,"vnpUrl",previous);server.stop(0); }
  }
}
