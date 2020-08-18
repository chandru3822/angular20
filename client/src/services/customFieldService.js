export function getCustomFieldReadOnly(store, field) {
  return field.ancillaryCustomFieldGroupAssignmentId !== null
    || field.readonly
    || ( field.customFieldGroupAssignmentReadOnly && field.whiteListedPositions.length === 0 )
    || ( field.customFieldGroupAssignmentReadOnly
      && field.whiteListedPositions.length > 0
      && !store.getters.userHasAnyPosition(field.whiteListedPositions.map(wlp => wlp.positionId)) )
}





