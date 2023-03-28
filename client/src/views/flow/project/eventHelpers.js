
export function hideEvent(event, store) {
    if(!store.getters.isFullAdmin &&
        event.eventHidden &&
        !store.getters.userHasAnyPosition(event.eventHiddenWhiteListedPositions?.map(wlp => wlp.positionId))
    ){
        return true
    }
    return false
}
