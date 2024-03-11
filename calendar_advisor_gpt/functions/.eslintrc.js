module.exports = {
  parser: "@babel/eslint-parser",
  parserOptions: {"requireConfigFile": false},
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "max-len": ["error", {"code": 120}],
    "quotes": ["error", "double"],
    "linebreak-style": ["error", (process.platform === "win32" ? "windows" : "unix")],
  },
};
