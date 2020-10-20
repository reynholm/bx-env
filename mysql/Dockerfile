ARG BX_MYSQL_IMAGE
FROM ${BX_MYSQL_IMAGE}

COPY --chown=mysql:root ./bx.cnf /etc/my.cnf.d/bx.cnf
COPY --chown=root:root ./bx.cnf /etc/mysql/conf.d/bx.cnf

RUN chmod 664 /etc/my.cnf.d/bx.cnf