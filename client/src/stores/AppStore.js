import { defineStore } from 'pinia'
import theme from '@/helpers/defaultTheme.js'
import { getSnackbar, shadeColorByPercent } from '@/helpers/helpers'
import cloneDeep from 'lodash.clonedeep'

const defaultState = {
	loading: false,
	selectedProcessStepName: null,
	availableUpdate: false,
	redirectUrl: null,
	spinnerUrl: null,
	announcements: [],
	theme: cloneDeep(theme.LIGHT),
	snack: {
		show: false
	}
}

export const useAppStore = defineStore('app', {
	persist: true,
	state: () => ({...defaultState}),
	getters: {},
	actions: {
		setPrimaryBaseColor(color) {
			//vuetify's color generator does weird stuff. like if maroon is the base color then lighten-5 is orange. but this code seems to make appropriate colors.
			//if adding a new color here like `lighten2` ensure you also add it in the defaultTheme.js
			if (color && color !== '') {
				this.theme.primary = {
					base: color,
					lighten3: shadeColorByPercent(color, .3),
					lighten5: shadeColorByPercent(color, .5),
					lighten9: shadeColorByPercent(color, .9)
				}
			} else {
				//vuex has issues if you try and set state.theme.primary = theme.LIGHT.primary (i tried using Vue.set and state.theme = { ...state.theme, primaryBlah }
				this.theme.primary = {
					base: theme.LIGHT.primary.base,
					lighten3: theme.LIGHT.primary.lighten3,
					lighten5: theme.LIGHT.primary.lighten5,
					lighten9: theme.LIGHT.primary.lighten9
				}
			}
		},
		setBannerColor(color) {
			this.theme.banner = (color && color !== '') ? color : theme.LIGHT.banner
		},
		showSnack(type, msg, displayAsHtml = false) {
			const snack = getSnackbar(type, msg, displayAsHtml)
			this.snack = {...snack, show: true}
		}
	}
})