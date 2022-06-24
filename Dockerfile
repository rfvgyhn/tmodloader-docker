FROM ubuntu as build

ARG TMOD_VERSION=2022.04.62.6
ARG TERRARIA_VERSION=1436

RUN apt update
RUN apt install -y dirmngr gnupg apt-transport-https ca-certificates software-properties-common
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN apt-add-repository -y 'deb https://download.mono-project.com/repo/ubuntu stable-focal main'
RUN apt install -y mono-complete 
RUN apt install -y curl unzip

WORKDIR /terraria-server

# RUN cp /usr/lib/libMonoPosixHelper.so .

RUN curl -SLO "https://terraria.org/api/download/pc-dedicated-server/terraria-server-${TERRARIA_VERSION}.zip" &&\
    unzip terraria-server-*.zip &&\
    rm terraria-server-*.zip &&\
    cp --verbose -a "${TERRARIA_VERSION}/Linux/." . &&\
    rm -rf "${TERRARIA_VERSION}" &&\
    rm TerrariaServer.exe

RUN curl -SLO "https://github.com/tModLoader/tModLoader/releases/download/v${TMOD_VERSION}/tModLoader.zip" &&\
    unzip tModLoader.zip &&\
    chmod u+x Build/start-tModLoaderServer.sh &&\
    chmod u+x Build/start-tModLoader.sh

FROM bitnami/dotnet:3.1-debian-10

WORKDIR /terraria-server
COPY --from=build /terraria-server ./

RUN apt update &&\
    apt -y install procps cron tmux
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
