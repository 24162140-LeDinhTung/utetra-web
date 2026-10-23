package com.utetra.exception;

import com.utetra.dto.response.ApiResponse;
import com.utetra.exception.custom.AccountBannedException;
import com.utetra.exception.custom.ResourceNotFoundException;
import java.util.HashMap;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
@lombok.extern.slf4j.Slf4j
public class GlobalExceptionHandler {

  @ExceptionHandler(ResourceNotFoundException.class)
  public ResponseEntity<ApiResponse<Void>> handleNotFound(ResourceNotFoundException ex) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND)
        .body(ApiResponse.error(404, ex.getMessage()));
  }

  @ExceptionHandler(AccountBannedException.class)
  public ResponseEntity<ApiResponse<Void>> handleBanned(AccountBannedException ex) {
    return ResponseEntity.status(HttpStatus.FORBIDDEN)
        .body(ApiResponse.error(403, ex.getMessage()));
  }

  @ExceptionHandler(BadCredentialsException.class)
  public ResponseEntity<ApiResponse<Void>> handleBadCredentials(BadCredentialsException ex) {
    return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
        .body(ApiResponse.error(401, "Email hoặc mật khẩu không đúng"));
  }

  @ExceptionHandler(MethodArgumentNotValidException.class)
  public ResponseEntity<ApiResponse<Map<String, String>>> handleValidation(
      MethodArgumentNotValidException ex) {
    Map<String, String> errors = new HashMap<>();
    for (FieldError error : ex.getBindingResult().getFieldErrors()) {
      errors.put(error.getField(), error.getDefaultMessage());
    }
    return ResponseEntity.status(HttpStatus.BAD_REQUEST)
        .body(new ApiResponse<>(400, "Dữ liệu không hợp lệ", errors));
  }

  @ExceptionHandler(org.springframework.security.access.AccessDeniedException.class)
  public ResponseEntity<ApiResponse<Void>> denied(Exception ex) {
    return ResponseEntity.status(403).body(ApiResponse.error(403, ex.getMessage()));
  }

  @ExceptionHandler({
    IllegalArgumentException.class,
    com.utetra.exception.custom.InsufficientStockException.class,
    com.utetra.exception.custom.InvalidOrderStatusException.class,
    com.utetra.exception.custom.VoucherInvalidException.class
  })
  public ResponseEntity<ApiResponse<Void>> invalid(Exception ex) {
    return ResponseEntity.badRequest().body(ApiResponse.error(400, ex.getMessage()));
  }

  @ExceptionHandler(IllegalStateException.class)
  public ResponseEntity<ApiResponse<Void>> unavailable(Exception ex) {
    return ResponseEntity.status(503).body(ApiResponse.error(503, ex.getMessage()));
  }

  @ExceptionHandler(org.springframework.dao.DataIntegrityViolationException.class)
  public ResponseEntity<ApiResponse<Void>> conflict(Exception ex) {
    return ResponseEntity.status(409)
        .body(ApiResponse.error(409, "Dữ liệu bị trùng hoặc đang được sử dụng"));
  }

  @ExceptionHandler({
    org.springframework.http.converter.HttpMessageNotReadableException.class,
    org.springframework.web.method.annotation.MethodArgumentTypeMismatchException.class,
    org.springframework.web.bind.MissingServletRequestParameterException.class,
    org.springframework.web.multipart.support.MissingServletRequestPartException.class
  })
  public ResponseEntity<ApiResponse<Void>> malformed(Exception ex) {
    return ResponseEntity.badRequest()
        .body(ApiResponse.error(400, "Dữ liệu gửi lên sai định dạng hoặc thiếu trường bắt buộc"));
  }

  @ExceptionHandler(org.springframework.web.multipart.MaxUploadSizeExceededException.class)
  public ResponseEntity<ApiResponse<Void>> uploadTooLarge(Exception ex) {
    return ResponseEntity.status(413)
        .body(ApiResponse.error(413, "Tệp tải lên vượt dung lượng cho phép"));
  }

  @ExceptionHandler(org.springframework.dao.PessimisticLockingFailureException.class)
  public ResponseEntity<ApiResponse<Void>> busy(Exception ex) {
    return ResponseEntity.status(409)
        .body(ApiResponse.error(409, "Dữ liệu đang được cập nhật. Vui lòng thử lại"));
  }

  @ExceptionHandler(Exception.class)
  public ResponseEntity<ApiResponse<Void>> handleAll(Exception ex) {
    log.error("Unhandled request failure", ex);
    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
        .body(ApiResponse.error(500, "Lỗi hệ thống. Vui lòng thử lại sau"));
  }
}
