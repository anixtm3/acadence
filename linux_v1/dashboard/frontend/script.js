async function load() {
  try {
    const res = await fetch("http://127.0.0.1:8000/session");
    const data = await res.json();

    const modeEl = document.getElementById("mode");

    modeEl.innerText = "Mode: " + data.mode;
    modeEl.className = "card " + (data.mode === "FOCUS" ? "focus" : "safe");

    document.getElementById("time").innerText =
      "Time: " + data.duration + "s";

    document.getElementById("warn").innerText =
      "Warnings: " + data.warnings;

    document.getElementById("exit").innerText =
      "Forced Exit: " + (data.forced_exit ? "Yes 🚨" : "No ✅");

  } catch (err) {
    console.log("Error:", err);
  }
}

load();
setInterval(load, 2000);