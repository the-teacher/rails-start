const ahForm = document.getElementById("ah-form");
if (ahForm)
  ahForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const input = document.getElementById("ah-input").value.trim();
    if (!input) return;

    const btn = document.getElementById("ah-btn");
    const result = document.getElementById("ah-result");
    const output = document.getElementById("ah-output");
    const meta = document.getElementById("ah-meta");

    btn.disabled = true;
    btn.textContent = "Thinking\u2026";
    result.style.display = "none";
    output.textContent = "";
    meta.textContent = "";

    try {
      const res = await fetch("/ai/agent", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ input }),
      });

      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();

      output.textContent = data.output;
      meta.textContent = `Model: ${data.model} \u00b7 ${data.time ? data.time + "s" : ""}`;
      result.style.display = "block";
    } catch (err) {
      output.textContent = "Error: " + err.message;
      result.style.display = "block";
    } finally {
      btn.disabled = false;
      btn.textContent = "Ask";
    }
  });
