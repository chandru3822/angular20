export const AppMutations = {
  INIT: 'storeInt',
  SET_LOADING: 'SET_LOADING'
}

export const AppStore = {
  state: {
    loading: false
  },
  mutations: {
    [AppMutations.SET_LOADING]: (state, loading) => (state.loading = loading)
  }

}
