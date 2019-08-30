export const AppMutations = {
  INIT: 'storeInt',
  SET_LOADING: 'SET_LOADING',
  SET_SELECTED_PROCESS_STEP_NAME: 'SET_SELECTED_PROCESS_STEP_NAME',
}

export const AppStore = {
  state: {
    loading: false,
    selectedProcessStepName: null
  },
  mutations: {
    [AppMutations.SET_LOADING]: (state, loading) => (state.loading = loading),
    [AppMutations.SET_SELECTED_PROCESS_STEP_NAME]: (state, selectedProcessStepName) => (state.selectedProcessStepName = selectedProcessStepName)
  }

}
