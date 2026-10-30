/* Presentation only: navigation markers and layout classes. No requests or form handlers. */
(() => {
  'use strict';
  if (!document.body.classList.contains('management-site')) return;
  const sidebar = document.getElementById('management-sidebar');
  const base = sidebar?.dataset.context || '';
  const localPath = path => {
    const relative = base && path.startsWith(base + '/') ? path.slice(base.length) : path;
    return relative.replace(/\/+$/, '') || '/';
  };
  let current = localPath(location.pathname);
  const aliases = new Map([
    ['/vendor/product-form', '/vendor/products'],
    ['/admin/category-form', '/admin/categories'],
    ['/admin/attribute-form', '/admin/attributes']
  ]);
  current = aliases.get(current) || current;
  let active;
  sidebar?.querySelectorAll('a.nav-link').forEach(link => {
    const path = localPath(new URL(link.href).pathname);
    if (current === path || current.startsWith(path + '/')) {
      link.classList.add('active');
      link.setAttribute('aria-current', 'page');
      active = link;
    }
  });
  const section = document.querySelector('.management-current-section');
  if (section && active) section.textContent = active.textContent.replace(/\s+/g, ' ').trim();

  const content = document.querySelector('.main-content > .container-fluid');
  if (!content) return;
  if (current === '/admin/dashboard') {
    content.querySelector(':scope > .row.g-4.mb-4')?.classList.add('management-stats');
    content.querySelector('.card-body > div[style*="height: 300px"]')?.classList.add('management-chart-placeholder');
  }
  const walletAmount = content.querySelector('.card.bg-success .display-4');
  walletAmount?.closest('.card')?.classList.add('management-wallet-card');
  walletAmount?.closest('.row')?.classList.add('management-wallet-summary');
})();
