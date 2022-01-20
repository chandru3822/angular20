export const ProjectMutations = {
  INIT: 'storeInt',
  SET_PPS: 'setPps',
  SET_PPS_EVENT: 'setPpsEvent',
  RESET_PROJECT_STATE: 'resetProjectState',
  RESET_PPS_STATE: 'resetPpsState',
  RESET_PPS_EVENT_STATE: 'resetPpsEventState',
}

export const ProjectStore = {
  state: {
    pps: null,
    ppsEvent: null
  },
  mutations: {
    [ProjectMutations.SET_PPS]: (state, pps) => (state.pps = pps),
    [ProjectMutations.SET_PPS_EVENT]: (state, ppsEvent) => (state.ppsEvent = ppsEvent),
    [ProjectMutations.RESET_PROJECT_STATE]: (state) => (Object.assign(state, {
      pps: {},
      ppsEvent: {}
    })),
    [ProjectMutations.RESET_PPS_STATE]: (state) => (Object.assign(state, {
      pps: {},
    })),
    [ProjectMutations.RESET_PPS_EVENT_STATE]: (state) => (Object.assign(state, {
      ppsEvent: {},
    })),
  },
}
