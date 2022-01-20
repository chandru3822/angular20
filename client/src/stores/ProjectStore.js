export const ProjectMutations = {
  INIT: 'storeInt',
  SET_PPS: 'setPps',
  SET_PPS_EVENT: 'setPpsEvent',
  RESET_PROJECT_STATE: 'resetProjectState',
  RESET_PPS_STATE: 'resetPpsState',
  RESET_PPS_EVENT_STATE: 'resetPpsEventState',
  SET_SELECTED_TAB: 'setSelectedTab',
  INCREMENT_RELOAD_KEY: 'updateReloadKey',
}

export const ProjectStore = {
  state: {
    pps: null,
    ppsEvent: null,
    selectedTab: 1,
    forceReloadKey: 0
  },
  mutations: {
    [ProjectMutations.SET_SELECTED_TAB]: (state, selectedTab) => (state.selectedTab = selectedTab),
    [ProjectMutations.INCREMENT_RELOAD_KEY]: (state) => {
      state.forceReloadKey++
    },
    [ProjectMutations.SET_PPS]: (state, pps) => (state.pps = pps),
    [ProjectMutations.SET_PPS_EVENT]: (state, ppsEvent) => (state.ppsEvent = ppsEvent),
    [ProjectMutations.RESET_PROJECT_STATE]: (state) => {
      state.pps = {}
      state.ppsEvent = {}
    },
    [ProjectMutations.RESET_PPS_STATE]: (state) => {
      state.pps = {}
    },
    [ProjectMutations.RESET_PPS_EVENT_STATE]: (state) => {
      state.ppsEvent = {}
    }
  },
}
