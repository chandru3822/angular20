import { defineStore } from 'pinia'
import moment from 'moment-timezone'

const defaultState = {
	selectedResourceId: null,
	showMap: false,
	timezone: null,
	startTime: null,
	endTime: null
}

export const useScheduleStore = defineStore('schedule', {
	persist: true,
	state: () => ({...defaultState}),
	getters: {
		getTimezone() {
			if (!this.timezone) {
				this.timezone = {
					friendlyValue: moment.tz.guess(),
					value: moment.tz.guess()
				}
			}
			return this.timezone
		}
	},
	actions: {

	}
})