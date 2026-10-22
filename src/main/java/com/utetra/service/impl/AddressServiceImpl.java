package com.utetra.service.impl;

import com.utetra.dto.request.user.CreateAddressRequest;
import com.utetra.dto.response.user.AddressResponse;
import com.utetra.entity.Address;
import com.utetra.entity.User;
import com.utetra.exception.custom.ResourceNotFoundException;
import com.utetra.repository.AddressRepository;
import com.utetra.repository.UserRepository;
import com.utetra.service.AddressService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AddressServiceImpl implements AddressService {

    private final AddressRepository addressRepository;
    private final UserRepository userRepository;

    @Override
    public List<AddressResponse> getAddresses(Long userId) {
        return addressRepository.findByUserId(userId).stream()
                .map(this::mapToResponse)
                .toList();
    }

    @Override
    @Transactional
    public AddressResponse addAddress(Long userId, CreateAddressRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        // Nếu đây là địa chỉ đầu tiên, tự động set làm mặc định
        boolean isFirst = addressRepository.findByUserId(userId).isEmpty();
        
        Address address = new Address();
        address.setUserId(userId);
        mapToEntity(address, request);
        if (isFirst) {
            address.setIsDefault(true);
        } else if (Boolean.TRUE.equals(request.getIsDefault())) {
            clearDefaultAddress(userId); // Xóa mặc định cũ
            address.setIsDefault(true);
        }

        return mapToResponse(addressRepository.save(address));
    }

    @Override
    @Transactional
    public AddressResponse updateAddress(Long userId, Long addressId, CreateAddressRequest request) {
        Address address = addressRepository.findById(addressId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy địa chỉ"));

        // Bảo mật: Chỉ được sửa địa chỉ của chính mình
        if (!address.getUserId().equals(userId)) {
            throw new RuntimeException("Bạn không có quyền sửa địa chỉ này");
        }

        mapToEntity(address, request);

        if (Boolean.TRUE.equals(request.getIsDefault())) {
            clearDefaultAddress(userId);
            address.setIsDefault(true);
        }

        return mapToResponse(addressRepository.save(address));
    }

    @Override
    @Transactional
    public void deleteAddress(Long userId, Long addressId) {
        Address address = addressRepository.findById(addressId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy địa chỉ"));

        if (!address.getUserId().equals(userId)) {
            throw new RuntimeException("Bạn không có quyền xóa địa chỉ này");
        }

        // Không cho phép xóa địa chỉ mặc định nếu còn địa chỉ khác
        if (Boolean.TRUE.equals(address.getIsDefault()) && addressRepository.findByUserId(userId).size() > 1) {
            throw new RuntimeException("Vui lòng đặt một địa chỉ khác làm mặc định trước khi xóa");
        }

        addressRepository.delete(address);
    }

    @Override
    @Transactional
    public void setDefaultAddress(Long userId, Long addressId) {
        Address address = addressRepository.findById(addressId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy địa chỉ"));

        if (!address.getUserId().equals(userId)) {
            throw new RuntimeException("Bạn không có quyền thao tác trên địa chỉ này");
        }

        clearDefaultAddress(userId);
        address.setIsDefault(true);
        addressRepository.save(address);
    }

    // Hàm phụ trợ: Xóa trạng thái mặc định của tất cả địa chỉ cũ
    private void clearDefaultAddress(Long userId) {
        List<Address> addresses = addressRepository.findByUserId(userId);
        for (Address a : addresses) {
            if (Boolean.TRUE.equals(a.getIsDefault())) {
                a.setIsDefault(false);
                addressRepository.save(a);
            }
        }
    }

    private void mapToEntity(Address address, CreateAddressRequest request) {
        address.setReceiverName(request.getReceiverName());
        address.setPhone(request.getPhone());
        address.setProvince(request.getProvince());
        address.setDistrict(request.getDistrict());
        address.setWard(request.getWard());
        address.setDetail(request.getDetail());
        address.setLabel(request.getLabel());
    }

    private AddressResponse mapToResponse(Address address) {
        AddressResponse res = new AddressResponse();
        res.setId(address.getId());
        res.setReceiverName(address.getReceiverName());
        res.setPhone(address.getPhone());
        res.setProvince(address.getProvince());
        res.setDistrict(address.getDistrict());
        res.setWard(address.getWard());
        res.setDetail(address.getDetail());
        res.setLabel(address.getLabel());
        res.setIsDefault(address.getIsDefault());
        return res;
    }
}