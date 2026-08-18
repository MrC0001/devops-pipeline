function setText(id, value) {
  document.querySelector(`#${id}`).textContent = value;
}

async function loadDeploymentDetails() {
  try {
    const response = await fetch("/version");

    if (!response.ok) {
      throw new Error("Version request failed");
    }

    const details = await response.json();
    setText("version", details.version);
    setText("commit", details.commit);
    setText("deployed-at", details.deployedAt);
  } catch {
    setText("version", "Unavailable");
    setText("commit", "Unavailable");
    setText("deployed-at", "Unavailable");
  }
}

document.querySelector("#check-health").addEventListener("click", async () => {
  setText("health-result", "Checking...");

  try {
    const response = await fetch("/health");
    const health = await response.json();
    setText("health-result", response.ok ? health.status : "unhealthy");
  } catch {
    setText("health-result", "unavailable");
  }
});

loadDeploymentDetails();
