# ============================================================================
# UnveilR Dockerfile
# Node.js 22 + Canvas + Better-SQLite3 + Lune
# Optimized for Render
# ============================================================================

FROM node:22-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_ENV=production
ENV PROD=true

WORKDIR /app

# ----------------------------------------------------------------------------
# Install system dependencies
# ----------------------------------------------------------------------------
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

# ----------------------------------------------------------------------------
# Copy package files
# ----------------------------------------------------------------------------
COPY package*.json ./

# ----------------------------------------------------------------------------
# Install Node modules
# ----------------------------------------------------------------------------
RUN if [ -f package-lock.json ]; then \
        npm ci --omit=dev --build-from-source; \
    else \
        npm install --omit=dev --build-from-source; \
    fi

# ----------------------------------------------------------------------------
# Copy project
# ----------------------------------------------------------------------------
COPY . .

# ----------------------------------------------------------------------------
# Create required folders
# ----------------------------------------------------------------------------
RUN mkdir -p \
    unveilr \
    unveilr/cache \
    unveilr/temp \
    unveilr/inputs \
    unveilr/dumps \
    storage \
    cache \
    logs

# ----------------------------------------------------------------------------
# Install Lune
# ----------------------------------------------------------------------------
RUN wget -O lune.zip \
https://github.com/lune-org/lune/releases/download/v0.10.4/lune-0.10.4-linux-x86_64.zip \
 && unzip lune.zip \
 && chmod +x lune \
 && mv lune /usr/local/bin/lune \
 && rm lune.zip

RUN lune --version

# ----------------------------------------------------------------------------
# Create fallback files
# ----------------------------------------------------------------------------
RUN test -f injection.lua || \
echo '-- fallback injection' > injection.lua

RUN test -f oracle.oracle || \
echo 'fallback_key' > oracle.oracle

RUN test -f badSites.json || \
echo '[]' > badSites.json

# ----------------------------------------------------------------------------
# Expose port
# ----------------------------------------------------------------------------
EXPOSE 8000

# ----------------------------------------------------------------------------
# Start bot
# ----------------------------------------------------------------------------
CMD ["npm", "start"]
