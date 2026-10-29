const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { JSDOM } = require('jsdom');
const source = fs.readFileSync(path.join(__dirname, '../../main/resources/static/js/commerce.js'), 'utf8');
const wait = async predicate => { for(let i=0;i<100;i++){if(predicate())return;await new Promise(r=>setTimeout(r,10));}throw Error('UI timed out'); };
function browser(page, handler, search) {
  const dom = new JSDOM('<div id="commerce" data-page="'+page+'"><div id="notice"></div><div id="commerce-content"></div></div>', {url:'http://localhost/customer/'+page+(search ?? (page==='payment'?'?orderId=9':page==='review'?'?orderId=9&productId=3':'?shopId=1')),runScripts:'outside-only',pretendToBeVisual:true});
  const w=dom.window;w.localStorage.setItem('accessToken','test-token');w.Headers=Headers;
  w.fetch=async (url,options={})=>({ok:true,status:200,text:async()=>JSON.stringify(await handler(url,options))});
  class Socket{constructor(){Socket.last=this;}send(){} close(){}}
  w.WebSocket=Socket;w.HTMLElement.prototype.scrollIntoView=function(){};w.eval(source);return {w,dom,Socket};
}
const item = quantity => [{shopId:1,shopName:'Shop A',subtotal:quantity*30000,items:[{cartItemId:3,productName:'Trà sữa',quantity,unitPrice:30000,lineTotal:quantity*30000,selectedAttributes:'{"Size":"L","Đường":"50%"}'}]}];
test('cart plus/minus persist immediately, minimum is one, attributes are readable', async()=>{
 let quantity=1;const writes=[];
 const b=browser('cart',async(url,o)=>{if(o.method==='PUT'){quantity=JSON.parse(o.body).quantity;writes.push(quantity);return {};}return item(quantity);});
 try{
  await wait(()=>b.w.document.querySelector('#plus-3'));
  assert.match(b.w.document.body.textContent,/Kích cỡ: L · Đường: 50%/);
  assert.doesNotMatch(b.w.document.body.textContent,/\{"Size"|Lưu/);
  assert.equal(b.w.document.querySelector('#minus-3').disabled,true);
  b.w.document.querySelector('#plus-3').click();await wait(()=>quantity===2 && b.w.document.querySelector('#qty-3').value==='2');
  b.w.document.querySelector('#minus-3').click();await wait(()=>quantity===1 && b.w.document.querySelector('#qty-3').value==='1');
  assert.deepEqual(writes,[2,1]);
 }finally{b.dom.window.close();}
});
test('checkout selects current shop voucher and invalidates quote after realtime changes',async()=>{
 let offers=[{code:'SAVE10',type:'PRODUCT',discountType:'PERCENT',value:10,minimum:50000,maximum:20000,eligible:true}];const quotes=[];
 const b=browser('checkout',async(url,o)=>{
  if(url==='/api/customer/cart')return item(2);
  if(url==='/api/payment/methods')return [{code:'COD',available:true}];
  if(url.includes('/offers?'))return offers;
  if(url.endsWith('/quote')){quotes.push(JSON.parse(o.body));return {subtotal:60000,discountAmount:6000,shippingFee:15000,totalAmount:69000};}
  throw Error('Unexpected URL '+url);
 });
 try{
  await wait(()=>b.w.document.querySelector('[name=offer]')?.options.length===2);
  const select=b.w.document.querySelector('[name=offer]');select.value='SAVE10';select.dispatchEvent(new b.w.Event('change',{bubbles:true}));
  b.w.document.querySelector('[name=shippingAddress]').value='Địa chỉ thử';b.w.document.querySelector('#quote').click();
  await wait(()=>quotes.length && !b.w.document.querySelector('#place').disabled);
  assert.equal(quotes[0].voucherCode,'SAVE10');assert.equal('offer' in quotes[0],false);assert.equal(quotes[0].shopId,1);
  offers=[];b.Socket.last.onmessage({data:'MESSAGE\n\n{"shopId":1}\0'});
  await wait(()=>b.w.document.querySelector('[name=offer]').options.length===1);
  assert.equal(b.w.document.querySelector('#place').disabled,true);
 }finally{b.dom.window.close();}
});

test('payment renders provider QR automatically and removes it after verified status update', async()=>{
 let paid=false,created=0;
 const b=browser('payment',async(url,o)=>{
  if(url==='/api/payment/vnpay/qr'){created++;return {qrImage:'data:image/png;base64,aGVsbG8=',expiresAt:new Date(Date.now()+60000).toISOString(),environment:'sandbox'};}
  if(url==='/api/customer/orders/9')return {id:9,orderCode:'UTE-9',shopName:'Shop A',subtotal:60000,discountAmount:0,shippingFee:15000,totalAmount:75000,paymentMethod:'VNPAY',paymentStatus:paid?'SUCCESS':'PENDING',status:paid?'CONFIRMED':'NEW'};
  throw Error('Unexpected '+url);
 });
 try {
  await wait(()=>b.w.document.querySelector('#payment-qr img'));
  assert.equal(created,1);assert.match(b.w.document.body.textContent,/QR thử nghiệm/);
  paid=true;b.Socket.last.onmessage({data:'MESSAGE\n\n{"orderId":9,"paymentStatus":"SUCCESS"}\0'});
  await wait(()=>!b.w.document.querySelector('#payment-qr'));
  assert.match(b.w.document.body.textContent,/Đã thanh toán/);assert.equal(created,1);
 }finally{b.dom.window.close();}
});
test('payment leaves portal fallback when hosted QR is unavailable',async()=>{
 const b=browser('payment',async url=>{
  if(url==='/api/payment/vnpay/qr')throw Error('Merchant chưa hỗ trợ QR');
  return {id:9,orderCode:'UTE-9',shopName:'A',subtotal:60000,discountAmount:0,shippingFee:15000,totalAmount:75000,paymentMethod:'VNPAY',paymentStatus:'PENDING',status:'NEW'};
 });
 try{await wait(()=>b.w.document.querySelector('#qr-retry'));assert.ok(b.w.document.querySelector('#pay'));assert.equal(b.w.document.querySelector('#payment-qr img'),null);}
 finally{b.dom.window.close();}
});

test('review allows short comment and zero media files',async()=>{
 let sent;
 const b=browser('review',async(url,options)=>{if(url==='/api/customer/reviews'){sent=JSON.parse(options.body);return {id:1};}throw Error('Unexpected upload/request '+url);});
 try{
  await wait(()=>b.w.document.querySelector('#review-form'));
  const form=b.w.document.querySelector('#review-form');
  assert.equal(form.elements.comment.required,false);assert.equal(form.elements.comment.minLength,-1);
  assert.equal(form.elements.media.required,false);
  form.elements.comment.value='Ngon';form.dispatchEvent(new b.w.Event('submit',{bubbles:true,cancelable:true}));
  await wait(()=>sent);assert.equal(sent.comment,'Ngon');assert.deepEqual(sent.mediaUrls,[]);assert.equal(sent.rating,5);
 }finally{b.dom.window.close();}
});


test('cart checkboxes change selected total and persist after quantity auto-save',async()=>{
 let quantity=1;
 const data=()=>[{shopId:1,shopName:'A',subtotal:quantity*30000+40000,items:[{cartItemId:3,productName:'A',unitPrice:30000,quantity,lineTotal:quantity*30000},{cartItemId:4,productName:'B',unitPrice:40000,quantity:1,lineTotal:40000}]}];
 const b=browser('cart',async(url,o)=>{if(o.method==='PUT')quantity=JSON.parse(o.body).quantity;return data();});
 try{
  await wait(()=>b.w.document.querySelector('#choose-4'));
  const box=b.w.document.querySelector('#choose-4');box.click();
  assert.match(b.w.document.querySelector('#selected-total-1').textContent,/30.000/);
  assert.equal(b.w.document.querySelector('#all-1').indeterminate,true);
  b.w.document.querySelector('#plus-3').click();await wait(()=>b.w.document.querySelector('#qty-3').value==='2');
  assert.equal(b.w.document.querySelector('#choose-4').checked,false);
  b.w.document.querySelector('#all-1').click();b.w.document.querySelector('#all-1').click();
  assert.equal(b.w.document.querySelector('#checkout-1').disabled,true);
 }finally{b.dom.window.close();}
});

test('checkout shows and quotes only selected ids including offer eligibility query',async()=>{
 const writes=[],urls=[];
 const b=browser('checkout',async(url,o)=>{
  urls.push(url);
  if(url==='/api/customer/cart')return [{...item(1)[0],items:[...item(1)[0].items,{cartItemId:4,productName:'Không chọn',quantity:1,lineTotal:90000}]}];
  if(url==='/api/payment/methods')return [{code:'COD',available:true}];
  if(url.includes('/offers?'))return [];
  if(url.endsWith('/quote')){writes.push(JSON.parse(o.body));return {subtotal:30000,discountAmount:0,shippingFee:15000,totalAmount:45000};}
  throw Error(url);
 },'?shopId=1&cartItemIds=3');
 try{await wait(()=>b.w.document.querySelector('#quote'));b.w.document.querySelector('[name=shippingAddress]').value='Địa chỉ thử';b.w.document.querySelector('#quote').click();await wait(()=>writes.length&&urls.some(u=>u.includes('/offers?')));assert.deepEqual(writes[0].cartItemIds,[3]);assert.doesNotMatch(b.w.document.querySelector('table').textContent,/Không chọn/);assert.ok(urls.some(u=>u.endsWith('cartItemIds=3')));}
 finally{b.dom.window.close();}
});

test('order filters, history and next transitions display Vietnamese but send enum codes',async()=>{
 let status='CONFIRMED',sent;
 const b=browser('vendor-order',async(url,o)=>{
  if(o.method==='PATCH'){sent=JSON.parse(o.body);status=sent.status;return {};}
  return {id:1,orderCode:'A',shopName:'Shop A',status,paymentStatus:'PENDING',paymentMethod:'COD',shippingAddress:'Địa chỉ',items:[],statusHistory:[{status:'CONFIRMED',createdAt:'2026-10-29',note:'Đặt hàng'}]};
 });
 try{await wait(()=>b.w.document.querySelector('#status-form'));assert.match(b.w.document.body.textContent,/Đã xác nhận/);assert.match(b.w.document.body.textContent,/Chờ thanh toán/);const select=b.w.document.querySelector('[name=status]');assert.equal(select.options[0].value,'PICKED_UP');assert.equal(select.options[0].textContent,'Đã lấy hàng');b.w.document.querySelector('#status-form').dispatchEvent(new b.w.Event('submit',{cancelable:true}));await wait(()=>sent);assert.equal(sent.status,'PICKED_UP');}
 finally{b.dom.window.close();}
});

test('voucher and promotion details show conditions without opening edit',async()=>{
 for(const promotion of [false,true]){
  const b=browser(promotion?'vendor-promotions':'vendor-vouchers',async url=>{
   if(url==='/api/vendor/catalog/shops')return [{id:1,name:'Shop A'}];
   if(url.endsWith('/products/3'))return {name:'Trà sữa'};
   return [{id:4,code:'SAVE10',name:'Ưu đãi trà',voucherType:'PRODUCT',discountType:'PERCENT',discountValue:10,minOrderAmount:50000,maxDiscountAmount:20000,usedCount:1,usageLimit:100,startDate:'2026-01-01T00:00:00',endDate:'2027-01-01T00:00:00',productIds:[3]}];
  });
  try{await wait(()=>b.w.document.querySelector('#detail-4'));b.w.document.querySelector('#detail-4').click();await wait(()=>b.w.document.querySelector('#discount-details').hidden===false);assert.equal(b.w.document.querySelector('#discount-title').textContent,'Tạo mới');if(promotion)await wait(()=>b.w.document.querySelector('#promotion-products').textContent.includes('Trà sữa'));else{const text=b.w.document.querySelector('#discount-details').textContent;assert.match(text,/50.000/);assert.match(text,/20.000/);assert.match(text,/1 \/ 100/);}b.w.document.querySelector('#close-details').click();assert.equal(b.w.document.querySelector('#discount-details').hidden,true);}
  finally{b.dom.window.close();}
 }
});
