const { invoke } = window.__TAURI__.core;
const { listen } = window.__TAURI__.event;
const { getCurrentWindow } = window.__TAURI__.window;

const preview = document.getElementById('preview');
const editor = document.getElementById('editor');
const fileName = document.getElementById('fileName');
const btnEdit = document.getElementById('btnEdit');
const btnSave = document.getElementById('btnSave');
const themeSel = document.getElementById('theme');

const EMPTY_STATE = preview.innerHTML;
const MARKDOWN_RE = /\.(md|markdown)$/i;

let current = { path: null, name: null };
let source = '';
let editing = false;

marked.setOptions({ gfm: true, breaks: false });

function render(md) {
  try {
    preview.innerHTML = DOMPurify.sanitize(marked.parse(md || ''));
  } catch (err) {
    preview.innerHTML = '';
    const box = document.createElement('pre');
    box.className = 'render-error';
    box.textContent = 'Gagal menampilkan markdown:\n' + (err && err.message ? err.message : String(err));
    preview.appendChild(box);
  }
}

function applyTheme(name) {
  document.body.dataset.theme = name;
  localStorage.setItem('mdv-theme', name);
}

let flashTimer = null;
function flash(msg) {
  const name = current.name;
  fileName.classList.remove('muted');
  fileName.textContent = name ? `${name} · ${msg}` : msg;
  clearTimeout(flashTimer);
  flashTimer = setTimeout(() => {
    if (current.name !== name) return;
    fileName.textContent = name || 'Belum ada file';
    fileName.classList.toggle('muted', !name);
  }, 1600);
}

function setEditLabel(text) {
  const label = btnEdit.querySelector('span');
  if (label) label.textContent = text;
  btnEdit.title = text === 'Edit' ? 'Edit (Ctrl+E)' : 'Kembali ke preview (Esc)';
}

function showPreview() {
  editing = false;
  editor.hidden = true;
  preview.hidden = false;
  btnSave.hidden = true;
  setEditLabel('Edit');
}

function setEditing(on) {
  if (on) {
    if (!current.path) return;
    editor.value = source;
    editor.hidden = false;
    preview.hidden = true;
    btnSave.hidden = false;
    setEditLabel('Preview');
    editor.focus();
  } else {
    source = editor.value;
    showPreview();
    render(source);
  }
  editing = on;
}

function loadFile({ path, name, content }) {
  current = { path, name };
  source = content || '';
  fileName.textContent = name;
  fileName.classList.remove('muted');
  document.title = `${name} - MarkdownViewer`;
  getCurrentWindow().setTitle(`${name} - MarkdownViewer`).catch(() => {});
  showPreview();
  render(source);
}

function showEmpty() {
  current = { path: null, name: null };
  source = '';
  preview.innerHTML = EMPTY_STATE;
  preview.hidden = false;
  fileName.textContent = 'Belum ada file';
  fileName.classList.add('muted');
  document.title = 'MarkdownViewer';
  getCurrentWindow().setTitle('MarkdownViewer').catch(() => {});
  showPreview();
}

async function openPath(path) {
  try {
    const file = await invoke('open_path', { path });
    if (file) loadFile(file);
    return true;
  } catch (err) {
    alert(String(err));
    return false;
  }
}

async function openFile() {
  try {
    const file = await invoke('open_file_dialog');
    if (file) loadFile(file);
  } catch (err) {
    alert(String(err));
  }
}

async function reload() {
  if (!current.path) return openFile();
  if (editing && editor.value !== source) {
    if (!confirm('Perubahan belum disimpan. Muat ulang file dan buang perubahan?')) return;
  }
  await openPath(current.path);
}

async function save() {
  if (!current.path) return;
  if (editing) source = editor.value;
  try {
    await invoke('save_file', { path: current.path, content: source });
    render(source);
    flash('Tersimpan');
  } catch (err) {
    alert(String(err));
  }
}

async function exportPNG() {
  if (!current.path) return flash('Buka file dulu');
  const base = current.name.replace(MARKDOWN_RE, '');
  if (editing) setEditing(false);
  try {
    const bg = getComputedStyle(document.body).getPropertyValue('--bg').trim() || '#ffffff';
    const dataUrl = await htmlToImage.toPng(preview, { backgroundColor: bg, pixelRatio: 2 });
    const base64 = dataUrl.split(',')[1];
    const saved = await invoke('save_png', { defaultName: base + '.png', dataBase64: base64 });
    if (saved) flash('PNG tersimpan');
  } catch (err) {
    alert(String(err));
  }
}

document.getElementById('btnOpen').addEventListener('click', openFile);
btnEdit.addEventListener('click', () => setEditing(!editing));
btnSave.addEventListener('click', save);
themeSel.addEventListener('change', () => applyTheme(themeSel.value));

document.getElementById('btnPDF').addEventListener('click', () => {
  if (!current.path) return flash('Buka file dulu');
  document.title = current.name.replace(MARKDOWN_RE, '');
  window.print();
});

document.getElementById('btnPNG').addEventListener('click', exportPNG);

document.addEventListener('keydown', (e) => {
  const mod = e.ctrlKey || e.metaKey;
  if (e.key === 'Escape' && editing) { e.preventDefault(); setEditing(false); return; }
  if (!mod) return;
  if (e.key === 'o') { e.preventDefault(); openFile(); }
  if (e.key === 's') { e.preventDefault(); save(); }
  if (e.key === 'e') { e.preventDefault(); setEditing(!editing); }
  if (e.key === 'r') { e.preventDefault(); reload(); }
});

// Cegah webview pindah halaman saat link diklik.
preview.addEventListener('click', (e) => {
  const link = e.target.closest && e.target.closest('a');
  if (!link) return;
  const href = link.getAttribute('href') || '';
  if (href.startsWith('#')) return;
  e.preventDefault();
});

listen('file:loaded', (e) => loadFile(e.payload));
listen('file:error', (e) => alert(e.payload));

// File dari argumen CLI / second instance bisa datang sebelum listener siap.
invoke('take_pending_file')
  .then((file) => { if (file) loadFile(file); })
  .catch(() => {});

// Drag & drop file .md ke jendela.
listen('tauri://drag-drop', (e) => {
  const paths = (e.payload && e.payload.paths) || [];
  const md = paths.find((p) => MARKDOWN_RE.test(p));
  if (md) openPath(md);
});

const savedTheme = localStorage.getItem('mdv-theme');
const knownTheme = Array.from(themeSel.options).some((o) => o.value === savedTheme);
applyTheme(knownTheme ? savedTheme : 'system');
themeSel.value = document.body.dataset.theme;
