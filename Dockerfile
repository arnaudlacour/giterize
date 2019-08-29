ARG ORIGINAL_IMAGE
FROM ${ORIGINAL_IMAGE}
ARG ORIGINAL_ENTRYPOINT
ENV ORIGINAL_ENTRYPOINT=${ORIGINAL_ENTRYPOINT}
ARG ORIGINAL_CMD
ENV ORIGINAL_CMD=${ORIGINAL_CMD}
# a variable for cases when .subst files need to expand to ${variable}
# in the template, use _DOLLAR_{variable}
ENV _DOLLAR_="$"
# Get git and envsubst on Alpine-based images
RUN set -x \
    && which apk \
    && apk add --update libintl \
    && apk add --virtual build_deps gettext \
    && apk add git \
    && cp /usr/bin/envsubst /usr/local/bin/envsubst \
    && apk del build_deps \
    || exit 0
# Get envsubst via yum
RUN set -x \
    && which yum \  
    && yum -y install gettext git \
    || exit 0
# Get envsubst on Debian
RUN set -x \
    && which apt-get \
    && apt-get update \
    && apt-get -y install gettext-base git \
    && apt-get clean \
    && which git \
    && which ensubst \
    || exit 0

COPY giterized-entrypoint.sh /

ENTRYPOINT [ "/giterized-entrypoint.sh" ]