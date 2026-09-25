// Case 08: Audio Transcription — POST multipart file, returns transcript text
(function () {
  const form      = document.getElementById("ah-form");
  const input     = document.getElementById("ah-input");
  const fileLabel = document.getElementById("ah-file-label");
  const fileName  = document.getElementById("ah-file-name");
  const modelSel  = document.getElementById("ah-model");
  const btn       = document.getElementById("ah-btn");
  const wrap      = document.getElementById("ah-text-wrap");
  const meta      = document.getElementById("ah-meta");
  const tokens    = document.getElementById("ah-tokens");
  const costEl    = document.getElementById("ah-cost");
  if (!form) return;

  input.addEventListener("change", () => {
    const file = input.files[0];
    if (file) {
      fileName.textContent = file.name;
      fileLabel.classList.add("has-file");
    } else {
      fileName.textContent = "Choose an audio file…";
      fileLabel.classList.remove("has-file");
    }
  });

  form.addEventListener("submit", (e) => {
    e.preventDefault();
    const file = input.files[0];
    if (!file) return;

    wrap.innerHTML = '<span class="ah-placeholder">Transcribing…</span>';
    meta.textContent = "";
    if (tokens) tokens.textContent = "";
    if (costEl) costEl.textContent = "";
    btn.disabled = true;
    btn.textContent = "Transcribing…";

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

    const formData = new FormData();
    formData.append("audio", file);
    if (modelSel) formData.append("model", modelSel.value);

    fetch("/ai/requests/transcribe/call", {
      method:  "POST",
      headers: { "X-CSRF-Token": csrfToken || "" },
      body:    formData,
    })
      .then((r) => r.json())
      .then(({ text, model, time, usage, cost, error }) => {
        if (error) {
          wrap.innerHTML = '<span class="ah-placeholder" style="color:#ff3b30">Error: ' + error + "</span>";
        } else {
          wrap.textContent = text;

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
        btn.textContent = "Transcribe";
      });
  });
})();
