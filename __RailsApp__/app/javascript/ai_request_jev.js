// Case 09: Jev (TypeSafe AI) — plain fetch POST, no streaming.
// Shows two sections: the full raw answer structure, and a small
// human-readable summary derived from it (client-side only — the gem/provider
// itself does no interpretation, this is purely a display concern).
(function () {
  const input = document.getElementById("ah-input");
  const form = document.getElementById("ah-form");
  const btn = document.getElementById("ah-btn");
  const output = document.getElementById("ah-output");
  const meta = document.getElementById("ah-meta");
  const summary = document.getElementById("ah-jev-summary");
  if (!form) return;

  input.addEventListener("keydown", (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      form.requestSubmit();
    }
  });

  // One row's label/value for a single answer, based on its `type`.
  function formatAnswer(name, answer) {
    const label = name.replace(/_/g, " ");

    if (answer.type === "noul") {
      const pct = Math.round(answer.noul * 100);
      const verdict = answer.noul >= 0.5 ? "Yes" : "No";
      return { label, value: `${verdict} (${pct}%)` };
    }

    if (answer.type === "choice") {
      const pct = Math.round((answer.probabilities?.[answer.choice] ?? 0) * 100);
      return { label, value: `${answer.choice} (${pct}%)` };
    }

    if (answer.type === "score") {
      const maxIndex = answer.probabilities
        ? Object.keys(answer.probabilities).length - 1
        : null;
      const score = Number(answer.score).toFixed(2);
      return { label, value: maxIndex != null ? `${score} / ${maxIndex}` : score };
    }

    return { label, value: JSON.stringify(answer) };
  }

  function renderSummary(data) {
    const entries = Object.entries(data || {});
    if (!entries.length) {
      summary.innerHTML = '<span class="ah-placeholder">No answers.</span>';
      return;
    }
    summary.innerHTML = entries
      .map(([name, answer]) => {
        const { label, value } = formatAnswer(name, answer);
        return (
          '<div class="ah-jev-row">' +
          `<span class="ah-jev-row-label">${label}</span>` +
          `<span class="ah-jev-row-value">${value}</span>` +
          "</div>"
        );
      })
      .join("");
  }

  form.addEventListener("submit", (e) => {
    e.preventDefault();
    const value = input.value.trim();
    if (!value) return;

    output.textContent = "";
    meta.textContent = "";
    summary.innerHTML = "";
    document.getElementById("ah-tokens").textContent = "";
    document.getElementById("ah-cost").textContent = "";
    btn.disabled = true;
    btn.textContent = "Evaluating…";

    fetch("/ai/requests/jev/call", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ input: value }),
    })
      .then((r) => r.json())
      .then(({ output: data, model, time, usage, error }) => {
        if (error) {
          output.textContent = "Error: " + error;
          summary.innerHTML = `<span class="ah-placeholder">${error}</span>`;
        } else {
          output.textContent = JSON.stringify(data, null, 2);
          renderSummary(data);
          const metaParts = [];
          if (model) metaParts.push(`Model: ${model}`);
          if (time) metaParts.push(`${time}s`);
          meta.textContent = metaParts.join(" · ");
          const tokens = document.getElementById("ah-tokens");
          if (usage && tokens)
            tokens.textContent = `Tokens: ${usage.input} in / ${usage.output} out / ${usage.total} total`;
        }
      })
      .catch(() => {
        output.textContent = "Network error.";
      })
      .finally(() => {
        btn.disabled = false;
        btn.textContent = "Ask";
      });
  });
})();
