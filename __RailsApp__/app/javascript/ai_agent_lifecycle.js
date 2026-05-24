// Case 03: Lifecycle Agent — SSE streaming + lifecycle sidebar events.
function appendLifecycleEvent(p) {
  var el2 = document.getElementById("ah-events");
  if (!el2) return;
  var icons = { info: "●", success: "✓", warning: "⚠", error: "✗" };
  var el = document.createElement("div");
  el.className = "ah-event ah-event--" + (p.level || "info");
  el.innerHTML =
    '<span class="ah-event-icon">' +
    (icons[p.level] || "●") +
    "</span>" +
    '<span class="ah-event-text">' +
    p.text +
    "</span>";
  el2.appendChild(el);
  el2.scrollTop = el2.scrollHeight;
}

(function () {
  var inp = document.getElementById("ah-input");
  var frm = document.getElementById("ah-form");
  var btn = document.getElementById("ah-btn");
  var out = document.getElementById("ah-output");
  var met = document.getElementById("ah-meta");
  var sdb = document.getElementById("ah-events");
  if (!frm) return;

  inp.addEventListener("keydown", function (e) {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      frm.requestSubmit();
    }
  });

  frm.addEventListener("submit", function (e) {
    e.preventDefault();
    var val = inp.value.trim();
    if (!val) return;
    out.textContent = "";
    out.classList.add("streaming");
    met.textContent = "";
    btn.disabled = true;
    btn.textContent = "Thinking…";
    if (sdb) sdb.innerHTML = "";

    var es = new EventSource(
      "/ai/agents/lifecycle/stream?input=" + encodeURIComponent(val),
    );
    var done = false;

    function end() {
      done = true;
      es.close();
      out.classList.remove("streaming");
      btn.disabled = false;
      btn.textContent = "Ask";
    }

    es.onmessage = function (ev) {
      var p = JSON.parse(ev.data);
      if (p.done) {
        end();
        return;
      }
      if (p.error) {
        out.textContent += "\nError: " + p.error;
        end();
        return;
      }
      out.textContent += p.token;
      out.scrollTop = out.scrollHeight;
    };

    es.addEventListener("lifecycle", function (ev) {
      var p = JSON.parse(ev.data);
      appendLifecycleEvent(p);
      if (p.event === "after_call" && p.model)
        met.textContent =
          "Model: " + p.model + " · " + (p.time ? p.time + "s" : "");
    });

    es.onerror = function () {
      if (done) return;
      end();
      if (!out.textContent) out.textContent = "Connection error.";
    };
  });
})();
