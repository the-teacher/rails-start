// Tribunal 03: Content Safety — POST /ai/tribunals/safety/call
// Two panels, matched by result "kind" (text/jev) rather than array index —
// robust even if one of the two requests fails (partial failure is tolerated
// by the tribunal by default).
(function () {
  var form = document.getElementById("ah-tribunal-form");
  var input = document.getElementById("ah-tribunal-input");
  var btn = document.getElementById("ah-tribunal-btn");
  if (!form) return;

  var KINDS = ["text", "jev"];

  function resetUI() {
    KINDS.forEach(function (kind) {
      document.getElementById("ah-panel-" + kind).className = "ah-tribunal-panel";
      document.getElementById("ah-badge-" + kind).textContent = "";
      document.getElementById("ah-result-" + kind).textContent = "—";
      document.getElementById("ah-reason-" + kind).textContent = "";
      document.getElementById("ah-tokens-" + kind).textContent = "";
      document.getElementById("ah-time-" + kind).textContent = "";
      document.getElementById("ah-cost-" + kind).textContent = "";
    });
    var vv = document.getElementById("ah-verdict-value");
    var vt = document.getElementById("ah-verdict-time");
    var vc = document.getElementById("ah-verdict-cost");
    var fv = document.getElementById("ah-final-verdict");
    vv.textContent = "—";
    vv.className = "ah-verdict-value";
    vt.textContent = "";
    vc.textContent = "";
    fv.className = "ah-tribunal-verdict";
  }

  function populatePanel(r) {
    var safe = !r.flagged;
    var panel = document.getElementById("ah-panel-" + r.kind);
    var badge = document.getElementById("ah-badge-" + r.kind);
    var result = document.getElementById("ah-result-" + r.kind);
    var reason = document.getElementById("ah-reason-" + r.kind);
    var tokens = document.getElementById("ah-tokens-" + r.kind);
    var time = document.getElementById("ah-time-" + r.kind);
    var model = document.getElementById("ah-model-" + r.kind);
    if (!panel) return;

    panel.classList.add(safe ? "ah-tribunal-panel--polite" : "ah-tribunal-panel--rude");
    badge.textContent = safe ? "✓" : "✗";
    badge.className = "ah-panel-badge ah-panel-badge--" + (safe ? "polite" : "rude");
    result.textContent = safe ? "Safe" : "Flagged";
    result.className = "ah-panel-result ah-panel-result--" + (safe ? "polite" : "rude");
    reason.textContent = r.reason || "";
    model.textContent = r.model || model.textContent;

    if (r.usage) {
      tokens.textContent =
        "Tokens: " + r.usage.input + " in / " + r.usage.output + " out / " + r.usage.total + " total";
    }
    if (r.time) time.textContent = r.time + "s";
    var cost = document.getElementById("ah-cost-" + r.kind);
    if (r.cost && cost) cost.textContent = "$" + (+r.cost).toFixed(6);
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
    btn.textContent = "Evaluating…";

    fetch("/ai/tribunals/safety/call", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: "input=" + encodeURIComponent(val),
    })
      .then(function (res) {
        return res.json();
      })
      .then(function (data) {
        if (data.error) {
          document.getElementById("ah-verdict-value").textContent = "Error: " + data.error;
          return;
        }

        (data.results || []).forEach(populatePanel);

        var verdict = data.verdict;
        var vv = document.getElementById("ah-verdict-value");
        var vt = document.getElementById("ah-verdict-time");
        var vc = document.getElementById("ah-verdict-cost");
        var fv = document.getElementById("ah-final-verdict");

        vv.textContent = verdict ? "✓ Safe" : "✗ Flagged";
        vv.className = "ah-verdict-value ah-verdict-value--" + (verdict ? "polite" : "rude");
        fv.className = "ah-tribunal-verdict ah-tribunal-verdict--" + (verdict ? "polite" : "rude");

        if (data.time) vt.textContent = "Total time: " + data.time + "s";
        var totalCost = (data.results || []).reduce(function (sum, r) {
          return sum + (r.cost ? +r.cost : 0);
        }, 0);
        if (totalCost > 0) vc.textContent = "Total cost: $" + totalCost.toFixed(6);
      })
      .catch(function () {
        document.getElementById("ah-verdict-value").textContent = "Network error";
      })
      .finally(function () {
        btn.disabled = false;
        btn.textContent = "Evaluate";
      });
  });
})();
