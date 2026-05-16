# KiteEdge Gateway — Elixir release (Phoenix API + Channels)
# Builds the umbrella release containing all four OTP apps.
# docker-compose exposes port 4000.

# ---- Build stage ----
FROM hexpm/elixir:1.16.3-erlang-26.2.5-debian-bookworm-20240513-slim AS build

RUN apt-get update -y && \
    apt-get install -y build-essential git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV MIX_ENV=prod

# Install hex + rebar
RUN mix local.hex --force && mix local.rebar --force

# Cache deps
COPY mix.exs mix.lock ./
COPY apps/kite_edge/mix.exs apps/kite_edge/mix.exs
COPY apps/kite_edge_web/mix.exs apps/kite_edge_web/mix.exs
COPY apps/market_data/mix.exs apps/market_data/mix.exs
COPY apps/notification/mix.exs apps/notification/mix.exs
COPY config/config.exs config/prod.exs config/

RUN mix deps.get --only prod && mix deps.compile

# Copy app source
COPY apps apps
COPY config config

# Compile and build release
RUN mix compile && mix release kite_edge

# ---- Runtime stage ----
FROM debian:bookworm-slim AS runtime

RUN apt-get update -y && \
    apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV KITEEDGE_SERVICE=gateway

WORKDIR /app
RUN useradd --create-home appuser
COPY --from=build --chown=appuser:appuser /app/_build/prod/rel/kite_edge ./
USER appuser

EXPOSE 4000

CMD ["bin/kite_edge", "start"]
