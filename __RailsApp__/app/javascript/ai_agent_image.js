// Case 07: Image Generation — POST, returns image via OpenRouter
(function () {
  const form   = document.getElementById("ah-form");
  const input  = document.getElementById("ah-input");
  const btn    = document.getElementById("ah-btn");
  const wrap   = document.getElementById("ah-image-wrap");
  const meta   = document.getElementById("ah-meta");
  const tokens = document.getElementById("ah-tokens");
  const costEl = document.getElementById("ah-cost");
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

    wrap.innerHTML = '<span class="ah-placeholder">Generating…</span>';
    meta.textContent = "";
    if (tokens) tokens.textContent = "";
    if (costEl) costEl.textContent = "";
    btn.disabled = true;
    btn.textContent = "Generating…";

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

    fetch("/ai/agents/image/call", {
      method:  "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken || "",
      },
      body: JSON.stringify({ input: value }),
    })
      .then((r) => r.json())
      .then(({ b64, model, time, usage, cost, error }) => {
        if (error) {
          wrap.innerHTML = '<span class="ah-placeholder" style="color:#ff3b30">Error: ' + error + "</span>";
        } else {
          const img = document.createElement("img");
          img.src = b64.startsWith("data:") ? b64 : "data:image/png;base64," + b64;
          img.alt = value;
          img.className = "ah-generated-image";
          wrap.innerHTML = "";
          wrap.appendChild(img);

          const parts = [];
          if (model) parts.push("Model: " + model);
          if (time)  parts.push(time + "s");
          meta.textContent = parts.join(" · ");

          if (usage && tokens)
            tokens.textContent = `Tokens: ${usage.input} in / ${usage.output} out / ${usage.total} total`;
          if (cost && costEl)
            costEl.textContent = "$" + (+cost).toFixed(6);
        }
      })
      .catch(() => {
        wrap.innerHTML = '<span class="ah-placeholder" style="color:#ff3b30">Network error.</span>';
      })
      .finally(() => {
        btn.disabled = false;
        btn.textContent = "Generate";
      });
  });
})();
