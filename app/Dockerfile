# app/Dockerfile

# ── Stage 1: Build ──────────────────────────
FROM node:18-alpine AS builder
WORKDIR /app

# Copy dependency files first (Docker layer caching optimization)
COPY package*.json ./
RUN npm ci --omit=dev

# ── Stage 2: Production Image ───────────────
FROM node:18-alpine

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && adduser -S nodeuser -u 1001

WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY app.js ./
COPY package.json ./

USER nodeuser
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "app.js"]
