(() => {
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
    const html = marked.parse(md);
    preview.innerHTML = DOMPurify.sanitize(html);
  }

  function applyTheme(name) {
    document.body.dataset.theme = name;
    localStorage.setItem('mdv-theme', name);
  }

  function setEditing(on) {
    editing = on;
    editor.hidden = !on;
    preview.hidden = on;
    btnSave.hidden = !on;
    themeSel.disabled = on;
    btnEdit.textContent = on ? 'Preview' : 'Edit';
    if (on) {
      editor.value = source;
      editor.focus();
    } else {
      source = editor.value;
      render(source);
    }
  }

  function loadFile({ path, name, content }) {
    current = { path, name };
    source = content;
    fileName.textContent = name;
    document.title = `${name} - MarkdownViewer`;
    setEditing(false);
    render(source);
  }

  async function save() {
    if (!current.path) return;
    if (editing) source = editor.value;
    await window.mdv.saveFile(current.path, source);
    render(source);
    flash('Tersimpan');
  }

  function flash(msg) {
    fileName.textContent = `${current.name} · ${msg}`;
    setTimeout(() => { fileName.textContent = current.name; }, 1500);
  }

  document.getElementById('btnOpen').addEventListener('click', () => window.mdv.openFile());
  btnEdit.addEventListener('click', () => setEditing(!editing));
  btnSave.addEventListener('click', save);
  themeSel.addEventListener('change', () => applyTheme(themeSel.value));

  document.getElementById('btnPDF').addEventListener('click', () => {
    if (!current.path) return flash('Buka file dulu');
    window.mdv.exportPDF(current.name.replace(/\.(md|markdown)$/i, '') + '.pdf');
  });

  document.getElementById('btnPNG').addEventListener('click', () => {
    if (!current.path) return flash('Buka file dulu');
    window.mdv.exportPNG(current.name.replace(/\.(md|markdown)$/i, '') + '.png');
  });

  document.addEventListener('keydown', (e) => {
    if (!(e.ctrlKey || e.metaKey)) return;
    if (e.key === 'o') { e.preventDefault(); window.mdv.openFile(); }
    if (e.key === 's') { e.preventDefault(); if (editing) save(); }
    if (e.key === 'e') { e.preventDefault(); if (current.path) setEditing(!editing); }
  });

  window.mdv.onFileLoaded(loadFile);
  applyTheme(localStorage.getItem('mdv-theme') || 'system');
  themeSel.value = document.body.dataset.theme;
})();
