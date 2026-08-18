const path = require("node:path");
const express = require("express");
const helmet = require("helmet");

function createApp(options = {}) {
  const app = express();
  const { deployment = {}, logger = console } = options;

  const details = {
    version: deployment.version || "1.0.0",
    commit: deployment.commit || "local",
    deployedAt: deployment.deployedAt || "not deployed"
  };

  app.use(helmet({
    contentSecurityPolicy: {
      directives: {
        "upgrade-insecure-requests": null
      }
    }
  }));

  app.use((request, response, next) => {
    const startedAt = process.hrtime.bigint();

    response.on("finish", () => {
      const durationMs = Number(process.hrtime.bigint() - startedAt) / 1_000_000;

      logger.info(JSON.stringify({
        timestamp: new Date().toISOString(),
        level: "info",
        method: request.method,
        path: request.path,
        status: response.statusCode,
        durationMs: Number(durationMs.toFixed(2))
      }));
    });

    next();
  });

  app.get("/health", (_request, response) => {
    response.json({ status: "ok" });
  });

  app.get("/version", (_request, response) => {
    response.json(details);
  });

  app.use(express.static(path.join(__dirname, "../public")));

  app.use((_request, response) => {
    response.status(404).json({ error: "not found" });
  });

  return app;
}

module.exports = { createApp };
