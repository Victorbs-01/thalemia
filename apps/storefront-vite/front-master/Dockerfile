# Multi-stage build for front-master storefront

# Build stage
FROM node:20-alpine AS builder

# Enable Corepack for pnpm
RUN corepack enable && corepack prepare pnpm@9.15.4 --activate

WORKDIR /app

# Copy workspace configuration
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY nx.json tsconfig.base.json ./

# Copy all libs and apps needed for build
COPY libs ./libs
COPY apps/storefront-vite/front-master ./apps/storefront-vite/front-master

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build the application
RUN pnpm nx build front-master --prod

# Production stage with nginx
FROM nginx:alpine

# Copy built assets from builder
COPY --from=builder /app/dist/apps/storefront-vite/front-master /usr/share/nginx/html

# Copy nginx configuration
COPY apps/storefront-vite/front-master/nginx.conf /etc/nginx/conf.d/default.conf

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
