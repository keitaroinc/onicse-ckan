###################
### Extensions ####
###################
FROM ghcr.io/keitaroinc/ckan:2.11.2 as extbuild

# Switch to the root user
USER root

RUN wget https://github.com/mikefarah/yq/releases/download/v4.25.1/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq

WORKDIR /tmp/plugins/
COPY download-extensions.sh download-extensions.sh
COPY extensions.yaml extensions.yaml
RUN ls -l
RUN pip install --upgrade pip
RUN ./download-extensions.sh

###########
## MAIN ###
###########
FROM ghcr.io/keitaroinc/ckan:2.11.2

ENV APP_DIR=/app
ENV EXT_WHEEL_DIR=${APP_DIR}/ext_wheels

RUN echo ${CKAN__PLUGINS}

# Switch to the root user
USER root 

# Get artifacts from build stages 
COPY --from=extbuild /wheels ${EXT_WHEEL_DIR}

# Install extensions and requirements
COPY install-extensions.sh /tmp/install-extensions.sh
RUN cat ${EXT_WHEEL_DIR}/full-requirements.txt
RUN chmod +x /tmp/install-extensions.sh && /tmp/install-extensions.sh
RUN pip install --no-index --find-links=/app/ext_wheels -r ${EXT_WHEEL_DIR}/full-requirements.txt
RUN echo ${CKAN__PLUGINS}

# Remove wheels
RUN rm -rf ${EXT_WHEEL_DIR}

USER ckan