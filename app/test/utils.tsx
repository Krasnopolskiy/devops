import { Theme } from "@/app/theme"
import { ThemeProvider } from "@/components/material"
import {
  type RenderOptions,
  type RenderResult,
  render,
} from "@testing-library/react"
import type { FC, ReactNode } from "react"

interface WrapperProps {
  children: ReactNode
}

const Wrapper: FC<WrapperProps> = ({ children }) => (
  <ThemeProvider value={Theme}>{children}</ThemeProvider>
)

const customRender = (
  ui: React.ReactElement,
  options?: Omit<RenderOptions, "queries">,
): RenderResult => {
  return render(ui, { wrapper: Wrapper, ...options })
}

/* eslint-disable import/export */
export * from "@testing-library/react"
export { customRender as render }
/* eslint-enable import/export */
