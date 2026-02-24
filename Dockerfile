FROM node:20-alpine AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && cp -R node_modules /production_modules && npm ci

FROM node:20-alpine AS test
WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY package*.json ./
COPY src/ ./src/
COPY tests/ ./tests/
RUN npm test

FROM node:20-alpine AS production
LABEL maintainer="Nicolas Torrres - Juan Perez"
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=dependencies /production_modules ./node_modules
COPY package*.json ./
COPY src/ ./src/
USER appuser
ENV NODE_ENV=production PORT=3000
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
CMD ["node", "src/app.js"]
