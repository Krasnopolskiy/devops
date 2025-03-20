/**
 * @jest-environment node
 */
import { GET } from "@/app/api/tasks/[id]/route"
import { prisma } from "@/lib/prisma"
import { faker } from "@faker-js/faker"
import { type Task, TaskState } from "@prisma/client"
import { NextRequest, type NextResponse } from "next/server"

describe("GET /api/tasks/[id]", () => {
  const makeRequest = async (id: number | string): Promise<NextResponse> => {
    const req = new NextRequest(`http://localhost/api/tasks/${id}`, {
      method: "GET",
    })
    const ctx = {
      params: { id: String(id) },
    }

    return await GET(req, ctx)
  }

  describe("when task exists", () => {
    let task: Task

    beforeAll(async () => {
      task = await prisma.task.create({
        data: {
          state: faker.helpers.arrayElement([TaskState.todo, TaskState.done]),
          title: faker.git.commitMessage(),
        },
      })
    })

    it("returns 200", async () => {
      const resp = await makeRequest(task.id)
      expect(resp.status).toEqual(200)
    })

    it("returns task", async () => {
      const resp = await makeRequest(task.id)
      const data = (await resp.json()) as Task[]

      expect(data).toEqual({
        ...task,
        createdAt: task.createdAt.toISOString(),
        updatedAt: task.updatedAt.toISOString(),
      })
    })
  })

  describe("when task does not exist", () => {
    it("returns 404", async () => {
      const resp = await makeRequest(12345)
      expect(resp.status).toEqual(404)
    })

    it("returns empty json", async () => {
      const resp = await makeRequest(12345)
      const data = (await resp.json()) as Task[]

      expect(data).toEqual({})
    })
  })
})
