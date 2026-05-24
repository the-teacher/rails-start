// Case 02: Streaming Agent — SSE, no lifecycle sidebar
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

    output.textContent = "";
    output.classList.add("streaming");
    meta.textContent = "";
    btn.disabled = true;
    btn.textContent = "Thinking\u2026";

    const es = new EventSource(
      "/ai/agents/streaming/stream?input=" + encodeURIComponent(input),
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

    es.onerror = () => {
      if (streamDone) return;
      closeStream();
      if (!output.textContent) output.textContent = "Connection error.";
    };
  });
