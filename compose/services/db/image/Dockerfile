FROM postgis/postgis:17-3.5-alpine

# Allow connections; we don't map out any ports so only linked docker containers can connect
RUN echo "host all  all    0.0.0.0/0  md5" >> /var/lib/postgresql/data/pg_hba.conf

# Customize default user/pass/db
ENV POSTGRES_DB ckan
ENV POSTGRES_USER ckan

# Include datastore setup scripts
COPY docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
