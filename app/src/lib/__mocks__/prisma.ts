import { PrismaClient } from "@prisma/client"
import { execSync } from "child_process"
import { URL } from "url"
import { v4 } from "uuid"

// eslint-disable-next-line
if (!process.env.DATABASE_URL) {
  throw new Error("please provide a database url")
}

const schema = `test-${v4()}`
const url = new URL(process.env.DATABASE_URL)
url.searchParams.set("schema", schema)

const dbURL = url.toString()

process.env.DATABASE_URL = dbURL

export const prisma = new PrismaClient({
  datasources: {
    db: { url: dbURL },
  },
})

beforeAll(() => {
  execSync("npx prisma db push", {
    env: {
      ...process.env,
      DATABASE_URL: dbURL,
    },
  })
})

afterAll(async () => {
  await prisma.$executeRawUnsafe(`DROP SCHEMA IF EXISTS "${schema}" CASCADE;`)
  await prisma.$disconnect()
})
