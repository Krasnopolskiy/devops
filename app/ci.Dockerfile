FROM node:18-alpine AS base

FROM base AS deps-ci

ENV NODE_ENV="test"

RUN apk add --no-cache --update openssl

WORKDIR /

COPY package.json package-lock.json ./

RUN npm ci && npm install -g prisma

WORKDIR /app
