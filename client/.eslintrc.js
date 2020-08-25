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
        'vuetify/grid-unknown-attributes': 'error',
        'vue/require-v-for-key': 'warn',
        'vue/no-unused-vars': 'warn',
        'vue/valid-v-for': 'warn',
        'no-unused-vars': 'warn',
        'no-undef': 'warn',
        'no-useless-catch': 'warn'
    },
    parserOptions: {
        parser: 'babel-eslint'
    }
}
