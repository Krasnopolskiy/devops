import "@/app/globals.css"
import { Theme } from "@/app/theme"
import { ThemeProvider } from "@/components/material"
import type { Metadata } from "next"
import type { ReactNode } from "react"

export const metadata: Metadata = {
  title: "ToDo application",
  description: "Sample ToDo application for DevOps course",
}

export interface LayoutProps {
  children?: ReactNode
}

export default function RootLayout({ children }: LayoutProps): ReactNode {
  return (
    <html lang="en">
      <ThemeProvider value={Theme}>
        <body className="bg-blue-gray-50">{children}</body>
      </ThemeProvider>
    </html>
  )
}
