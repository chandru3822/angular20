export const BrsActions = {}

export const BrsMutations = {
  SET_COMMISSION_POSITION_ID: 'setCommissionPositionId',
}

export const BrsStore = {
  state: {
    commissionPositionId: null,
  },
  mutations: {
    [BrsMutations.SET_COMMISSION_POSITION_ID]: (state, positionId) =>
      (state.commissionPositionId = positionId),
  },
  actions: {},
  getters: {},
}
