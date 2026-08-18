const { createApp } = require("./app");

const port = Number(process.env.PORT || 3000);

const app = createApp({
  deployment: {
    version: process.env.APP_VERSION,
    commit: process.env.GIT_COMMIT,
    deployedAt: process.env.DEPLOYED_AT
  }
});

app.listen(port, () => {
  console.log(JSON.stringify({
    level: "info",
    message: "Application started",
    port
  }));
});
