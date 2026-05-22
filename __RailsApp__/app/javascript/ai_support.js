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

    // Reset
    output.textContent = "";
    output.classList.add("streaming");
    meta.textContent = "";
    btn.disabled = true;
    btn.textContent = "Thinking\u2026";

    const es = new EventSource(
      "/ai/agent_stream?input=" + encodeURIComponent(input),
    );

    es.onmessage = ({ data }) => {
      const payload = JSON.parse(data);

      if (payload.done) {
        es.close();
        output.classList.remove("streaming");
        btn.disabled = false;
        btn.textContent = "Ask";
        return;
      }

      if (payload.error) {
        output.textContent += "\nError: " + payload.error;
        es.close();
        output.classList.remove("streaming");
        btn.disabled = false;
        btn.textContent = "Ask";
        return;
      }

      output.textContent += payload.token;
      output.scrollTop = output.scrollHeight;
    };

    es.onerror = () => {
      es.close();
      output.classList.remove("streaming");
      if (!output.textContent) output.textContent = "Connection error.";
      btn.disabled = false;
      btn.textContent = "Ask";
    };
  });
