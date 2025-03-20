import type { NextRequest, NextResponse } from "next/server"
//eslint-disable-next-line import/no-named-as-default
import pino from "pino"

export const logger = pino({
  enabled: true,
  browser: {
    write: (o) => console.log(JSON.stringify(o)),
  },
  level: process.env.NODE_ENV === "production" ? "info" : "debug",
  timestamp: true,
})

export const logHttp = (
  request: NextRequest,
  response: NextResponse,
  obj: object = {},
): void => {
  logger.info({
    request: {
      url: request.url,
      path: request.nextUrl?.pathname,
      ip: request.ip,
      params: Object.fromEntries(request.nextUrl?.searchParams ?? []),
      method: request.method,
      headers: Object.fromEntries(request.headers ?? []),
    },
    response: {
      status: response.status,
      headers: Object.fromEntries(response.headers ?? []),
    },
    ...obj,
  })
}

export default logger
