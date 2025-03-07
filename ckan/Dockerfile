###################
### Extensions ####
###################
FROM ghcr.io/keitaroinc/ckan:2.11.2-xloader as extbuild

# Switch to the root user
USER root

# Install necessary packages to build extensions
RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/v3.13/main \
        python3-dev && \
    apk add --no-cache \
        libffi-dev \
        libffi \
        openssl-dev \
        musl \
        musl-dev \
        geos \
        geos-dev \
        proj-util \
        proj-dev \
        libxml2 \
        libxslt \
        gcc \
        libxml2-dev \
        libxslt-dev

RUN wget https://github.com/mikefarah/yq/releases/download/v4.25.1/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq

# WORKDIR /tmp/plugins/
# COPY download-extensions.sh download-extensions.sh
# COPY extensions.yaml extensions.yaml
# RUN ls -l
# RUN pip install --upgrade pip
# RUN ./download-extensions.sh

###########
## MAIN ###
###########
FROM ghcr.io/keitaroinc/ckan:2.11.2-xloader

ENV APP_DIR=/srv/app
ENV EXT_WHEEL_DIR=${APP_DIR}/ext_wheels

RUN echo ${CKAN__PLUGINS}

# Switch to the root user
USER root 
       
# install
RUN apk update
RUN apk add --no-cache python3-dev \
        openssl \
        busybox-suid \
        tzdata \
        xmlsec \
        libffi-dev \
        libffi \
        openssl-dev \
        musl \
        musl-dev \
        geos \
        geos-dev \
        proj-util \
        proj-dev \
        libxml2 \
        libxslt \
        gcc \
        libxml2-dev \
        libxslt-dev

# RUN pip uninstall --yes setuptools
# RUN pip install setuptools==44.1.0
# Get artifacts from build stages 
# COPY --from=extbuild /wheels ${EXT_WHEEL_DIR}

# Install extensions and requirements
# COPY install-extensions.sh /tmp/install-extensions.sh
# RUN cat ${EXT_WHEEL_DIR}/full-requirements.txt
# RUN chmod +x /tmp/install-extensions.sh && /tmp/install-extensions.sh
# RUN pip install --no-index --find-links=/srv/app/ext_wheels -r ${EXT_WHEEL_DIR}/full-requirements.txt
# RUN echo ${CKAN__PLUGINS}

RUN mkdir -p /var/lib/ckan/default
RUN chown ckan:ckan /var/lib/ckan/default

# Remove wheels
RUN rm -rf ${EXT_WHEEL_DIR}

USER ckan