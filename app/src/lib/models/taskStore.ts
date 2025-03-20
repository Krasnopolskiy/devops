import { fetchTasks } from "@/lib/api/tasks"
import { Task } from "@/lib/models/task"
import { makeAutoObservable, runInAction } from "mobx"

export class TaskStore {
  tasks: Task[] = []
  isLoading: boolean = false

  constructor() {
    makeAutoObservable(this, {})
  }

  add(): void {
    const task = new Task(this)
    this.tasks.push(task)
  }

  remove(task: Task): void {
    this.tasks.splice(this.tasks.indexOf(task), 1)
  }

  fetch(): void {
    this.isLoading = true

    fetchTasks()
      .then((apiTasks) =>
        runInAction(() => {
          this.tasks = apiTasks
            .map((apiTask) => Task.fromJson(this, apiTask))
            .sort((a, b) => a.id - b.id)
          this.isLoading = false
        }),
      )
      .catch((e) => console.log(e))
      .finally(() => runInAction(() => (this.isLoading = false)))
  }
}
