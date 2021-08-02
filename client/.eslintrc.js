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
        'no-console': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
        'no-debugger': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
        'vuetify/no-deprecated-classes': 'error',
        'vuetify/grid-unknown-attributes': 'warn',
        'vue/return-in-computed-property': 'warn',
        'vue/no-unused-components' : 'off',
        'vue/require-v-for-key': 'off',
        'vue/no-unused-vars': 'warn',
        'vue/valid-v-for': 'off',
        'vue/valid-v-on' : 'warn',
        'vue/no-use-v-if-with-v-for': 'warn',
        'vue/no-parsing-error': 'warn',
        'no-unused-vars': 'warn',
        'no-undef': 'warn',
        'no-useless-catch': 'warn',
        'no-useless-escape': 'warn'
    },
    parserOptions: {
        parser: 'babel-eslint'
    }
}
