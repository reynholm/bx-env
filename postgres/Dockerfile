FROM postgres:11-alpine

ARG POSTGRES_USER
ARG POSTGRES_PASSWORD
ARG POSTGRES_DB

COPY pgcrypto.sh /docker-entrypoint-initdb.d/