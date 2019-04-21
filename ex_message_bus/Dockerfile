FROM elixir:1.8.1-alpine as base

ARG UID=1000
ARG GID=1000

ENV MIX_HOME=/mnt/code/.mix
ENV HEX_HOME=/mnt/code/.hex

# postgres
RUN apk --no-cache --update add postgresql-client \
shadow


RUN groupadd -g ${GID} -r code && useradd -u ${UID} --no-log-init -r -m -g code code \
&& chown -R code:code /home/code

COPY . /mnt/code
WORKDIR /mnt/code

RUN chown -R code:code /mnt/code
USER code

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix deps.compile
RUN mix deps
