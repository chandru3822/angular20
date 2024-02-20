export const ScheduleActions = {}

export const ScheduleMutations = {
    SET_START_TIME: 'setStartTime',
    SET_END_TIME: 'setEndTime'
}

export const ScheduleStore = {
    state: {
        startTime: null,
        endTime: null
    },
    mutations: {
        [ScheduleMutations.SET_START_TIME]: (state, startTime) => (state.startTime = startTime),
        [ScheduleMutations.SET_END_TIME]: (state, endTime) => (state.endTime = endTime)
    },
    actions:{},
}
