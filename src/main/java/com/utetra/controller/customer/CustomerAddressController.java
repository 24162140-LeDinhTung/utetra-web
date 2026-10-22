package com.utetra.controller.customer;

import com.utetra.dto.request.user.CreateAddressRequest;
import com.utetra.dto.response.ApiResponse;
import com.utetra.dto.response.user.AddressResponse;
import com.utetra.security.UserPrincipal;
import com.utetra.service.AddressService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/customer/addresses")
@RequiredArgsConstructor
public class CustomerAddressController {

    private final AddressService addressService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<AddressResponse>>> getAll(@AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.success(addressService.getAddresses(principal.getId())));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<AddressResponse>> add(@AuthenticationPrincipal UserPrincipal principal,
                                                            @Valid @RequestBody CreateAddressRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Thêm địa chỉ thành công", addressService.addAddress(principal.getId(), request)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<AddressResponse>> update(@AuthenticationPrincipal UserPrincipal principal,
                                                               @PathVariable Long id,
                                                               @Valid @RequestBody CreateAddressRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Cập nhật địa chỉ thành công", addressService.updateAddress(principal.getId(), id, request)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@AuthenticationPrincipal UserPrincipal principal,
                                                    @PathVariable Long id) {
        addressService.deleteAddress(principal.getId(), id);
        return ResponseEntity.ok(ApiResponse.success("Xóa địa chỉ thành công", null));
    }

    @PatchMapping("/{id}/default")
    public ResponseEntity<ApiResponse<Void>> setDefault(@AuthenticationPrincipal UserPrincipal principal,
                                                        @PathVariable Long id) {
        addressService.setDefaultAddress(principal.getId(), id);
        return ResponseEntity.ok(ApiResponse.success("Đặt làm địa chỉ mặc định thành công", null));
    }
}