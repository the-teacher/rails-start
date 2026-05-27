// Tribunal 02: Politeness Lifecycle — SSE stream with live sidebar events.
function appendTribunalEvent(p) {
  var sdb = document.getElementById("ah-events");
  if (!sdb) return;
  var icons = { info: "●", success: "✓", warning: "⚠", error: "✗" };
  var sourceLabels = { tribunal: "tribunal", agent: "agent" };
  var el = document.createElement("div");
  el.className = "ah-event ah-event--" + (p.level || "info");
  var sourceBadge = p.source
    ? '<span class="ah-event-source ah-event-source--' +
      p.source +
      '">' +
      (sourceLabels[p.source] || p.source) +
      "</span>"
    : "";
  el.innerHTML =
    '<span class="ah-event-icon">' +
    (icons[p.level] || "●") +
    "</span>" +
    sourceBadge +
    '<span class="ah-event-text">' +
    p.text +
    "</span>";
  sdb.appendChild(el);
  sdb.scrollTop = sdb.scrollHeight;
}

function populatePanel(i, p) {
  var polite = p.result === true;
  var panel = document.getElementById("ah-panel-" + i);
  var badge = document.getElementById("ah-badge-" + i);
  var result = document.getElementById("ah-result-" + i);
  var reason = document.getElementById("ah-reason-" + i);
  var tokens = document.getElementById("ah-tokens-" + i);
  var time = document.getElementById("ah-time-" + i);
  var cost = document.getElementById("ah-cost-" + i);
  var model = document.getElementById("ah-model-" + i);

  panel.classList.remove("ah-tribunal-panel--waiting");
  panel.classList.add(
    polite ? "ah-tribunal-panel--polite" : "ah-tribunal-panel--rude",
  );

  badge.textContent = polite ? "✓" : "✗";
  badge.className =
    "ah-panel-badge ah-panel-badge--" + (polite ? "polite" : "rude");

  result.textContent = polite ? "Polite" : "Not polite";
  result.className =
    "ah-panel-result ah-panel-result--" + (polite ? "polite" : "rude");

  reason.textContent = p.reason || "";
  if (p.model) model.textContent = p.model;

  if (p.usage)
    tokens.textContent =
      "Tokens: " +
      p.usage.input_tokens +
      " in / " +
      p.usage.output_tokens +
      " out / " +
      p.usage.total_tokens +
      " total";
  if (p.time) time.textContent = p.time + "s";
  if (p.cost)
    cost.textContent =
      "Cost: $" +
      p.cost.total_cost.toFixed(6) +
      " (in: $" +
      p.cost.input_cost.toFixed(6) +
      " / out: $" +
      p.cost.output_cost.toFixed(6) +
      ")";
}

(function () {
  var form = document.getElementById("ah-tribunal-form");
  var input = document.getElementById("ah-tribunal-input");
  var btn = document.getElementById("ah-tribunal-btn");
  if (!form) return;

  function resetUI() {
    for (var i = 0; i < 3; i++) {
      document.getElementById("ah-panel-" + i).className =
        "ah-tribunal-panel ah-tribunal-panel--waiting";
      document.getElementById("ah-badge-" + i).textContent = "";
      document.getElementById("ah-result-" + i).textContent = "…";
      document.getElementById("ah-reason-" + i).textContent = "";
      document.getElementById("ah-tokens-" + i).textContent = "";
      document.getElementById("ah-time-" + i).textContent = "";
      document.getElementById("ah-cost-" + i).textContent = "";
    }
    var vv = document.getElementById("ah-verdict-value");
    var vt = document.getElementById("ah-verdict-time");
    var vc = document.getElementById("ah-verdict-cost");
    var fv = document.getElementById("ah-final-verdict");
    vv.textContent = "…";
    vv.className = "ah-verdict-value";
    vt.textContent = "";
    vc.textContent = "";
    fv.className = "ah-tribunal-verdict";
    var sdb = document.getElementById("ah-events");
    if (sdb) sdb.innerHTML = "";
  }

  input.addEventListener("keydown", function (e) {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      form.requestSubmit();
    }
  });

  form.addEventListener("submit", function (e) {
    e.preventDefault();
    var val = input.value.trim();
    if (!val) return;

    resetUI();
    btn.disabled = true;
    btn.textContent = "Evaluating\u2026";

    var es = new EventSource(
      "/ai/tribunals/politeness/lifecycle/stream?input=" +
        encodeURIComponent(val),
    );
    var done = false;

    function closeStream() {
      done = true;
      es.close();
      btn.disabled = false;
      btn.textContent = "Evaluate";
    }

    // Final done event — update total time, surface any partial errors
    es.addEventListener("completion", function (ev) {
      var p = JSON.parse(ev.data);
      if (p.done) {
        var vt = document.getElementById("ah-verdict-time");
        if (p.time) vt.textContent = "Total time: " + p.time + "s";
        if (p.error) {
          document.getElementById("ah-verdict-value").textContent =
            "Error: " + p.error;
        }
        // Show any agent errors that weren't surfaced via lifecycle events
        if (p.errors && p.errors.length > 0) {
          p.errors.forEach(function (e) {
            appendTribunalEvent({
              level: "error",
              text: "Failed: " + e.agent.split("::").pop() + " — " + e.error,
              event: "agent_error_summary",
            });
          });
        }
        closeStream();
      }
    });

    // Lifecycle sidebar + live panel population
    es.addEventListener("processing", function (ev) {
      var p = JSON.parse(ev.data);
      appendTribunalEvent(p);

      if (p.event === "agent_done" && p.index != null) {
        populatePanel(p.index, p);
      }

      if (p.event === "verdict") {
        var verdict = p.verdict;
        var vv = document.getElementById("ah-verdict-value");
        var fv = document.getElementById("ah-final-verdict");
        vv.textContent = verdict ? "✓ Polite" : "✗ Not polite";
        vv.className =
          "ah-verdict-value ah-verdict-value--" + (verdict ? "polite" : "rude");
        fv.className =
          "ah-tribunal-verdict ah-tribunal-verdict--" +
          (verdict ? "polite" : "rude");

        // Sum up costs for total
        var totalCost = 0;
        for (var i = 0; i < 3; i++) {
          var c = document.getElementById("ah-cost-" + i).textContent;
          var m = c.match(/\$(\d+\.\d+)/);
          if (m) totalCost += parseFloat(m[1]);
        }
        var vc = document.getElementById("ah-verdict-cost");
        if (totalCost > 0)
          vc.textContent = "Total cost: $" + totalCost.toFixed(6);
      }
    });

    es.onerror = function () {
      if (done) return;
      closeStream();
      document.getElementById("ah-verdict-value").textContent =
        "Connection error.";
    };
  });
})();
