/**
 * @jest-environment node
 */
import { PUT } from "@/app/api/tasks/[id]/route"
import { prisma } from "@/lib/prisma"
import { faker } from "@faker-js/faker"
import { type Task, TaskState } from "@prisma/client"
import { NextRequest, type NextResponse } from "next/server"

// import { createRequest } from "node-mocks-http"

describe("PUT /api/tasks/[id]", () => {
  const newState = TaskState.done
  const newTitle = faker.git.commitMessage()

  const makeRequest = async (id: number | string): Promise<NextResponse> => {
    const req = new NextRequest(`http://localhost/api/tasks/${id}`, {
      method: "PUT",
      body: JSON.stringify({
        state: newState,
        title: newTitle,
      }),
    })
    const ctx = {
      params: { id: String(id) },
    }

    return await PUT(req, ctx)
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

    it("updates task", async () => {
      await makeRequest(task.id)
      const newTask = await prisma.task.findUnique({
        where: { id: task.id },
      })

      expect(newTask).toMatchObject({
        ...task,
        updatedAt: newTask?.updatedAt,
        state: newState,
        title: newTitle,
      })
      expect(newTask?.updatedAt.getTime()).toBeGreaterThanOrEqual(
        task.updatedAt.getTime(),
      )
    })

    it("returns updated task", async () => {
      const resp = await makeRequest(task.id)
      const data = (await resp.json()) as Task

      expect(data).toMatchObject({
        id: task.id,
        state: newState,
        title: newTitle,
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
