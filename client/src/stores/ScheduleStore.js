import moment from 'moment-timezone'

export const ScheduleMutations = {
    SET_SELECTED_RESOURCE_ID: 'setSelectedResourceId',
    SHOW_HIDE_MAP:'showHideMap',
    SET_TIMEZONE_SCHEDULE:'setTimezoneSchedule',
    SET_START_TIME: 'setStartTime',
    SET_END_TIME: 'setEndTime'
}

export const ScheduleActions = {
    CHANGE_TIMEZONE_SCHEDULE: 'changeTimezoneSchedule'
}

export const ScheduleStore = {
    state: {
        selectedResourceId: null,
        showMap: false,
        timezone: {},
        startTime: null,
        endTime: null
    },
    mutations: {
        [ScheduleMutations.SET_SELECTED_RESOURCE_ID]: (state, resourceId) => (state.selectedResourceId = resourceId),
        [ScheduleMutations.SHOW_HIDE_MAP]: (state) => state.showMap = !state.showMap,
        [ScheduleMutations.SET_TIMEZONE_SCHEDULE]:(state, timezone) => {
			if (!timezone) {
				timezone = {
					friendlyValue: moment.tz.guess(),
					value: moment.tz.guess()
				}
			}
			state.timezone = timezone
		},
        [ScheduleMutations.SET_START_TIME]: (state, startTime) => (state.startTime = startTime),
        [ScheduleMutations.SET_END_TIME]: (state, endTime) => (state.endTime = endTime)
    },
    actions:{
        [ScheduleActions.CHANGE_TIMEZONE_SCHEDULE]: async({ commit, state}, timezone) => {
            state.timezone = timezone
            commit(ScheduleMutations.SET_TIMEZONE_SCHEDULE, state.timezone)
        }
    },
}
