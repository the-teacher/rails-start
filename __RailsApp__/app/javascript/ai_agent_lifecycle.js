// Case 03: Lifecycle Agent — SSE streaming + lifecycle sidebar events
function appendLifecycleEvent({ event, text, level }) {
  const events = document.getElementById("ah-events");
  if (!events) return;
  const icons = {
    info: "\u25cf",
    success: "\u2713",
    warning: "\u26a0",
    error: "\u2717",
  };
  const el = document.createElement("div");
  el.className = `ah-event ah-event--${level || "info"}`;
  el.innerHTML =
    `<span class="ah-event-icon">${icons[level] || "\u25cf"}</span>` +
    `<span class="ah-event-text">${text}</span>`;
  events.appendChild(el);
  events.scrollTop = events.scrollHeight;
}

const ahInput = document.getElementById("ah-input");
if (ahInput)
  ahInput.addEventListener("keydown", (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      document.getElementById("ah-form").requestSubmit();
    }
  });

const ahForm = document.getElementById("ah-form");
if (ahForm)
  ahForm.addEventListener("submit", (e) => {
    e.preventDefault();
    const input = document.getElementById("ah-input").value.trim();
    if (!input) return;

    const btn = document.getElementById("ah-btn");
    const output = document.getElementById("ah-output");
    const meta = document.getElementById("ah-meta");
    const events = document.getElementById("ah-events");

    output.textContent = "";
    output.classList.add("streaming");
    meta.textContent = "";
    btn.disabled = true;
    btn.textContent = "Thinking\u2026";
    if (events) events.innerHTML = "";

    const es = new EventSource(
      "/ai/agents/lifecycle/stream?input=" + encodeURIComponent(input),
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

    es.addEventListener("lifecycle", ({ data }) => {
      const payload = JSON.parse(data);
      appendLifecycleEvent(payload);
      if (payload.event === "after_call" && payload.model)
        meta.textContent = `Model: ${payload.model} \u00b7 ${payload.time ? payload.time + "s" : ""}`;
    });

    es.onerror = () => {
      if (streamDone) return;
      closeStream();
      if (!output.textContent) output.textContent = "Connection error.";
    };
  });
