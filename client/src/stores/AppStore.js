import theme from "@/helpers/defaultTheme";
import { shadeColorByPercent } from "@/helpers/helpers"
import colors from 'vuetify/lib/util/colors'

export const AppMutations = {
  INIT: 'storeInt',
  SET_LOADING: 'SET_LOADING',
  SET_AVAILABLE_UPDATE: 'SET_AVAILABLE_UPDATE',
  SET_SELECTED_PROCESS_STEP_NAME: 'SET_SELECTED_PROCESS_STEP_NAME',
  SHOW_SNACK: 'SHOW_SNACK',
  SET_REDIRECT_URL: 'SET_REDIRECT_URL',
  SET_SPINNER_URL: 'SET_SPINNER_URL',
  SET_PRIMARY_BASE_COLOR: 'SET_PRIMARY_BASE_COLOR',
  SET_BANNER_COLOR: 'SET_BANNER_COLOR',
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
    [AppMutations.SET_REDIRECT_URL]: (state, url) => (state.redirectUrl = url),
    [AppMutations.SET_SPINNER_URL]: (state, url) => (state.spinnerUrl = url),
    [AppMutations.SET_PRIMARY_BASE_COLOR]: (state, color) => {
      //let vuetify do it based on a hex code - ugly
      //   state.theme.primary = color && color !== '' ? color : theme.LIGHT.primary

      //use material colors - pretty but limited
      // state.theme.primary = colors.red

      //calculate it ourselves (prettier...i think, but annoying to have to do)
      if(color && color !== '') {
        state.theme.primary.base = color
        // state.theme.primary.lighten1 = shadeColorByPercent(color, .1)
        // state.theme.primary.lighten2 = shadeColorByPercent(color, .2)
        state.theme.primary.lighten3 = shadeColorByPercent(color, .3)
        // state.theme.primary.lighten4 = shadeColorByPercent(color, .4)
        state.theme.primary.lighten5 = shadeColorByPercent(color, .5)
        // state.theme.primary.lighten6 = shadeColorByPercent(color, .6)
        // state.theme.primary.lighten7 = shadeColorByPercent(color, .7)
        // state.theme.primary.lighten8 = shadeColorByPercent(color, .8)
        state.theme.primary.lighten9 = shadeColorByPercent(color, .9)
      } else {
        state.theme.primary = theme.LIGHT.primary
      }
    },
    [AppMutations.SET_BANNER_COLOR]: (state, color) => (state.theme.banner = color && color !== '' ? color : theme.LIGHT.banner)
  }
}
