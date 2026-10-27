package com.utetra.service;

import com.utetra.dto.request.user.CreateAddressRequest;
import com.utetra.dto.response.user.AddressResponse;

import java.util.List;

public interface AddressService {
    List<AddressResponse> getAddresses(Long userId);
    AddressResponse addAddress(Long userId, CreateAddressRequest request);
    AddressResponse updateAddress(Long userId, Long addressId, CreateAddressRequest request);
    void deleteAddress(Long userId, Long addressId);
    void setDefaultAddress(Long userId, Long addressId);
}