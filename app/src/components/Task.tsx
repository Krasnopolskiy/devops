"use client"

import { MaterialIconButton } from "@/components/MaterialIconButton"
import { Checkbox, Input, Spinner, Typography } from "@/components/material"
import { type Task as TaskModel, TaskState } from "@/lib/models/task"
import { clsx } from "clsx"
import { observer } from "mobx-react-lite"
import { type FC, useRef, useState } from "react"

export interface TaskProps {
  className?: string
  task: TaskModel
}

export const Task: FC<TaskProps> = observer(({ className, task }) => {
  const [isEditing, setIsEditing] = useState(task.id <= 0)
  const ref = useRef<HTMLInputElement>(null)

  const editDone = (): void => {
    const newTitle = ref?.current?.value?.trim()
    setIsEditing(false)

    if (newTitle == undefined) return
    if (newTitle == "") {
      if (task.id <= 0) task.delete()

      return
    }

    if (newTitle != task.title) {
      task.title = newTitle
    }
  }

  return (
    <div
      className={clsx([
        "flex flex-row flex-nowrap justify-between items-stretch h-12",
        className,
      ])}
    >
      {isEditing ? (
        <Input
          autoFocus
          inputRef={ref}
          label=""
          aria-label="title"
          containerProps={{ className: "h-full" }}
          labelProps={{ className: "before:mr-0 after:ml-0" }}
          defaultValue={task.title}
          onBlur={editDone}
          onKeyDown={(e): void => {
            if (e.key === "Enter") {
              editDone()
            }
          }}
        />
      ) : (
        <>
          <div className="flex flex-row flex-nowrap items-center gap-2">
            {task.isLoading ? (
              <div className="p-2">
                <Spinner className="h-7 w-7" />
              </div>
            ) : (
              <Checkbox
                checked={task.state == TaskState.Done}
                onChange={(e): void => {
                  task.state = e.currentTarget.checked
                    ? TaskState.Done
                    : TaskState.ToDo
                }}
              />
            )}
            <Typography
              className={clsx({
                "line-through": task.state == TaskState.Done,
              })}
            >
              {task.title}
            </Typography>
          </div>
          <div className="flex flex-row flex-nowrap items-center">
            <MaterialIconButton
              icon="edit"
              aria-label="edit"
              variant="text"
              className="rounded-full"
              disabled={task.isLoading}
              onClick={(): void => {
                setIsEditing(true)
              }}
            />
            <MaterialIconButton
              icon="delete"
              aria-label="delete"
              variant="text"
              className="rounded-full"
              disabled={task.isLoading}
              onClick={(): void => {
                task.delete()
              }}
            />
          </div>
        </>
      )}
    </div>
  )
})

export default Task
