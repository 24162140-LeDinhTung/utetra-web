const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');

const jsp = fs.readFileSync(path.join(__dirname,
  '../../main/webapp/WEB-INF/decorators/main-decorator.jsp'), 'utf8');
const script = jsp.match(/<script>\s*([\s\S]*?)<\/script>/)[1]
  .replaceAll('${pageContext.request.contextPath}', '/utetra');
function browser(token) {
  const stored = new Map([['accessToken', token], ['userRoles', '["ROLE_CUSTOMER"]']]);
  const buttons = { innerHTML: 'Đăng nhập' };
  const document = { cookie: '', getElementById: () => buttons };
  const location = { protocol: 'https:', href: '' };
  const context = vm.createContext({ document, location, window: { location }, atob,
    localStorage: { getItem: key => stored.get(key), removeItem: key => stored.delete(key) } });
  // profile.jsp declares its own top-level token before the decorator script runs.
  vm.runInContext('const token = "profile-token";', context);
  vm.runInContext(script, context);
  return { context, stored, buttons, document, location };
}
function token(exp) {
  return 'header.' + Buffer.from(JSON.stringify({ exp })).toString('base64url') + '.signature';
}
test('valid stored token restores cookie for page navigation; logout clears both stores', () => {
  const b = browser(token(Math.floor(Date.now() / 1000) + 60));
  assert.match(b.document.cookie, /accessToken=.+; path=\/; SameSite=Lax; Secure/);
  assert.match(b.buttons.innerHTML, /\/utetra\/customer\/profile/);
  vm.runInContext('window.logout()', b.context);
  assert.equal(b.stored.has('accessToken'), false);
  assert.equal(b.stored.has('userRoles'), false);
  assert.match(b.document.cookie, /Max-Age=0/);
  assert.equal(b.location.href, '/utetra/');
});
test('expired or malformed stored token does not show an authenticated account button', () => {
  for (const value of [token(1), 'invalid-token']) {
    const b = browser(value);
    assert.equal(b.stored.has('accessToken'), false);
    assert.equal(b.buttons.innerHTML, 'Đăng nhập');
    assert.match(b.document.cookie, /Max-Age=0/);
  }
});
