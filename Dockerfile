FROM node:20-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_ENV=production

WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    make \
    g++ \
    gcc \
    git \
    curl \
    wget \
    unzip \
    zip \
    sqlite3 \
    libsqlite3-dev \
    pkg-config \
    ca-certificates \
    lua5.1 \
    liblua5.1-0-dev \
    libcairo2-dev \
    libjpeg62-turbo-dev \
    libgif-dev \
    librsvg2-dev \
    libpango1.0-dev \
    libpixman-1-dev \
    libpng-dev \
    libfreetype6-dev \
    fontconfig \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*

COPY package*.json ./

RUN npm install --omit=dev

COPY . .

RUN mkdir -p \
    unveilr \
    unveilr/cache \
    unveilr/temp \
    unveilr/inputs \
    unveilr/dumps \
    storage \
    cache \
    logs

RUN wget -O lune.zip https://github.com/lune-org/lune/releases/download/v0.10.4/lune-0.10.4-linux-x86_64.zip \
    && unzip lune.zip \
    && chmod +x lune \
    && mv lune /usr/local/bin/lune \
    && rm lune.zip

RUN test -f injection.lua || echo "-- fallback injection" > injection.lua
RUN test -f oracle.oracle || echo "fallback_key" > oracle.oracle
RUN test -f badSites.json || echo "[]" > badSites.json

EXPOSE 8000

CMD ["npm", "start"]
