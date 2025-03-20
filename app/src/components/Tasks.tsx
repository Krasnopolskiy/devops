"use client"

import { Task } from "@/components/Task"
import { type TaskStore } from "@/lib/models/taskStore"
import { clsx } from "clsx"
import { observer } from "mobx-react-lite"
import { type FC } from "react"

export interface TasksProps {
  className?: string
  store: TaskStore
}

export const Tasks: FC<TasksProps> = observer(({ className, store }) => (
  <ul className={clsx([className])}>
    {store.tasks
      .slice(0)
      .reverse()
      .map((task) => (
        <li
          key={task.id}
          className="p-2"
        >
          <Task task={task} />
        </li>
      ))}
  </ul>
))
