# BlueRaven - Albatross


## Front-End
* Vue 2.x
* Vite
* Netlify Hosted

### System Requirements
* Node v20+

### Prerequisites
1. Create a **Personal Access Token** on GitHub either by clicking [here](https://github.com/settings/tokens) or by navigating to `Setting -> Developer Settings -> Personal Access Tokens` in GitHub.
2. Login to npm or manually create an entry in `~/.npmrc`. See [GitHub Docs](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-npm-registry) for more information.

    ```bash
    npm login --scope=@7oaksgroup --registry=https://npm.pkg.github.com
    ```

   If your `npm` version >= 9, add the `--auth-type=legacy` argument:
    ```bash
    npm login --scope=@7oaksgroup --registry=https://npm.pkg.github.com --auth-type=legacy
    ```

   When prompted, input the following values to authenticate:
    ```js
    Username: <GITHUB_USERNAME>
    Password: <PERSONAL_ACCESS_TOKEN>
    Email:    <PUBLIC_EMAIL_ADDRESS>
    ```

   Execute if you are unsure about your current `npm` version:
    ```bash
    npm --version
    ```

### Project Setup
Ensure that all the instructions below are performed in the `client/` directory of the project.

Install dependencies and packages defined in `client/package.json`
```bash
  npm install
```

Start development server locally
```bash
  npm run dev
```

Run tests against the code
```bash
  npm run test
```

Lint files & fix any issues
```bash
  npm run lint
```

Compile & minify code
```bash
  npm run build
```

### Front-End Notes
Use `Vuetify` theme values and not hard coded colors where to simplify future changes to the theme.

* Example for updating theme values in `/plugin/vuetify/index.js`:
  ```js
  theme: {
    primary: '#1F3C73',
    primaryCustom: '#1F3C73',
  },
  ```

* How to reference changes in CSS
  ```css
  background-color: var(--v-primaryCustom-base);
  ```

* Implement new `Vuetify` change within a component
  ```js
  <ComponentExample
    color="primaryCustom"
  />
  ```

<br />

---

## Back-End
* Java
* Spring Framework
* ECS/Fargate Hosted

### System Requirements
* Java 21
* Maven
* Docker
* Docker Compose

### Prerequisites
Ensure that all the instructions below are performed in the root directory of the project.
1. Copy the `.env` file to create a `.env.local` file for environment variables
    ```bash
    cp .env .env.local
    ```
2. Add the environment variables below in your `.env.local`
    ```js
    DATABASE_URL=<JDBC_POSTGRES_URL>
    DATABASE_USERNAME=
    DATABASE_PASSWORD=
    DATABASE_READONLY_URL=<JDBC_READONLY_POSTGRES_URL>
    ```
3. Ensure Docker is running which can be done by simply opening Docker Desktop. Alternatively, you can manually start Docker from the terminal:
   #### _Mac OS_
   Open Docker Desktop from Mac Terminal
    ```bash
    open /Applications/Docker.app
    ```

   Start Docker in the Terminal using Docker CLI
    ```bash
    docker desktop start
    ```

   #### _Linux Terminal_

   Start Docker Desktop
    ```bash
    systemctl --user start docker-desktop
    ```

   Start Docker Engine using systemd
    ```bash
    sudo systemctl start docker
    ```

   #### _Windows Powershell/CmdLine (Administrator)_

   Start Docker Desktop from shell
    ```shell
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    ```

   Start Docker service
    ```shell
    net start com.docker.service
    ```

You can execute the following to see the state of Docker regardless of OS
```shell
  docker info
```

### Project Setup

Start Redis, Postgres, Gotenberg, & Localstack containers
```bash
  docker-compose --env-file .env.local up
```

Download dependencies using Maven
```bash
  mvn install
```

If you're not connecting to stage Database environment. Download the latest production database dump file and restore to your local Docker setup.
You will need to have your public key added to the bastion host/jump box. Note that this process will take several minutes to download the file (~7gb) and restore it to your docker container.

```bash
  cd bin && ./local-pump.sh
```

Run Application (from CLI)
```bash
  mvn spring-boot:run -Dspring-boot.run.profiles=local
```

### Back-End Notes
* [Flyway](https://flywaydb.org/) - Database migrations located in `src/main/resources/db/migration/`
* [GitHub Actions](https://docs.github.com/en/actions) - Continuous Delivery located in `.github/workflows`
* [AWS](https://aws.amazon.com/console/) utilizing ECS/RDS/S3 - ECS Service Definitions located in `.aws/`
* [Netlify](https://www.netlify.com/) - Front-End Deployment/Hosting Provider configuration located in `netlify.toml`
