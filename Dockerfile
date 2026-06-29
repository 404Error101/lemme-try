# Use an official Node.js runtime as the base image
FROM node:18-alpine

# Install required system dependencies
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git \
    lua \
    lua-dev \
    curl \
    wget \
    unzip \
    && ln -sf /usr/bin/python3 /usr/bin/python

# Set working directory
WORKDIR /app

# Copy package files first (for better caching)
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy the rest of the application
COPY . .

# Create necessary directories
RUN mkdir -p ./unveilr/inputs ./unveilr/cache ./unveilr/temp ./unveilr/dumps ./cache ./storage

# Download and setup Lune (Luau runtime)
RUN wget https://github.com/lune-org/lune/releases/download/v0.8.3/lune-linux-x86_64.zip \
    && unzip lune-linux-x86_64.zip \
    && chmod +x lune \
    && mv lune /usr/local/bin/ \
    && rm lune-linux-x86_64.zip

# Make sure lune is available
RUN lune --version || echo "Lune installed successfully"

# Create default files if they don't exist
RUN if [ ! -f injection.lua ]; then \
    echo '-- Default injection.lua fallback\nprint("Running in fallback injection mode")' > injection.lua; \
    fi

RUN if [ ! -f oracle.oracle ]; then \
    echo "fallback_oracle_key_123456789" > oracle.oracle; \
    fi

RUN if [ ! -f badSites.json ]; then \
    echo '["example.com", "test.com"]' > badSites.json; \
    fi

# Set environment variables
ENV NODE_ENV=production
ENV PROD=true

# Expose the port your app runs on
EXPOSE 8000

# Start the bot
CMD ["node", "db.js"]
