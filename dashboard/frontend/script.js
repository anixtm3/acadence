const API = ""; // same-origin (FastAPI serves the page)
const POLL_MS = 2000;

const el = (id) => document.getElementById(id);

const state = {
  status: null,
  sessions: [],
  lastError: null,
  tickTimer: null,
  pollTimer: null,
};

function fmtDuration(seconds) {
  const s = Math.max(0, Number(seconds || 0));
  const hh = String(Math.floor(s / 3600)).padStart(2, "0");
  const mm = String(Math.floor((s % 3600) / 60)).padStart(2, "0");
  const ss = String(Math.floor(s % 60)).padStart(2, "0");
  return `${hh}:${mm}:${ss}`;
}

function fmtIso(iso) {
  if (!iso) return "—";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return String(iso);
  return d.toLocaleString();
}

function setToast(message, kind = "info") {
  const t = el("toast");
  if (!t) return;
  if (!message) {
    t.classList.add("hidden");
    t.textContent = "";
    return;
  }
  t.classList.remove("hidden");
  t.textContent = message;
  t.style.borderColor = kind === "error" ? "rgba(239,68,68,0.45)" : "rgba(255,255,255,0.12)";
}

async function apiFetch(path, options = {}) {
  const res = await fetch(`${API}${path}`, {
    headers: { "Content-Type": "application/json" },
    ...options,
  });
  const text = await res.text();
  let body = null;
  try {
    body = text ? JSON.parse(text) : null;
  } catch {
    body = text;
  }
  if (!res.ok) {
    const detail = body && body.detail ? body.detail : `HTTP ${res.status}`;
    throw new Error(detail);
  }
  return body;
}

function applyStatusUI(status) {
  const active = Boolean(status && status.active);
  const mode = status?.mode || "NONE";

  el("backendStatus").textContent = "Online";
  el("activeMode").textContent = mode;
  el("sessionMode").textContent = mode === "NONE" ? "Idle" : mode;

  el("activeDot").style.background =
    mode === "FOCUS" ? "rgba(239,68,68,0.85)" :
    mode === "STUDY" ? "rgba(59,130,246,0.85)" :
    mode === "CODE" ? "rgba(34,197,94,0.85)" :
    "rgba(255,255,255,0.30)";

  el("sessionBadge").textContent = active ? "active" : "idle";
  el("sessionBadge").className =
    "ml-2 inline-flex items-center rounded-full px-2 py-0.5 text-xs ring-1 " +
    (active ? "bg-white/10 text-text ring-white/10" : "bg-white/5 text-muted ring-white/10");

  el("sessionId").textContent = status?.session_id ?? "—";
  el("sessionStart").textContent = fmtIso(status?.start_time);
  el("sessionWarnings").textContent = String(status?.warnings ?? 0);
  el("sessionForced").textContent = status?.forced_exit ? "Yes" : "No";

  // Button logic
  const isActive = active && mode !== "NONE";
  el("btnExit").disabled = !isActive;
  el("btnFocus").disabled = isActive;
  el("btnStudy").disabled = isActive;
  el("btnCode").disabled = isActive;
}

function applyHistoryUI(items) {
  const body = el("historyBody");
  el("historyCount").textContent = String(items?.length ?? 0);

  if (!body) return;
  body.innerHTML = "";

  if (!items || items.length === 0) {
    const tr = document.createElement("tr");
    tr.innerHTML = `<td class="px-4 py-4 text-muted" colspan="6">No sessions yet.</td>`;
    body.appendChild(tr);
    return;
  }

  for (const s of items) {
    const tr = document.createElement("tr");
    tr.className = "hover:bg-white/5 transition-colors";
    const forced = Number(s.forced_exit || 0) ? "Yes" : "No";
    const mode = String(s.mode || "—");
    tr.innerHTML = `
      <td class="px-4 py-3 font-semibold">${mode}</td>
      <td class="px-4 py-3 tabular-nums text-muted">${fmtDuration(s.duration_seconds || 0)}</td>
      <td class="px-4 py-3 tabular-nums text-muted">${Number(s.warnings || 0)}</td>
      <td class="px-4 py-3 ${forced === "Yes" ? "text-red-300" : "text-muted"}">${forced}</td>
      <td class="px-4 py-3 text-muted">${fmtIso(s.start_time)}</td>
      <td class="px-4 py-3 text-muted">${fmtIso(s.end_time)}</td>
    `;
    body.appendChild(tr);
  }
}

function startLocalTicker() {
  if (state.tickTimer) clearInterval(state.tickTimer);
  state.tickTimer = setInterval(() => {
    const st = state.status;
    if (!st) return;
    const secs = Number(st.duration_seconds || 0) + 1;
    st.duration_seconds = secs;
    el("sessionDuration").textContent = fmtDuration(secs);
  }, 1000);
}

async function refreshStatus() {
  const status = await apiFetch("/status");
  state.status = status;
  applyStatusUI(status);
  el("sessionDuration").textContent = fmtDuration(status?.duration_seconds ?? 0);
}

async function refreshSessions() {
  const data = await apiFetch("/sessions?limit=25");
  state.sessions = data?.items || [];
  applyHistoryUI(state.sessions);
}

async function poll() {
  try {
    await refreshStatus();
    await refreshSessions();
    setToast("");
    state.lastError = null;
  } catch (e) {
    state.lastError = e?.message || String(e);
    el("backendStatus").textContent = "Offline";
    setToast(state.lastError, "error");
  }
}

async function startMode(modeName) {
  setToast(`Starting ${modeName}…`);
  try {
    await apiFetch(`/mode/${modeName}`, { method: "POST", body: "{}" });
    await poll();
    setToast(`${modeName} started.`);
  } catch (e) {
    setToast(e?.message || String(e), "error");
  }
}

async function exitMode() {
  setToast("Exit requested — check for password prompt…");
  try {
    await apiFetch("/exit", { method: "POST", body: "{}" });
    await poll();
    setToast("Exited.");
  } catch (e) {
    setToast(e?.message || String(e), "error");
  }
}

function wireUI() {
  el("btnFocus").addEventListener("click", () => startMode("focus"));
  el("btnStudy").addEventListener("click", () => startMode("study"));
  el("btnCode").addEventListener("click", () => startMode("code"));
  el("btnExit").addEventListener("click", () => exitMode());
  el("btnRefresh").addEventListener("click", () => poll());
}

async function main() {
  wireUI();
  startLocalTicker();
  await poll();
  state.pollTimer = setInterval(poll, POLL_MS);
}

main();