<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <!-- Sửa lại thẻ title -->
    <title>UTETra</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Lấy các thẻ <link>, <style> từ file con (login.jsp) -->
    <sitemesh:write property='head'/>
</head>
<body class="bg-light d-flex align-items-center justify-content-center" style="min-height: 100vh;">
    <div class="container">
        <!-- Chèn nội dung HTML từ login.jsp -->
        <sitemesh:write property='body'/>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Lấy các thẻ <script> từ file con -->
    <sitemesh:write property='script'/>
</body>
</html>