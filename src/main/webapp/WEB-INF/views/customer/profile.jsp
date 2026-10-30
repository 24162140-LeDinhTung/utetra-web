<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head><title><c:choose><c:when test="${editingProfile}">Chỉnh sửa tài khoản</c:when><c:otherwise>Thông tin tài khoản</c:otherwise></c:choose> - UTETra</title></head>
<body>
<header class="customer-page-intro"><p class="customer-eyebrow">TÀI KHOẢN UTETRA</p><h1><c:choose><c:when test="${editingProfile}">Chỉnh sửa thông tin</c:when><c:otherwise>Thông tin tài khoản</c:otherwise></c:choose></h1></header>
<div id="profile-page" class="row customer-account" data-context="${pageContext.request.contextPath}" data-editing="${editingProfile}">
  <div class="col-md-3 mb-4 customer-account-sidebar">
    <div class="card shadow-sm border-0 rounded-4 mb-4 text-center p-4 customer-account-avatar">
      <img id="avatarImg" alt="Ảnh đại diện của bạn" src="${pageContext.request.contextPath}/images/customer-avatar.svg" class="rounded-circle mx-auto mb-3 shadow" style="width:120px;height:120px;object-fit:cover">
      <h5 id="userFullName" class="fw-bold mb-1">Đang tải…</h5><p id="userEmail" class="text-muted small mb-3"></p>
      <c:if test="${editingProfile}"><form id="avatarForm"><label for="avatarFile" class="form-label">Đổi ảnh đại diện</label><input type="file" id="avatarFile" class="form-control form-control-sm mb-2" accept="image/jpeg,image/png,image/webp,image/gif" required><button class="btn btn-warning fw-bold btn-sm w-100" type="submit">Cập nhật ảnh</button></form></c:if>
    </div>
    <div class="list-group shadow-sm border-0 rounded-4 overflow-hidden customer-account-menu">
      <a href="${pageContext.request.contextPath}/customer/profile" class="list-group-item list-group-item-action active fw-bold">Thông tin cá nhân</a>
      <a href="${pageContext.request.contextPath}/customer/favorites" class="list-group-item list-group-item-action fw-bold">Sản phẩm yêu thích</a>
      <a href="${pageContext.request.contextPath}/customer/history" class="list-group-item list-group-item-action fw-bold">Sản phẩm đã xem</a>
    </div>
  </div>
  <div class="col-md-9 customer-account-content">
    <div id="profile-notice" role="status" aria-live="polite"></div>
    <div class="card shadow-sm border-0 rounded-4">
      <div class="card-header bg-white border-0 pt-4 px-4"><h2 class="h5 fw-bold text-warning">Thông tin cá nhân</h2></div>
      <div class="card-body px-4 pb-4">
        <c:choose><c:when test="${editingProfile}">
          <form id="profileForm">
            <div class="mb-3"><label for="fullName" class="form-label fw-bold">Họ và tên</label><input type="text" id="fullName" class="form-control bg-light" required maxlength="255"></div>
            <div class="mb-3"><label for="email" class="form-label fw-bold">Email (không thể đổi)</label><input type="email" id="email" class="form-control bg-light" disabled></div>
            <div class="mb-4"><label for="phone" class="form-label fw-bold">Số điện thoại</label><input type="tel" id="phone" class="form-control bg-light" maxlength="30"></div>
            <div class="d-flex gap-2 flex-wrap"><button type="submit" class="btn btn-warning fw-bold px-4">Lưu thay đổi</button><a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/customer/profile">Quay lại thông tin</a></div>
          </form>
        </c:when><c:otherwise>
          <dl class="profile-facts"><div><dt>Họ và tên</dt><dd id="profile-fullName">Đang tải…</dd></div><div><dt>Email đăng nhập</dt><dd id="profile-email">Đang tải…</dd></div><div><dt>Số điện thoại</dt><dd id="profile-phone">Đang tải…</dd></div><div><dt>Địa chỉ nhận hàng</dt><dd id="profile-shippingAddress">Chưa có địa chỉ giao hàng thành công</dd></div><div><dt>Ngày tham gia</dt><dd id="profile-createdAt">Đang tải…</dd></div></dl>
          <a href="${pageContext.request.contextPath}/customer/profile/edit" class="btn btn-warning fw-bold mt-3" id="edit-profile">Chỉnh sửa thông tin</a>
        </c:otherwise></c:choose>
      </div>
    </div>
  </div>
</div>
<script src="${pageContext.request.contextPath}/js/profile.js?v=20261030-1" defer></script>
</body></html>
