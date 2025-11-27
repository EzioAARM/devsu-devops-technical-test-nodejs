module.exports = {
    env: {
        browser: true,
        commonjs: true,
        es2021: true,
        node: true,
        jest: true,
    },
    extends: ["eslint:recommended"],
    parserOptions: {
        ecmaVersion: 12,
        sourceType: "module",
    },
    rules: {
        indent: ["error", 4],
        "linebreak-style": [
            "error",
            process.platform === "win32" ? "windows" : "unix",
        ],
        quotes: ["error", "single"],
        semi: ["error", "never"],
        "no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
        "no-console": "off", // Allow console for server logging
        complexity: ["error", 15],
        "max-depth": ["error", 4],
        "max-len": ["error", { code: 120, ignoreUrls: true }],
        "no-var": "error",
        "prefer-const": "error",
        "no-multiple-empty-lines": ["error", { max: 2 }],
        "eol-last": "error",
    },
    overrides: [
        {
            files: ["*.test.js", "**/__tests__/**/*.js"],
            rules: {
                "no-console": "off",
            },
        },
    ],
};
