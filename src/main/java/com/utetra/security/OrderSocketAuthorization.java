package com.utetra.security;

import com.utetra.entity.*;
import com.utetra.enums.UserStatus;
import com.utetra.repository.*;
import java.util.regex.*;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.*;
import org.springframework.messaging.simp.stomp.*;
import org.springframework.messaging.support.*;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@RequiredArgsConstructor
public class OrderSocketAuthorization implements ChannelInterceptor {
  private final JwtProvider jwt;
  private final UserRepository users;
  private final OrderRepository orders;
  private final ShopRepository shops;

  @Override
  @Transactional(readOnly = true)
  public Message<?> preSend(Message<?> message, MessageChannel channel) {
    StompHeaderAccessor h = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);
    if (h == null) return message;
    if (h.getCommand() == StompCommand.CONNECT) {
      String bearer = h.getFirstNativeHeader("Authorization");
      if (bearer == null
          || !bearer.startsWith("Bearer ")
          || !jwt.validateToken(bearer.substring(7)))
        throw new AccessDeniedException("Cần đăng nhập WebSocket");
      User user =
          users
              .findById(jwt.getUserIdFromToken(bearer.substring(7)))
              .filter(
                  u -> u.getStatus() == UserStatus.ACTIVE && !Boolean.TRUE.equals(u.getIsDeleted()))
              .orElseThrow(() -> new AccessDeniedException("Tài khoản không hợp lệ"));
      UserPrincipal principal = new UserPrincipal(user);
      h.setUser(
          new UsernamePasswordAuthenticationToken(principal, null, principal.getAuthorities()));
    }
    if (h.getCommand() == StompCommand.SEND)
      throw new AccessDeniedException("Không được phát thông báo đơn hàng từ client");
    if (h.getCommand() == StompCommand.SUBSCRIBE) {
      if (!(h.getUser() instanceof UsernamePasswordAuthenticationToken auth)
          || !(auth.getPrincipal() instanceof UserPrincipal user))
        throw new AccessDeniedException("Chưa xác thực");
      String destination = h.getDestination() == null ? "" : h.getDestination();
      Matcher order = Pattern.compile("/topic/order/(\\d+)/status").matcher(destination);
      Matcher shop = Pattern.compile("/topic/shop/(\\d+)/orders").matcher(destination);
      Matcher offers = Pattern.compile("/topic/shop/(\\d+)/offers").matcher(destination);
      boolean allowed = false;
      if (offers.matches()) {
        allowed = shops.findById(Long.valueOf(offers.group(1)))
            .filter(s -> !Boolean.TRUE.equals(s.getIsDeleted())).isPresent();
      } else if (order.matches()) {
        Order o =
            orders
                .findById(Long.valueOf(order.group(1)))
                .orElseThrow(() -> new AccessDeniedException("Không tìm thấy đơn"));
        allowed =
            o.getUser().getId().equals(user.getId())
                || o.getShop().getOwner().getId().equals(user.getId());
      } else if (shop.matches()) {
        Shop s =
            shops
                .findById(Long.valueOf(shop.group(1)))
                .orElseThrow(() -> new AccessDeniedException("Không tìm thấy cửa hàng"));
        allowed = s.getOwner().getId().equals(user.getId());
      }
      if (!allowed) throw new AccessDeniedException("Không được theo dõi kênh này");
    }
    return message;
  }
}
