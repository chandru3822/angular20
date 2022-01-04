module.exports = {
  root: true,
  env: {
    node: true
  },
  'extends': [
    'plugin:vue/essential',
    'eslint:recommended'
  ],
  plugins: [
    'vuetify'
  ],
  rules: {
    'no-console': 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'vuetify/no-deprecated-classes': 'warn',
    'vuetify/grid-unknown-attributes': 'warn',
    'vue/return-in-computed-property': 'warn',
    'vue/no-unused-components': 'off',
    'vue/require-v-for-key': 'off',
    'vue/no-unused-vars': 'off',
    'vue/valid-v-for': 'off',
    'vue/valid-v-on': 'warn',
    'vue/no-use-v-if-with-v-for': 'warn',
    'vue/no-parsing-error': 'warn',
    'vue/multi-word-component-names': 'off',
    'vue/valid-v-slot' : 'off',
    'vue/no-mutating-props' : 'warn',
    'vue/no-useless-template-attributes': 'warn',
    'no-unused-vars': 'warn',
    'no-undef': 'warn',
    'no-useless-catch': 'warn',
    'no-useless-escape': 'warn',
    'no-unsafe-optional-chaining' : 'warn'
  },
  parserOptions: {
    "parser": "@babel/eslint-parser",
    "requireConfigFile": false
  }
}
