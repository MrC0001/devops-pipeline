const js = require("@eslint/js");

module.exports = [
  {
    ignores: ["node_modules/**", "coverage/**"]
  },
  js.configs.recommended,
  {
    files: ["src/**/*.js", "test/**/*.js", "eslint.config.js"],
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "commonjs",
      globals: {
        __dirname: "readonly",
        console: "readonly",
        module: "readonly",
        process: "readonly",
        require: "readonly"
      }
    },
    rules: {
      "no-unused-vars": ["error", { "argsIgnorePattern": "^_" }]
    }
  },
  {
    files: ["public/**/*.js"],
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "script",
      globals: {
        document: "readonly",
        fetch: "readonly"
      }
    }
  }
];
