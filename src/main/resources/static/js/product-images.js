/* Customer photo presentation. Demo/missing photos only; no API or commerce changes. */
(() => {
  'use strict';
  if (!document.body.classList.contains('customer-site')) return;

  const scriptUrl = document.currentScript?.src || new URL('js/product-images.js', document.baseURI).href;
  const assetBase = new URL('../images/drinks/', scriptUrl);
  const normalize = value => String(value || '').normalize('NFD').toLowerCase()
    .replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').replace(/\s+/g, ' ').trim();
  const photos = new Map([
    ['tra sua truyen thong', 'tra-sua-truyen-thong.png'],
    ['tra sua o long', 'tra-sua-o-long.jpg'],
    ['tra sua matcha', 'tra-sua-matcha.png'],
    ['tra sua socola', 'tra-sua-socola.jpg'],
    ['tra dao cam sa', 'tra-dao-cam-sa.webp'],
    ['tra vai', 'tra-vai.jpg'],
    ['tra chanh day', 'tra-chanh-day.png'],
    ['tra dau', 'tra-dau.jpg'],
    ['sua tuoi tran chau', 'sua-tuoi-tran-chau.webp'],
    ['matcha latte', 'matcha-latte.jpg'],
    ['cacao sua', 'cacao-sua.webp'],
    ['ca cao sua', 'cacao-sua.webp'],
    ['tra kem cheese', 'tra-kem-cheese.jpg']
  ]);

  function isDemo(image) {
    const source = image.getAttribute('src')?.trim();
    if (!source) return true;
    try {
      const url = new URL(source, document.baseURI);
      return url.pathname.endsWith('/images/part-b-demo.svg') || url.hostname === 'via.placeholder.com';
    } catch {
      return false;
    }
  }

  function setPhoto(image, name, eager = false) {
    const file = photos.get(normalize(name));
    if (!file || !isDemo(image)) return;
    image.alt = name.trim();
    image.classList.add('customer-drink-photo');
    image.loading = eager ? 'eager' : 'lazy';
    image.decoding = 'async';
    image.src = new URL(file, assetBase).href;
  }

  const main = document.getElementById('main-content');
  if (!main) return;
  function refreshPhotos() {
    main.querySelectorAll('.ute-card, .customer-shop-products .card, .customer-collection-card, #favorite-list .card, #history-list .card').forEach(card => {
      let image = card.querySelector(':scope > img');
      const name = card.querySelector('h3, h6, .card-title')?.textContent.trim() || image?.alt || '';
      if (!photos.has(normalize(name))) return;
      const placeholder = card.querySelector(':scope > .ute-placeholder');
      if (!image && placeholder) {
        image = document.createElement('img');
        setPhoto(image, name);
        placeholder.replaceWith(image);
      } else if (image) {
        setPhoto(image, name);
      }
    });

    const product = main.querySelector('#commerce[data-page="product-detail"] #commerce-content > .ute-panel:first-of-type');
    const gallery = product?.querySelector(':scope > .ute-gallery');
    const name = product?.querySelector('h1')?.textContent.trim() || '';
    if (gallery && photos.has(normalize(name))) {
      if (!gallery.children.length) {
        const image = document.createElement('img');
        setPhoto(image, name, true);
        gallery.append(image);
      } else {
        gallery.querySelectorAll(':scope > .ute-placeholder').forEach(placeholder => {
          const image = document.createElement('img');
          setPhoto(image, name, true);
          placeholder.replaceWith(image);
        });
        gallery.querySelectorAll(':scope > img').forEach(image => setPhoto(image, name, true));
      }
    }
  }

  refreshPhotos();
  const observer = new MutationObserver(refreshPhotos);
  observer.observe(main, { childList: true, subtree: true });
  window.addEventListener('pagehide', () => observer.disconnect(), { once: true });
})();
