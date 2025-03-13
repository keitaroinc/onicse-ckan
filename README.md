# CKAN Infrastructure

This repository contains the Docker Compose setup for deploying CKAN along with its dependencies, including PostgreSQL, Solr, Redis, and CKAN workers.

## Folder Structure

```
/compose/
├── config/
│   ├── ckan/
│   │   └── .env
│   ├── db/
│   │   └── .env
│   ├── nginx/
│   │   └── .env
│   ├── redis/
│   │   └── .env
│   ├── solr/
│   │   └── .env
│   └── .global-env
├── services/
│   ├── ckan/
│   │   ├── ckan.yaml
│   │   └── image/
│   ├── ckan-workers/
│   │   ├── ckan-worker-default.yaml
│   │   ├── ckan-worker-priority.yaml
│   │   └── ckan-worker-bulk.yaml
│   ├── db/
│   │   ├── db.yaml
│   │   └── image/
│   ├── nginx/
│   │   ├── nginx.yaml
|   |   └── image/
│   ├── redis/
│   │   └── redis.yaml
│   ├── solr/
│   │   ├── solr.yaml
|   |   └── image/
└── docker-compose.yml
```

## Changing CKAN and PostgreSQL Passwords
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
   docker compose build --no-cache
   ```
3. **Start the Docker containers:**
   ```sh
   docker compose up -d
   ```

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

By following these steps, you can build, deploy, and manage the CKAN infrastructure using Docker Compose.