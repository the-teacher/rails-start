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
        if (payload.model)
          meta.textContent =
            "Model: " + payload.model + " \u00b7 " + payload.time + "s";
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
