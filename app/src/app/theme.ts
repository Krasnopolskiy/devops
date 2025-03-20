import type {
  CheckboxStylesType,
  IconButtonStyleTypes,
  InputStylesType,
  SpinnerStyleTypes,
} from "@material-tailwind/react"

export const Theme: {
  checkbox: CheckboxStylesType
  iconButton: IconButtonStyleTypes
  input: InputStylesType
  spinner: SpinnerStyleTypes
} = {
  checkbox: {
    defaultProps: {
      color: "blue",
    },
  },
  iconButton: {
    defaultProps: {
      color: "blue-gray",
    },
  },
  input: {
    defaultProps: {
      color: "blue",
    },
  },
  spinner: {
    defaultProps: {
      color: "blue",
    },
  },
}
