(() => {
  'use strict';
  const root=document.getElementById('profile-page');if(!root)return;
  const base=root.dataset.context||'',editing=root.dataset.editing==='true';
  const $=id=>root.querySelector('#'+id);
  const notice=(text,bad=false)=>{$('profile-notice').className='alert alert-'+(bad?'danger':'success');$('profile-notice').textContent=text;};
  async function api(path,options={}){
    const token=localStorage.getItem('accessToken');
    const response=await fetch(base+'/api/customer/profile'+path,{...options,headers:{...(token?{Authorization:'Bearer '+token}:{}),...options.headers}});
    if(response.status===401){location.href=base+'/auth/login';throw Error('Phiên đăng nhập đã hết hạn');}
    const body=await response.json();if(!response.ok||body.code!==200)throw Error(body.message||'Không thể tải thông tin tài khoản');return body.data;
  }
  function render(user){
    $('userFullName').textContent=user.fullName||'Chưa cập nhật';$('userEmail').textContent=user.email;
    if(user.avatarUrl){try{const u=new URL(user.avatarUrl.startsWith('/')?base+user.avatarUrl:user.avatarUrl,location.origin);if(['http:','https:'].includes(u.protocol))$('avatarImg').src=u.href;}catch{/* Keep default image. */}}
    if(editing){$('fullName').value=user.fullName||'';$('email').value=user.email;$('phone').value=user.phone||'';}
    else{for(const key of ['fullName','email','phone'])$('profile-'+key).textContent=user[key]||'Chưa cập nhật';$('profile-createdAt').textContent=user.createdAt?new Date(user.createdAt).toLocaleDateString('vi-VN'):'Chưa cập nhật';}
    window.dispatchEvent(new CustomEvent('utetra:profile-updated',{detail:user}));
  }
  $('avatarImg').addEventListener('error',()=>{const fallback=base+'/images/customer-avatar.svg';if(!$('avatarImg').src.endsWith(fallback))$('avatarImg').src=fallback;});
  if(editing){
    $('profileForm').addEventListener('submit',async e=>{e.preventDefault();const button=e.submitter||e.currentTarget.querySelector('button');button.disabled=true;try{const user=await api('',{method:'PUT',headers:{'Content-Type':'application/json'},body:JSON.stringify({fullName:$('fullName').value.trim(),phone:$('phone').value.trim()})});render(user);location.href=base+'/customer/profile';}catch(error){notice(error.message,true);}finally{button.disabled=false;}});
    $('avatarForm').addEventListener('submit',async e=>{e.preventDefault();const button=e.currentTarget.querySelector('button');button.disabled=true;try{const file=$('avatarFile').files[0];if(!file)throw Error('Vui lòng chọn ảnh');const data=new FormData();data.append('file',file);await api('/avatar',{method:'POST',body:data});render(await api(''));$('avatarFile').value='';notice('Đã cập nhật ảnh đại diện.');}catch(error){notice(error.message,true);}finally{button.disabled=false;}});
  }
  api('').then(render).catch(error=>notice(error.message,true));
})();
