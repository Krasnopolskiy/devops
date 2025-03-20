import { logHttp, logger } from "@/lib/logger"
import { apiRequestCounter, apiRequestHist } from "@/lib/metrics"
import { type NextRequest, NextResponse } from "next/server"
import { performance } from "perf_hooks"

//eslint-disable-next-line @typescript-eslint/no-explicit-any
export type Context = any

export type Route = (
  request: NextRequest,
  context?: Context,
) => Promise<NextResponse>

export type Middleware = (
  route: Route,
  request: NextRequest,
  context?: Context,
) => Promise<NextResponse>

export const withMiddlewares = (
  route: Route,
  middlewares: Middleware[],
): Route => {
  for (const middleware of middlewares) {
    const r = route
    route = async (request, context): Promise<NextResponse> => {
      return await middleware(r, request, context)
    }
  }

  return route
}

export const recoveryMiddleware: Middleware = async (
  route,
  request,
  context,
) => {
  try {
    return await route(request, context)
  } catch (e) {
    logger.error({ name: "api", err: e })
    return NextResponse.json({}, { status: 500 })
  }
}

export const metricsMiddleware: Middleware = async (
  route,
  request,
  context,
) => {
  const start = performance.now()
  const response = await route(request, context)
  const duration = performance.now() - start

  apiRequestCounter
    .labels({
      method: request.method,
      path: request.nextUrl?.pathname,
      status: response.status,
    })
    .inc()

  apiRequestHist
    .labels({
      method: request.method,
      path: request.nextUrl?.pathname,
    })
    .observe(duration)

  return response
}

export const loggingMiddleware: Middleware = async (
  route,
  request,
  context,
) => {
  const start = performance.now()
  const response = await route(request, context)
  const duration = Math.round(performance.now() - start)

  logHttp(request, response, { name: "api", duration: duration })

  return response
}

export const apiRoute = (route: Route): Route =>
  withMiddlewares(route, [
    recoveryMiddleware,
    metricsMiddleware,
    loggingMiddleware,
  ])
