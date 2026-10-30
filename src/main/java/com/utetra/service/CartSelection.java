package com.utetra.service;

import java.util.*;
import java.util.function.Function;

/** Select only lines in the authenticated buyer's cart for the requested shop. */
public final class CartSelection {
  private CartSelection() {}

  public static <T> List<T> select(List<T> lines, List<Long> requested, Function<T, Long> id) {
    // Older clients omitted this field and purchased the entire shop cart.
    if (requested == null) return lines;
    Set<Long> ids = new HashSet<>(requested);
    if (requested.isEmpty() || requested.size() > 500 || ids.contains(null)
        || ids.stream().anyMatch(x -> x <= 0) || ids.size() != requested.size())
      throw new IllegalArgumentException("Vui lòng chọn ít nhất một món hợp lệ, không trùng lặp");
    List<T> selected = lines.stream().filter(x -> ids.contains(id.apply(x))).toList();
    if (selected.size() != ids.size())
      throw new IllegalArgumentException("Món đã chọn không còn trong giỏ của bạn tại cửa hàng này. Hãy chọn lại");
    return selected;
  }
}
