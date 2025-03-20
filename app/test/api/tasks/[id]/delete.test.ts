/**
 * @jest-environment node
 */
import { DELETE } from "@/app/api/tasks/[id]/route"
import { prisma } from "@/lib/prisma"
import { type Task, TaskState } from "@prisma/client"
import { NextRequest, type NextResponse } from "next/server"

describe("PUT /api/tasks/[id]", () => {
  const makeRequest = async (id: number | string): Promise<NextResponse> => {
    const req = new NextRequest(`http://localhost/api/tasks/${id}`, {
      method: "DELETE",
    })
    const ctx = {
      params: { id: String(id) },
    }

    return await DELETE(req, ctx)
  }

  describe("when task exists", () => {
    let task: Task

    beforeEach(async () => {
      task = await prisma.task.create({
        data: {
          state: TaskState.todo,
          title: "default title",
        },
      })
    })

    afterEach(async () => {
      await prisma.task.deleteMany()
    })

    it("returns 200", async () => {
      const resp = await makeRequest(task.id)
      expect(resp.status).toEqual(200)
    })

    it("deletes task", async () => {
      await makeRequest(task.id)

      const count = await prisma.task.count()
      expect(count).toStrictEqual(0)
    })

    it("returns deleted task", async () => {
      const resp = await makeRequest(task.id)
      const data = (await resp.json()) as Task

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
