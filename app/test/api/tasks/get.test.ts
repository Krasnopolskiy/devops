/**
 * @jest-environment node
 */
import { GET } from "@/app/api/tasks/route"
import { prisma } from "@/lib/prisma"
import { faker } from "@faker-js/faker"
import { type Task, TaskState } from "@prisma/client"
import { NextRequest, type NextResponse } from "next/server"

describe("GET /api/tasks", () => {
  const makeRequest = async (): Promise<NextResponse> => {
    const req = new NextRequest("http://localhost/api/tasks", {
      method: "GET",
    })

    return await GET(req)
  }

  const tasksCount = 5
  const tasksData = faker.helpers.multiple(
    () => ({
      state: faker.helpers.arrayElement([TaskState.todo, TaskState.done]),
      title: faker.git.commitMessage(),
    }),
    { count: tasksCount },
  )

  beforeAll(async () => {
    await prisma.task.createMany({
      data: tasksData,
    })
  })

  it("returns 200", async () => {
    const resp = await makeRequest()
    expect(resp.status).toEqual(200)
  })

  it("returns all tasks", async () => {
    const resp = await makeRequest()
    const data = (await resp.json()) as Task[]

    expect(data).toHaveLength(tasksCount)
    expect(data).toMatchObject(tasksData)
  })
})
