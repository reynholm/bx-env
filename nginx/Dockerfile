FROM nginx:stable

ARG CONTAINER_GID
ARG CONTAINER_UID
ARG CONTAINER_USER
ARG CONTAINER_GROUP

RUN groupadd -g ${CONTAINER_GID} ${CONTAINER_GROUP} && \
    useradd -u ${CONTAINER_UID} -g ${CONTAINER_GID} ${CONTAINER_USER}

COPY ./etc/ /etc/nginx/

RUN envsubst < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 0755 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["nginx"]