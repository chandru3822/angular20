export const AppMutations = {
  INIT: 'storeInt',
  SET_LOADING: 'SET_LOADING',
  SET_AVAILABLE_UPDATE: 'SET_AVAILABLE_UPDATE',
  SET_SELECTED_PROCESS_STEP_NAME: 'SET_SELECTED_PROCESS_STEP_NAME',
  SHOW_SNACK: 'SHOW_SNACK',
}

export const AppStore = {
  state: {
    loading: false,
    selectedProcessStepName: null,
    availableUpdate: false
  },
  mutations: {
    [AppMutations.SET_AVAILABLE_UPDATE]: (state, availableUpdate) => (state.availableUpdate = availableUpdate),
    [AppMutations.SET_LOADING]: (state, loading) => (state.loading = loading),
    [AppMutations.SET_SELECTED_PROCESS_STEP_NAME]: (state, selectedProcessStepName) => (state.selectedProcessStepName = selectedProcessStepName),
    [AppMutations.SHOW_SNACK]: (state, snack) => (state.snack = snack)
  }

}
