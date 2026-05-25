// Case 02: Streaming Agent — SSE, no lifecycle sidebar
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
    output.classList.add("streaming");
    meta.textContent = "";
    document.getElementById("ah-tokens").textContent = "";
    document.getElementById("ah-cost").textContent = "";
    btn.disabled = true;
    btn.textContent = "Thinking\u2026";

    const es = new EventSource(
      "/ai/agents/streaming/stream?input=" + encodeURIComponent(value),
    );
    let streamDone = false;

    function closeStream() {
      streamDone = true;
      es.close();
      output.classList.remove("streaming");
      btn.disabled = false;
      btn.textContent = "Ask";
    }

    es.onmessage = ({ data }) => {
      const payload = JSON.parse(data);
      if (payload.done) {
        const metaParts = [];
        if (payload.model) metaParts.push("Model: " + payload.model);
        if (payload.time) metaParts.push(payload.time + "s");
        meta.textContent = metaParts.join(" \u00b7 ");
        const tokens = document.getElementById("ah-tokens");
        const u = payload.usage;
        if (u && tokens)
          tokens.textContent = `Tokens: ${u.input_tokens} in / ${u.output_tokens} out / ${u.total_tokens} total`;
        const costEl = document.getElementById("ah-cost");
        const c = payload.cost;
        if (c && costEl)
          costEl.textContent = `Cost: $${c.total_cost.toFixed(6)} (in: $${c.input_cost.toFixed(6)} / out: $${c.output_cost.toFixed(6)})`;
        closeStream();
        return;
      }
      if (payload.error) {
        output.textContent += "\nError: " + payload.error;
        closeStream();
        return;
      }
      output.textContent += payload.token;
      output.scrollTop = output.scrollHeight;
    };

    es.onerror = () => {
      if (streamDone) return;
      closeStream();
      if (!output.textContent) output.textContent = "Connection error.";
    };
  });
})();
