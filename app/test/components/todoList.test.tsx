import { TodoList } from "@/components/TodoList"
import {
  type Task as APITask,
  type TaskData as APITaskData,
  createTask,
  deleteTask,
  fetchTasks,
  updateTask,
} from "@/lib/api/tasks"
import { TaskState } from "@/lib/models/task"
import { faker } from "@faker-js/faker"
import { fireEvent, render, screen, waitFor, within } from "test-utils"

jest.mock("@/lib/api/tasks")

const fetchTasksMock = fetchTasks as jest.MockedFunction<typeof fetchTasks>
const createTaskMock = createTask as jest.MockedFunction<typeof createTask>
const updateTaskMock = updateTask as jest.MockedFunction<typeof updateTask>
const deleteTaskMock = deleteTask as jest.MockedFunction<typeof deleteTask>

describe("TodoList", () => {
  const tasks = Array.from<unknown, APITask>({ length: 3 }, (_, i) => ({
    id: i + 1,
    createdAt: faker.date.anytime().toISOString(),
    updatedAt: faker.date.anytime().toISOString(),
    state: faker.helpers.arrayElement(Object.values(TaskState)),
    title: faker.git.commitMessage(),
  }))

  describe("without tasks", () => {
    beforeEach(() => {
      fetchTasksMock.mockResolvedValueOnce([])
    })

    afterEach(() => {
      fetchTasksMock.mockClear()
    })

    it("fetches tasks", async () => {
      render(<TodoList />)

      await waitFor(() => {
        expect(fetchTasksMock).toHaveBeenCalled()
      })
    })

    it("renders an empty list", async () => {
      render(<TodoList />)
      await waitFor(() => {})

      const listEl = screen.getByRole("list")
      expect(listEl).toBeInTheDocument()
      expect(listEl).toBeEmptyDOMElement()
    })

    it("renders add button", async () => {
      render(<TodoList />)
      await waitFor(() => {})

      const addBtnEl = screen.getByRole("button", { name: "add" })
      expect(addBtnEl).toBeInTheDocument()
    })
  })

  describe("with tasks", () => {
    beforeEach(() => {
      fetchTasksMock.mockResolvedValueOnce(tasks)
    })

    afterEach(() => {
      fetchTasksMock.mockClear()
    })

    it("fetches tasks", async () => {
      render(<TodoList />)

      await waitFor(() => {
        expect(fetchTasksMock).toHaveBeenCalled()
      })
    })

    it("renders a list with tasks", async () => {
      render(<TodoList />)
      await waitFor(() => {})

      const listEl = screen.getByRole("list")
      expect(listEl).toBeInTheDocument()

      const taskEls = within(listEl).queryAllByRole("listitem")
      expect(taskEls).toHaveLength(tasks.length)

      for (let i = 0; i < tasks.length; i++) {
        const task = tasks[tasks.length - i - 1]
        const taskEl = taskEls[i]

        const stateEl = within(taskEl).getByRole("checkbox")
        const titleEl = within(taskEl).getByText(task.title)
        within(taskEl).getByRole("button", { name: "edit" })
        within(taskEl).getByRole("button", { name: "delete" })

        if (task.state == TaskState.Done.toString()) {
          expect(stateEl).toBeChecked()
          expect(titleEl).toHaveClass("line-through")
        } else {
          expect(stateEl).not.toBeChecked()
          expect(titleEl).not.toHaveClass("line-through")
        }
      }
    })

    it("renders add button", async () => {
      render(<TodoList />)
      await waitFor(() => {})

      const addBtnEl = screen.getByRole("button", { name: "add" })
      expect(addBtnEl).toBeInTheDocument()
    })
  })

  describe("create new task", () => {
    const newTask: APITask = {
      id: 10,
      createdAt: faker.date.anytime().toISOString(),
      updatedAt: faker.date.anytime().toISOString(),
      state: TaskState.ToDo,
      title: faker.git.commitMessage(),
    }

    beforeEach(() => {
      fetchTasksMock.mockResolvedValueOnce(tasks)
      createTaskMock.mockResolvedValueOnce(newTask)
    })

    afterEach(() => {
      fetchTasksMock.mockClear()
      createTaskMock.mockClear()
    })

    test("", async () => {
      render(<TodoList />)
      await waitFor(() => {})

      // Click add button
      fireEvent.click(screen.getByRole("button", { name: "add" }))

      // Check that input was added on top of the tasks list
      let taskEls = within(screen.getByRole("list")).queryAllByRole("listitem")
      expect(taskEls).toHaveLength(tasks.length + 1)
      let newTaskEl = taskEls[0]
      const inputEl = within(newTaskEl).getByLabelText("title")

      // Fill input
      fireEvent.change(inputEl, { target: { value: newTask.title } })

      // Submit input
      fireEvent.keyDown(inputEl, { key: "Enter" })
      await waitFor(() => {
        expect(createTaskMock).toHaveBeenCalledWith<[APITaskData]>({
          state: TaskState.ToDo,
          title: newTask.title,
        })
      })

      // Check that new task on top of the list
      taskEls = within(screen.getByRole("list")).queryAllByRole("listitem")
      expect(taskEls).toHaveLength(tasks.length + 1)
      newTaskEl = taskEls[0]

      // Check new task attributes
      expect(within(newTaskEl).getByRole("checkbox")).not.toBeChecked()
      expect(within(newTaskEl).getByText(newTask.title)).not.toHaveClass(
        "line-through",
      )
      within(newTaskEl).getByRole("button", { name: "edit" })
      within(newTaskEl).getByRole("button", { name: "delete" })
    })
  })

  describe("mark task done", () => {
    const task: APITask = {
      id: faker.number.int({ min: 1 }),
      createdAt: faker.date.anytime().toISOString(),
      updatedAt: faker.date.anytime().toISOString(),
      state: TaskState.ToDo,
      title: faker.git.commitMessage(),
    }

    beforeEach(() => {
      fetchTasksMock.mockResolvedValueOnce([task])
      updateTaskMock.mockResolvedValueOnce({ ...task, state: TaskState.Done })
    })

    afterEach(() => {
      fetchTasksMock.mockClear()
      updateTaskMock.mockClear()
    })

    test("", async () => {
      render(<TodoList />)
      await waitFor(() => {})

      // Get elements
      const taskEl = within(screen.getByRole("list"))
        .queryAllByRole("listitem")
        .at(-1) as HTMLElement
      const stateEl = within(taskEl).getByRole("checkbox")
      const titleEl = within(taskEl).getByText(task.title)

      // Check that initial task state is ToDo
      expect(stateEl).not.toBeChecked()
      expect(titleEl).not.toHaveClass("line-through")

      // Click checkbox
      fireEvent.click(stateEl)
      await waitFor(() => {
        expect(updateTaskMock).toHaveBeenCalledWith<[number, APITaskData]>(
          task.id,
          {
            state: TaskState.Done,
            title: task.title,
          },
        )
      })

      // Check that task state is Done
      expect(stateEl).toBeChecked()
      expect(titleEl).toHaveClass("line-through")
    })
  })

  describe("mark task todo", () => {
    const task: APITask = {
      id: faker.number.int({ min: 1 }),
      createdAt: faker.date.anytime().toISOString(),
      updatedAt: faker.date.anytime().toISOString(),
      state: TaskState.Done,
      title: faker.git.commitMessage(),
    }

    beforeEach(() => {
      fetchTasksMock.mockResolvedValueOnce([task])
      updateTaskMock.mockResolvedValueOnce({ ...task, state: TaskState.ToDo })
    })

    afterEach(() => {
      fetchTasksMock.mockClear()
      updateTaskMock.mockClear()
    })

    test("", async () => {
      render(<TodoList />)
      await waitFor(() => {})

      // Get elements
      const taskEl = within(screen.getByRole("list"))
        .queryAllByRole("listitem")
        .at(-1) as HTMLElement
      const stateEl = within(taskEl).getByRole("checkbox")
      const titleEl = within(taskEl).getByText(task.title)

      // Check that initial task state is Done
      expect(stateEl).toBeChecked()
      expect(titleEl).toHaveClass("line-through")

      // Click checkbox
      fireEvent.click(stateEl)
      await waitFor(() => {
        expect(updateTaskMock).toHaveBeenCalledWith<[number, APITaskData]>(
          task.id,
          {
            state: TaskState.ToDo,
            title: task.title,
          },
        )
      })

      // Check that task state is Done
      expect(stateEl).not.toBeChecked()
      expect(titleEl).not.toHaveClass("line-through")
    })
  })

  describe("change task title", () => {
    const task: APITask = {
      id: faker.number.int({ min: 1 }),
      createdAt: faker.date.anytime().toISOString(),
      updatedAt: faker.date.anytime().toISOString(),
      state: faker.helpers.arrayElement(Object.values(TaskState)),
      title: faker.git.commitMessage(),
    }
    const newTitle = "new awesome title"

    beforeEach(() => {
      fetchTasksMock.mockResolvedValueOnce([task])
      updateTaskMock.mockResolvedValueOnce({ ...task, title: newTitle })
    })

    afterEach(() => {
      fetchTasksMock.mockClear()
      updateTaskMock.mockClear()
    })

    test("", async () => {
      render(<TodoList />)
      await waitFor(() => {})

      // Get elements
      const taskEl = within(screen.getByRole("list"))
        .queryAllByRole("listitem")
        .at(-1) as HTMLElement
      const editBtn = within(taskEl).getByRole("button", { name: "edit" })

      // Check that initial title is rendered
      expect(within(taskEl).getByText(task.title)).toBeInTheDocument()

      // Click edit button
      fireEvent.click(editBtn)

      // Check input contains initial text
      const inputEl = within(taskEl).getByLabelText("title")
      expect(inputEl).toHaveValue(task.title)

      // Fill input
      fireEvent.change(inputEl, { target: { value: newTitle } })

      // Submit input
      fireEvent.keyDown(inputEl, { key: "Enter" })
      await waitFor(() => {
        expect(updateTaskMock).toHaveBeenCalledWith<[number, APITaskData]>(
          task.id,
          {
            state: task.state,
            title: newTitle,
          },
        )
      })

      // Check that new title is rendered
      expect(within(taskEl).getByText(newTitle)).toBeInTheDocument()
    })
  })

  describe("delete task", () => {
    const task: APITask = {
      id: faker.number.int({ min: 1 }),
      createdAt: faker.date.anytime().toISOString(),
      updatedAt: faker.date.anytime().toISOString(),
      state: faker.helpers.arrayElement(Object.values(TaskState)),
      title: faker.git.commitMessage(),
    }

    beforeEach(() => {
      fetchTasksMock.mockResolvedValueOnce([task])
      deleteTaskMock.mockResolvedValueOnce(task)
    })

    afterEach(() => {
      fetchTasksMock.mockClear()
      deleteTaskMock.mockClear()
    })

    test("", async () => {
      render(<TodoList />)
      await waitFor(() => {})

      // Get elements
      const taskEl = within(screen.getByRole("list"))
        .queryAllByRole("listitem")
        .at(-1) as HTMLElement
      const delBtn = within(taskEl).getByRole("button", { name: "delete" })

      // Click edit button
      fireEvent.click(delBtn)
      await waitFor(() => {
        expect(deleteTaskMock).toHaveBeenCalledWith<[number]>(task.id)
      })

      // Check that no tasks left in the list
      expect(screen.getByRole("list")).toBeEmptyDOMElement()
    })
  })
})
