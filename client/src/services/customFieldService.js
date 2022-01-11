export function getCustomFieldReadOnly(store, field) {
  let readonly = false
  //more verbose but easier to figure out what is going on
  if(field.ancillaryCustomFieldGroupAssignmentId !== null) {
    //all ancillary fields are ALWAYS readonly
    readonly = true
  } else if (field.whiteListedPositions?.length > 0) {
    //this is a change to how it used to work.  now having white listed positions overrides the master/higher level readonly
    //do any of the users active positions match the white listed positions
    readonly = !store.getters.userHasAnyPosition(field.whiteListedPositions?.map(wlp => wlp.positionId))
  } else if (field.customFieldGroupAssignmentReadOnly) {
    //the cfga is marked as readonly but there are no whitelisted positions.  always readonly
    readonly = true
  } else if(field.readonly) {
    //no other scenario is true, and the master level readonly flag is true
    readonly = true
  }

  return readonly
}

export function getEventCustomFieldReadOnly(store, field) {
  let readonly = false
  //more verbose but easier to figure out what is going on
  if (field.whiteListedPositions?.length > 0) {
    //this is a change to how it used to work.  now having white listed positions overrides the master/higher level readonly
    //do any of the users active positions match the white listed positions
    readonly = !store.getters.userHasAnyPosition(field.whiteListedPositions?.map(wlp => wlp.positionId))
  } else if (field.customFieldGroupAssignmentReadOnly) {
    //the cfga is marked as readonly but there are no whitelisted positions.  always readonly
    readonly = true
  } else if(field.readonly) {
    //no other scenario is true, and the master level readonly flag is true
    readonly = true
  }

  return readonly
}

export function getEventDefaultFieldReadOnly(store, whiteListedPositions, fieldReadOnlyValue) {
  let readonly = false
  console.log('randaLogger',whiteListedPositions)
  if (whiteListedPositions?.length > 0) {
    //do any of the user's active positions match the white listed positions
    readonly = !store.getters.userHasAnyPosition(whiteListedPositions?.map(wlp => wlp.positionId))
  } else if (fieldReadOnlyValue) {
    //the field is marked as readonly but there are no whitelisted positions.  always readonly
    readonly = true
  }

  return readonly
}





