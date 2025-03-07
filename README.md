# ONICSE CKAN Infrastructure

This repository contains the infrastructure and configuration for deploying and managing CKAN portal for ONICSE using docker compose.

---

## Local Setup

This setup provides an isolated environment to test CKAN features, extensions, and configurations.

### Key Components

1. **Docker Compose**: The `docker-compose.yml` orchestrates the services (CKAN, PostgreSQL, Solr) for local environment.
2. **Environment Variables**: `.ckan-env` and `.env` contain the necessary environment-specific variables.
3. **Directory Breakdown**:
    - `ckan/`: CKAN-specific build files and configurations.
    - `nginx/`: Needed config files for prod environment
    - `postgresql/`: PostgreSQL configuration tailored for development.
    - `psql-init/`: Scripts for postgres db initialization
    - `solr8/`: Apache Solr configurations for search.

### Steps to Run local Setup

1. **Build Images**:
   ```bash
   docker compose build --no-cache
   ```

2. **Start Services**:
   ```bash
   docker compose up -d
   ```

3. **Access CKAN**: CKAN will be available at `http://localhost:5000`.

***For local setup nginx service is ignored in the docker-compose.yml file***
---
