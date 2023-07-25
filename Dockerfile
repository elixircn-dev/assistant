FROM alpine:3


RUN apk add ncurses libstdc++


ARG APP_HOME=/home/assistant


COPY _build/prod/rel/assistant $APP_HOME


WORKDIR $APP_HOME


ENV LANG=C.UTF-8
ENV PATH="$APP_HOME/bin:$PATH"


ENTRYPOINT [ "assistant", "start" ]
