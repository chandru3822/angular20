export const ScheduleActions = {}

export const ScheduleMutations = {
    SET_SELECTED_RESOURCE_ID: 'setSelectedResourceId',
    SHOW_HIDE_MAP:'showHideMap',
    SET_START_TIME: 'setStartTime',
    SET_END_TIME: 'setEndTime'
}

export const ScheduleStore = {
    state: {
        selectedResourceId: null,
        showMap: false,
        startTime: null,
        endTime: null
    },
    mutations: {
        [ScheduleMutations.SET_SELECTED_RESOURCE_ID]: (state, resourceId) => (state.selectedResourceId = resourceId),
        [ScheduleMutations.SHOW_HIDE_MAP]: (state) => state.showMap = !state.showMap,
        [ScheduleMutations.SET_START_TIME]: (state, startTime) => (state.startTime = startTime),
        [ScheduleMutations.SET_END_TIME]: (state, endTime) => (state.endTime = endTime)
    },
    actions:{},
}
