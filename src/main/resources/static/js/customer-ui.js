/* Visual enhancements only. No requests, prices, form values, or commerce handlers. */
(() => {
  'use strict';
  if (!document.body.classList.contains('customer-site')) return;

  const navigation = document.querySelector('#customer-navigation');
  navigation?.querySelectorAll('.nav-link').forEach(link => {
    const path = new URL(link.href).pathname;
    const current = location.pathname;
    if (current === path || (path !== '/' && current.startsWith(path + '/'))) {
      link.setAttribute('aria-current', 'page');
    }
  });

  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const observed = new WeakSet();
  const revealObserver = !reduceMotion && 'IntersectionObserver' in window
    ? new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (!entry.isIntersecting) return;
        entry.target.classList.remove('customer-reveal-pending');
        entry.target.classList.add('customer-reveal-visible');
        revealObserver.unobserve(entry.target);
      });
    }, { threshold: 0.06 }) : null;

  function reveal(scope) {
    if (!revealObserver) return;
    scope.querySelectorAll('[data-reveal], .ute-card').forEach((element, index) => {
      if (observed.has(element)) return;
      observed.add(element);
      element.setAttribute('data-reveal', '');
      element.style.setProperty('--reveal-delay', Math.min(index % 4, 3) * 65 + 'ms');
      element.classList.add('customer-reveal-pending');
      revealObserver.observe(element);
    });
  }

  const content = document.getElementById('commerce-content');
  const statusClasses = {
    'Chờ thanh toán':'pending', 'Đã xác nhận':'pending', 'Đã lấy hàng':'shipping', 'Đang giao hàng':'shipping', 'Đã giao hàng':'good', 'Đã thanh toán':'good', 'Đã hủy':'bad', 'Đã trả hàng':'bad', 'Đã hoàn tiền':'bad', 'Thanh toán thất bại':'bad', NEW: 'pending', PENDING: 'pending', CONFIRMED: 'pending',
    SHIPPING: 'shipping', DELIVERED: 'good', SUCCESS: 'good',
    CANCELLED: 'bad', FAILED: 'bad', REFUNDED: 'bad'
  };
  function decorate() {
    if (!content) return;
    content.classList.toggle('customer-is-loading', content.textContent.trim() === 'Đang tải dữ liệu…');
    content.querySelectorAll('td').forEach(cell => {
      if (cell.childElementCount || !Object.hasOwn(statusClasses, cell.textContent.trim())) return;
      const badge = document.createElement('span');
      badge.className = 'customer-status customer-status--' + statusClasses[cell.textContent.trim()];
      badge.textContent = cell.textContent;
      cell.replaceChildren(badge);
    });
    reveal(content);
  }
  reveal(document);
  decorate();
  if (content) {
    const observer = new MutationObserver(decorate);
    observer.observe(content, { childList: true, subtree: true });
    window.addEventListener('pagehide', () => { observer.disconnect(); revealObserver?.disconnect(); }, { once: true });
  }
})();
