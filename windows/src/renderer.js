const { invoke } = window.__TAURI__.core;
const { listen } = window.__TAURI__.event;
const { getCurrentWindow } = window.__TAURI__.window;

const preview = document.getElementById('preview');
const editor = document.getElementById('editor');
const fileName = document.getElementById('fileName');
const btnEdit = document.getElementById('btnEdit');
const btnSave = document.getElementById('btnSave');
const themeSel = document.getElementById('theme');

let current = { path: null, name: null };
let source = '';
let editing = false;

marked.setOptions({ gfm: true, breaks: false });

function render(md) {
  preview.innerHTML = DOMPurify.sanitize(marked.parse(md));
}

function applyTheme(name) {
  document.body.dataset.theme = name;
  localStorage.setItem('mdv-theme', name);
}

let savedFileName = null;
function flash(msg) {
  savedFileName = current.name;
  fileName.textContent = `${current.name} · ${msg}`;
  setTimeout(() => {
    if (savedFileName === current.name) fileName.textContent = current.name;
  }, 1500);
}

function showPreview() {
  editing = false;
  editor.hidden = true;
  preview.hidden = false;
  btnSave.hidden = true;
  themeSel.disabled = false;
  btnEdit.textContent = 'Edit';
}

function setEditing(on) {
  if (on) {
    editor.value = source;
    editor.hidden = false;
    preview.hidden = true;
    btnSave.hidden = false;
    themeSel.disabled = true;
    btnEdit.textContent = 'Preview';
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
  source = content;
  fileName.textContent = name;
  document.title = `${name} - MarkdownViewer`;
  getCurrentWindow().setTitle(`${name} - MarkdownViewer`).catch(() => {});
  showPreview();
  render(source);
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

async function openFile() {
  try {
    const file = await invoke('open_file_dialog');
    if (file) loadFile(file);
  } catch (err) {
    alert(String(err));
  }
}

async function exportPNG() {
  if (!current.path) return flash('Buka file dulu');
  const base = current.name.replace(/\.(md|markdown)$/i, '');
  const wasEditing = editing;
  if (wasEditing) setEditing(false);
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
btnEdit.addEventListener('click', () => current.path && setEditing(!editing));
btnSave.addEventListener('click', save);
themeSel.addEventListener('change', () => applyTheme(themeSel.value));

document.getElementById('btnPDF').addEventListener('click', () => {
  if (!current.path) return flash('Buka file dulu');
  document.title = current.name.replace(/\.(md|markdown)$/i, '');
  window.print();
});

document.getElementById('btnPNG').addEventListener('click', exportPNG);

document.addEventListener('keydown', (e) => {
  if (!(e.ctrlKey || e.metaKey)) return;
  if (e.key === 'o') { e.preventDefault(); openFile(); }
  if (e.key === 's') { e.preventDefault(); if (editing) save(); }
  if (e.key === 'e') { e.preventDefault(); if (current.path) setEditing(!editing); }
});

listen('file:loaded', (e) => loadFile(e.payload));
listen('file:error', (e) => alert(e.payload));

applyTheme(localStorage.getItem('mdv-theme') || 'system');
themeSel.value = document.body.dataset.theme;
