const { app, BrowserWindow, dialog, ipcMain, shell } = require('electron');
const path = require('path');
const fs = require('fs');

let win = null;
let pendingFile = null;

function createWindow() {
  win = new BrowserWindow({
    width: 1000,
    height: 760,
    minWidth: 600,
    minHeight: 400,
    title: 'MarkdownViewer',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });
  win.loadFile(path.join(__dirname, 'index.html'));
  win.webContents.on('did-finish-load', () => {
    if (pendingFile) {
      openFile(pendingFile);
      pendingFile = null;
    }
  });
  win.on('closed', () => { win = null; });
}

function openFile(filePath) {
  if (!win) return;
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    win.webContents.send('file:loaded', { path: filePath, name: path.basename(filePath), content });
  } catch (err) {
    dialog.showErrorBox('Gagal membuka file', err.message);
  }
}

// File dibuka dari Explorer ("Open with") atau argumen command line
function fileFromArgv(argv) {
  return argv.find((a) => /\.(md|markdown)$/i.test(a) && fs.existsSync(a)) || null;
}

const gotLock = app.requestSingleInstanceLock();
if (!gotLock) {
  app.quit();
} else {
  app.on('second-instance', (_e, argv) => {
    const file = fileFromArgv(argv);
    if (win) {
      if (win.isMinimized()) win.restore();
      win.focus();
    }
    if (file) openFile(file);
  });

  app.whenReady().then(() => {
    pendingFile = fileFromArgv(process.argv);
    createWindow();
    app.on('activate', () => { if (BrowserWindow.getAllWindows().length === 0) createWindow(); });
  });
}

app.on('window-all-closed', () => app.quit());

ipcMain.handle('file:open', async () => {
  const res = await dialog.showOpenDialog(win, {
    properties: ['openFile'],
    filters: [{ name: 'Markdown', extensions: ['md', 'markdown'] }],
  });
  if (res.canceled || res.filePaths.length === 0) return null;
  openFile(res.filePaths[0]);
  return true;
});

ipcMain.handle('file:save', async (_e, { filePath, content }) => {
  fs.writeFileSync(filePath, content, 'utf8');
  return true;
});

ipcMain.handle('file:reveal', (_e, filePath) => {
  shell.showItemInFolder(filePath);
});

ipcMain.handle('export:png', async (_e, defaultName) => {
  const res = await dialog.showSaveDialog(win, {
    defaultPath: defaultName,
    filters: [{ name: 'PNG', extensions: ['png'] }],
  });
  if (res.canceled || !res.filePath) return null;
  const image = await win.webContents.capturePage();
  fs.writeFileSync(res.filePath, image.toPNG());
  return res.filePath;
});

ipcMain.handle('export:pdf', async (_e, defaultName) => {
  const res = await dialog.showSaveDialog(win, {
    defaultPath: defaultName,
    filters: [{ name: 'PDF', extensions: ['pdf'] }],
  });
  if (res.canceled || !res.filePath) return null;
  const data = await win.webContents.printToPDF({
    pageSize: 'A4',
    margins: { marginType: 'default' },
    printBackground: true,
  });
  fs.writeFileSync(res.filePath, data);
  return res.filePath;
});
