import { apiRoute } from "@/lib/api"
import { prisma } from "@/lib/prisma"
import { type Task, TaskState } from "@prisma/client"
import { NextResponse } from "next/server"

export const GET = apiRoute(async (_request) => {
  const tasks = await prisma.task.findMany({
    orderBy: [{ id: "asc" }],
  })

  return NextResponse.json(tasks)
})

export const POST = apiRoute(async (request) => {
  const { title } = (await request.json()) as Task

  const task = await prisma.task.create({
    data: {
      state: TaskState.todo,
      title: title,
    },
  })

  return NextResponse.json(task, { status: 201 })
})
