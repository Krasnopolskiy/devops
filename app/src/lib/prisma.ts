import { logger } from "@/lib/logger"
import { PrismaClient } from "@prisma/client"

const globalForPrisma = global as unknown as { prisma: PrismaClient }

export const buildClient = (): PrismaClient => {
  const prisma = new PrismaClient({
    log: [
      {
        emit: "event",
        level: "query",
      },
      {
        emit: "event",
        level: "info",
      },
      {
        emit: "event",
        level: "warn",
      },
      {
        emit: "event",
        level: "error",
      },
    ],
  })

  prisma.$on("query", (e) => {
    logger.info({
      name: "prisma",
      query: e.query,
      duration: e.duration,
    })
  })

  prisma.$on("info", (e) => {
    logger.info({
      name: "prisma",
      message: e.message,
    })
  })

  prisma.$on("warn", (e) => {
    logger.warn({
      name: "prisma",
      message: e.message,
    })
  })

  prisma.$on("error", (e) => {
    logger.error({
      name: "prisma",
      message: e.message,
    })
  })

  return prisma
}

export const prisma = globalForPrisma.prisma ?? buildClient()

if (process.env.NODE_ENV != "production") globalForPrisma.prisma
