FROM frolvlad/alpine-glibc as build

ARG TMOD_VERSION=2022.04.62.6
ARG TERRARIA_VERSION=1436

RUN apk add --no-cache mono --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing && \
    apk add --no-cache --virtual=.build-dependencies ca-certificates && \
    cert-sync /etc/ssl/certs/ca-certificates.crt && \
    apk del .build-dependencies
    
RUN apk add bash icu-libs krb5-libs libgcc libintl libssl1.1 libstdc++ zlib &&\
    apk add libgdiplus --repository https://dl-3.alpinelinux.org/alpine/edge/testing/

WORKDIR /terraria-server

RUN cp /usr/lib/libMonoPosixHelper.so .

RUN curl -SLO "https://terraria.org/api/download/pc-dedicated-server/terraria-server-${TERRARIA_VERSION}.zip" &&\
    unzip terraria-server-*.zip &&\
    rm terraria-server-*.zip &&\
    cp --verbose -a "${TERRARIA_VERSION}/Linux/." . &&\
    rm -rf "${TERRARIA_VERSION}" &&\
    rm TerrariaServer.exe


FROM steamcmd/steamcmd:alpine-3 as tmod

WORKDIR /tmod-util

COPY Setup_tModLoaderServer.sh install.txt ./
RUN chmod u+x Setup_tModLoaderServer.sh &&\
    ./ Setup_tModLoaderServer.sh
    
WORKDIR ../tmod
RUN chmod u+x start-tModLoader*


FROM frolvlad/alpine-glibc 

WORKDIR ./tModLoader
COPY --from=tmod /tModLoader ./

WORKDIR ../terraria-server
COPY --from=build /terraria-server ./

RUN apk update &&\
    apk add --no-cache procps tmux
RUN ln -s ${HOME}/.local/share/Terraria/ /terraria
COPY inject.sh /usr/local/bin/inject
COPY handle-idle.sh /usr/local/bin/handle-idle

EXPOSE 7777
ENV TMOD_SHUTDOWN_MSG="Shutting down!"
ENV TMOD_AUTOSAVE_INTERVAL="*/10 * * * *"
ENV TMOD_IDLE_CHECK_INTERVAL=""
ENV TMOD_IDLE_CHECK_OFFSET=0

COPY config.txt entrypoint.sh ./
RUN chmod +x entrypoint.sh /usr/local/bin/inject /usr/local/bin/handle-idle

ENTRYPOINT [ "/terraria-server/entrypoint.sh" ]
