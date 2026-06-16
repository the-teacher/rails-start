// Case 06: Memory Agent — POST, no streaming, chat-style history
function fmtCost(c) {
  if (!c) return "";
  return "$" + (+c).toFixed(6);
}

(function () {
  const form    = document.getElementById("ah-form");
  const input   = document.getElementById("ah-input");
  const btn     = document.getElementById("ah-btn");
  const chat    = document.getElementById("ah-chat");
  if (!form) return;

  // Scroll chat to bottom on load (history may already be present)
  chat.scrollTop = chat.scrollHeight;

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

    // Remove "no messages" placeholder if present
    const empty = document.getElementById("ah-chat-empty");
    if (empty) empty.remove();

    // Append user bubble immediately
    appendMsg(value, "user");
    input.value = "";
    btn.disabled = true;
    btn.textContent = "Thinking…";

    // Append loading bubble
    const loading = appendMsg("⋯", "assistant loading");

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

    fetch("/ai/agents/memory/call", {
      method:  "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken || "",
      },
      body: JSON.stringify({ input: value }),
    })
      .then((r) => r.json())
      .then(({ output, model, time, usage, cost, error }) => {
        loading.remove();
        if (error) {
          appendMsg("Error: " + error, "assistant error");
        } else {
          const bubble = appendMsg(output, "assistant");
          const parts = [];
          if (model) parts.push(model);
          if (time)  parts.push(time + "s");
          if (usage) parts.push(`${usage.input}↑ ${usage.output}↓ tok`);
          if (cost)  parts.push(fmtCost(cost));
          if (parts.length) {
            const meta = document.createElement("span");
            meta.className = "ah-chat-meta";
            meta.textContent = parts.join(" · ");
            bubble.appendChild(meta);
          }
        }
      })
      .catch(() => {
        loading.remove();
        appendMsg("Network error.", "assistant error");
      })
      .finally(() => {
        btn.disabled = false;
        btn.textContent = "Send";
      });
  });

  function appendMsg(text, type) {
    const div = document.createElement("div");
    div.className = "ah-chat-msg ah-chat-msg--" + type.split(" ")[0];
    if (type.includes("loading")) div.classList.add("ah-chat-msg--loading");
    div.textContent = text;
    chat.appendChild(div);
    chat.scrollTop = chat.scrollHeight;
    return div;
  }
})();
