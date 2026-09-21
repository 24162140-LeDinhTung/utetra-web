package com.utetra.mapper;

import com.utetra.dto.request.voucher.CreateVoucherRequest;
import com.utetra.entity.Voucher;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface VoucherMapper {

    Voucher toEntity(CreateVoucherRequest request);
}