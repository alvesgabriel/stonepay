FROM elixir:1.11.3-alpine

RUN apk update && \
    apk add --upgrade build-base && \
    apk add --upgrade inotify-tools && \
    apk add --upgrade nodejs && \
    apk add --upgrade curl && \
    curl -L https://npmjs.org/install.sh | sh && \
    mix local.hex --force && \
    mix local.rebar --force

ENV APP_NAME /app
RUN mkdir $APP_NAME
WORKDIR $APP_NAME

CMD ["mix", "phx.server"]
