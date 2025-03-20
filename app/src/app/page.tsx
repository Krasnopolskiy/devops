"use client"

import { TodoList } from "@/components/TodoList"
import type { ReactNode } from "react"

export default function Home(): ReactNode {
  return (
    <main className="min-h-screen sm:py-12">
      <TodoList />
    </main>
  )
}
