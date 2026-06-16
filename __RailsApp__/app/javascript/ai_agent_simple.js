// Case 01: Simple Agent — plain fetch POST, no streaming
(function () {
  const input = document.getElementById("ah-input");
  const form = document.getElementById("ah-form");
  const btn = document.getElementById("ah-btn");
  const output = document.getElementById("ah-output");
  const meta = document.getElementById("ah-meta");
  if (!form) return;

  input.addEventListener("keydown", (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      form.requestSubmit();
    }
  });

  form.addEventListener("submit", (e) => {
    e.preventDefault();
    const value = input.value.trim();
    if (!value) return;

    output.textContent = "";
    meta.textContent = "";
    document.getElementById("ah-tokens").textContent = "";
    document.getElementById("ah-cost").textContent = "";
    btn.disabled = true;
    btn.textContent = "Thinking\u2026";

    fetch("/ai/agents/simple/call", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ input: value }),
    })
      .then((r) => r.json())
      .then(({ output: text, model, time, usage, cost, error }) => {
        if (error) {
          output.textContent = "Error: " + error;
        } else {
          output.textContent = text;
          const metaParts = [];
          if (model) metaParts.push(`Model: ${model}`);
          if (time) metaParts.push(`${time}s`);
          meta.textContent = metaParts.join(" \u00b7 ");
          const tokens = document.getElementById("ah-tokens");
          if (usage && tokens)
            tokens.textContent = `Tokens: ${usage.input} in / ${usage.output} out / ${usage.total} total`;
          const costEl = document.getElementById("ah-cost");
          if (cost && costEl)
            costEl.textContent = "$" + (+cost).toFixed(6);
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
