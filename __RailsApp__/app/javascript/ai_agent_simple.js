// Case 01: Simple Agent — plain fetch POST, no streaming
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
    meta.textContent = "";
    btn.disabled = true;
    btn.textContent = "Thinking\u2026";

    fetch("/ai/agents/simple/call", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ input }),
    })
      .then((r) => r.json())
      .then(({ output: text, model, time, error }) => {
        if (error) {
          output.textContent = "Error: " + error;
        } else {
          output.textContent = text;
          meta.textContent = model ? `Model: ${model} \u00b7 ${time}s` : "";
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
