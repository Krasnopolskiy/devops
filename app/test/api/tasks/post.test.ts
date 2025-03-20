/**
 * @jest-environment node
 */
import { POST } from "@/app/api/tasks/route"
import { prisma } from "@/lib/prisma"
import { faker } from "@faker-js/faker"
import { type Task, TaskState } from "@prisma/client"
import { NextRequest, type NextResponse } from "next/server"

describe("POST /api/tasks", () => {
  const title = faker.git.commitMessage()

  const makeRequest = async (): Promise<NextResponse> => {
    const req = new NextRequest("http://localhost/api/tasks", {
      method: "POST",
      body: JSON.stringify({
        title: title,
      }),
    })

    return await POST(req)
  }

  afterEach(async () => {
    await prisma.task.deleteMany()
  })

  it("returns 201", async () => {
    const resp = await makeRequest()

    expect(resp.status).toEqual(201)
  })

  it("creates task", async () => {
    await makeRequest()
    const task = await prisma.task.findFirst()

    expect(task).toMatchObject({
      state: TaskState.todo,
      title: title,
    })
  })

  it("returns new task", async () => {
    const resp = await makeRequest()
    const data = (await resp.json()) as Task

    expect(data).toMatchObject({
      state: TaskState.todo,
      title: title,
    })
  })
})
