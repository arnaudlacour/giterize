ARG ORIGINAL_IMAGE
FROM ${ORIGINAL_IMAGE}
ARG ORIGINAL_ENTRYPOINT
ENV ORIGINAL_ENTRYPOINT=${ORIGINAL_ENTRYPOINT}
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
    && which apt \
    && apt -y install gettext-base \
    || exit 0
COPY giterized-entrypoint.sh /
ENTRYPOINT [ "/giterized-entrypoint.sh" ]