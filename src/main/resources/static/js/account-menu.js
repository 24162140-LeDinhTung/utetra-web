/* Shared signed-in account control for storefront, vendor and admin. */
(() => {
  'use strict';
  const script=document.currentScript;
  const base=script?.dataset.context || '';
  const safeAvatar=value=>{if(!value)return base+'/images/customer-avatar.svg';try{const src=value.startsWith('/')?base+value:value;const u=new URL(src,location.origin);return ['http:','https:'].includes(u.protocol)?u.href:base+'/images/customer-avatar.svg';}catch{return base+'/images/customer-avatar.svg';}};
  function clearLogin(){for(const key of ['accessToken','refreshToken','userRole','userRoles'])localStorage.removeItem(key);document.cookie='accessToken=; Max-Age=0; path=/; SameSite=Lax';}
  document.querySelectorAll('[data-account-menu]').forEach(host=>{
    const menu=document.createElement('details');menu.className='account-menu';
    const trigger=document.createElement('summary');trigger.className='account-trigger';trigger.setAttribute('aria-label','Mở menu tài khoản');
    const avatar=document.createElement('img');avatar.src=safeAvatar(null);avatar.alt='';avatar.width=38;avatar.height=38;
    avatar.addEventListener('error',()=>{const fallback=base+'/images/customer-avatar.svg';if(!avatar.src.endsWith(fallback))avatar.src=fallback;});
    const name=document.createElement('span');name.className='account-name';name.textContent='Tài khoản';trigger.append(avatar,name);
    const dropdown=document.createElement('div');dropdown.className='account-dropdown';
    const email=document.createElement('p');email.className='account-email';
    const profile=document.createElement('a');profile.href=base+'/customer/profile';profile.textContent='Thông tin tài khoản';
    const logout=document.createElement('button');logout.type='button';logout.textContent='Đăng xuất';logout.addEventListener('click',()=>{clearLogin();location.href=base+'/auth/login';});
    dropdown.append(email,profile,logout);menu.append(trigger,dropdown);host.replaceChildren(menu);
    document.addEventListener('click',e=>{if(!menu.contains(e.target))menu.open=false;});
    menu.addEventListener('keydown',e=>{if(e.key==='Escape'){menu.open=false;trigger.focus();}});
    const render=user=>{name.textContent=user.fullName||user.email||'Tài khoản';email.textContent=user.email||'';avatar.src=safeAvatar(user.avatarUrl);};
    window.addEventListener('utetra:profile-updated',e=>render(e.detail));
    fetch(base+'/api/customer/profile',{headers:localStorage.getItem('accessToken')?{Authorization:'Bearer '+localStorage.getItem('accessToken')}:{}})
      .then(async response=>{if(response.status===401){clearLogin();location.href=base+'/auth/login';return;}if(!response.ok)throw Error('profile');const body=await response.json();if(body.code===200)render(body.data);})
      .catch(()=>{email.textContent='Chưa tải được thông tin tài khoản';});
  });
})();
