import theme from "@/helpers/defaultTheme";
import { shadeColorByPercent } from "@/helpers/helpers"
import Vue from 'vue'
// import colors from 'vuetify/lib/util/colors'

export const AppMutations = {
  INIT: 'storeInt',
  SET_LOADING: 'SET_LOADING',
  SET_AVAILABLE_UPDATE: 'SET_AVAILABLE_UPDATE',
  SET_SELECTED_PROCESS_STEP_NAME: 'SET_SELECTED_PROCESS_STEP_NAME',
  SHOW_SNACK: 'SHOW_SNACK',
  SHOW_ANNOUNCEMENT: 'SHOW_ANNOUNCEMENT',
  SET_REDIRECT_URL: 'SET_REDIRECT_URL',
  SET_SPINNER_URL: 'SET_SPINNER_URL',
  SET_PRIMARY_BASE_COLOR: 'SET_PRIMARY_BASE_COLOR',
  SET_BANNER_COLOR: 'SET_BANNER_COLOR',
  SET_INITIAL_THEME: 'SET_INITIAL_THEME',
}

export const AppStore = {
  state: {
    loading: false,
    selectedProcessStepName: null,
    availableUpdate: false,
    redirectUrl: null,
    spinnerUrl: null,
    theme: theme.LIGHT
  },
  mutations: {
    [AppMutations.SET_AVAILABLE_UPDATE]: (state, availableUpdate) => (state.availableUpdate = availableUpdate),
    [AppMutations.SET_LOADING]: (state, loading) => (state.loading = loading),
    [AppMutations.SET_SELECTED_PROCESS_STEP_NAME]: (state, selectedProcessStepName) => (state.selectedProcessStepName = selectedProcessStepName),
    [AppMutations.SHOW_SNACK]: (state, snack) => (state.snack = snack),
    [AppMutations.SHOW_ANNOUNCEMENT]: (state, {announcement, positionOffset}) => (state.announcement = { ...announcement, positionOffset}),
    [AppMutations.SET_REDIRECT_URL]: (state, url) => (state.redirectUrl = url),
    [AppMutations.SET_SPINNER_URL]: (state, url) => (state.spinnerUrl = url),
    [AppMutations.SET_INITIAL_THEME]: (state) => {
      if(state.theme === undefined) {
        state.theme = { ...theme.LIGHT }
      }
    },
    [AppMutations.SET_PRIMARY_BASE_COLOR]: (state, color) => {

      //vuetify's color generator does weird stuff. like if maroon is the base color then lighten-5 is orange. but this code seems to make appropriate colors.
      //if adding a new color here like `lighten2` ensure you also add it in the defaultTheme.js
      if(color && color !== '') {
        state.theme.primary = {
          base: color,
          lighten3: shadeColorByPercent(color, .3),
          lighten5: shadeColorByPercent(color, .5),
          lighten9: shadeColorByPercent(color, .9),
        }
      } else {
        //vuex has issues if you try and set state.theme.primary = theme.LIGHT.primary (i tried using Vue.set and state.theme = { ...state.theme, primaryBlah }
        state.theme.primary = {
          base: theme.LIGHT.primary.base,
          lighten3: theme.LIGHT.primary.lighten3,
          lighten5: theme.LIGHT.primary.lighten5,
          lighten9: theme.LIGHT.primary.lighten9,
        }
      }
    },
    [AppMutations.SET_BANNER_COLOR]: (state, color) => (state.theme.banner = color && color !== '' ? color : theme.LIGHT.banner)
  }
}
