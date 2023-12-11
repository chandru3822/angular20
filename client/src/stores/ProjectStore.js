export const ProjectMutations = {
  INIT: 'storeInt',
  SET_PPS: 'setPps',
  SET_PPS_EVENT: 'setPpsEvent',
  SET_LINK_LABEL: 'setLinkLabel',
  SET_LINK_ID: 'setLinkId',
  RESET_PROJECT_STATE: 'resetProjectState',
  RESET_PPS_STATE: 'resetPpsState',
  RESET_PPS_EVENT_STATE: 'resetPpsEventState',
  SET_SELECTED_TAB: 'setSelectedTab',
  SET_NOTES_ACTIVITY_VIEW: 'setNotesActivityView',
  INCREMENT_RELOAD_KEY: 'updateReloadKey',
  FLIP_MANUAL_COLUMN_SPLIT: 'flipManualColumnSplit',
  LEFT_SIDE_COLLAPSE: 'leftSideCollapse',
  RIGHT_SIDE_COLLAPSE: 'rightSideCollapse',
  ACTIVE_PPS_COLLAPSE: 'activePpsCollapse',
  ACTIVE_EVENT_COLLAPSE: 'activeEventCollapse'
}

export const ProjectStore = {
  state: {
      pps: null,
      linkLabel: null,
      ppsEvent: null,
      selectedTab: 1,
      notesActivityView: 1,
      forceReloadKey: 0,
      manualColumnSplit: false,
      leftSideSplit: false,
      rightSideSplit: false,
      activePpsDropdown: true,
      activeEventDropdown: true
  },
  mutations: {
    [ProjectMutations.FLIP_MANUAL_COLUMN_SPLIT]: (state) => {
      state.manualColumnSplit = !state.manualColumnSplit},
    [ProjectMutations.LEFT_SIDE_COLLAPSE]: (state) => {
      state.leftSideSplit = !state.leftSideSplit},
    [ProjectMutations.RIGHT_SIDE_COLLAPSE]: (state) => {
      state.rightSideSplit = !state.rightSideSplit},
    [ProjectMutations.SET_SELECTED_TAB]: (state, selectedTab) => (state.selectedTab = selectedTab),
    [ProjectMutations.SET_NOTES_ACTIVITY_VIEW]: (state, notesActivityView) => (state.notesActivityView = notesActivityView),
    [ProjectMutations.INCREMENT_RELOAD_KEY]: (state) => {
      state.forceReloadKey++
    },
    [ProjectMutations.SET_PPS]: (state, pps) => (state.pps = pps),
    [ProjectMutations.SET_PPS_EVENT]: (state, ppsEvent) => (state.ppsEvent = ppsEvent),
    [ProjectMutations.SET_LINK_LABEL]: (state, linkLabel) => (state.linkLabel = linkLabel),
    [ProjectMutations.SET_LINK_ID]: (state, linkId) => (state.linkId = linkId),
    [ProjectMutations.RESET_PROJECT_STATE]: (state) => {
      state.pps = {}
      state.ppsEvent = {}
    },
    [ProjectMutations.RESET_PPS_STATE]: (state) => {
      state.pps = {}
    },
    [ProjectMutations.RESET_PPS_EVENT_STATE]: (state) => {
      state.ppsEvent = {}
    },
    [ProjectMutations.ACTIVE_PPS_COLLAPSE]: (state) => {
        state.activePpsDropdown = !state.activePpsDropdown
    },
    [ProjectMutations.ACTIVE_EVENT_COLLAPSE]: (state) => {
        state.activeEventDropdown = !state.activeEventDropdown
    }
  },
}
