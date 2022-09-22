# blueraven-albatros

## Set up environment
1. Create a PAT on GitHub
2. Run the following or manually create an entry in `~/.npmrc` see [GitHub Docs](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-npm-registry) for more information
```
$ npm login --scope=@7oaksgroup --registry=https://npm.pkg.github.com

> Username: USERNAME
> Password: TOKEN
> Email: PUBLIC-EMAIL-ADDRESS
```

## Project setup
```
npm install
```

### Compiles and hot-reloads for development
```
npm run dev
```

### Compiles and minifies for production
```
npm run build
```

### Run your tests
```
npm run test
```

### Lints and fixes files
```
npm run lint
```

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).

### Dev Notes
Use vuetify theme values and not hard coded colors where appropriate. <br/>
Example in /plugin/vuetify/index.js
```
theme: {
    primary: '#1F3C73',
    primaryCustom: '#1F3C73',
  },
```

Usage in css:
```
background-color: var(--v-primaryCustom-base);
```

Usage in component:
```
color="primaryCustom"
```
