const {test}=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const {JSDOM}=require('jsdom');
const source=fs.readFileSync(path.join(__dirname,'../../main/resources/static/js/shop-form.js'),'utf8');
test('shop images preview selected files and restore originals; non images are blocked',()=>{
 const dom=new JSDOM('<form id="shop-form"><input type="file" data-shop-image="preview"><img id="preview" data-original="/uploads/old.png" src="/uploads/old.png"></form>',{url:'https://example.test/',runScripts:'outside-only'});
 const w=dom.window,revoked=[];w.URL.createObjectURL=()=> 'blob:preview';w.URL.revokeObjectURL=url=>revoked.push(url);
 const input=w.document.querySelector('input'),image=w.document.querySelector('img');let files=[];
 Object.defineProperty(input,'files',{get:()=>files});
 try{
  w.eval(source);files=[new w.File(['image'],'photo.png',{type:'image/png'})];input.dispatchEvent(new w.Event('change'));
  assert.equal(image.src,'blob:preview');assert.equal(image.hidden,false);assert.equal(input.validationMessage,'');
  files=[];input.dispatchEvent(new w.Event('change'));assert.match(image.src,/uploads\/old.png$/);assert.deepEqual(revoked,['blob:preview']);
  files=[new w.File(['text'],'bad.html',{type:'text/html'})];input.dispatchEvent(new w.Event('change'));assert.notEqual(input.validationMessage,'');assert.equal(image.hidden,true);
 }finally{w.close();}
});
