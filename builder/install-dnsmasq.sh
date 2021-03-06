#!/bin/sh

set -eux

INSTALL_PATH="${1%/}"
if [ "${INSTALL_PATH}" = "" ]; then
    echo "usage: $0 INSTALL_PATH"
    echo "example: $0 /usr/local"
    exit 1
fi

set -eux \
    && umask 077 \
    && apt-get update \
    && apt-get install -y \
        --no-install-recommends --no-install-suggests \
        dnsmasq \
        binutils \
    && for d in bin etc lib run sbin; do mkdir -p "${INSTALL_PATH}/${d}"; done \
    && src_path=/usr/sbin/dnsmasq; true \
    && cp -a ${src_path} "${INSTALL_PATH}/sbin/" \
    && _libs=$(ldd ${src_path} | \
                cut -d ' ' -f 3 | \
                grep -v -E '(^$|libdl.so|libc.so)') \
    && for lib in ${_libs}; do \
        lib_path=$(readlink -f ${lib}); \
        lib_link=$(readlink ${lib}); \
        cp ${lib_path} "${INSTALL_PATH}/lib/"; \
        ln -s ${lib_link} "${INSTALL_PATH}/lib/$(basename ${lib})"; \
        done \
    && (strip "${INSTALL_PATH}/sbin/dnsmasq" "${INSTALL_PATH}"/lib/* || true)
