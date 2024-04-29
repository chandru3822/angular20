//usage: exec('customFieldHasValue(fieldId, expectedValue)') => bool
export const exec = function (expr, context = []) {
  //returns a boolean if the provided fieldId matches the value passed in
  function customFieldHasValue(fieldId, value) {
    const match = context?.find(
      (f) => f.fieldId === fieldId && f.value === value
    )
    return match !== undefined
  }

  const fn = new Function('customFieldHasValue', `"use strict"; return ${expr}`)
  return fn(customFieldHasValue)
}

export const buildContext = function (customFieldGroups = []) {
  return customFieldGroups
    ?.flatMap((cfg) => cfg.customFieldValues)
    ?.filter((f) => f.customFieldId !== null)
    ?.map((f) => {
      const value = getValueFromCustomField(f)
      return {
        fieldId: f.customFieldId,
        value
      }
    })
}

const getValueFromCustomField = function (field) {
  switch (field.dataTypeId) {
    case 1:
      return field.dateValue
    case 2:
      return field.timestampValue
    case 3:
      return field.booleanValue
    case 4:
      return field.numericValue
    case 5:
    case 12:
      return field.textValue
    case 6:
    case 8:
    case 9:
      return field.intValue
    case 7:
    case 10:
      return field.intArrayValue
    case 13:
      return field.richTextValue
  }
}
