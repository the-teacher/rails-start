// Pipeline 01 — Support Pipeline — SSE live event log.

var STEP_ICONS = { pending: "○", running: "◎", done: "✓", stopped: "✗" };
var LOG_ICONS  = { info: "●", success: "✓", error: "✗", warning: "⚠" };
var SOURCE_LABELS = {
  pipeline: "pipeline",
  laundry:  "laundry",
  tribunal: "tribunal",
  agent:    "agent",
};
var SOURCE_COLORS = {
  pipeline: "ah-pl-badge--pipeline",
  laundry:  "ah-pl-badge--laundry",
  tribunal: "ah-pl-badge--tribunal",
  agent:    "ah-pl-badge--agent",
};

// Update state of a step or group element.
// Uses data-base-class to preserve the element's base CSS class(es).
function plSetStep(stepName, state) {
  var el   = document.getElementById("ah-pl-step-" + stepName);
  var icon = document.getElementById("ah-pl-icon-" + stepName);
  if (!el) return;
  var base = el.getAttribute("data-base-class") || "ah-pl-step";
  el.className = state === "pending"
    ? base
    : base + " " + base.split(" ")[0] + "--" + state;
  if (icon) icon.textContent = STEP_ICONS[state] || "○";
}

function plResetSteps() {
  ["laundry", "injection_guard", "translate", "compact",
   "safety_tribunal", "relevance_guard", "respond"].forEach(function(s) {
    plSetStep(s, "pending");
  });
}

function plAppendLog(text, level, source) {
  var log   = document.getElementById("ah-pl-log");
  var empty = document.getElementById("ah-pl-log-empty");
  if (empty) empty.remove();
  var lvl  = level || "info";
  var line = document.createElement("div");
  line.className = "ah-pl-log-line ah-pl-log-line--" + lvl;

  var badgeHtml = "";
  if (source && SOURCE_LABELS[source]) {
    badgeHtml =
      '<span class="ah-pl-source-badge ah-pl-badge--' + source + '">' +
      SOURCE_LABELS[source] +
      "</span>";
  }

  line.innerHTML =
    '<span class="ah-pl-log-icon">' + (LOG_ICONS[lvl] || "●") + "</span>" +
    badgeHtml +
    '<span class="ah-pl-log-text">' + text + "</span>";
  log.appendChild(line);
  log.scrollTop = log.scrollHeight;
}

function plResetLog() {
  document.getElementById("ah-pl-log").innerHTML =
    '<div class="ah-pl-log-empty" id="ah-pl-log-empty">Running…</div>';
}

function plResetOutput() {
  document.getElementById("ah-pl-output").textContent = "—";
  document.getElementById("ah-pl-output-meta").textContent = "";
}

(function () {
  var form  = document.getElementById("ah-pl-form");
  var input = document.getElementById("ah-pl-input");
  var btn   = document.getElementById("ah-pl-btn");
  if (!form) return;

  input.addEventListener("keydown", function (e) {
    if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); form.requestSubmit(); }
  });

  form.addEventListener("submit", function (e) {
    e.preventDefault();
    var val = (input.value || "").trim();
    if (!val) return;

    plResetSteps();
    plResetLog();
    plResetOutput();
    btn.disabled    = true;
    btn.textContent = "Running…";

    var es         = new EventSource("/ai/pipelines/support/stream?input=" + encodeURIComponent(val));
    var activeStep = null;

    function closeStream() {
      es.close();
      btn.disabled    = false;
      btn.textContent = "Run pipeline";
    }

    // ── Done envelope ────────────────────────────────────────────────────────
    es.addEventListener("completion", function (ev) {
      var p = JSON.parse(ev.data);
      if (!p.done) return;

      if (p.error) {
        plAppendLog("Error: " + p.error, "error", "pipeline");
      } else if (p.stopped) {
        plAppendLog("Pipeline stopped at: " + p.stopped_at, "error", "pipeline");
      } else {
        document.getElementById("ah-pl-output").textContent = p.output || "";
        if (p.time) document.getElementById("ah-pl-output-meta").textContent = "Total: " + p.time + "s";
      }
      closeStream();
    });

    // ── All SSE processing events ────────────────────────────────────────────
    es.addEventListener("processing", function (ev) {
      var p   = JSON.parse(ev.data);
      var src = p.source || "pipeline";
      var lvl = p.level  || "info";

      if (p.event === "step_start") {
        activeStep = p.step;
        plSetStep(p.step, "running");
        plAppendLog(p.text, "info", src);

      } else if (p.event === "step_done") {
        plSetStep(p.step, "done");
        plAppendLog(p.text, "success", src);

      } else if (p.event === "stopped") {
        plSetStep(p.step || activeStep, "stopped");
        // also mark laundry group stopped if an inner step stopped
        if (p.step && ["injection_guard","translate","compact"].indexOf(p.step) !== -1) {
          plSetStep("laundry", "stopped");
        }
        plAppendLog(p.text, "error", "pipeline");

      } else if (p.event === "complete" || p.event === "laundry_complete") {
        plAppendLog(p.text, "success", src);

      } else {
        // tribunal / agent sub-events
        plAppendLog(p.text || p.event, lvl, src);
      }
    });

    es.onerror = function () {
      plAppendLog("Connection lost", "error", "pipeline");
      closeStream();
    };
  });
})();
