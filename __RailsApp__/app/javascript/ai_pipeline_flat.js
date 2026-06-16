// Pipeline 02 — Flat Support Pipeline — SSE live event log.

var STEP_ICONS = { pending: "○", running: "◎", done: "✓", stopped: "✗" };
var LOG_ICONS  = { info: "●", success: "✓", error: "✗", warning: "⚠" };
var SOURCE_LABELS = {
  pipeline: "pipeline",
  tribunal: "tribunal",
  agent:    "agent",
};
var SOURCE_COLORS = {
  pipeline: "ah-pl-badge--pipeline",
  tribunal: "ah-pl-badge--tribunal",
  agent:    "ah-pl-badge--agent",
};

var FLAT_STEPS = [
  "injection_guard", "translate", "compact",
  "safety_tribunal", "relevance_guard", "respond"
];

// ── Step state ───────────────────────────────────────────────────────────────

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
  FLAT_STEPS.forEach(function(s) { plSetStep(s, "pending"); });
}

// ── Event log ────────────────────────────────────────────────────────────────

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

// ── Stats tree ───────────────────────────────────────────────────────────────

var plStats        = { steps: [] };
var plCurrentGroup = null;

function plResetStats() {
  plStats        = { steps: [] };
  plCurrentGroup = null;
  var wrap = document.getElementById("ah-pl-stats");
  if (wrap) { wrap.innerHTML = ""; wrap.style.display = "none"; }
}

function plFindStep(name) {
  return plStats.steps.find(function(s) { return s.name === name; });
}

function plSumChildCosts(children) {
  if (!children || !children.length) return 0;
  return children.reduce(function(acc, c) { return acc + (c.cost || 0); }, 0);
}

function plFormatTime(t) {
  return (t != null && t !== "?") ? (+t).toFixed(2) + "s" : "?";
}

function plFormatCost(c) {
  if (!c || c <= 0) return null;
  if (c < 0.0001)   return "$" + c.toFixed(6);
  if (c < 0.001)    return "$" + c.toFixed(5);
  return "$" + c.toFixed(4);
}

function plShortModel(m) {
  if (!m) return null;
  var parts = ("" + m).split("/");
  return parts[parts.length - 1];
}

function plBuildStatRow(prefix, label, time, cost, model, kind) {
  var metaParts = [];
  if (time != null && time !== "?") {
    metaParts.push('<span class="ah-pl-stime">' + plFormatTime(time) + "</span>");
  }
  var costStr = plFormatCost(cost);
  if (costStr) {
    metaParts.push('<span class="ah-pl-scost">' + costStr + "</span>");
  }
  var modelStr = plShortModel(model);
  if (modelStr) {
    metaParts.push('<span class="ah-pl-smodel">' + modelStr + "</span>");
  }

  var kindBadge = "";
  if (kind === "tribunal") {
    kindBadge = ' <span class="ah-pl-stats-tag ah-pl-stats-tag--tribunal">tribunal</span>';
  }

  return (
    '<div class="ah-pl-stats-row">' +
    '<span class="ah-pl-sprefix">' + prefix + "</span>" +
    '<span class="ah-pl-sname">' + (label || "?") + "</span>" +
    kindBadge +
    (metaParts.length
      ? '<span class="ah-pl-smeta"> =&gt; ' + metaParts.join(" | ") + "</span>"
      : "") +
    "</div>"
  );
}

function plRenderStats(totalTime) {
  var wrap = document.getElementById("ah-pl-stats");
  if (!wrap || !plStats.steps.length) return;

  var pipelineName = wrap.getAttribute("data-pipeline") || "Pipeline";
  var grandCost = 0;
  var n = plStats.steps.length;
  var rows = "";

  plStats.steps.forEach(function(step, i) {
    var last = i === n - 1;
    var childCost = plSumChildCosts(step.children);
    var displayCost = (step.cost != null && step.cost > 0) ? step.cost : childCost;
    grandCost += displayCost || 0;

    rows += plBuildStatRow(
      last ? "└─ " : "├─ ",
      step.label,
      step.time,
      displayCost,
      step.model,
      step.kind
    );

    if (step.children && step.children.length) {
      var nc = step.children.length;
      step.children.forEach(function(child, j) {
        var clast = j === nc - 1;
        var indent = (last ? "   " : "│  ") + (clast ? "└─ " : "├─ ");
        rows += plBuildStatRow(indent, child.label, child.time, child.cost, child.model);
      });
    }
  });

  var totalCostStr = plFormatCost(grandCost);
  var totalHtml =
    '<div class="ah-pl-stats-total">' +
    '<span class="ah-pl-stime">Total: ' + plFormatTime(totalTime) + "</span>" +
    (totalCostStr ? ' <span class="ah-pl-scost">' + totalCostStr + "</span>" : "") +
    "</div>";

  wrap.innerHTML =
    '<div class="ah-pl-stats-title">EXECUTION STATS</div>' +
    '<div class="ah-pl-stats-tree">' +
    '<div class="ah-pl-stats-root">' + pipelineName + '</div>' +
    rows + totalHtml + "</div>";
  wrap.style.display = "block";
}

// ── Main SSE loop ─────────────────────────────────────────────────────────────

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
    plResetStats();
    btn.disabled    = true;
    btn.textContent = "Running…";

    var es         = new EventSource("/ai/pipelines/flat/stream?input=" + encodeURIComponent(val));
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
        plRenderStats(p.time);
      } else {
        document.getElementById("ah-pl-output").textContent = p.output || "";
        if (p.time) document.getElementById("ah-pl-output-meta").textContent = "Total: " + p.time + "s";
        plRenderStats(p.time);
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
        plStats.steps.push({ name: p.step, label: p.label, kind: p.kind || null, time: null, cost: null, model: null, children: [] });
        plCurrentGroup = p.step;
        plSetStep(p.step, "running");
        plAppendLog(p.text, "info", src);

      } else if (p.event === "step_done") {
        var step = plFindStep(p.step);
        if (step) { step.time = p.time; step.cost = p.cost; step.model = p.model; }
        plSetStep(p.step, "done");
        plAppendLog(p.text, "success", src);

      } else if (p.event === "stopped") {
        plSetStep(p.step || activeStep, "stopped");
        plAppendLog(p.text, "error", "pipeline");

      } else if (p.event === "complete") {
        plAppendLog(p.text, "success", src);

      } else if (p.event === "tribunal_before_agent") {
        var group = plFindStep(plCurrentGroup);
        if (group) {
          group.children.push({ label: p.agent, index: p.index, time: null, cost: null, model: null });
        }
        plAppendLog(p.text || p.event, lvl, src);

      } else if (p.event === "tribunal_after_agent") {
        var group = plFindStep(plCurrentGroup);
        if (group && p.index != null) {
          var agent = group.children.find(function(a) { return a.index === p.index; });
          if (agent) { agent.time = p.time; agent.cost = p.cost; agent.model = p.model; }
        }
        plAppendLog(p.text || p.event, lvl, src);

      } else {
        plAppendLog(p.text || p.event, lvl, src);
      }
    });

    es.onerror = function () {
      plAppendLog("Connection lost", "error", "pipeline");
      closeStream();
    };
  });
})();
