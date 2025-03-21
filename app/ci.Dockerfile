FROM node:18-alpine AS base

FROM base AS deps

ENV NODE_ENV="test"

WORKDIR /

COPY package.json package-lock.json ./

RUN npm ci && npm install -g prisma

WORKDIR /app
