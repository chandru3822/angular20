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
  if (whiteListedPositions?.length > 0) {
    //do any of the user's active positions match the white listed positions
    readonly = !store.getters.userHasAnyPosition(whiteListedPositions?.map(wlp => wlp.positionId))
  } else if (fieldReadOnlyValue) {
    //the field is marked as readonly but there are no whitelisted positions.  always readonly
    readonly = true
  }

  return readonly
}
//
// export function getEventCustomFieldHidden(store, field) {
//     let hidden = false
//     //more verbose but easier to figure out what is going on
//     if (field.whiteListedPositions?.length > 0) {
//         //this is a change to how it used to work.  now having white listed positions overrides the master/higher level readonly
//         //do any of the users active positions match the white listed positions
//         hidden = !store.getters.userHasAnyPosition(field.whiteListedPositions?.map(wlp => wlp.positionId))
//     // } else if (field.customFieldGroupAssignmentReadOnly) {
//     //     //the cfga is marked as readonly but there are no whitelisted positions.  always readonly
//     //     hidden = true
//     } else if(field.hidden) {
//         //no other scenario is true, and the master level hidden flag is true
//         hidden = true
//     }
//
//     return hidden
// }

export function getEventDefaultFieldHidden(store, whiteListedPositions, fieldHiddenValue) {
  let hidden = false
  if (whiteListedPositions?.length > 0) {
    //do any of the user's active positions match the white listed positions
    hidden = !store.getters.userHasAnyPosition(whiteListedPositions?.map(wlp => wlp.positionId))
  } else if (fieldHiddenValue) {
    //the field is marked as hidden but there are no whitelisted positions.  always hidden
    hidden = true
  }

  return hidden
}

