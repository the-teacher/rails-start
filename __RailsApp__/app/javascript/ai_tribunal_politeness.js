// Tribunal 01: Politeness — POST /ai/tribunals/politeness/call
// Sends input, then populates 3 verdict panels + final verdict.
(function () {
  var form = document.getElementById("ah-tribunal-form");
  var input = document.getElementById("ah-tribunal-input");
  var btn = document.getElementById("ah-tribunal-btn");
  if (!form) return;

  function resetUI() {
    for (var i = 0; i < 3; i++) {
      document.getElementById("ah-panel-" + i).className = "ah-tribunal-panel";
      document.getElementById("ah-badge-" + i).textContent = "";
      document.getElementById("ah-result-" + i).textContent = "—";
      document.getElementById("ah-reason-" + i).textContent = "";
      document.getElementById("ah-tokens-" + i).textContent = "";
      document.getElementById("ah-time-" + i).textContent = "";
      document.getElementById("ah-cost-" + i).textContent = "";
    }
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

  function populatePanel(i, r) {
    var polite = r.result === true;
    var panel = document.getElementById("ah-panel-" + i);
    var badge = document.getElementById("ah-badge-" + i);
    var result = document.getElementById("ah-result-" + i);
    var reason = document.getElementById("ah-reason-" + i);
    var tokens = document.getElementById("ah-tokens-" + i);
    var time = document.getElementById("ah-time-" + i);
    var model = document.getElementById("ah-model-" + i);

    panel.classList.add(
      polite ? "ah-tribunal-panel--polite" : "ah-tribunal-panel--rude",
    );
    badge.textContent = polite ? "✓" : "✗";
    badge.className =
      "ah-panel-badge ah-panel-badge--" + (polite ? "polite" : "rude");
    result.textContent = polite ? "Polite" : "Not polite";
    result.className =
      "ah-panel-result ah-panel-result--" + (polite ? "polite" : "rude");
    reason.textContent = r.reason || "";
    model.textContent = r.model || model.textContent;

    if (r.usage) {
      tokens.textContent =
        "Tokens: " +
        r.usage.input +
        " in / " +
        r.usage.output +
        " out / " +
        r.usage.total +
        " total";
    }
    if (r.time) {
      time.textContent = r.time + "s";
    }
    var cost = document.getElementById("ah-cost-" + i);
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

    fetch("/ai/tribunals/politeness/call", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: "input=" + encodeURIComponent(val),
    })
      .then(function (res) {
        return res.json();
      })
      .then(function (data) {
        if (data.error) {
          document.getElementById("ah-verdict-value").textContent =
            "Error: " + data.error;
          return;
        }

        // Populate each model panel
        (data.results || []).forEach(function (r) {
          populatePanel(r.index, r);
        });

        // Final verdict
        var verdict = data.verdict;
        var vv = document.getElementById("ah-verdict-value");
        var vt = document.getElementById("ah-verdict-time");
        var vc = document.getElementById("ah-verdict-cost");
        var fv = document.getElementById("ah-final-verdict");

        vv.textContent = verdict ? "✓ Polite" : "✗ Not polite";
        vv.className =
          "ah-verdict-value ah-verdict-value--" + (verdict ? "polite" : "rude");
        fv.className =
          "ah-tribunal-verdict ah-tribunal-verdict--" +
          (verdict ? "polite" : "rude");

        if (data.time) {
          vt.textContent = "Total time: " + data.time + "s";
        }
        var totalCost = (data.results || []).reduce(function (sum, r) {
          return sum + (r.cost ? +r.cost : 0);
        }, 0);
        if (totalCost > 0) {
          vc.textContent = "Total cost: $" + totalCost.toFixed(6);
        }
      })
      .catch(function (err) {
        document.getElementById("ah-verdict-value").textContent =
          "Network error";
      })
      .finally(function () {
        btn.disabled = false;
        btn.textContent = "Evaluate";
      });
  });
})();
