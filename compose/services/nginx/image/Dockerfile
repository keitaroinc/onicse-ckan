FROM nginx:stable-alpine

ENV NGINX_DIR=/etc/nginx

RUN rm /etc/nginx/conf.d/default.conf

COPY setup/nginx.conf ${NGINX_DIR}/nginx.conf
COPY setup/index.html /usr/share/nginx/html/index.html
COPY setup/default.conf ${NGINX_DIR}/conf.d/

RUN mkdir -p ${NGINX_DIR}/certs

