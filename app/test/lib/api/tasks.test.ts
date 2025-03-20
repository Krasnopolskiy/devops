/**
 * @jest-environment node
 */
import {
  type Task,
  type TaskData,
  createTask,
  deleteTask,
  fetchTask,
  fetchTasks,
  updateTask,
} from "@/lib/api/tasks"
import { faker } from "@faker-js/faker"

type FetchArgs = [RequestInfo | URL, RequestInit?]

global.fetch = jest.fn()
const fetchMock = global.fetch as jest.MockedFunction<typeof fetch>

describe("fetchTasks", () => {
  const tasks = Array.from<unknown, Task>({ length: 3 }, (_, i) => ({
    id: i + 1,
    createdAt: faker.date.anytime().toISOString(),
    updatedAt: faker.date.anytime().toISOString(),
    state: faker.helpers.arrayElement(["todo", "done"]),
    title: faker.git.commitMessage(),
  }))

  beforeEach(() => {
    fetchMock.mockResolvedValueOnce(
      new Response(JSON.stringify(tasks), { status: 200 }),
    )
  })

  afterEach(() => {
    fetchMock.mockClear()
  })

  it("sends a valid request", async () => {
    await fetchTasks()
    expect(fetchMock).toHaveBeenCalledWith<FetchArgs>("/api/tasks")
  })

  it("resolves tasks", async () => {
    await expect(fetchTasks()).resolves.toEqual(tasks)
  })
})

describe("createTask", () => {
  const task: Task = {
    id: faker.number.int({ min: 1 }),
    createdAt: faker.date.anytime().toISOString(),
    updatedAt: faker.date.anytime().toISOString(),
    state: faker.helpers.arrayElement(["todo", "done"]),
    title: faker.git.commitMessage(),
  }
  const taskData: TaskData = {
    state: task.state,
    title: task.title,
  }

  beforeEach(() => {
    fetchMock.mockResolvedValueOnce(
      new Response(JSON.stringify(task), { status: 201 }),
    )
  })

  afterEach(() => {
    fetchMock.mockClear()
  })

  it("sends a valid request", async () => {
    await createTask(taskData)
    expect(fetchMock).toHaveBeenCalledWith<FetchArgs>("/api/tasks", {
      method: "POST",
      body: JSON.stringify(taskData),
    })
  })

  it("resolves task", async () => {
    await expect(createTask(taskData)).resolves.toEqual(task)
  })
})

describe("fetchTask", () => {
  const task: Task = {
    id: faker.number.int({ min: 1 }),
    createdAt: faker.date.anytime().toISOString(),
    updatedAt: faker.date.anytime().toISOString(),
    state: faker.helpers.arrayElement(["todo", "done"]),
    title: faker.git.commitMessage(),
  }

  beforeEach(() => {
    fetchMock.mockResolvedValueOnce(
      new Response(JSON.stringify(task), { status: 200 }),
    )
  })

  afterEach(() => {
    fetchMock.mockClear()
  })

  it("sends a valid request", async () => {
    await fetchTask(task.id)
    expect(fetchMock).toHaveBeenCalledWith<FetchArgs>(`/api/tasks/${task.id}`)
  })

  it("resolves task", async () => {
    await expect(fetchTask(task.id)).resolves.toEqual(task)
  })
})

describe("updateTask", () => {
  const task: Task = {
    id: faker.number.int({ min: 1 }),
    createdAt: faker.date.anytime().toISOString(),
    updatedAt: faker.date.anytime().toISOString(),
    state: "todo",
    title: faker.git.commitMessage(),
  }
  const taskData: TaskData = {
    state: "done",
    title: faker.git.commitMessage(),
  }

  beforeEach(() => {
    fetchMock.mockResolvedValueOnce(
      new Response(JSON.stringify(task), { status: 200 }),
    )
  })

  afterEach(() => {
    fetchMock.mockClear()
  })

  it("sends a valid request", async () => {
    await updateTask(task.id, taskData)
    expect(fetchMock).toHaveBeenCalledWith<FetchArgs>(`/api/tasks/${task.id}`, {
      method: "PUT",
      body: JSON.stringify(taskData),
    })
  })

  it("resolves task", async () => {
    await expect(updateTask(task.id, taskData)).resolves.toEqual(task)
  })
})

describe("deleteTask", () => {
  const task: Task = {
    id: faker.number.int({ min: 1 }),
    createdAt: faker.date.anytime().toISOString(),
    updatedAt: faker.date.anytime().toISOString(),
    state: "todo",
    title: faker.git.commitMessage(),
  }

  beforeEach(() => {
    fetchMock.mockResolvedValueOnce(
      new Response(JSON.stringify(task), { status: 200 }),
    )
  })

  afterEach(() => {
    fetchMock.mockClear()
  })

  it("sends a valid request", async () => {
    await deleteTask(task.id)
    expect(fetchMock).toHaveBeenCalledWith<FetchArgs>(`/api/tasks/${task.id}`, {
      method: "DELETE",
    })
  })

  it("resolves task", async () => {
    await expect(deleteTask(task.id)).resolves.toEqual(task)
  })
})
