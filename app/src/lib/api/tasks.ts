export interface TaskData {
  state: string
  title: string
}

export interface Task extends TaskData {
  id: number
  createdAt: string
  updatedAt: string
}

export const fetchTasks = async (): Promise<Task[]> => {
  const res = await fetch("/api/tasks")
  return (await res.json()) as Task[]
}

export const createTask = async (data: TaskData): Promise<Task> => {
  const res = await fetch("/api/tasks", {
    method: "POST",
    body: JSON.stringify(data),
  })

  return (await res.json()) as Task
}

export const fetchTask = async (id: number): Promise<Task> => {
  const res = await fetch(`/api/tasks/${id}`)
  return (await res.json()) as Task
}

export const updateTask = async (id: number, data: TaskData): Promise<Task> => {
  const res = await fetch(`/api/tasks/${id}`, {
    method: "PUT",
    body: JSON.stringify(data),
  })
  return (await res.json()) as Task
}

export const deleteTask = async (id: number): Promise<Task> => {
  const res = await fetch(`/api/tasks/${id}`, { method: "DELETE" })
  return (await res.json()) as Task
}
