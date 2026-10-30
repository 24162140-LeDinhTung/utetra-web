(() => {
  'use strict';
  const form=document.getElementById('shop-form');if(!form)return;
  const urls=new Set();
  for(const input of form.querySelectorAll('[data-shop-image]')){
    const image=document.getElementById(input.dataset.shopImage);let current;
    image.addEventListener('error',()=>{image.hidden=true;});
    input.addEventListener('change',()=>{
      if(current){URL.revokeObjectURL(current);urls.delete(current);current=null;}
      input.setCustomValidity('');const file=input.files[0];
      if(file && (!['image/jpeg','image/png','image/webp','image/gif'].includes(file.type)||file.size>20*1024*1024)){
        input.setCustomValidity('Chỉ nhận ảnh JPG, PNG, WebP hoặc GIF tối đa 20 MB.');input.reportValidity();image.hidden=true;return;
      }
      const original=image.dataset.original||'';
      if(file){current=URL.createObjectURL(file);urls.add(current);image.src=current;image.hidden=false;}
      else{image.hidden=!original;if(original)image.src=original;}
    });
  }
  window.addEventListener('pagehide',()=>{for(const url of urls)URL.revokeObjectURL(url);},{once:true});
})();
