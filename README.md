# CKAN Infrastructure

This repository contains the Docker Compose setup for deploying CKAN along with its dependencies, including PostgreSQL, Solr, Redis, and CKAN workers.

## System Requirements

Before setting up CKAN, ensure your system meets the following requirements:

- Operating System: Linux
- RAM: At least 4GB available
- Docker: Install Docker from [official docker documentation](https://docs.docker.com/engine/install/ubuntu/)
- Docker compose: Install docker compose from [official docker documentation](https://docs.docker.com/compose/install/)

## Folder Structure

```
/compose/
├── config/                   # Configuration files for all services
│   ├── ckan/                 # CKAN-specific environment configurations
│   │   └── .env              # CKAN environment variables
│   ├── db/                   # PostgreSQL configurations
│   │   └── .env              # Database environment variables
│   ├── nginx/                # Nginx environment configurations
│   │   └── .env              # Nginx environment variables
│   ├── redis/                # Redis configurations
│   │   └── .env              # Redis environment variables
│   ├── solr/                 # Solr search configurations
│   │   └── .env              # Solr environment variables
│   └── .global-env           # Global environment variables
├── services/                 # Service definitions
│   ├── ckan/                 # CKAN application service
│   │   ├── ckan.yaml         # CKAN service configuration
│   │   └── image/            # CKAN Docker image setup
│   ├── ckan-workers/         # CKAN worker services for background jobs
│   │   ├── ckan-worker-default.yaml
│   │   ├── ckan-worker-priority.yaml
│   │   └── ckan-worker-bulk.yaml
│   ├── db/                   # Database service
│   │   ├── db.yaml           # PostgreSQL service configuration
│   │   └── image/            # PostgreSQL Docker image setup
│   ├── nginx/                # Web server service
│   │   ├── nginx.yaml        # Nginx configuration
│   │   └── image/            # Nginx Docker image setup
│   ├── redis/                # Redis service
│   │   └── redis.yaml        # Redis configuration
│   ├── solr/                 # Solr service
│   │   ├── solr.yaml         # Solr service configuration
│   │   └── image/            # Solr Docker image setup
└── docker-compose.yml        # Docker Compose file
├── README.md                 # Documentation file for the repository
```

## Getting Started

### Clone the repository

```sh
git clone https://github.com/keitaroinc/onicse-ckan.git
cd onicse-ckan/compose
```

### Understanding the docker-compose.yml file

The docker-compose.yml file defines the CKAN environment and includes multiple service configurations:

```sh
include:
  - path: services/ckan/ckan.yaml
    env_file:
      - config/ckan/.env
      - config/.global-env
    project_directory: .
  - path: services/ckan-workers/ckan-worker-default.yaml
    env_file:
      - config/ckan/.env
      - config/.global-env
    project_directory: .
    .
    .
    .
networks:
  frontend:
  backend:
```

Key Components

- [include](https://docs.docker.com/compose/how-tos/multiple-compose-files/include/): Includes service definitions from separate YAML files for better modularity.
- [env_file](https://docs.docker.com/compose/how-tos/environment-variables/set-environment-variables/#use-the-env_file-attribute): Loads environment variables from .env files for each service.
- [networks](https://docs.docker.com/compose/how-tos/networking/): Defines isolated networks for frontend and backend communication.

## Understanding the Configuration Files

### `.yaml` Files in the `services` Folder

Each service has a corresponding `.yaml` file that defines how the container should be built, configured, and run. These files specify:

- Image: The Docker image used for the service.
- Environment Variables: The `.env` files that provide configurations.
- Volumes: Files or directories that should be mounted in the container. (see [volumes documentation](https://docs.docker.com/engine/storage/volumes/))
- Networks: How services communicate with each other.

`ckan.yaml` defines the main CKAN service, linking it to PostgreSQL, Solr, and Redis.

### Example `ckan.yaml`:

```sh
services:
  ckan:
    build:
      context: ${PWD}/services/ckan/image
    networks:
      - frontend
      - backend
    depends_on:
      db:
        condition: service_healthy
        restart: true
      solr:
        condition: service_healthy
        restart: true
    ports:
      - "0.0.0.0:${CKAN_PORT}:5000"
    env_file:
      - ${PWD}/config/db/.env
      - ${PWD}/config/ckan/.env
    volumes:
      - ckan_data:/app/data

```

`ckan.yaml` defines the main CKAN service, linking it to PostgreSQL, Solr, and Redis.

- `build.context`: Specifies the build directory for the CKAN image.

- `networks`: Connects CKAN to both `frontend` and `backend` networks.
- `depends_on`: Ensures CKAN starts only after PostgreSQL (db) and Solr (solr) are healthy and allows restarting if they fail.
- `ports`: Exposes CKAN on the host machine, using the environment variable `${CKAN_PORT}`.
- `env_file`: Loads environment variables from .env files in config/db/ and config/ckan/.
- `volumes`: Mounts ckan_data as a persistent storage location for CKAN data.

**Default Exposed Ports in CKAN**

[Ports documentation](https://docs.docker.com/get-started/docker-concepts/running-containers/publishing-ports/)

In this Docker Compose setup, CKAN is exposed on **port 5000** inside the container. This is defined in the `ckan.yaml` file:

- `${CKAN_PORT}` is an environment variable defined in .env, allowing you to dynamically set the port.
- Inside the CKAN container, CKAN always runs on **port 5000**, but externally, it can be mapped to any available port.

**Change CKAN Exposed Port**

Modify the `.env` File
Open the config/ckan/.env file and change CKAN_PORT to your desired port, for example:

```sh
CKAN_PORT=8080
```

Modify `ckan.yaml` (If Needed)

If your `ckan.yaml` does not already reference the environment variable, modify the ports section:

```sh
services:
  ckan:
    ports:
      - "8080:5000"
```

This maps **port 8080** on the host to **port 5000** inside the CKAN container.

After changing the port, you must rebuild and restart CKAN:

```sh
docker compose build
docker compose down
docker compose up -d
```

This ensures the new port configuration is applied.

### `.global-env` file

In the `.global-env` file you can change the CKAN and REDIS version, which is applied anywhere in the setup where it is used

```sh
#CKAN
CKAN_VERSION=2.11.2

# Redis
REDIS_VERSION=6.0.7
```

### `.env` Files in the `config` Folder

These files store environment variables used by different services to configure settings like credentials, connection details, and system parameters. For CKAN env variables CKAN plugin `envvars` is used (see [envvars documentation](https://github.com/ckan/ckanext-envvars) on how it works)

- `ckan/.env` – Contains CKAN-specific configurations (e.g., admin credentials, site URL). See CKAN [environment variables](https://docs.ckan.org/en/2.11/maintaining/configuration.html#environment-variables)

- `db/.env` – Stores PostgreSQL credentials (e.g., database name, user, password).
- `nginx/.env` – Stores Nginx settings.
- `redis/.env` – Configures Redis.
- `solr/.env` – Configures Solr.
- `.global-env` – Contains environment variables shared across multiple services.

## Managing Environment Secrets

For production deployments, create your own `.env` files with sensitive data such as database credentials and API keys. **Do not commit these files to the repository**. Instead, add them to `.gitignore` to prevent accidental exposure:

- Create your own `.env` files manually

```sh
cp config/ckan/.env config/ckan/.env-prod
cp config/db/.env config/ckan/.env-prod
```

Change the configuration in services to reference the newly created `.env-prod` file

For `ckan.yaml`, `ckan-worker-bulk.yaml`, `ckan-worker-default.yaml`, `ckan-worker-priority.yaml` change these lines:

```sh
env_file:
   - ${PWD}/config/db/.env
   - ${PWD}/config/ckan/.env
```

to

```sh
env_file:
   - ${PWD}/config/db/.env-prod
   - ${PWD}/config/ckan/.env-prod
```

For `db.yaml` change this:

```sh
env_file:
   - ${PWD}/config/db/.env
```

to this

```sh
env_file:
   - ${PWD}/config/db/.env-prod
```

Add `.env` files to `.gitignore` to prevent committing sensitive data:

```sh
echo "config/**/*.env-prod" >> .gitignore
```

## Networking and Loadbalancing

### Using an External Web Proxy

If you already have a web proxy or load balancer, you can configure it to proxy pass requests to `http://localhost:5000` without using the built-in Nginx service. This is useful if you prefer centralized management of your proxy/load balancer infrastructure.

### Using the Nginx Profile for production

Nginx serves as a reverse proxy in this setup:

- **Traffic Handling**: It accepts incoming HTTP/S requests and forwards them to CKAN running on `localhost:5000`.
- **SSL Termination**: Nginx handles SSL encryption/decryption, enhancing security.

For those who do not have an external web proxy, a dedicated Nginx service is provided via a Docker Compose profile:

```sh
docker compose --profile nginx up -d
```

This command starts all services plus the Nginx service. The Nginx container handles incoming HTTPS requests and forwards them to CKAN.

Generating and Configuring SSL Certificates
Whether you use an external proxy or the built-in Nginx, you need valid SSL certificates for secure HTTPS connections.

### Generating SSL Certificates

You can generate your own certificates using any of the SSL providers, or use the free Let's Encrypt certificate authority

- Install certbot:

```sh
sudo apt install certbot
```

- Generate certificates

```sh
sudo certbot certonly --standalone -d yourdomain.com
```

This command creates your certificate files, typically located under /etc/letsencrypt/live/yourdomain.com/.

### Configuring SSL in the Nginx Docker Image

If you opt to use the provided Nginx service, you must add your SSL certificates to the Nginx Docker image. To do so:

**Copy Your Certificates**:

- Place your SSL certificate (`fullchain.pem`) and private key (`privkey.pem`) in a directory that is accessible during the Docker build (e.g., within the compose/services/nginx/image/setup/ directory).

**Update the Dockerfile for Nginx**:
Modify the Nginx (`services/nginx/image/Dockerfile`) to copy the certificate files into the container.

For example:

```sh
FROM nginx:stable-alpine
.
.
COPY setup/default.conf /etc/nginx/conf.d/default.conf
COPY certs/fullchain.pem /etc/nginx/certs/fullchain.pem
COPY certs/privkey.pem /etc/nginx/certs/privkey.pem
.
.
```

**Update the Nginx Configuration**:
In the (`services/nginx/image/default.conf`) file, configure Nginx to use your SSL certificates:

```sh
server {
    listen       443 ssl;
    listen  [::]:443 ssl;
    server_name  yourdomain.com;
    ssl_certificate /etc/nginx/certs/fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/privkey.pem;

    location / {
        proxy_pass http://localhost:5000/;
    }
}
```

By following these steps, you can either integrate your existing proxy/load balancing solution or use the built-in Nginx service with your own SSL certificates, ensuring secure, efficient routing of traffic to your CKAN instance.

## CKAN Environment Variables

### Using the envvars plugin

CKAN utilizes the envvars plugin to inject environment variables into its configuration files. This allows dynamic configuration without hardcoding sensitive data.

- **Simplifies Configuration** – No need to manually edit `production.ini`, settings can be managed using `.env` files or directly as environment variables.
- **Better for Containers** – Works seamlessly with **Docker Compose**, Kubernetes, and cloud platforms where configurations are passed as environment variables.
- **More Secure** – Credentials and secrets (e.g., database passwords, API keys) can be set via environment variables without exposing them in configuration files.

### How the envvars plugin works

- **CKAN** loads environment variables with the **CKAN\_** prefix at startup.
- These variables override corresponding values in `production.ini`.
- The `envvars` plugin must be enabled in CKAN for this to work, in the docker image is already enabled by default.

**For more information on ckanext-envvars please check official [documentation](https://github.com/ckan/ckanext-envvars)**

### Commonly Used CKAN Environment Variables

Here are some of the most frequently used CKAN environment variables:

`DATABASE_URL`
Specifies the connection URL for the PostgreSQL database.
Example: `postgresql://ckan:ckan@db/ckan`

`CKAN_SITE_URL`
Defines the public URL of the CKAN instance.
Example: `https://prod-domain.com`

`CKAN_SYSADMIN_PASSWORD`
Sets the system administrator password for CKAN.

`CKAN_STORAGE_PATH`
Specifies the directory for CKAN storage (e.g., file uploads).

`REDIS_URL`
Defines the connection URL for Redis used for caching and queuing.

`SOLR_URL`
Specifies the connection URL for the Solr search server.

`REDIS_URL`
Defines the connection URL for Redis used for caching and queuing.

`SOLR_URL`
Specifies the connection URL for the Solr search server.

For a complete list of CKAN configuration options, refer to the [CKAN documentation](https://docs.ckan.org/en/2.11/maintaining/configuration.html#environment-variables).

## JWT, Beaker Session Secret, and XLoader API Key Generation

When the CKAN container starts it automatically generates several critical secrets using the CKAN base docker image script [start_ckan.sh](https://github.com/keitaroinc/docker-ckan/blob/master/images/ckan/2.11/setup/app/start_ckan.sh):

- **JWT_SECRET**:
  A random secret key is generated for signing and verifying JSON Web Tokens (JWTs). This key ensures that the JWT tokens used for authentication are secure.
- **BEAKER_SESSION_SECRET**:
  A random secret is generated for Beaker, which manages session data. This secret secures the session cookies and helps prevent tampering.
- **XLOADER_API_KEY**:
  A random API key is generated for the xloader functionality in CKAN. This key is used to authenticate API calls made to the xloader.

> [!NOTE]: Although these secrets are auto-generated, for production deployments you can override them with your own secure values in your .env-prod file for consistency and control.

- To change the secrets look for these env variables in the `.env` file:

```properties
CKAN___API_TOKEN__JWT__ENCODE__SECRET=
CKAN___API_TOKEN__JWT__DECODE__SECRET=
CKAN___BEAKER__SESSION__SECRET=
```

## Deploy CKAN locally

**_For local deployment nginx is not needed site can be accessed on localhost_**

```sh
docker compose build
docker compose up -d
```
See [Troubleshooting](#per) for permission issues, or check docker [official documentation](https://docs.docker.com/engine/install/linux-postinstall/) to manage docker as a non-root user.

To see if the containers are running

```sh
docker ps
```

### Access the application

Open web browser and go to http://localhost:5000

### Stopping the containers

```sh
docker compose down
```

This stops and removes the containers but keeps the data. Check on how to [remove the volumes](#remove-specific-volumes)
or use

```sh
docker compose down -v
```

**This removes all volumes**

# Deploying to production

## Preparing environment

**_Change passwords for ckan user, postgres and datastore before deploying to production environment_**

To change the CKAN and PostgreSQL passwords, follow these steps:

### CKAN Password

1. **Open the CKAN `compose/config/ckan/.env` file and update following env variable:**

   ```properties
   CKAN_SYSADMIN_PASSWORD=new_password
   ```

2. **Save and close the file.**

### PostgreSQL and Datastore Password

1. **Open the PostgreSQL `compose/config/db/.env` file and update following env variables:**

   ```properties
   POSTGRES_PASSWORD=new_password
   DATASTORE_READONLY_PASSWORD=new_password
   ```

2. **Save and close the file.**

## Set production domain

Before building the docker containers and deploying CKAN with Nginx for a production environment, follow these steps to configure the public domain:

1. **Open the CKAN `compose/config/ckan/.env` file and update the following env variable to your desired domain:**

```properties
   CKAN_SITE_URL=https://prod-domain.com
```

2. **Save and close the file.**

## Optional Steps

3. **Set up Load Balancing:**

   Open the Nginx configuration file and update it to reflect your domain and SSL settings.

   ```properties
   compose/services/nginx/image/setup/default.conf
   ```

4. **Update the Nginx configuration:**

   ```properties
   server {
       listen       443 ssl;
       listen  [::]:443 ssl;
       server_name  yourdomain.com;
       ssl_certificate /etc/nginx/certs/yourcertificate.crt;
       ssl_certificate_key /etc/nginx/certs/yourprivatekey.key;

       location / {
           proxy_pass http://ckan:5000/;

       }

   }
   ```

5. **Save and close the file.**

# Building and deploying Docker setup

1. **Navigate to the project directory:**

   ```sh
   cd compose
   ```

2. **Build the Docker containers:**

   ```sh
   docker compose build
   ```

3. **Start the Docker containers:**

   **Optional**

   **_Use nginx if you don't have web proxy_**

   ```sh
   docker compose --profile nginx up -d
   ```

   #### Explanation:

   - `--profile nginx`: Starts all services plus the nginx service, which is required for production.

   - `-d` (detached mode): Starts the services defined in a docker-compose.yml file in detached mode, meaning they run in the background. This allows the user to continue using the terminal for other tasks without the output of the containers cluttering the screen.

   If not using nginx as web proxy just run

   ```sh
   docker compose up -d
   ```

4. **Check to ensure all services are running correctly:**

   ```sh
   docker ps -a
   ```

   **_This displays all containers on your system, not just the running ones. This includes containers that are stopped or have exited, which is useful for troubleshooting or reviewing past container activity._**

5. **If any issues arise with some container, check the logs, -f option tails the logs, better for troubleshooting**
   ```sh
   docker logs containerName -f
   ```
6. **Access CKAN**

   Open your web browser and navigate to `https://prod-domain.com` to access the CKAN instance.

7. **Execute interactive shell in the docker container**

   To execute interactive shell in the container use exec, for more information check [official documentation](https://docs.docker.com/reference/cli/docker/container/exec/)

   ```sh
   docker exec -it container-name sh
   ```

8. **Stopping CKAN Containers**

   To stop the running CKAN containers, use the following command:

   ```sh
   docker compose down
   ```

   This stops and removes all running containers but **keeps the volumes intact**, meaning your data will persist.

   To stop containers and remove volumes, use with precaution:

   **⚠ Warning: This removes all volumes**
   ```sh
   docker compose down -v
   ```

# Remove specific volumes

By default, Docker Compose does not remove volumes when bringing down containers. If you want to remove all data (including the database, uploaded files, and cached data), you must explicitly delete the volumes:
## ⚠ Warning: Deleting volumes will permanently erase all stored data. Make sure you have backups if needed, check how to make [backups](#creating-backups)

- List all volumes:

```sh
docker volume ls
```

Remove specific volumes:

```sh
docker volume rm volume_name
```

Replace volume_name with the actual volume name.


## CKAN Plugins Management

CKAN plugins (extensions) can be managed using the `extensions.yaml` file located at `services/ckan/image/extensions.yaml`. This file specifies the plugins to be installed along with their configuration.

**Example Format for Adding a Plugin**:

```sh
extensions:
  - url: https://github.com/ckan/ckanext-plugin
    branch_tag: master
    requirements: requirements.txt
    name: ckanext-plugin
```

| Property     | Description                                                                                                                                                                          |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| url          | The GitHub repository URL of the extension. This is where CKAN pulls the source code from.                                                                                           |
| branch_tag   | The branch or tag from which the extension should be installed (e.g., master, 2.11, or a specific release tag like v1.0.0).                                                          |
| requirements | The requirements file inside the repository that lists the Python dependencies needed for the extension to work. If the plugin does not have requirements.txt file, leave this empty |
| name         | The name of the extension, this name is used when enabling the plugin in CKAN.                                                                                                       |

After adding the wanted plugin in the `extensions.yaml` file, also add the plugin in the `.env` file to the `CKAN__PLUGINS` env variable as addition to already installed plugins

```sh
CKAN__PLUGINS=envvars activity image_view text_view datatables_view datastore xloader onicse_theme
```

## Rebuilding Containers After Making Changes

After making changes to the CKAN setup, such as modifying the configuration files, updating dependencies, or changing installed plugins, you need to rebuild the Docker images before restarting the containers.

### Why is docker compose build Needed?

- **Applies Configuration Changes**
  - If you modify environment variables, .env files, or configuration settings, simply restarting the containers (docker compose restart) may not apply these changes. Rebuilding ensures all configurations are correctly applied.
- **Updates Installed Plugins and Extensions**
  - If you've added new CKAN extensions (plugins) to extensions.yaml, CKAN won't recognize them until the image is rebuilt.
- **Applies Updates from the Dockerfile**
  - If you've changed the Dockerfile or CKAN source code, these changes will only take effect after a rebuild.

## Creating Backups

Before making any changes, upgrading, or removing CKAN data, it's important to create backups of your database, uploaded files, and configurations.

- **Backup PostgreSQL Database**

Run the following command inside the running CKAN container or from a machine that has access to the database:

```sh
docker exec -t ckan-db pg_dump -U ckan -d ckan > ckan_backup_$(date +%Y%m%d).sql
```

- This will create a dump of the CKAN database `ckan` and save it as `ckan_backup_YYYYMMDD.sql`.
- Replace `ckan-db` with the actual name of your PostgreSQL container if it's different.

To restore the backup, use:

```sh
cat ckan_backup_YYYYMMDD.sql | docker exec -i ckan-db psql -U ckan -d ckan
```

- **Backup Uploaded Files (Storage Path)**
  CKAN stores uploaded files in a directory (usually inside a Docker volume). To back it up:

```sh
docker run --rm --volumes-from ckan -v $(pwd):/backup ubuntu tar czvf /backup/ckan_storage_backup_$(date +%Y%m%d).tar.gz /var/lib/ckan
```

This creates a compressed backup (`tar.gz`) of CKAN’s file storage directory.

Adjust the storage path if you have a custom setup.

To restore:

```sh
docker run --rm --volumes-from ckan -v $(pwd):/backup ubuntu tar xzvf /backup/ckan_storage_backup_YYYYMMDD.tar.gz -C /
```

## Troubleshooting

### Common Issues and How to Resolve Them

### Port already in use?

- Change the port mapping e.g., 9090:80 instead of 8080:80.

### Permission issues:

- Try running commands with sudo

```sh
sudo docker compose up -d
```

### Container Fails to Start or Crashes:

- **Check Logs**: Use the following command to view detailed logs:

```sh
docker logs containerName
```

- **Review Dependencies**: Make sure that dependent services (e.g., PostgreSQL, Solr) are healthy. Containers configured with depends_on may fail if these dependencies are not ready.
- **Rebuild Without Cache**: If changes to configurations or images are not reflected, rebuild the images using the --no-cache flag, this will automatically pull a fresh image from the repo. It also won't use the cached version that is prebuilt with any parameters.

```sh
docker compose build --no-cache
```

### Environment Variable Issues:

Ensure that all required environment variables are correctly set in your `.env` file. Missing or misconfigured environment variables (e.g., `DATABASE_URL`, `JWT_SECRET`) can cause application errors.

By following these steps, you can build, deploy, and manage the CKAN infrastructure using Docker Compose.

**Useful links for docker**

Official Docker Documentation
Comprehensive guide and reference for all things Docker.
https://docs.docker.com/

Docker Compose Documentation
Learn how to define and run multi-container Docker applications.
https://docs.docker.com/compose/

This repository contains base docker images and docker-compose used to build and run CKAN.
https://github.com/keitaroinc/docker-ckan

Here you can find many CKAN related blog posts
https://www.keitaro.com/insights/
