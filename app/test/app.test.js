const { test } = require("node:test");
const assert = require("node:assert/strict");
const request = require("supertest");

const { createApp } = require("../src/app");

const silentLogger = { info() {} };

function makeApp(deployment) {
  return createApp({ deployment, logger: silentLogger });
}

test("GET / returns the DevOps Pipeline page", async () => {
  const response = await request(makeApp()).get("/");

  assert.equal(response.status, 200);
  assert.match(response.headers["content-type"], /^text\/html/);
  assert.match(response.text, /DevOps Pipeline/);
  assert.ok(response.headers["content-security-policy"]);
  assert.doesNotMatch(response.headers["content-security-policy"], /upgrade-insecure-requests/);
  assert.equal(response.headers["x-content-type-options"], "nosniff");
  assert.equal(response.headers["x-powered-by"], undefined);
});

test("GET /health reports that the application is healthy", async () => {
  const response = await request(makeApp()).get("/health");

  assert.equal(response.status, 200);
  assert.deepEqual(response.body, { status: "ok" });
});

test("GET /version returns deployment metadata", async () => {
  const deployment = {
    version: "1.2.3",
    commit: "abc1234",
    deployedAt: "2026-07-30T12:00:00Z"
  };

  const response = await request(makeApp(deployment)).get("/version");

  assert.equal(response.status, 200);
  assert.deepEqual(response.body, deployment);
});

test("the browser assets are served by the application", async () => {
  const app = makeApp();
  const [scriptResponse, styleResponse] = await Promise.all([
    request(app).get("/app.js"),
    request(app).get("/styles.css")
  ]);

  assert.equal(scriptResponse.status, 200);
  assert.match(scriptResponse.headers["content-type"], /javascript/);
  assert.equal(styleResponse.status, 200);
  assert.match(styleResponse.headers["content-type"], /text\/css/);
});

test("unknown routes return a JSON 404 response", async () => {
  const response = await request(makeApp()).get("/missing");

  assert.equal(response.status, 404);
  assert.deepEqual(response.body, { error: "not found" });
});
