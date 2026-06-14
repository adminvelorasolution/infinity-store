/* ══════════════════════════════════════════
   INFINITY STORE — Shared JS
══════════════════════════════════════════ */

// ── Supabase config ──
const SUPABASE_URL = 'https://eupsqwqobogpgvmmrotv.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV1cHNxd3FvYm9ncGd2bW1yb3R2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNzA5OTUsImV4cCI6MjA5Njk0Njk5NX0.hVG3Wx090zaA96uK5GcYByxlAtpz7V4k28PG8xh-u50';
const STORAGE_BUCKET   = 'produits';

// ── Admin password (simple, à remplacer par auth Supabase) ──
const ADMIN_PASSWORD = 'infinity2025';
const ADMIN_SESSION_KEY = 'infinity_admin';

// ── Nav burger ──
function toggleNav() {
  const nav = document.getElementById('navLinks');
  nav.classList.toggle('open');
}

// Fermer nav si clic extérieur
document.addEventListener('click', (e) => {
  const nav = document.getElementById('navLinks');
  const burger = document.getElementById('navBurger');
  if (nav && burger && !nav.contains(e.target) && !burger.contains(e.target)) {
    nav.classList.remove('open');
  }
});

// ── Login Modal ──
function openLoginModal() {
  // Si déjà connecté → redirect admin
  if (isAdmin()) {
    window.location.href = 'admin/dashboard.html';
    return;
  }
  const m = document.getElementById('loginModal');
  if (m) m.classList.add('open');
  setTimeout(() => { const pw = document.getElementById('adminPassword'); if (pw) pw.focus(); }, 200);
}

function closeLoginModal() {
  const m = document.getElementById('loginModal');
  if (m) m.classList.remove('open');
  const err = document.getElementById('loginError');
  if (err) { err.style.display = 'none'; err.textContent = ''; }
}

function closeLoginOnOutside(e) {
  if (e.target === e.currentTarget) closeLoginModal();
}

function doLogin() {
  const pw = document.getElementById('adminPassword');
  const err = document.getElementById('loginError');
  if (!pw) return;
  if (pw.value === ADMIN_PASSWORD) {
    sessionStorage.setItem(ADMIN_SESSION_KEY, '1');
    closeLoginModal();
    showToast('✓ Connecté — redirection…');
    setTimeout(() => { window.location.href = 'admin/dashboard.html'; }, 800);
  } else {
    if (err) { err.textContent = 'Mot de passe incorrect.'; err.style.display = 'block'; }
    pw.value = '';
    pw.focus();
    pw.style.borderColor = 'var(--red)';
    setTimeout(() => { pw.style.borderColor = ''; }, 1200);
  }
}

function isAdmin() {
  return sessionStorage.getItem(ADMIN_SESSION_KEY) === '1';
}

function requireAdmin() {
  if (!isAdmin()) { window.location.href = '../index.html'; }
}

// ── Toast ──
function showToast(msg, icon = 'fas fa-check') {
  let t = document.getElementById('globalToast');
  if (!t) {
    t = document.createElement('div');
    t.id = 'globalToast';
    t.className = 'toast';
    document.body.appendChild(t);
  }
  t.innerHTML = `<i class="${icon}"></i> ${msg}`;
  t.classList.add('show');
  clearTimeout(t._timer);
  t._timer = setTimeout(() => t.classList.remove('show'), 2800);
}

// ── Supabase fetch helper ──
async function sbFetch(path, options = {}) {
  const url = `${SUPABASE_URL}/rest/v1/${path}`;
  const headers = {
    'apikey': SUPABASE_ANON_KEY,
    'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
    ...options.headers
  };
  const res = await fetch(url, { ...options, headers });
  if (!res.ok) throw new Error(await res.text());
  return res.status === 204 ? null : res.json();
}

// ── Format price ──
function formatPrice(n) {
  if (!n && n !== 0) return '—';
  return Number(n).toLocaleString('fr-MG') + ' Ar';
}

// ── Escape HTML ──
function esc(s) {
  if (!s) return '';
  return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
