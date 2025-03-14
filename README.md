# CKAN Infrastructure

This repository contains the Docker Compose setup for deploying CKAN along with its dependencies, including PostgreSQL, Solr, Redis, and CKAN workers.

## System Requirements
Before setting up CKAN, ensure your system meets the following requirements:
 - Operating System: Linux (Ubuntu recommended)
 - RAM: At least 4GB recommended
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
cd compose
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
```
Key Components
 - include: Includes service definitions from separate YAML files for better modularity.
 - env_file: Loads environment variables from .env files for each service.
 - networks: Defines isolated networks for frontend and backend communication.

## Understanding the Configuration Files
### ```.yaml``` Files in the ```services``` Folder
Each service has a corresponding ```.yaml``` file that defines how the container should be built, configured, and run. These files specify:
- Image: The Docker image used for the service.
- Environment Variables: The ```.env``` files that provide configurations.
- Volumes: Files or directories that should be mounted in the container.
- Networks: How services communicate with each other.

```ckan.yaml``` defines the main CKAN service, linking it to PostgreSQL, Solr, and Redis.
### Explanation for ```ckan.yaml``` as example:
```ckan.yaml``` defines the main CKAN service, linking it to PostgreSQL, Solr, and Redis.
- ```build.context```: Specifies the build directory for the CKAN image.

- ```networks```: Connects CKAN to both frontend and backend networks.
- ```depends_on```: Ensures CKAN starts only after PostgreSQL (db) and Solr (solr) are healthy and allows restarting if they fail.
- ```ports```: Exposes CKAN on the host machine, using the environment variable ${CKAN_PORT}.
- ```env_file```: Loads environment variables from .env files in config/db/ and config/ckan/.
- ```volumes```: Mounts ckan_data as a persistent storage location for CKAN data.
### ```.env``` Files in the ```config``` Folder
These files store environment variables used by different services to configure settings like credentials, connection details, and system parameters.
- ```ckan/.env``` – Contains CKAN-specific configurations (e.g., admin credentials, site URL).

- ```db/.env``` – Stores PostgreSQL credentials (e.g., database name, user, password).
- ```nginx/.env``` – Stores Nginx settings.
- ```redis/.env``` – Configures Redis.
- ```solr/.env``` – Configures Solr.
- ```.global-env``` – Contains environment variables shared across multiple services.

## Managing Environment Secrets
For production deployments, you should create your own ```.env``` files with sensitive data such as database credentials and API keys. **Do not commit these files to the repository**. Instead, add them to ```.gitignore``` to prevent accidental exposure:

- Create your own ```.env``` files manually
```sh
cp config/ckan/.env config/ckan/.env-prod
cp config/db/.env config/ckan/.env-prod
```
Change the configuration in services to reference the newly created ```.env-prod``` file

For ```ckan.yaml```, ```ckan-worker-bulk.yaml```, ```ckan-worker-default.yaml```, ```ckan-worker-priority.yaml``` change these lines:
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
For ```db.yaml``` change this:
```sh
env_file:
   - ${PWD}/config/db/.env
```
to this
```sh
env_file:
   - ${PWD}/config/db/.env-prod
```
Add ```.env``` files to ```.gitignore``` to prevent committing sensitive data:
```sh
echo "config/**/*.env-prod" >> .gitignore
```

### Start the containers
***For local deployment nginx is not needed site can be accessed on localhost***
```sh
docker compose up -d
```
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
This stops and removes the containers but keeps the data.
# Deploying to production

***Change passwords for ckan user and postgres before deploying to production environment***

To change the CKAN and PostgreSQL passwords, follow these steps:

### CKAN Password

1. **Open the CKAN `compose/config/ckan/.env` file and update following env variable:**

   ```properties
   CKAN_SYSADMIN_PASSWORD=new_password
   ```
2. **Save and close the file.**

### PostgreSQL Password

1. **Open the PostgreSQL `compose/config/db/.env` file and update following env variable:**

   ```properties
   POSTGRES_PASSWORD=new_password
   ```

2. **Save and close the file.**


## Set production domain 
Before building the docker containers and deploying CKAN with Nginx for a production environment, follow these steps to configure the public domain:

1. **Open the CKAN `compose/config/ckan/.env` file and update the following env variable to your desired domain:**
```properties
   CKAN_SITE_URL=https://prod-domain.com
   ```
2. **Save and close the file.**
3. **Configure Nginx:**

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
       ssl_certificate /etc/nginx/certs/ckan-local.crt;
       ssl_certificate_key /etc/nginx/certs/ckan-local.key;
       
       location / {
           proxy_pass http://ckan:5000/;
           
       }
       
   }
   ```
5. **Save and close the file.**

## Building and deploying Docker container
1. **Navigate to the project directory:**

   ```sh
   cd compose
   ```

2. **Build the Docker containers:**

   ```sh
   docker compose build
   ```
3. **Start the Docker containers:**

   ***For production nginx is needed and to start the containers use --profile:***
   ```sh
   docker compose --profile nginx up -d 
   ```
   #### Explanation:
   - ```--profile nginx```: Starts all services plus the nginx service, which is required for production.

   - ```-d``` (detached mode): Starts the services defined in a docker-compose.yml file in detached mode, meaning they run in the background. This allows the user to continue using the terminal for other tasks without the output of the containers cluttering the screen.

3. **Check to ensure all services are running correctly:**

   ```sh
   docker ps
   ```
4. **If any issues arise with some container, check the logs:**
   ```sh
   docker logs containerName
   ```

5. **Access CKAN**

   Open your web browser and navigate to `https://prod-domain.com` to access the CKAN instance.

## Troubleshooting
### Port already in use?
Change the port mapping e.g., 9090:80 instead of 8080:80.

### Permission issues:
Try running commands with sudo
```sh
sudo docker compose up -d
```
### Check logs
```sh
docker logs containerName
```
By following these steps, you can build, deploy, and manage the CKAN infrastructure using Docker Compose.