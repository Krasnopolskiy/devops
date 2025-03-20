import { logHttp } from "@/lib/logger"
import { type NextRequest, NextResponse } from "next/server"

export function middleware(request: NextRequest): NextResponse {
  const response = NextResponse.next()

  logHttp(request, response, { name: "server" })

  return response
}

export const config = {
  runtime: "nodejs",
  matcher: ["/((?!api|_next/static|_next/image|favicon.ico).*)"],
}
