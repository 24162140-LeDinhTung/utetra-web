<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Rút tiền</title>
</head>
<body>
    <div class="container mt-4">
        <div class="card w-50 mx-auto">
            <div class="card-header bg-primary text-white">
                <h4>Yêu cầu rút tiền</h4>
            </div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/vendor/withdraw/save" method="post">
                    <input type="hidden" name="shopId" value="${shopId}">
                    
                    <div class="mb-3">
                        <label class="form-label">Số tiền muốn rút (VNĐ)</label>
                        <input type="number" class="form-control" name="amount" min="10000" required>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">Số tài khoản ngân hàng</label>
                        <input type="text" class="form-control" name="bankAccount" required>
                    </div>

                    <button type="submit" class="btn btn-success w-100">Gửi yêu cầu</button>
                </form>
            </div>
        </div>
    </div>
</body>
</html>