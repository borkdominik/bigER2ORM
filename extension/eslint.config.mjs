import typescriptEslint from "@typescript-eslint/eslint-plugin";
import tsParser from "@typescript-eslint/parser";
import path from "node:path";
import { fileURLToPath } from "node:url";
import js from "@eslint/js";
import { FlatCompat } from "@eslint/eslintrc";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
    baseDirectory: __dirname,
    recommendedConfig: js.configs.recommended,
    allConfig: js.configs.all
});

export default [{
    ignores: ["**/test.erd"],
}, ...compat.extends(
    "eslint:recommended",
    "plugin:@typescript-eslint/eslint-recommended",
    "plugin:@typescript-eslint/recommended",
), {
    plugins: {
        "@typescript-eslint": typescriptEslint,
    },

    languageOptions: {
        parser: tsParser,
        ecmaVersion: 5,
        sourceType: "module",

        parserOptions: {
            project: "tsconfig.json",
        },
    },

    rules: {
        "@typescript-eslint/no-namespace": "off",

        "brace-style": ["warn", "1tbs", {
            allowSingleLine: true,
        }],

        "keyword-spacing": "warn",
        semi: "off",
        "@typescript-eslint/semi": ["error"],

        "@typescript-eslint/no-unused-vars": ["error", {
            args: "none",
        }],

        "template-curly-spacing": ["error", "never"],

        "switch-colon-spacing": ["error", {
            after: true,
            before: false,
        }],

        "space-unary-ops": ["error", {
            words: true,
            nonwords: false,
        }],

        "space-infix-ops": ["error", {
            int32Hint: false,
        }],

        "no-array-constructor": "error",
        "space-before-blocks": "error",

        "new-cap": ["error", {
            capIsNew: true,
        }],

        "no-trailing-spaces": "error",

        "key-spacing": ["error", {
            beforeColon: false,
            afterColon: true,
        }],

        "func-call-spacing": ["error", "never"],

        "comma-spacing": ["error", {
            before: false,
            after: true,
        }],

        "block-spacing": "error",
        "array-bracket-spacing": ["error", "never"],
        "space-in-parens": ["error", "never"],
        "spaced-comment": ["error", "always"],
        "no-mixed-operators": "error",
        "no-case-declarations": "error",
        "operator-linebreak": ["error", "after"],
        "no-multi-assign": "error",
        "no-dupe-class-members": "error",
        "function-paren-newline": ["error", "multiline"],
        "@typescript-eslint/no-explicit-any": "off",
        "no-duplicate-imports": "error",
        "no-alert": "error",

        "no-console": ["warn", {
            allow: ["warn", "error"],
        }],

        "jsx-quotes": ["error", "prefer-double"],
        "no-whitespace-before-property": "error",

        "no-multiple-empty-lines": ["error", {
            max: 2,
            maxEOF: 0,
        }],

        "no-multi-spaces": "error",
    },
}];