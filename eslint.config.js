const js = require("@eslint/js");
const globals = require("globals");

module.exports = [
  { ignores: ["node_modules/"] },
  js.configs.recommended,
  {
    files: ["**/*.js"],
    languageOptions: {
      ecmaVersion: 2023,
      sourceType: "script",
      globals: { ...globals.browser },
    },
    rules: {
      "no-var": "error",
      "prefer-const": "error",
      eqeqeq: "error",
    },
  },
  {
    files: ["eslint.config.js", "test/**/*.js", "lib.js"],
    languageOptions: { globals: { ...globals.node } },
  },
];
