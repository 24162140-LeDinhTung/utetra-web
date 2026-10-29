const {test}=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const {JSDOM}=require('jsdom');
const menuSource=fs.readFileSync(path.join(__dirname,'../../main/resources/static/js/account-menu.js'),'utf8');
const profileSource=fs.readFileSync(path.join(__dirname,'../../main/resources/static/js/profile.js'),'utf8');
const wait=async predicate=>{for(let i=0;i<100;i++){if(predicate())return;await new Promise(r=>setTimeout(r,10));}throw Error('Timed out');};
test('account dropdown renders real profile safely and handles dismissal',async()=>{
 const dom=new JSDOM('<div data-account-menu></div><button id="outside">Ngoài menu</button>',{url:'https://test.example/',runScripts:'outside-only'});
 const w=dom.window;w.localStorage.setItem('accessToken','test');
 w.fetch=async()=>({ok:true,status:200,json:async()=>({code:200,data:{fullName:'<img src=x onerror=alert(1)>',email:'test@example.test',avatarUrl:'javascript:alert(1)'}})});
 try{w.eval(menuSource);await wait(()=>w.document.querySelector('.account-email')?.textContent==='test@example.test');assert.equal(w.document.querySelector('.account-name').textContent,'<img src=x onerror=alert(1)>');assert.equal(w.document.querySelector('.account-name img'),null);assert.match(w.document.querySelector('.account-trigger img').src,/customer-avatar.svg$/);assert.match(w.document.querySelector('.account-dropdown a').href,/customer\/profile$/);const menu=w.document.querySelector('details');menu.open=true;w.document.querySelector('#outside').click();assert.equal(menu.open,false);menu.open=true;menu.dispatchEvent(new w.KeyboardEvent('keydown',{key:'Escape',bubbles:true}));assert.equal(menu.open,false);}
 finally{w.close();}
});
test('profile view loads display values without sending writes or rendering editable fields',async()=>{
 const dom=new JSDOM('<div id="profile-page" data-editing="false"><div id="profile-notice"></div><img id="avatarImg"><div id="userFullName"></div><div id="userEmail"></div><dl><dd id="profile-fullName"></dd><dd id="profile-email"></dd><dd id="profile-phone"></dd><dd id="profile-createdAt"></dd></dl></div>',{url:'https://test.example/customer/profile',runScripts:'outside-only'});
 const w=dom.window,calls=[];w.fetch=async(url,options)=>{calls.push(options);return {ok:true,status:200,json:async()=>({code:200,data:{fullName:'Khách hàng',email:'user@test.example',phone:null,createdAt:'2026-10-29T12:00:00'}})}};
 try{w.eval(profileSource);await wait(()=>w.document.querySelector('#profile-fullName').textContent==='Khách hàng');assert.equal(w.document.querySelector('#profile-phone').textContent,'Chưa cập nhật');assert.equal(w.document.querySelector('form,input'),null);assert.equal(calls.length,1);assert.equal(calls[0].method,undefined);}
 finally{w.close();}
});
