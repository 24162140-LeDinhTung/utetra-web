/* Part B browser client. All prices and authorization are rechecked by the server. */
(() => {
  'use strict';
  const root = document.getElementById('commerce');
  if (!root) return;
  const base = root.dataset.context || '';
  const page = root.dataset.page;
  const content = document.getElementById('commerce-content');
  const query = new URLSearchParams(location.search);
  const $ = (selector) => root.querySelector(selector);
  const esc = (s) => String(s ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  const attributesText = raw => {try {const value=JSON.parse(raw || '{}');return esc(Object.entries(value).map(([k,v])=>(k==='Size'?'Kích cỡ':k)+': '+v).join(' · '));}catch{return esc(raw);}};
  const statusLabels = {NEW:'Chờ thanh toán', CONFIRMED:'Đã xác nhận', PICKED_UP:'Đã lấy hàng', SHIPPING:'Đang giao hàng', DELIVERED:'Đã giao hàng', CANCELLED:'Đã hủy', RETURNED:'Đã trả hàng', REFUNDED:'Đã hoàn tiền', PENDING:'Chờ thanh toán', SUCCESS:'Đã thanh toán', FAILED:'Thanh toán thất bại'};
  const statusText = value => esc(statusLabels[value] || value);
  const methodText = value => esc(({COD:'Tiền mặt khi nhận hàng',VNPAY:'VNPay',MOMO:'MoMo'})[value] || value);
  const dateText = value => value ? esc(new Date(value).toLocaleString('vi-VN')) : 'Không giới hạn';
  const money = n => new Intl.NumberFormat('vi-VN', {style:'currency',currency:'VND'}).format(n || 0);
  const url = s => base + s;
  const safeMedia = s => {try {const u = new URL(s, location.origin); return ['https:','http:'].includes(u.protocol) ? esc(u.href) : '';} catch {return '';}};
  const link = (href, title, cls='btn btn-outline-success') => `<a class="${cls}" href="${url(href)}">${esc(title)}</a>`;
  const action = (id, title, cls='btn btn-success', type='button') => `<button id="${id}" type="${type}" class="${cls}">${esc(title)}</button>`;
  const field = (name, title, type='text', value='', extra='') => `<label>${esc(title)}<input name="${name}" type="${type}" value="${esc(value)}" ${extra}></label>`;
  const select = (name, title, items, value='') => `<label>${esc(title)}<select name="${name}">${items.map(([v,t])=>`<option value="${esc(v)}" ${String(v)===String(value)?'selected':''}>${esc(t)}</option>`).join('')}</select></label>`;
  const formData = form => Object.fromEntries(new FormData(form));
  const notice = (message, bad=false) => {$('#notice').className = `alert alert-${bad?'danger':'success'}`; $('#notice').textContent = message;};
  async function api(path, options={}) {
    const headers = new Headers(options.headers || {});
    const token = localStorage.getItem('accessToken');
    if (token) headers.set('Authorization', 'Bearer '+token);
    if (options.body && !(options.body instanceof FormData) && !(options.body instanceof URLSearchParams)) {
      headers.set('Content-Type', 'application/json'); options.body = JSON.stringify(options.body);
    }
    const response = await fetch(url(path), {...options, headers});
    const raw = await response.text(); let data;
    try {data = raw ? JSON.parse(raw) : null;} catch {data = null;}
    if (!response.ok) {
      if (response.status === 401) {
        localStorage.removeItem('accessToken'); localStorage.removeItem('userRoles');
        document.cookie='accessToken=; Max-Age=0; path=/; SameSite=Lax';
        location.assign(url('/auth/login'));
        throw new Error('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      }
      if (response.status === 403) throw new Error('Tài khoản không có quyền thực hiện thao tác này. Hãy kiểm tra tài khoản/đăng nhập.');
      const details = data?.data && typeof data.data==='object' ? Object.values(data.data).join('; ') : '';
      throw new Error(data?.message ? data.message + (details ? ': '+details : '') : 'Không tải được dữ liệu ('+response.status+').');
    }
    return data;
  }
  function bind(selector, event, fn) {
    $(selector)?.addEventListener(event, async e => {
      e.preventDefault(); const target = e.currentTarget;
      const button = target.tagName==='FORM' ? target.querySelector('[type=submit]') : target;
      if (button) button.disabled = true;
      try {await fn(e);} catch(err) {notice(err.message, true);} finally {if (button) button.disabled = false;}
    });
  }
  function requireLogin() {
    if (localStorage.getItem('accessToken')) return true;
    content.innerHTML = `<h1>Vui lòng đăng nhập</h1><p>Đăng nhập để tiếp tục công việc với tài khoản của bạn.</p>${link('/auth/login','Đăng nhập')}`;
    return false;
  }
  const table = (headers, rows) => `<div class="ute-scroll"><table class="ute-table"><thead><tr>${headers.map(h=>`<th>${esc(h)}</th>`).join('')}</tr></thead><tbody>${rows.join('') || `<tr><td colspan="${headers.length}">Chưa có dữ liệu.</td></tr>`}</tbody></table></div>`;
  const image = (src, name) => safeMedia(src) ? `<img src="${safeMedia(src)}" alt="${esc(name)}" loading="lazy">` : '<div class="ute-placeholder" aria-label="Chưa có ảnh">☕</div>';
  const cards = products => `<div class="ute-grid">${products.map(p=>`<article class="ute-card">${image(p.thumbnailUrl,p.name)}<div class="ute-info"><div class="ute-muted">${esc(p.shopName)}</div><h3 class="h6 mt-2">${esc(p.name)}</h3><p class="ute-price">${money(p.price)}</p><p class="small">Đã bán ${p.soldCount} · Còn ${p.stock}</p>${link('/products/'+p.id,'Xem và chọn')}</div></article>`).join('')}</div>`;
  function pager(total, current, onPage) {
    const box=document.createElement('div');box.className='ute-actions';
    for (const [title,n,disabled] of [['Trang trước',current-1,current<=0],['Trang sau',current+1,current+1>=total]]) {
      const b=document.createElement('button');b.className='btn btn-outline-secondary';b.textContent=title;b.disabled=disabled;
      b.onclick=()=>onPage(n).catch(e=>notice(e.message,true));box.append(b);
    }
    const label=document.createElement('span');label.className='align-self-center';label.textContent=`Trang ${current+1} / ${Math.max(1,total)}`;box.append(label);content.append(box);
  }
  async function home() {
    content.innerHTML = `<section class="ute-hero"><p>UTETRA · CÁC CỬA HÀNG</p><h1>Mỗi cửa hàng, một menu riêng</h1><p>Khám phá những món bán chạy, chọn cửa hàng bạn thích và đặt giao tận nơi.</p>${link('/products','Khám phá thực đơn','btn btn-success')}</section><div id="shops"></div>${action('more-shops','Xem thêm cửa hàng')}`;
    let number=0;
    async function load() {
      const p=await api('/api/products/home/shops?page='+number++);
      for (const s of p.content) {
        const section=document.createElement('section');section.innerHTML=`<div class="d-flex justify-content-between align-items-center gap-3"><h2 class="h4">${esc(s.shopName)}</h2>${link('/products?shopId='+s.shopId,'Xem '+s.totalProducts+' sản phẩm')}</div>${s.products.length?cards(s.products):'<p class="ute-muted">Cửa hàng chưa có sản phẩm đang mở bán.</p>'}`;$('#shops').append(section);
      }
      $('#more-shops').hidden=number>=p.totalPages;
      if(!p.totalElements)$('#shops').textContent='Chưa có cửa hàng. Quản trị viên cần tạo dữ liệu cửa hàng trước.';
    }
    bind('#more-shops','click',load);await load();
  }
  async function products() {
    const categories=await api('/api/categories');
    content.innerHTML=`<h1>Thực đơn ${query.get('shopId')?'của cửa hàng':'tất cả cửa hàng'}</h1><form id="search" class="ute-toolbar">${field('keyword','Tên món','search',query.get('keyword')||'')}${select('categoryId','Danh mục',[['','Tất cả'],...categories.map(c=>[c.id,c.name])],query.get('categoryId'))}${select('sort','Sắp xếp',[['newest','Mới nhất'],['best_selling','Bán chạy'],['price_asc','Giá tăng dần'],['price_desc','Giá giảm dần']],query.get('sort')||'best_selling')}${action('search-submit','Tìm kiếm','btn btn-success','submit')}</form><div id="results"></div>`;
    let number=0;
    async function load(next=0, append=false) {
      const params=new URLSearchParams(formData($('#search')));if(query.get('shopId'))params.set('shopId',query.get('shopId'));params.set('page',next);params.set('size','12');
      const p=await api('/api/products?'+params);number=next;
      if(!append)$('#results').innerHTML=`<p>${p.totalElements} sản phẩm</p><div id="product-cards"></div>`;
      $('#product-cards').insertAdjacentHTML('beforeend', cards(p.items));$('#load-products')?.remove();
      if(number+1<p.totalPages){$('#results').insertAdjacentHTML('beforeend',action('load-products','Xem thêm sản phẩm'));bind('#load-products','click',()=>load(number+1,true));}
    }
    bind('#search','submit',()=>load());await load();
  }
  async function productDetail() {
    const id=location.pathname.split('/').pop();const p=await api('/api/products/'+id);
    content.innerHTML=`${link('/products?shopId='+p.shopId,'← '+p.shopName)}<section class="ute-panel"><h1>${esc(p.name)}</h1><div class="ute-gallery">${p.imageUrls.map(src=>image(src,p.name)).join('')}</div><p class="mt-3">${esc(p.description)}</p><p class="ute-price h4" id="detail-price">${money(p.price)}</p><p>Danh mục: ${esc(p.categoryName)} · Tồn kho: ${p.stock}</p><form id="add-cart" class="ute-form">${p.attributes.map(a=>select('attr-'+a.attributeId,a.attributeName,a.values.map(v=>[v.value,v.value+(v.extraPrice?' (+'+money(v.extraPrice)+')':'')]))).join('')}${field('quantity','Số lượng','number',1,`required min="1" max="${p.stock}"`)}${action('add-submit',p.stock?'Thêm vào giỏ hàng':'Hết hàng','btn btn-success','submit')}</form></section><h2 class="h4">Đánh giá từ người đã mua</h2><div id="reviews"></div>${action('more-reviews','Xem thêm đánh giá','btn btn-outline-secondary')}`;
    $('#add-submit').disabled=p.stock<=0;
    $('#add-cart').insertAdjacentHTML('afterend',action('favorite-product','Yêu thích / bỏ yêu thích','btn btn-outline-danger mt-3'));
    bind('#favorite-product','click',async()=>{if(!localStorage.getItem('accessToken')){location.href=url('/auth/login');return;}await api('/api/customer/favorites/products/'+p.id,{method:'POST'});notice('Đã cập nhật danh sách yêu thích.');});
    const extra=()=>{let total=Number(p.price);for(const a of p.attributes){const value=$('#add-cart').elements.namedItem('attr-'+a.attributeId).value;total+=Number(a.values.find(v=>v.value===value)?.extraPrice||0);}$('#detail-price').textContent=money(total);};$('#add-cart').onchange=extra;extra();
    bind('#add-cart','submit',async()=>{
      if(!localStorage.getItem('accessToken')){location.href=url('/auth/login');return;}
      const form=$('#add-cart');const quantity=Number(form.elements.quantity.value);const data={};for(const a of p.attributes)data[a.attributeName]=form.elements.namedItem('attr-'+a.attributeId).value;
      await api('/api/customer/cart/items',{method:'POST',body:{productId:p.id,quantity,selectedAttributes:JSON.stringify(data)}});notice('Đã thêm vào giỏ hàng của '+p.shopName+'.');
    });
    let number=0;async function reviews(){const r=await api(`/api/products/${id}/reviews?page=${number++}`);for(const item of r.content)$('#reviews').insertAdjacentHTML('beforeend',`<article class="ute-panel"><strong>${esc(item.userFullName)} · ${item.rating}/5</strong><p>${esc(item.comment)}</p><div class="ute-gallery">${item.mediaUrls.map(src=>(src.includes('/video/')||/\.(mp4|webm)(?:[?#]|$)/i.test(src))?`<video controls src="${safeMedia(src)}"></video>`:image(src,'Ảnh đánh giá')).join('')}</div></article>`);$('#more-reviews').hidden=number>=r.totalPages;if(!r.totalElements)$('#reviews').textContent='Chưa có đánh giá.';}bind('#more-reviews','click',reviews);await reviews();
  }
  // Keep the buyer's selection when a quantity change reloads the cart.
  const cartChoices = new Map();
  async function cart() {
    const carts=await api('/api/customer/cart');
    content.innerHTML='<h1>Giỏ hàng của bạn</h1><p class="ute-muted">Tick những món muốn mua. Mỗi cửa hàng được đặt thành một đơn riêng; món chưa chọn vẫn ở trong giỏ.</p>';
    if(!carts.length)content.insertAdjacentHTML('beforeend',`<p>Giỏ hàng đang trống.</p>${link('/products','Chọn món')}`);
    for(const c of carts){
      for(const i of c.items)if(!cartChoices.has(i.cartItemId))cartChoices.set(i.cartItemId,!i.unavailableReason);
      const section=document.createElement('section');section.className='ute-panel';
      section.innerHTML=`<h2 class="h4">${esc(c.shopName)}</h2><label class="cart-select-all"><input type="checkbox" id="all-${c.shopId}"> Chọn tất cả món có thể mua</label>${table(['Chọn','Món','Đơn giá','Số lượng','Thành tiền',''],c.items.map(i=>`<tr><td><input class="cart-item-choice" type="checkbox" id="choose-${i.cartItemId}" aria-label="Chọn ${esc(i.productName)}" ${cartChoices.get(i.cartItemId)&&!i.unavailableReason?'checked':''} ${i.unavailableReason?'disabled':''}></td><td>${esc(i.productName)}<br><small>${attributesText(i.selectedAttributes)}</small>${i.unavailableReason?'<p class="text-danger">'+esc(i.unavailableReason)+'</p>':''}</td><td>${money(i.unitPrice)}</td><td><div class="cart-quantity">${action('minus-'+i.cartItemId,'−','btn btn-sm btn-outline-success')}<input aria-label="Số lượng ${esc(i.productName)}" id="qty-${i.cartItemId}" type="number" min="1" value="${i.quantity}">${action('plus-'+i.cartItemId,'+','btn btn-sm btn-outline-success')}</div></td><td>${money(i.lineTotal)}</td><td>${action('remove-'+i.cartItemId,'Xóa','btn btn-sm btn-outline-danger')}</td></tr>`))}<p class="ute-total" id="selected-total-${c.shopId}"></p>${action('checkout-'+c.shopId,'Mua các món đã chọn','btn btn-success')}`;
      content.append(section);
      const selected=()=>c.items.filter(i=>!i.unavailableReason&&cartChoices.get(i.cartItemId));
      function refreshSelection(){
        const chosen=selected(),available=c.items.filter(i=>!i.unavailableReason);
        const all=$('#all-'+c.shopId);all.checked=available.length>0&&chosen.length===available.length;all.indeterminate=chosen.length>0&&!all.checked;all.disabled=!available.length;
        $('#selected-total-'+c.shopId).textContent='Đã chọn '+chosen.length+' món · Tạm tính: '+money(chosen.reduce((sum,i)=>sum+Number(i.lineTotal),0));
        $('#checkout-'+c.shopId).disabled=!chosen.length;
      }
      $('#all-'+c.shopId).addEventListener('change',e=>{for(const i of c.items)if(!i.unavailableReason){cartChoices.set(i.cartItemId,e.target.checked);$('#choose-'+i.cartItemId).checked=e.target.checked;}refreshSelection();});
      bind('#checkout-'+c.shopId,'click',()=>{const ids=selected().map(i=>i.cartItemId);if(ids.length)location.href=url('/customer/checkout?shopId='+c.shopId+'&cartItemIds='+ids.join(','));});
      for(const i of c.items){
        $('#choose-'+i.cartItemId).addEventListener('change',e=>{cartChoices.set(i.cartItemId,e.target.checked);refreshSelection();});
        const input=$('#qty-'+i.cartItemId);let busy=false;
        const update=async quantity=>{if(busy)return;if(!Number.isInteger(quantity)||quantity<1){input.value=i.quantity;return;}busy=true;const controls=[...section.querySelectorAll('button,input')].map(x=>[x,x.disabled]);controls.forEach(([x])=>x.disabled=true);try{await api('/api/customer/cart/items/'+i.cartItemId,{method:'PUT',body:{quantity}});await cart();}catch(e){input.value=i.quantity;notice(e.message,true);}finally{busy=false;controls.forEach(([x,disabled])=>x.disabled=disabled);}};
        bind('#minus-'+i.cartItemId,'click',()=>update(i.quantity-1));bind('#plus-'+i.cartItemId,'click',()=>update(i.quantity+1));input.addEventListener('change',()=>update(Number(input.value)));$('#minus-'+i.cartItemId).disabled=i.quantity<=1;
        bind('#remove-'+i.cartItemId,'click',async()=>{await api('/api/customer/cart/items/'+i.cartItemId,{method:'DELETE'});cartChoices.delete(i.cartItemId);await cart();notice('Đã xóa món.');});
      }
      refreshSelection();
    }
  }
  function totals(q){return `<p>Tiền món: ${money(q.subtotal)}</p><p>Giảm giá món: −${money(q.discountAmount)}</p><p>Phí giao hàng: ${money(q.shippingFee)}</p><p class="ute-total">Tổng thanh toán: ${money(q.totalAmount)}</p>`;}
  async function checkout() {
    const shopId=Number(query.get('shopId'));const carts=await api('/api/customer/cart');const c=carts.find(x=>x.shopId===shopId);if(!c)throw new Error('Chọn cửa hàng trong giỏ trước khi thanh toán.');
    const idsParam=query.get('cartItemIds');
    const cartItemIds=idsParam===null?c.items.map(i=>i.cartItemId):idsParam.split(',').map(Number);
    if(!cartItemIds.length||cartItemIds.some(id=>!Number.isSafeInteger(id)||id<=0)||new Set(cartItemIds).size!==cartItemIds.length||cartItemIds.some(id=>!c.items.some(i=>i.cartItemId===id)))throw new Error('Danh sách món đã chọn không còn hợp lệ. Hãy quay lại giỏ hàng chọn lại.');
    c.items=c.items.filter(i=>cartItemIds.includes(i.cartItemId));
    content.innerHTML=`<h1>Đặt hàng · ${esc(c.shopName)}</h1>${table(['Món','Số lượng','Thành tiền'],c.items.map(i=>`<tr><td>${esc(i.productName)}<br>${attributesText(i.selectedAttributes)}</td><td>${i.quantity}</td><td>${money(i.lineTotal)}</td></tr>`))}<form id="checkout" class="ute-form ute-panel"><label>Địa chỉ nhận hàng<textarea name="shippingAddress" required maxlength="2000" placeholder="Tên người nhận, số điện thoại, số nhà, đường, phường/xã…"></textarea></label>${field('voucherCode','Mã giảm giá (nếu có)')}${select('offer','Ưu đãi của cửa hàng', [['','Chọn mã giảm giá']])}<small id="offer-status" aria-live="polite"></small>${select('paymentMethod','Phương thức thanh toán',[['COD','Tiền mặt khi nhận hàng'],['VNPAY','VNPay'],['MOMO','MoMo']])}<div class="ute-actions">${action('quote','Tính lại tổng tiền','btn btn-outline-success')}${action('place','Xác nhận đặt hàng','btn btn-success','submit')}</div><div id="quote-result"></div></form>`;
    let currentQuote='';let confirmedTotal=null;
    let offersBusy=false,offersVersion='';
    async function refreshOffers(){
      if(offersBusy || document.hidden)return; offersBusy=true;
      try{
        const offers=await api('/api/customer/orders/offers?shopId='+shopId+'&cartItemIds='+cartItemIds.join(','));
        const version=JSON.stringify(offers);
        if(version!==offersVersion){
          const current=$('[name=offer]').value;
          $('[name=offer]').innerHTML='<option value="">Chọn mã giảm giá</option>'+offers.map(o=>'<option value="'+esc(o.code)+'" '+(!o.eligible?'disabled':'')+'>'+esc(o.code)+' — '+(o.type==='SHIPPING'?'Giảm phí giao hàng ':'Giảm tiền món ')+(o.discountType==='PERCENT'?o.value+'%':money(o.value))+'; đơn từ '+money(o.minimum)+(o.maximum!=null?'; tối đa '+money(o.maximum):'')+(!o.eligible?' (chưa đủ điều kiện)':'')+'</option>').join('');
          $('[name=offer]').value=offers.some(o=>o.code===current&&o.eligible)?current:'';
          if(offersVersion){$('#place').disabled=true;currentQuote='';$('#quote-result').textContent='Ưu đãi đã thay đổi. Hãy tính lại tổng tiền.';}
          offersVersion=version;
        }
        $('#offer-status').textContent=offers.length?'Ưu đãi cập nhật trực tiếp; kiểm tra lại mỗi 5 giây khi mất kết nối.':'Chưa có mã khả dụng cho tài khoản này tại cửa hàng.';
      }catch(e){$('#offer-status').textContent='Không cập nhật được ưu đãi: '+e.message;}finally{offersBusy=false;}
    }
    $('[name=offer]').addEventListener('change',()=>{$('[name=voucherCode]').value=$('[name=offer]').value;$('#place').disabled=true;currentQuote='';});
    $('[name=voucherCode]').addEventListener('input',()=>{$('[name=offer]').value='';});
    const offersTimer=setInterval(refreshOffers,5000);
    window.addEventListener('pagehide',()=>clearInterval(offersTimer),{once:true});
    window.addEventListener('focus',refreshOffers);
    setTimeout(refreshOffers,0);
    watch('/topic/shop/'+shopId+'/offers',()=>{currentQuote='';$('#place').disabled=true;$('#quote-result').textContent='Ưu đãi cửa hàng vừa thay đổi. Hãy tính lại tổng tiền.';refreshOffers();});
    const methods=await api('/api/payment/methods');
    for(const option of $('[name=paymentMethod]').options){const method=methods.find(m=>m.code===option.value);option.disabled=!method?.available;if(option.disabled)option.textContent+=' — chưa cấu hình';}
    const request=()=>{const {offer,...body}=formData($('#checkout'));return {...body,shopId,cartItemIds};};
    async function quote(){if(!$('#checkout').reportValidity())return;const body=request();const q=await api('/api/customer/orders/quote',{method:'POST',body});$('#quote-result').innerHTML=totals(q);currentQuote=JSON.stringify(body);confirmedTotal=q.totalAmount;$('#place').disabled=false;}
    $('#place').disabled=true;$('#checkout').addEventListener('input',()=>{$('#place').disabled=true;currentQuote='';});$('#checkout').addEventListener('change',()=>{$('#place').disabled=true;currentQuote='';});
    bind('#quote','click',quote);bind('#checkout','submit',async()=>{const body=request();if(JSON.stringify(body)!==currentQuote){await quote();return;}const o=await api('/api/customer/orders',{method:'POST',body:{...body,expectedTotalAmount:confirmedTotal}});location.href=url('/customer/payment?orderId='+o.id);});
  }
  let stopPaymentWatch = () => {};
  async function payment() {
    stopPaymentWatch();
    const orderId=query.get('localOrderId')||query.get('orderId');if(!orderId)throw new Error('Thiếu mã đơn hàng.');
    const o=await api('/api/customer/orders/'+orderId);
    const pending=o.paymentMethod==='VNPAY'&&o.status==='NEW'&&o.paymentStatus!=='SUCCESS';
    content.innerHTML=`<h1>Thanh toán đơn hàng</h1><section class="ute-panel"><p>${esc(o.orderCode)}</p><p>Cửa hàng: ${esc(o.shopName)}</p>${totals(o)}<p>Phương thức: ${methodText(o.paymentMethod)} · Thanh toán: <strong>${statusText(o.paymentStatus)}</strong></p><p id="payment-note">${o.paymentMethod==='COD'?'Thanh toán cho người giao hàng khi nhận đơn.':'Web tự cập nhật khi nhận xác nhận thanh toán từ cổng.'}</p>${pending?'<div id="payment-qr" aria-live="polite"><p>Đang lấy mã QR từ VNPay…</p></div>':''}<div class="ute-actions">${action('refresh-payment','Cập nhật trạng thái','btn btn-outline-success')}${o.status==='NEW'&&o.paymentStatus!=='SUCCESS'?action('pay','Mở cổng '+o.paymentMethod):''}${link('/customer/orders/'+o.id,'Xem đơn hàng')}</div></section>`;
    bind('#refresh-payment','click',payment);
    bind('#pay','click',async()=>{const result=await api('/api/payment/'+o.paymentMethod.toLowerCase(),{method:'POST',body:{orderId:o.id}});location.assign(result.paymentUrl);});
    let disposed=false,checking=false,expiresAt=null;
    async function refreshStatus(){
      if(disposed||checking||document.hidden)return;checking=true;
      try{const current=await api('/api/customer/orders/'+o.id);if(!disposed&&(current.paymentStatus!==o.paymentStatus||current.status!==o.status))await payment();}
      catch(e){if(!disposed)$('#payment-note').textContent='Chưa cập nhật được trạng thái. '+e.message;}finally{checking=false;}
    }
    async function loadQr(){
      const box=$('#payment-qr');if(!box||disposed)return;
      box.textContent='Đang lấy mã QR từ VNPay…';
      try{
        const result=await api('/api/payment/vnpay/qr',{method:'POST',body:{orderId:o.id}});if(disposed)return;
        if(!/^data:image\/png;base64,[A-Za-z0-9+/=]+$/.test(result.qrImage))throw new Error('Ảnh QR không hợp lệ.');
        expiresAt=Date.parse(result.expiresAt);
        box.innerHTML='<h2 class="h5">Quét mã thanh toán VNPay</h2>'+(result.environment==='sandbox'?'<p class="text-warning">QR thử nghiệm — không dùng để chuyển tiền thật.</p>':'<p>Quét bằng ứng dụng hỗ trợ VNPAY-QR và kiểm tra số tiền trước khi xác nhận.</p>')+'<img alt="Mã QR thanh toán đơn hàng" style="max-width:100%;width:320px;height:auto" src="'+result.qrImage+'"><p id="qr-countdown"></p>';
      }catch(e){if(!disposed){box.innerHTML='<p>'+esc(e.message)+'</p>'+action('qr-retry','Thử lấy lại QR','btn btn-outline-success');bind('#qr-retry','click',loadQr);}}
    }
    const polling=setInterval(refreshStatus,5000);
    const countdown=setInterval(()=>{if(!expiresAt||disposed)return;const left=Math.max(0,Math.ceil((expiresAt-Date.now())/1000));const node=$('#qr-countdown');if(node)node.textContent='Mã hết hạn sau '+Math.floor(left/60)+':'+String(left%60).padStart(2,'0');if(left===0){expiresAt=null;$('#payment-qr').innerHTML='<p>Mã QR đã hết hạn.</p>'+action('qr-retry','Tạo lại mã QR','btn btn-outline-success');bind('#qr-retry','click',loadQr);}},1000);
    stopPaymentWatch=()=>{disposed=true;clearInterval(polling);clearInterval(countdown);};
    window.addEventListener('pagehide',()=>stopPaymentWatch(),{once:true});
    if(o.paymentStatus!=='SUCCESS')watch('/topic/order/'+o.id+'/status',refreshStatus);
    if(pending)await loadQr();
  }
  const vendorNav = () => `<nav class="ute-nav">${link('/vendor/products','Sản phẩm')}${link('/vendor/orders','Đơn hàng')}${link('/vendor/vouchers','Voucher')}${link('/vendor/promotions','Khuyến mãi')}</nav>`;
  const adminNav = () => `<nav class="ute-nav">${link('/admin/categories','Danh mục')}${link('/admin/attributes','Thuộc tính & duyệt sản phẩm')}</nav>`;
  async function vendorShell(title, render) {
    const shops=await api('/api/vendor/catalog/shops');let shopId=Number(query.get('shopId')||sessionStorage.getItem('vendorShopId'));
    if(!shops.some(s=>s.id===shopId))shopId=shops[0]?.id;
    content.innerHTML=vendorNav()+`<h1>${esc(title)}</h1>`;
    if(!shopId){content.insertAdjacentHTML('beforeend','<p>Tài khoản chưa quản lý cửa hàng nào. Hãy tạo hoặc nhận quyền sở hữu cửa hàng trong module quản lý shop.</p>');return;}
    sessionStorage.setItem('vendorShopId',shopId);content.insertAdjacentHTML('beforeend',`<div class="ute-toolbar">${select('shop','Cửa hàng đang quản lý',shops.map(s=>[s.id,s.name]),shopId)}</div><div id="vendor-body"></div>`);
    $('[name=shop]').onchange=()=>{const params=new URLSearchParams(location.search);params.set('shopId',$('[name=shop]').value);params.delete('id');location.search=params;};watch('/topic/shop/'+shopId+'/orders');await render(shopId,$('#vendor-body'));
  }
  async function vendorProducts() {
    await vendorShell('Sản phẩm theo cửa hàng',async(shop,body)=>{let number=0;async function load(n=0){number=n;const p=await api(`/api/vendor/shops/${shop}/products?page=${n}`);body.innerHTML=`${link('/vendor/product-form?shopId='+shop,'Thêm sản phẩm','btn btn-success')}<p class="mt-3 ute-muted">Sản phẩm mới ở trạng thái chờ duyệt; quản trị viên duyệt trước khi mở bán.</p>${table(['Món','Giá','Tồn','Đã bán','Trạng thái',''],p.items.map(i=>`<tr><td>${esc(i.name)}</td><td>${money(i.price)}</td><td>${i.stock}</td><td>${i.soldCount}</td><td>${esc(({ACTIVE:'Đang bán',PENDING:'Chờ duyệt',ARCHIVED:'Đã ẩn'})[i.status]||i.status)}</td><td>${link('/vendor/product-form?shopId='+shop+'&id='+i.id,'Sửa','btn btn-sm btn-outline-success')} ${action('delete-'+i.id,'Xóa','btn btn-sm btn-outline-danger')}</td></tr>`))}<div class="ute-actions">${action('vp-prev','Trang trước','btn btn-outline-secondary')}${action('vp-next','Trang sau','btn btn-outline-secondary')}</div>`;$('#vp-prev').disabled=n===0;$('#vp-next').disabled=n+1>=p.totalPages;bind('#vp-prev','click',()=>load(number-1));bind('#vp-next','click',()=>load(number+1));for(const i of p.items)bind('#delete-'+i.id,'click',async()=>{if(!confirm('Ẩn sản phẩm '+i.name+' khỏi danh sách?'))return;await api(`/api/vendor/shops/${shop}/products/${i.id}`,{method:'DELETE'});await load();});}await load();});
  }
  async function vendorProductForm() {
    await vendorShell('Thông tin sản phẩm',async(shop,body)=>{const id=query.get('id');const p=id?await api(`/api/vendor/shops/${shop}/products/${id}`):{};const cats=await api('/api/categories');body.innerHTML=`<form id="product-form" class="ute-form ute-panel">${field('name','Tên món','text',p.name||'','required maxlength="255"')}${select('categoryId','Danh mục',cats.map(c=>[c.id,c.name]),p.categoryId)}<label>Mô tả<textarea name="description">${esc(p.description)}</textarea></label>${field('price','Giá (VND)','number',p.price||30000,'required min="1" step="1"')}${field('stock','Tồn kho','number',p.stock??10,'required min="0" step="1"')}${action('save-product','Lưu sản phẩm','btn btn-success','submit')}</form>${id?`<section class="ute-panel"><h2 class="h5">Ảnh sản phẩm</h2><div class="ute-gallery">${p.imageUrls.map(src=>image(src,p.name)).join('')}</div><form id="upload-product"><label class="my-3">Chọn ảnh <input name="file" type="file" accept="image/jpeg,image/png,image/webp,image/gif" required></label> ${action('upload-product-button','Tải ảnh lên','btn btn-outline-success','submit')}</form></section>`:'<p>Lưu sản phẩm trước khi tải ảnh lên.</p>'}`;
      bind('#product-form','submit',async()=>{const r=formData($('#product-form'));for(const key of ['categoryId','price','stock'])r[key]=Number(r[key]);const saved=await api(`/api/vendor/shops/${shop}/products`+(id?'/'+id:''),{method:id?'PUT':'POST',body:r});location.href=url(`/vendor/product-form?shopId=${shop}&id=${saved.id}`);});bind('#upload-product','submit',async()=>{await api(`/api/vendor/shops/${shop}/products/${id}/images`,{method:'POST',body:new FormData($('#upload-product'))});await vendorProductForm();notice('Đã tải ảnh lên.');});});
  }
  const statuses=['NEW','CONFIRMED','PICKED_UP','SHIPPING','DELIVERED','CANCELLED','RETURNED','REFUNDED'];
  async function orderList(vendor=false) {
    async function render(shop,body){body.innerHTML=`<div class="ute-toolbar">${select('status','Trạng thái',[['','Tất cả'],...statuses.map(x=>[x,statusLabels[x]])])}</div><div id="orders-table"></div><div class="ute-actions">${action('order-prev','Trang trước','btn btn-outline-secondary')}${action('order-next','Trang sau','btn btn-outline-secondary')}</div>`;let number=0;async function load(n=0){number=n;const p=await api((vendor?`/api/vendor/shops/${shop}/orders`:'/api/customer/orders')+`?page=${n}&status=${$('[name=status]').value}`);$('#orders-table').innerHTML=table(['Mã đơn','Cửa hàng','Tổng tiền','Trạng thái','Thanh toán',''],p.content.map(o=>`<tr><td>${esc(o.orderCode)}</td><td>${esc(o.shopName)}</td><td>${money(o.totalAmount)}</td><td>${statusText(o.status)}</td><td>${statusText(o.paymentStatus)}</td><td>${link((vendor?'/vendor':'/customer')+'/orders/'+o.id+(vendor?'?shopId='+shop:''),'Chi tiết','btn btn-sm btn-outline-success')}</td></tr>`));$('#order-prev').disabled=n===0;$('#order-next').disabled=n+1>=p.totalPages;}$('[name=status]').onchange=()=>load().catch(e=>notice(e.message,true));bind('#order-prev','click',()=>load(number-1));bind('#order-next','click',()=>load(number+1));await load();}
    if(vendor)await vendorShell('Đơn hàng cửa hàng',render);else{content.innerHTML='<h1>Đơn hàng của bạn</h1><div id="order-list"></div>';await render(null,$('#order-list'));}
  }
  async function orderDetail(vendor=false) {
    const id=location.pathname.split('/').pop();const shop=Number(query.get('shopId')||sessionStorage.getItem('vendorShopId'));const o=await api(vendor?`/api/vendor/shops/${shop}/orders/${id}`:'/api/customer/orders/'+id);
    watch('/topic/order/'+o.id+'/status');content.innerHTML=(vendor?vendorNav():'')+`<h1>Chi tiết đơn hàng</h1><section class="ute-panel"><p>${esc(o.orderCode)}</p><p><strong>${esc(o.shopName)}</strong> · ${statusText(o.status)} · ${methodText(o.paymentMethod)} / ${statusText(o.paymentStatus)}</p><p>Giao đến: ${esc(o.shippingAddress)}</p>${table(['Món','Đơn giá','Số lượng',''],o.items.map(i=>`<tr><td>${esc(i.productName)}<br>${attributesText(i.selectedAttributes)}</td><td>${money(i.unitPrice)}</td><td>${i.quantity}</td><td>${!vendor&&o.status==='DELIVERED'?link(`/customer/review?orderId=${o.id}&productId=${i.productId}`,'Đánh giá','btn btn-sm btn-outline-success'):''}</td></tr>`))}${totals(o)}</section><section class="ute-panel"><h2 class="h5">Lịch sử</h2>${o.statusHistory.map(h=>`<p>${esc(h.createdAt)} · <strong>${statusText(h.status)}</strong> · ${esc(h.note)}</p>`).join('')}</section>`;
    if(vendor){const next={NEW:['CONFIRMED','CANCELLED'],CONFIRMED:['PICKED_UP','CANCELLED'],PICKED_UP:['SHIPPING'],SHIPPING:['DELIVERED','RETURNED'],DELIVERED:['RETURNED'],RETURNED:['REFUNDED']}[o.status]||[];if(next.length){content.insertAdjacentHTML('beforeend',`<form id="status-form" class="ute-form ute-panel">${select('status','Chuyển trạng thái',next.map(s=>[s,statusLabels[s]]))}${field('note','Ghi chú / lý do','text','','maxlength="255"')}${action('save-status','Cập nhật trạng thái','btn btn-success','submit')}</form>`);bind('#status-form','submit',async()=>{await api(`/api/vendor/shops/${shop}/orders/${id}/status`,{method:'PATCH',body:formData($('#status-form'))});await orderDetail(true);notice('Đã cập nhật trạng thái.');});}}
    else if(['NEW','CONFIRMED'].includes(o.status)){content.insertAdjacentHTML('beforeend',`<div class="ute-actions">${o.status==='NEW'?link('/customer/payment?orderId='+id,'Thanh toán'):''}${action('cancel','Hủy đơn hàng','btn btn-outline-danger')}</div>`);bind('#cancel','click',async()=>{const reason=prompt('Lý do hủy đơn?');if(!reason?.trim())return;await api(`/api/customer/orders/${id}/cancel`,{method:'POST',body:{reason}});await orderDetail();notice('Đã hủy đơn. Nếu đã thanh toán trực tuyến, liên hệ cửa hàng để đối soát hoàn tiền.');});}
  }
  async function review() {
    content.innerHTML=`<h1>Đánh giá sản phẩm đã mua</h1><form id="review-form" class="ute-form ute-panel">${select('rating','Số sao',[[5,'5 · Rất hài lòng'],[4,'4 · Hài lòng'],[3,'3 · Bình thường'],[2,'2 · Chưa hài lòng'],[1,'1 · Không hài lòng']])}<label>Nội dung đánh giá (không bắt buộc)<textarea name="comment" maxlength="5000"></textarea></label><label>Ảnh/video (không bắt buộc, tối đa 5 tệp, 20 MB/tệp)<input type="file" name="media" multiple accept="image/jpeg,image/png,image/webp,image/gif,video/mp4,video/webm"></label>${action('review-save','Gửi đánh giá','btn btn-success','submit')}</form>`;
    bind('#review-form','submit',async()=>{const f=$('#review-form');const files=f.elements.media.files;if(files.length>5)throw new Error('Chọn tối đa 5 ảnh/video.');const mediaUrls=[];for(const file of files){const data=new FormData();data.append('file',file);const result=await api('/api/customer/reviews/media',{method:'POST',body:data});mediaUrls.push(result.url);}await api('/api/customer/reviews',{method:'POST',body:{productId:Number(query.get('productId')),orderId:Number(query.get('orderId')),rating:Number(f.elements.rating.value),comment:f.elements.comment.value,mediaUrls}});location.href=url('/products/'+query.get('productId'));});
  }
  async function discounts(promotion=false) {
    const kind=promotion?'promotions':'vouchers';await vendorShell(promotion?'Khuyến mãi sản phẩm':'Voucher cửa hàng',async(shop,body)=>{
      const endpoint=`/api/vendor/shops/${shop}/${kind}`;const list=await api(endpoint);let selected=null;
      body.innerHTML=`${table(promotion?['Tên','Mức giảm','Hiệu lực','']:['Mã','Áp dụng','Mức giảm','Lượt dùng',''],list.map(v=>`<tr><td>${esc(promotion?v.name:v.code)}</td>${promotion?'':`<td>${v.voucherType==='SHIPPING'?'Phí giao hàng':'Tiền món'}</td>`}<td>${v.discountType==='PERCENT'?v.discountValue+'%':money(v.discountValue)}</td><td>${promotion?dateText(v.startDate)+' → '+dateText(v.endDate):v.usedCount+' / '+(v.usageLimit??'∞')}</td><td>${action('detail-'+v.id,'Xem chi tiết','btn btn-sm btn-outline-success')} ${action('edit-'+v.id,'Sửa','btn btn-sm btn-outline-success')} ${action('delete-'+v.id,'Xóa','btn btn-sm btn-outline-danger')}</td></tr>`))}<section id="discount-details" class="ute-panel" hidden tabindex="-1" aria-live="polite"></section><h2 class="h4 mt-4" id="discount-title">Tạo mới</h2><form id="discount-form" class="ute-form ute-panel">${field(promotion?'name':'code',promotion?'Tên khuyến mãi':'Mã voucher','text','','required')}${promotion?field('productIds','ID sản phẩm trong cửa hàng (cách nhau bằng dấu phẩy)','text','','required'):select('voucherType','Áp dụng cho',[['PRODUCT','Tiền món'],['SHIPPING','Phí giao hàng']])}${select('discountType','Kiểu giảm',[['PERCENT','Phần trăm'],['FIXED','Số tiền cố định']])}${field('discountValue','Mức giảm','number',10,'required min="1"')}${promotion?'':field('minOrderAmount','Giá trị đơn tối thiểu','number',0,'min="0"')+field('maxDiscountAmount','Mức giảm tối đa (để trống nếu không giới hạn)','number','','min="0"')+field('usageLimit','Tổng số lượt (để trống nếu không giới hạn)','number','','min="1"')}${field('startDate','Bắt đầu','datetime-local','','required')}${field('endDate','Kết thúc','datetime-local','','required')}<div class="ute-actions">${action('discount-save','Lưu','btn btn-success','submit')}${action('discount-reset','Tạo mã mới','btn btn-outline-secondary')}</div></form>`;
      for(const v of list){bind('#detail-'+v.id,'click',async()=>{
        const panel=$('#discount-details');panel.dataset.detailId=String(v.id);const now=Date.now();const state=now<new Date(v.startDate).getTime()?'Chưa bắt đầu':now>=new Date(v.endDate).getTime()?'Đã hết hạn':!promotion&&v.usageLimit!=null&&v.usedCount>=v.usageLimit?'Đã hết lượt':'Đang có hiệu lực';
        const facts=[['Cửa hàng',$('[name=shop]').selectedOptions[0]?.textContent||''],[promotion?'Tên khuyến mãi':'Mã giảm giá',promotion?v.name:v.code],['Tình trạng',state],['Kiểu giảm',v.discountType==='PERCENT'?'Phần trăm':'Số tiền cố định'],['Mức giảm',v.discountType==='PERCENT'?v.discountValue+'%':money(v.discountValue)],['Bắt đầu',new Date(v.startDate).toLocaleString('vi-VN')],['Kết thúc',new Date(v.endDate).toLocaleString('vi-VN')]];
        if(!promotion)facts.push(['Áp dụng cho',v.voucherType==='SHIPPING'?'Phí giao hàng':'Tiền món'],['Đơn tối thiểu',money(v.minOrderAmount)],['Giảm tối đa',v.maxDiscountAmount==null?'Không giới hạn':money(v.maxDiscountAmount)],['Lượt đã dùng',v.usedCount+' / '+(v.usageLimit??'Không giới hạn')],['Giới hạn mỗi tài khoản','Một lần cho mỗi mã']);
        panel.hidden=false;panel.innerHTML='<h2 class="h4">Chi tiết '+(promotion?'khuyến mãi':'mã giảm giá')+'</h2><dl class="ute-facts">'+facts.map(([label,value])=>'<div><dt>'+esc(label)+'</dt><dd>'+esc(value)+'</dd></div>').join('')+'</dl>'+(promotion?'<h3 class="h6">Sản phẩm áp dụng</h3><ul id="promotion-products"></ul>':'')+action('close-details','Đóng chi tiết','btn btn-outline-secondary');
        bind('#close-details','click',()=>{panel.hidden=true;$('#detail-'+v.id).focus();});panel.focus();panel.scrollIntoView({behavior:'smooth',block:'center'});
        if(promotion){const products=await Promise.all(v.productIds.map(async id=>{try{const p=await api(`/api/vendor/shops/${shop}/products/${id}`);return p.name+' (#'+id+')';}catch{return 'Sản phẩm #'+id+' (không còn khả dụng)';}}));if(panel.isConnected&&panel.dataset.detailId===String(v.id)&&panel.querySelector('#promotion-products'))panel.querySelector('#promotion-products').innerHTML=products.map(name=>'<li>'+esc(name)+'</li>').join('');}
      });bind('#edit-'+v.id,'click',()=>{selected=v.id;$('#discount-title').textContent='Chỉnh sửa #'+v.id;const f=$('#discount-form');for(const [key,value] of Object.entries(v)){if(f.elements.namedItem(key))f.elements.namedItem(key).value=Array.isArray(value)?value.join(','):value??'';}f.scrollIntoView({behavior:'smooth'});});bind('#delete-'+v.id,'click',async()=>{if(!confirm('Xóa mục này?'))return;await api(endpoint+'/'+v.id,{method:'DELETE'});await discounts(promotion);});}
      bind('#discount-reset','click',()=>{selected=null;$('#discount-form').reset();$('#discount-title').textContent='Tạo mới';});bind('#discount-form','submit',async()=>{const r=formData($('#discount-form'));for(const k of ['discountValue','minOrderAmount','maxDiscountAmount','usageLimit'])if(k in r)r[k]=r[k]===''?null:Number(r[k]);if(promotion){r.productIds=r.productIds.split(',').map(x=>Number(x.trim()));r.promotionType=r.discountType;}await api(endpoint+(selected?'/'+selected:''),{method:selected?'PUT':'POST',body:r});await discounts(promotion);notice('Đã lưu.');});
    });
  }
  async function categories(form=false) {
    const data=await api('/api/admin/categories');content.innerHTML=adminNav()+'<h1>Danh mục sản phẩm</h1>';
    if(!form){content.insertAdjacentHTML('beforeend',link('/admin/category-form','Thêm danh mục','btn btn-success')+table(['Tên','Slug','Danh mục cha',''],data.map(c=>`<tr><td>${esc(c.name)}</td><td>${esc(c.slug)}</td><td>${esc(data.find(p=>p.id===c.parentId)?.name||'—')}</td><td>${link('/admin/category-form?id='+c.id,'Sửa','btn btn-sm btn-outline-success')} ${action('cat-delete-'+c.id,'Xóa','btn btn-sm btn-outline-danger')}</td></tr>`)));for(const c of data)bind('#cat-delete-'+c.id,'click',async()=>{if(!confirm('Ẩn danh mục '+c.name+'?'))return;await api('/api/admin/categories/'+c.id,{method:'DELETE'});await categories();});return;}
    const id=Number(query.get('id'));const c=data.find(x=>x.id===id)||{};content.insertAdjacentHTML('beforeend',`<form id="category-form" class="ute-form ute-panel">${field('name','Tên danh mục','text',c.name||'','required')}${field('slug','Slug (chữ thường, số, dấu gạch ngang)','text',c.slug||'','required pattern="[a-z0-9]+(-[a-z0-9]+)*"')}${select('parentId','Danh mục cha',[['','Không có'],...data.filter(x=>x.id!==id).map(x=>[x.id,x.name])],c.parentId)}${action('category-save','Lưu danh mục','btn btn-success','submit')}</form>`);bind('#category-form','submit',async()=>{const params=new URLSearchParams(formData($('#category-form')));if(!params.get('parentId'))params.delete('parentId');await api('/api/admin/categories'+(id?'/'+id:''),{method:id?'PUT':'POST',body:params});location.href=url('/admin/categories');});
  }
  async function attributes(form=false) {
    content.innerHTML=adminNav()+'<h1>Thuộc tính & duyệt sản phẩm</h1><div id="catalog-products"></div><div id="attribute-editor"></div>';
    let number=0;async function loadProducts(n=0){number=n;const list=await api('/api/admin/catalog/products?page='+n);$('#catalog-products').innerHTML=table(['ID','Món / cửa hàng','Trạng thái',''],list.content.map(p=>`<tr><td>${p.id}</td><td>${esc(p.name)}<br><small>${esc(p.shopName)}</small>${p.isDeleted?' · Đã xóa':''}</td><td>${esc(({ACTIVE:'Đang bán',PENDING:'Chờ duyệt',ARCHIVED:'Đã ẩn'})[p.status]||p.status)}</td><td>${link('/admin/attributes?productId='+p.id,'Thuộc tính','btn btn-sm btn-outline-success')} ${!p.isDeleted?action('approve-'+p.id,'Mở bán','btn btn-sm btn-outline-primary')+' '+action('archive-'+p.id,'Ẩn','btn btn-sm btn-outline-secondary'):''}</td></tr>`))+`<div class="ute-actions">${action('ap-prev','Trang trước','btn btn-outline-secondary')}${action('ap-next','Trang sau','btn btn-outline-secondary')}</div>`;$('#ap-prev').disabled=n===0;$('#ap-next').disabled=n+1>=list.totalPages;bind('#ap-prev','click',()=>loadProducts(number-1));bind('#ap-next','click',()=>loadProducts(number+1));for(const p of list.content){bind('#approve-'+p.id,'click',async()=>{await api(`/api/admin/catalog/products/${p.id}/status?status=ACTIVE`,{method:'PATCH'});await loadProducts(number);});bind('#archive-'+p.id,'click',async()=>{await api(`/api/admin/catalog/products/${p.id}/status?status=ARCHIVED`,{method:'PATCH'});await loadProducts(number);});}}
    await loadProducts();const productId=Number(query.get('productId'));if(!productId)return;
    const attrs=await api('/api/admin/attributes?productId='+productId);const editor=$('#attribute-editor');editor.innerHTML=`<section class="ute-panel"><h2 class="h4">Thuộc tính sản phẩm #${productId}</h2>${link('/admin/attribute-form?productId='+productId,'Thêm thuộc tính','btn btn-success')}${table(['Tên','Lựa chọn',''],attrs.map(a=>`<tr><td>${esc(a.name)}</td><td>${a.values.map(v=>esc(v.value)+' (+'+money(v.extraPrice)+')').join(', ')}</td><td>${link(`/admin/attribute-form?productId=${productId}&id=${a.id}`,'Sửa','btn btn-sm btn-outline-success')} ${action('attr-delete-'+a.id,'Xóa','btn btn-sm btn-outline-danger')}</td></tr>`))}</section>`;
    for(const a of attrs)bind('#attr-delete-'+a.id,'click',async()=>{if(!confirm('Xóa thuộc tính này?'))return;await api('/api/admin/attributes/'+a.id,{method:'DELETE'});await attributes();});
    if(form){const id=Number(query.get('id'));const a=attrs.find(x=>x.id===id)||{};editor.insertAdjacentHTML('beforeend',`<form id="attribute-form" class="ute-form ute-panel">${field('name','Tên thuộc tính (ví dụ: Size, Đường)','text',a.name||'','required')}<label>Lựa chọn: mỗi dòng là giá trị | phụ thu (VND)<textarea name="values" required placeholder="M | 0&#10;L | 5000">${esc(a.values?.map(v=>v.value+' | '+v.extraPrice).join('\n')||'')}</textarea></label>${action('attribute-save','Lưu thuộc tính','btn btn-success','submit')}</form>`);bind('#attribute-form','submit',async()=>{const r=formData($('#attribute-form'));const values=r.values.split('\n').filter(x=>x.trim()).map(line=>{const parts=line.split('|');return {value:parts[0].trim(),extraPrice:Number(parts[1]||0)};});await api('/api/admin/attributes'+(id?'/'+id:''),{method:id?'PUT':'POST',body:{productId,name:r.name,values}});location.href=url('/admin/attributes?productId='+productId);});editor.scrollIntoView();}
  }
  let socket;
  function watch(destination, onUpdate) {
    if(socket)socket.close();
    const token=localStorage.getItem('accessToken');if(!token)return;
    socket=new WebSocket((location.protocol==='https:'?'wss://':'ws://')+location.host+url('/ws-native'));
    let buffer='';
    socket.onopen=()=>socket.send('CONNECT\naccept-version:1.2\nhost:'+location.host+'\nAuthorization:Bearer '+token+'\nheart-beat:0,0\n\n\0');
    socket.onmessage=e=>{buffer+=e.data;let end;while((end=buffer.indexOf('\0'))>=0){const frame=buffer.slice(0,end).trimStart();buffer=buffer.slice(end+1);if(frame.startsWith('CONNECTED'))socket.send('SUBSCRIBE\nid:orders\ndestination:'+destination+'\nack:auto\n\n\0');else if(frame.startsWith('MESSAGE')){try{const update=JSON.parse(frame.slice(frame.indexOf('\n\n')+2));if(onUpdate){onUpdate(update);continue;}notice('Đơn #'+update.orderId+' vừa cập nhật: '+(statusLabels[update.status]||update.status)+' / '+(statusLabels[update.paymentStatus]||update.paymentStatus)+'. Tải lại trang để xem chi tiết.');}catch{/* Ignore malformed messages. */}}}};
    window.addEventListener('pagehide',()=>socket?.close(),{once:true});
  }
  const routes={home,products,'product-detail':productDetail,cart,checkout,payment,'customer-orders':()=>orderList(),'customer-order':()=>orderDetail(),review,'vendor-products':vendorProducts,'vendor-product-form':vendorProductForm,'vendor-orders':()=>orderList(true),'vendor-order':()=>orderDetail(true),'vendor-vouchers':()=>discounts(),'vendor-promotions':()=>discounts(true),'admin-categories':()=>categories(),'admin-category-form':()=>categories(true),'admin-attributes':()=>attributes(),'admin-attribute-form':()=>attributes(true)};
  async function main(){if(!['home','products','product-detail'].includes(page)&&!requireLogin())return;await routes[page]?.();}
  main().catch(e=>{notice(e.message,true);if(content.textContent==='Đang tải dữ liệu…')content.innerHTML=link('/','Về trang chủ');});
})();
