##
# This Dockerfile builds the `mit-scheme` and the `mechanics` runtime images
# using a multi-stage build.
#
# Build Arguments (using 'docker build --build-arg'):
#   - MITSCHEME_VERSION: MIT Scheme version (default 12.1).
#   - SCMUTILS_VERSION: Scmutils version (default 20230902).
#
# Usage:
#   docker build -f Dockerfile.multi-stage -t msd/mechanics:dev --target=mechanics .
#   docker build -f Dockerfile.multi-stage -t msd/mit-scheme:dev --target=mit-scheme .
##


##
# Stage: Builds the base image.
#
FROM --platform=linux/amd64 ubuntu:latest AS build-init

LABEL authors="Sam Ritchie <sritchie09@gmail.com>, Aaron Steele <eightysteele@gmail.com>"
LABEL github="https://github.com/mentat-collective/mit-scheme-docker"

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    libncurses-dev \
    libx11-dev \
    m4 \
    rlwrap \
    wget

WORKDIR /
RUN rm -rf /var/lib/apt/lists/*

##
# Stage: Downloads, compiles, installs MIT Scheme from source.
#
FROM build-init AS build-scheme

ARG MITSCHEME_VERSION=12.1

ARG MITSCHEME_DIR=mit-scheme-${MITSCHEME_VERSION}
ARG MITSCHEME_TAR=${MITSCHEME_DIR}-x86-64.tar.gz
ARG MITSCHEME_URL=http://ftp.gnu.org/gnu/mit-scheme/stable.pkg/${MITSCHEME_VERSION}/${MITSCHEME_TAR}
ARG MITSCHEME_MD5_URL=http://ftp.gnu.org/gnu/mit-scheme/stable.pkg/${MITSCHEME_VERSION}/md5sums.txt

WORKDIR /
RUN wget --no-check-certificate ${MITSCHEME_URL} \
    && wget --no-check-certificate ${MITSCHEME_MD5_URL} \
    && cat md5sums.txt | awk '/${MITSCHEME_TAR}/ {print}' | tee md5sums.txt \
    && tar xf ${MITSCHEME_TAR}

WORKDIR ${MITSCHEME_DIR}
RUN cd src \
    && ./configure \
    && make \
    && make install

WORKDIR /
RUN rm -rf ${MITSCHEME_DIR} ${MITSCHEME_TAR} md5sums.txt


##
# Stage: Downloads and installs SCMUtils from source.
#
FROM build-scheme AS build-scmutils

WORKDIR /
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    texinfo \
    texlive-xetex \
    texlive

WORKDIR /
RUN rm -rf /var/lib/apt/lists/*

ARG SCMUTILS_VERSION=20230902

ARG SCMUTILS_DIR=scmutils-${SCMUTILS_VERSION}
ARG SCMUTILS_TAR=${SCMUTILS_DIR}.tar.gz
ARG SCMUTILS_URL=https://groups.csail.mit.edu/mac/users/gjs/6946/mechanics-system-installation/native-code/${SCMUTILS_TAR}

WORKDIR /
COPY --from=build-scheme /usr/local /usr/local/

WORKDIR /
RUN curl -Lk ${SCMUTILS_URL} -o ${SCMUTILS_TAR} && \
    tar xf ${SCMUTILS_TAR}

WORKDIR ${SCMUTILS_DIR}
RUN ./install.sh \
	&& mv mechanics.sh /usr/local/bin/mechanics

WORKDIR /
RUN rm -rf ${SICMUTILS_DIR} ${SCMUTILS_TAR}


##
# Stage: Builds the runtime image for mit-scheme
#
FROM scratch AS mit-scheme

ENV PATH /usr/local/bin:/bin
ENV RUNTIME=mit-scheme
ENV RUNTIME_COMPLETION=/${RUNTIME}_completions.txt

WORKDIR /
COPY --from=build-init /bin/bash /bin/ls /bin/env /bin/sleep /bin/rlwrap /bin/
COPY --from=build-init /usr/lib/ /lib
COPY --from=build-init /usr/lib64/ /lib64
COPY --from=build-scheme /usr/local/bin/mit-scheme /usr/local/bin/
COPY --from=build-scheme /usr/local/lib/${MITSCHEME_LIB} /usr/local/lib/${MITSCHEME_LIB}

WORKDIR /
COPY /resources/mit-scheme_completions.txt /resources/mechanics_completions.txt /

ENTRYPOINT ["/bin/bash", "-c", "sleep .2 && exec rlwrap -f ${RUNTIME_COMPLETION} ${RUNTIME} $@"]


##
# Stage: Builds the runtime image for mechanics.
#
FROM build-scmutils AS mechanics

ENV PATH /usr/local/bin:/bin
ENV RUNTIME=mechanics
ENV RUNTIME_COMPLETION=/${RUNTIME}_completions.txt

WORKDIR /
COPY /resources/mit-scheme_completions.txt /resources/mechanics_completions.txt /

ENTRYPOINT ["/bin/bash", "-c", "sleep .2 && exec rlwrap -f ${RUNTIME_COMPLETION} ${RUNTIME} $@"]
