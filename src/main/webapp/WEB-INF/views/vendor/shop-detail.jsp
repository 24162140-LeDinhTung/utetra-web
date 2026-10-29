<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<h1 class="h3">Chi tiết cửa hàng</h1>
<div class="card p-4 mt-3"><dl class="ute-facts">
<div><dt>ID cửa hàng</dt><dd><c:out value="${shop.id}" default="Chưa cập nhật"/></dd></div>
<div><dt>Tên cửa hàng</dt><dd><c:out value="${shop.name}" default="Chưa cập nhật"/></dd></div>
<div><dt>Mô tả</dt><dd><c:out value="${shop.description}" default="Chưa cập nhật"/></dd></div>
<div><dt>Địa chỉ</dt><dd><c:out value="${shop.address}" default="Chưa cập nhật"/></dd></div>
<div><dt>Điện thoại</dt><dd><c:out value="${shop.phone}" default="Chưa cập nhật"/></dd></div>
<div><dt>Email</dt><dd><c:out value="${shop.email}" default="Chưa cập nhật"/></dd></div>
<div><dt>Ngày tạo</dt><dd><c:out value="${shop.createdAt}" default="Chưa cập nhật"/></dd></div>
<div><dt>Trạng thái</dt><dd><c:choose><c:when test="${shop.isDeleted}">Đã xóa</c:when><c:when test="${shop.status == 'ACTIVE'}">Hoạt động</c:when><c:when test="${shop.status == 'PENDING'}">Chờ duyệt</c:when><c:otherwise>Bị khóa</c:otherwise></c:choose></dd></div></dl>
<a href="${pageContext.request.contextPath}${backUrl}" class="btn btn-outline-secondary mt-3">Quay lại danh sách</a></div>