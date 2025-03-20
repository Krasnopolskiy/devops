import {
  type Task as APITask,
  type TaskData as APITaskData,
  createTask,
  deleteTask,
  updateTask,
} from "@/lib/api/tasks"
import { type TaskStore } from "@/lib/models/taskStore"
import { makeAutoObservable, runInAction } from "mobx"

export enum TaskState {
  ToDo = "todo",
  Done = "done",
}

export class Task {
  id: number = 0
  createdAt: Date = new Date()
  updatedAt: Date = new Date()
  _state: TaskState = TaskState.ToDo
  _title: string = ""

  isLoading: boolean = false
  store: TaskStore

  constructor(store: TaskStore) {
    makeAutoObservable(this, {
      store: false,
    })
    this.store = store
  }

  get state(): TaskState {
    return this._state
  }

  get title(): string {
    return this._title
  }

  get json(): APITaskData {
    return {
      state: this._state,
      title: this._title,
    }
  }

  set state(newState: TaskState) {
    this._state = newState
    this._save()
  }

  set title(newTitle: string) {
    this._title = newTitle
    this._save()
  }

  static fromJson(store: TaskStore, data: APITask): Task {
    const task = new Task(store)
    task.updateFromJson(data)
    return task
  }

  delete(): void {
    if (this.id <= 0) {
      this.store.remove(this)
      return
    }

    this.isLoading = true

    deleteTask(this.id)
      .then(() => this.store.remove(this))
      .catch((e) => console.log(e))
  }

  updateFromJson(data: APITask): void {
    this.id = data?.id
    this.createdAt = new Date(data?.createdAt ?? null)
    this.updatedAt = new Date(data?.updatedAt ?? null)
    this._state = data?.state as TaskState
    this._title = data?.title
  }

  _save(): void {
    if (this.id <= 0) {
      this._create()
    } else {
      this._update()
    }
  }

  _create(): void {
    this.isLoading = true
    createTask(this.json)
      .then((data) =>
        runInAction(() => {
          this.updateFromJson(data)
          this.isLoading = false
        }),
      )
      .catch((e) => console.log(e))
      .finally(() => runInAction(() => (this.isLoading = false)))
  }

  _update(): void {
    this.isLoading = true
    updateTask(this.id, this.json)
      .then((data) =>
        runInAction(() => {
          this.updateFromJson(data)
          this.isLoading = false
        }),
      )
      .catch((e) => console.log(e))
      .finally(() => runInAction(() => (this.isLoading = false)))
  }
}

export default Task
