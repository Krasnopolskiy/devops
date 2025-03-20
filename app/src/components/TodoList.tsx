"use client"

import { MaterialIconButton } from "@/components/MaterialIconButton"
import { Tasks } from "@/components/Tasks"
import { Card, CardBody, Spinner } from "@/components/material"
import { TaskStore } from "@/lib/models/taskStore"
import { clsx } from "clsx"
import { observer } from "mobx-react-lite"
import { type FC, useEffect, useState } from "react"

export interface TodoListProps {
  className?: string
}

export const TodoList: FC<TodoListProps> = observer(({ className }) => {
  const [store] = useState(() => new TaskStore())

  useEffect(() => {
    store.fetch()
  }, [store])

  return (
    <Card className={clsx(["w-full max-w-xl mx-auto", className])}>
      <CardBody className="p-2">
        {store.isLoading ? (
          <Spinner className="h-14 w-14 my-2 mx-auto" />
        ) : (
          <Tasks store={store} />
        )}
      </CardBody>
      <MaterialIconButton
        icon="add"
        aria-label="add"
        size="lg"
        color="blue"
        className={clsx([
          "fixed bottom-12 sm:bottom-16",
          "left-[50vw] -translate-x-1/2 lg:ml-[24rem]",
          "rounded-full text-4xl",
        ])}
        ripple={false}
        onClick={(): void => {
          store.add()
        }}
        disabled={store.isLoading}
      />
    </Card>
  )
})

export default TodoList
