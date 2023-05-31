FROM debian:bullseye


RUN apt-get update \
    && apt-get install libssl1.1 libsctp1 -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/apt/lists/partial/*


ARG APP_HOME=/home/assistant


COPY _build/prod/rel/assistant $APP_HOME


WORKDIR $APP_HOME


ENV LANG=C.UTF-8
ENV PATH="$APP_HOME/bin:$PATH"


ENTRYPOINT [ "assistant", "start" ]
