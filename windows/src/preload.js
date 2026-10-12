const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('mdv', {
  openFile: () => ipcRenderer.invoke('file:open'),
  saveFile: (filePath, content) => ipcRenderer.invoke('file:save', { filePath, content }),
  exportPDF: (defaultName) => ipcRenderer.invoke('export:pdf', defaultName),
  exportPNG: (defaultName) => ipcRenderer.invoke('export:png', defaultName),
  reveal: (filePath) => ipcRenderer.invoke('file:reveal', filePath),
  onFileLoaded: (cb) => ipcRenderer.on('file:loaded', (_e, data) => cb(data)),
});
