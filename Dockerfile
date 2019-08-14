ARG ORIGINAL_IMAGE
FROM ${ORIGINAL_IMAGE}
ARG ORIGINAL_ENTRYPOINT
ENV ORIGINAL_ENTRYPOINT=${ORIGINAL_ENTRYPOINT}
ARG ORIGINAL_CMD
ENV ORIGINAL_CMD=${ORIGINAL_CMD}
# a variable for cases when .subst files need to expand to ${variable}
# in the template, use _DOLLAR_{variable}
ENV _DOLLAR_="$"
# Get envsubst on Alpine-based images
RUN set -x \
    && which apk \
    && apk add --update libintl \
    && apk add --virtual build_deps gettext \
    && cp /usr/bin/envsubst /usr/local/bin/envsubst \
    && apk del build_deps \
    || exit 0
# Get envsubst via yum
RUN set -x \
    && which yum \
    && yum -y install gettext \
    || exit 0
# Get envsubst on Debian
RUN set -x \
    && which apt-get \
    && apt-get update \
    && apt-get -y install gettext-base \
    && apt-get clean \
    || exit 0

COPY giterized-entrypoint.sh /

ENTRYPOINT [ "/giterized-entrypoint.sh" ]