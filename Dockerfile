FROM python:3.12-alpine AS build

ENV UV_INSTALL_DIR="/uv"
ENV PATH="/uv:/root/.local/bin:$PATH"

RUN apk add --no-cache \
    bash curl g++ gcc libffi-dev make musl-dev

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

SHELL ["/bin/bash", "-c"]
WORKDIR /tmp

COPY pyproject.toml uv.lock install_unrar.sh ./

RUN uv sync --no-cache --locked && \
    uv pip uninstall --python /tmp/.venv/bin/python pyrogram && \
    uv pip install --python /tmp/.venv/bin/python \
        --no-deps --force-reinstall pyrofork==2.3.61 && \
    /tmp/.venv/bin/python -c \
        "import pyrogram.enums as e; assert hasattr(e, 'MessageOriginType'), 'MessageOriginType missing'; print('Pyrofork enum check OK')" && \
    bash /tmp/install_unrar.sh


FROM python:3.12-alpine

ENV UV_INSTALL_DIR="/uv"
ENV PATH="/uv:/venv/bin:/root/.local/bin:$PATH"
ENV TZ="Europe/Paris"

ARG VERSION="7.3.0"

LABEL org.opencontainers.image.authors="EDM115 <unzip@edm115.dev>"
LABEL org.opencontainers.image.base.name="python:3.12-alpine"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/EDM115/unzip-bot.git"
LABEL org.opencontainers.image.title="unzip-bot"
LABEL org.opencontainers.image.url="https://github.com/EDM115/unzip-bot"
LABEL org.opencontainers.image.version="${VERSION}"

RUN apk add --no-cache \
    bash cgroup-tools cpulimit curl ffmpeg git tar tzdata \
    util-linux zstd \
    && apk add --no-cache 7zip \
       --repository=https://dl-cdn.alpinelinux.org/alpine/edge/main \
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    && ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime

SHELL ["/bin/bash", "-c"]
WORKDIR /app

COPY --from=build /tmp/.venv /venv
COPY --from=build /usr/local/bin/unrar /tmp/unrar

RUN install -m 755 /tmp/unrar /usr/local/bin/unrar \
    && rm -f /tmp/unrar \
    && git clone --depth 1 -b v7 \
       https://github.com/EDM115/unzip-bot.git /app

RUN /venv/bin/python -c \
    "import pyrogram.enums as e; assert hasattr(e, 'MessageOriginType'), 'MessageOriginType missing'; print('Pyrofork enum check OK')"

COPY .env /app/.env

RUN chmod +x /app/start.sh

ENTRYPOINT ["/bin/bash", "/app/start.sh"]