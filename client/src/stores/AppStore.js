export const AppMutations = {
  INIT: 'storeInt',
  SET_LOADING: 'SET_LOADING'
}

export const AppStore = {
  state: {
    loading: false,
    allFileTypes: "doc,docx,csv,xls,xlsx,jpg,jpeg,gif,png,tiff,pdf",
    imageFileTypes: "jpg,jpeg,gif,png,tiff,pdf"
  },
  mutations: {
    [AppMutations.SET_LOADING]: (state, loading) => (state.loading = loading)
  }

}
