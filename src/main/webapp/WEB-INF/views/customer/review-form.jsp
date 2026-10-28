<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đánh giá sản phẩm - UTEtra</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        .star-rating { font-size: 2.5rem; color: #e4e5e9; cursor: pointer; }
        .star-rating .bi-star-fill.active { color: #ffc107; }
        .media-preview { position: relative; display: inline-block; margin-right: 10px; margin-bottom: 10px; }
        .media-preview img { width: 80px; height: 80px; object-fit: cover; border-radius: 8px; border: 1px solid #ddd; }
        .media-preview .btn-remove { position: absolute; top: -5px; right: -5px; padding: 0 5px; border-radius: 50%; }
    </style>
</head>
<body class="bg-light">
    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card shadow-sm border-0">
                    <div class="card-header bg-white py-3">
                        <h4 class="mb-0 fw-bold"><i class="bi bi-star-fill text-warning"></i> Đánh giá sản phẩm</h4>
                    </div>
                    <div class="card-body p-4">
                        <form id="reviewForm">
                            <!-- Chấm điểm -->
                            <div class="text-center mb-4">
                                <p class="text-muted mb-2">Bạn cảm thấy sản phẩm thế nào?</p>
                                <div class="star-rating" id="starRating">
                                    <i class="bi bi-star-fill" data-value="1"></i>
                                    <i class="bi bi-star-fill" data-value="2"></i>
                                    <i class="bi bi-star-fill" data-value="3"></i>
                                    <i class="bi bi-star-fill" data-value="4"></i>
                                    <i class="bi bi-star-fill" data-value="5"></i>
                                </div>
                                <input type="hidden" id="ratingValue" value="5">
                            </div>

                            <!-- Nội dung -->
                            <div class="mb-3">
                                <label class="form-label fw-bold">Bình luận của bạn <span class="text-danger">*</span></label>
                                <textarea class="form-control" id="comment" rows="4" required placeholder="Hãy chia sẻ cảm nhận của bạn về sản phẩm (ít nhất 50 ký tự)..."></textarea>
                                <div class="form-text text-end"><span id="charCount">0</span>/50 ký tự tối thiểu</div>
                            </div>

                            <!-- Upload ảnh (Bắt buộc) -->
                            <div class="mb-4">
                                <label class="form-label fw-bold">Hình ảnh thực tế <span class="text-danger">* (1-5 ảnh)</span></label>
                                <input type="file" class="form-control" id="fileInput" accept="image/jpeg,image/png,image/gif,image/webp,video/mp4,video/webm" multiple>
                                <div id="previewContainer" class="mt-3 d-flex flex-wrap"></div>
                            </div>

                            <button type="submit" class="btn btn-primary w-100 py-2 fw-bold" id="submitBtn">
                                Gửi Đánh Giá
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        const urlParams = new URLSearchParams(window.location.search);
        const productId = urlParams.get('productId');
        const orderId = urlParams.get('orderId');
        const contextPath = '${pageContext.request.contextPath}';

        let uploadedUrls = [];

        // Xử lý chấm sao
        const stars = document.querySelectorAll('.star-rating .bi-star-fill');
        const ratingInput = document.getElementById('ratingValue');

        function setRating(rating) {
            ratingInput.value = rating;
            stars.forEach(star => {
                if (parseInt(star.getAttribute('data-value')) <= rating) {
                    star.classList.add('active');
                } else {
                    star.classList.remove('active');
                }
            });
        }
        setRating(5);
        stars.forEach(star => {
            star.addEventListener('click', () => setRating(parseInt(star.getAttribute('data-value'))));
        });

        // Đếm ký tự
        const commentInput = document.getElementById('comment');
        const charCount = document.getElementById('charCount');
        commentInput.addEventListener('input', () => {
            const len = commentInput.value.trim().length;
            charCount.textContent = len;
            if (len >= 50) {
                charCount.classList.add('text-success');
                charCount.classList.remove('text-danger');
            } else {
                charCount.classList.add('text-danger');
                charCount.classList.remove('text-success');
            }
        });

        // Upload ảnh
        const fileInput = document.getElementById('fileInput');
        const previewContainer = document.getElementById('previewContainer');

        fileInput.addEventListener('change', async function() {
            const files = this.files;
            if (files.length === 0) return;
            if (uploadedUrls.length + files.length > 5) {
                alert('Chỉ được tải lên tối đa 5 ảnh!');
                return;
            }

            for (let file of files) {
                const formData = new FormData();
                formData.append('file', file);

                try {
                    const res = await fetch(contextPath + '/api/customer/reviews/media', {
                        method: 'POST',
                        body: formData
                    });
                    if (res.ok) {
                        const data = await res.json();
                        uploadedUrls.push(data.url);
                        addPreviewImage(data.url);
                    } else {
                        alert('Lỗi upload ảnh!');
                    }
                } catch (e) {
                    console.error(e);
                    alert('Lỗi kết nối khi upload ảnh');
                }
            }
            this.value = '';
        });

        function addPreviewImage(url) {
            const div = document.createElement('div');
            div.className = 'media-preview';
            const isVideo = /\.(mp4|webm)$/i.test(url);
            const image = document.createElement(isVideo ? 'video' : 'img');
            if (isVideo) image.controls = true;
            image.src = url.startsWith('/') ? contextPath + url : url;
            image.alt = 'Ảnh đánh giá';
            const remove = document.createElement('button');
            remove.type = 'button';
            remove.className = 'btn btn-danger btn-sm btn-remove';
            remove.textContent = '×';
            remove.addEventListener('click', () => window.removeImage(remove, url));
            div.append(image, remove);
            previewContainer.appendChild(div);
        }

        window.removeImage = function(btn, url) {
            uploadedUrls = uploadedUrls.filter(u => u !== url);
            btn.parentElement.remove();
        };

        // Submit Form
        document.getElementById('reviewForm').addEventListener('submit', async function(e) {
            e.preventDefault();

            const rating = ratingInput.value;
            const comment = commentInput.value.trim();

            if (comment.length < 50) {
                alert('Vui lòng nhập ít nhất 50 ký tự cho phần bình luận.');
                return;
            }
            if (uploadedUrls.length === 0) {
                alert('Vui lòng tải lên ít nhất 1 hình ảnh thực tế.');
                return;
            }

            const btn = document.getElementById('submitBtn');
            btn.disabled = true;
            btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Đang gửi...';

            const payload = {
                productId: parseInt(productId),
                orderId: parseInt(orderId),
                rating: parseInt(rating),
                comment: comment,
                mediaUrls: uploadedUrls
            };

            try {
                const res = await fetch(contextPath + '/api/customer/reviews', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });

                if (res.ok) {
                    alert('Cảm ơn bạn đã đánh giá sản phẩm!');
                    window.location.href = contextPath + '/customer/orders/' + orderId;
                } else {
                    const err = await res.json();
                    alert('Lỗi: ' + (err.message || 'Không thể gửi đánh giá'));
                }
            } catch (e) {
                alert('Lỗi kết nối Server');
            } finally {
                btn.disabled = false;
                btn.innerHTML = 'Gửi Đánh Giá';
            }
        });
    </script>
</body>
</html>
