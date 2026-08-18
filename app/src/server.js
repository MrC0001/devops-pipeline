const { createApp } = require("./app");

const port = Number(process.env.PORT || 3000);

const app = createApp({
  deployment: {
    version: process.env.APP_VERSION,
    commit: process.env.GIT_COMMIT,
    deployedAt: process.env.DEPLOYED_AT
  }
});

app.listen(port, "127.0.0.1", () => {
  console.log(JSON.stringify({
    level: "info",
    message: "DevOps Pipeline started",
    port
  }));
});
