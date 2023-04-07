# Blueraven - Albatross

## Frontend (Vue2.x/Vite)

### System Requirements
* Node 18+

#### Prerequisites
1. Create a PAT on GitHub
2. Run the following or manually create an entry in `~/.npmrc` see [GitHub Docs](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-npm-registry) for more information
```
$ npm login --scope=@7oaksgroup --registry=https://npm.pkg.github.com

> Username: USERNAME
> Password: TOKEN
> Email: PUBLIC-EMAIL-ADDRESS
```

#### Project setup
```
npm install
```

#### Compiles and hot-reloads for development
```
npm run dev
```

#### Compiles and minifies for production
```
npm run build
```

#### Run your tests
```
npm run test
```

#### Lints and fixes files
```
npm run lint
```

#### Dev Notes
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


## Backend (Spring/Java)

### System Requirements
* Java 16
* Maven

#### Start postgres and redis
```
docker-compose up
```

#### Download Maven dependencies
```
mvn install
```

#### Download the latest production dump file and restore to your local docker setup
(You will need to have your public key added to the bastion host)
```
cd bin && ./local-pump.sh
```
This will take several minutes to download the file (~7gb) and restore it to your docker container

#### Run Application (from CLI)
```
mvn spring-boot:run -Dspring-boot.run.profiles=local
```

#### Notes
* [Flyway](https://flywaydb.org/) - Database migrations - src/main/resources/db/migration/
* [GitHub Actions](https://docs.github.com/en/actions) - Continuous Delivery - .github/workflows
* [AWS](https://aws.amazon.com/console/) - (ECS/RDS/S3) - ECS Service Definitions - .aws/
* [Netlify](https://www.netlify.com/) - CDN - Front end deployment
