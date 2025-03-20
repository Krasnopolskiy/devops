FROM node:18-alpine AS base

FROM base AS deps

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm install

FROM base AS builder

ENV NEXT_TELEMETRY_DISABLED 1

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules

COPY . .

RUN npm run build

FROM base AS runner

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

EXPOSE 3000

WORKDIR /app

RUN npm install -g prisma

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

COPY --from=builder --chown=nextjs:nodejs /app/package.json /app/entrypoint.sh ./

COPY --from=builder --chown=nextjs:nodejs /app/prisma ./prisma

COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next

USER nextjs

ENTRYPOINT ["/bin/sh", "./entrypoint.sh"]
