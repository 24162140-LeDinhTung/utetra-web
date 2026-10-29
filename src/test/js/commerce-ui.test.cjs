const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { JSDOM } = require('jsdom');
const source = fs.readFileSync(path.join(__dirname, '../../main/resources/static/js/commerce.js'), 'utf8');
const wait = async predicate => { for(let i=0;i<100;i++){if(predicate())return;await new Promise(r=>setTimeout(r,10));}throw Error('UI timed out'); };
function browser(page, handler) {
  const dom = new JSDOM('<div id="commerce" data-page="'+page+'"><div id="notice"></div><div id="commerce-content"></div></div>', {url:'http://localhost/customer/'+page+(page==='payment'?'?orderId=9':'?shopId=1'),runScripts:'outside-only',pretendToBeVisual:true});
  const w=dom.window;w.localStorage.setItem('accessToken','test-token');w.Headers=Headers;
  w.fetch=async (url,options={})=>({ok:true,status:200,text:async()=>JSON.stringify(await handler(url,options))});
  class Socket{constructor(){Socket.last=this;}send(){} close(){}}
  w.WebSocket=Socket;w.eval(source);return {w,dom,Socket};
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
  assert.match(b.w.document.body.textContent,/SUCCESS/);assert.equal(created,1);
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
