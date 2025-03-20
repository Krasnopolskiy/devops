import { register } from "@/lib/metrics"
import { prisma } from "@/lib/prisma"
import { type NextRequest, NextResponse } from "next/server"

export async function GET(_request: NextRequest): Promise<NextResponse> {
  const metrics = await register.metrics()

  let prismaMetrics = ""
  try {
    prismaMetrics = await prisma.$metrics.prometheus()
  } catch (e) {
    // continue regardless of error
  }

  return new NextResponse(metrics + "\n" + prismaMetrics, {
    status: 200,
    headers: { contentType: register.contentType },
  })
}

export const dynamic = "force-dynamic"
export const revalidate = 5
