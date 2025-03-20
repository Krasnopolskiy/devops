"use client"

import { IconButton } from "@/components/material"
import { type IconButtonProps } from "@material-tailwind/react"
import { clsx } from "clsx"
import { forwardRef } from "react"

export interface MaterialIconButtonProps
  extends Omit<IconButtonProps, "children"> {
  icon: string
  iconClassName?: string
}

export const MaterialIconButton = forwardRef<
  HTMLButtonElement,
  MaterialIconButtonProps
>(({ icon, iconClassName, ...props }, ref) => {
  return (
    <IconButton
      // @ts-expect-error Bug in material-tailwind type system
      ref={ref}
      {...props}
    >
      <i className={clsx(["material-icons", iconClassName])}>{icon}</i>
    </IconButton>
  )
})
MaterialIconButton.displayName = "MaterialIconButton"

export default MaterialIconButton
