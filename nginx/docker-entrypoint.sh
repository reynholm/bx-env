#!/bin/bash

BX_ENV_WORKDIR=/etc/nginx
BX_ENV_TEMPLATE=bx.template
BX_ENV_TARGETDIR=sites-enabled
WWW_DIR=/var/www/public_html
DEFAULT=0

# create nginx configs
cd $WWW_DIR || exit

[[ ! (-d "${BX_ENV_WORKDIR}/${BX_ENV_TARGETDIR}") ]] && mkdir -p "${BX_ENV_WORKDIR}/${BX_ENV_TARGETDIR}" || exit

for f in *
do
  if [[ ! (-d $f) ]]
  then
    continue
  fi

  TEMPLATE="${BX_ENV_WORKDIR}/${BX_ENV_TEMPLATE}"
  OUTPUT="${BX_ENV_WORKDIR}/${BX_ENV_TARGETDIR}/${f}.conf"

  DEFAULT_STRING=""
  if [[ $DEFAULT == 0 ]]
  then
    DEFAULT_STRING="default_server"
    DEFAULT=1
  fi

  [[ -f $f ]] && continue

  touch "${OUTPUT}" && sed -e "s/%NAME%/${f}/; s/%DEFAULT%/${DEFAULT_STRING}/" "${TEMPLATE}" > ${OUTPUT}
done
########################

set -e

[[ $DEBUG == true ]] && set -x

# allow arguments to be passed to nginx
if [[ ${1:0:1} = '-' ]]; then
    EXTRA_ARGS="$@"
    set --
elif [[ ${1} == nginx || ${1} == $(which nginx) ]]; then
    EXTRA_ARGS="${@:2}"
    set --
fi

# default behaviour is to launch nginx
if [[ -z ${1} ]]; then
    echo "Starting nginx..."
    exec $(which nginx) -g "daemon off;" ${EXTRA_ARGS}
else
    exec "$@"
fi