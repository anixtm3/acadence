const { app, BrowserWindow } = require("electron");
const path = require("path");
const { spawn } = require("child_process");

let backendProcess;

function startBackend() {
  const pythonPath = path.join(__dirname, "../venv/bin/python");
  const backendPath = path.join(__dirname, "../dashboard/backend/main.py");

  backendProcess = spawn(pythonPath, [backendPath]);

  backendProcess.stdout.on("data", (data) => {
    console.log(`Backend: ${data}`);
  });

  backendProcess.stderr.on("data", (data) => {
    console.error(`Backend Error: ${data}`);
  });

  backendProcess.on("close", (code) => {
    console.log(`Backend exited with code ${code}`);
  });
}

function createWindow() {
  const win = new BrowserWindow({
    width: 1200,
    height: 800,
  });

  win.loadURL("http://127.0.0.1:8000");
}

app.whenReady().then(() => {
  startBackend();

  // wait for FastAPI to boot
  setTimeout(createWindow, 2000);
});

app.on("will-quit", () => {
  if (backendProcess) backendProcess.kill();
});