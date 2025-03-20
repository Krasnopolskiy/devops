import { apiRoute } from "@/lib/api"
import { prisma } from "@/lib/prisma"
import { Prisma, type Task } from "@prisma/client"
import { NextResponse } from "next/server"

interface Context {
  params: {
    id: string
  }
}

export const GET = apiRoute(async (_request, { params: { id } }: Context) => {
  const task = await prisma.task.findUnique({
    where: { id: Number(id) },
  })

  if (task == null) {
    return NextResponse.json({}, { status: 404 })
  }

  return NextResponse.json(task)
})

export const PUT = apiRoute(async (request, { params: { id } }: Context) => {
  const { state, title } = (await request.json()) as Task

  try {
    const task = await prisma.task.update({
      where: { id: Number(id) },
      data: {
        state: state,
        title: title,
      },
    })

    return NextResponse.json(task)
  } catch (e) {
    if (e instanceof Prisma.PrismaClientKnownRequestError) {
      if (e.code === "P2025") {
        return NextResponse.json({}, { status: 404 })
      }
    }

    throw e
  }
})

export const DELETE = apiRoute(
  async (_request, { params: { id } }: Context) => {
    try {
      const task = await prisma.task.delete({
        where: { id: Number(id) },
      })

      return NextResponse.json(task)
    } catch (e) {
      if (e instanceof Prisma.PrismaClientKnownRequestError) {
        if (e.code === "P2025") {
          return NextResponse.json({}, { status: 404 })
        }
      }

      throw e
    }
  },
)
