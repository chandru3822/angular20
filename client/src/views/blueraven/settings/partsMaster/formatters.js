const dateTimeFormat = new Intl.DateTimeFormat('default', {
  dateStyle: 'short',
  timeStyle: 'short'
})

const numberFormat = new Intl.NumberFormat('default', {
  maximumFractionDigits: 15
})

export const capitalize = (value) => {
  if (!value) return
  return value[0].toUpperCase() + value?.slice(1).toLowerCase()
}

export const timestamp = (value) => {
  if (!value) {
    return
  }

  return dateTimeFormat.format(new Date(value))
}

export const customValueFormatter = ({ value, type }) => {
  if (Array.isArray(value)) {
    return value?.join(', ')
  }

  if (type === 'timestamp') {
    return dateTimeFormat.format(new Date(value))
  }

  if (!isNaN(value) && (type === 'numeric' || type === 'integer')) {
    return numberFormat.format(value)
  }

  if (type === 'boolean') {
    return value ? '✔' : ''
  }
  return value
}
