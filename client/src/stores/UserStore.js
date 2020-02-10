import {postRequest} from "@/helpers/helpers";

export const UserActions = {
  LOGIN_SUCCESS: 'loginSuccess',
  CHANGE_CONTEXT: 'changeContext',
  LOGOUT: 'logout',
  CHANGE_TIMEZONE: 'changeTimezone'
}

export const UserMutations = {
  SET_JWT: 'setJwt',
  AUTH_STATUS: 'authStatus',
  LOGIN_ERROR: 'setLoginError',
  INIT: 'storeInt',
  SET_DETAILS: 'setDetails',
  SET_USER_IMAGE: 'setUserImage',
}

export const UserStore = {
  state: {
    authorized: false,
    jwt: null,
    loginError: null,
    details: null
  },
  mutations: {
    [UserMutations.SET_JWT]: (state, jwt) => (state.jwt = jwt),
    [UserMutations.AUTH_STATUS]: (state, status) => (state.authorized = status),
    [UserMutations.LOGIN_ERROR]: (state, err) => (state.loginError = err),
    [UserMutations.SET_DETAILS]: (state, details) => (state.details = details),
    [UserMutations.SET_USER_IMAGE]: (state, image) => (state.userImage = image),
  },
  actions: {
    [UserActions.CHANGE_TIMEZONE]: async ({ commit, getters, state }, timezone) => {
      state.details.timezone = timezone
      //todo: date/time inputs don't update when the zone is changed. should we refresh?

      commit(UserMutations.SET_DETAILS, state.details)
    },
    [UserActions.LOGIN_SUCCESS]: async ({ commit, getters }, details) => {
      commit(UserMutations.LOGIN_ERROR, '')

      commit(UserMutations.SET_DETAILS, details)

      //TODO: permissions when we know how they are being genericized
      commit(UserMutations.AUTH_STATUS, true)

      if (getters.userHasAnyFeatureAccess) {
        commit(UserMutations.AUTH_STATUS, true)
      } else {
        commit(
          UserMutations.LOGIN_ERROR,
          'You do not have permission to access this app.'
        )
      }
    },
    [UserActions.CHANGE_CONTEXT]: async ({ commit, getters }, params) => {

      //change context
      let url
      if(params.isAdmin) {
        url = `/user/changeContextAdmin/${params.companyId}`
      } else {
        url = `/user/changeContext/${params.companyId}`
      }

      const {data} = await postRequest(url)

      //update vuex store - user details
      commit(UserMutations.SET_DETAILS, data)

      //refresh entire app
      window.location.reload()
    },
    [UserActions.LOGOUT]: () => {
      localStorage.removeItem('store')
    }
  },
  getters: {
    userHasAnyFeatureAccess: state => {
      // this function returns true if the user has any access level for any feature -
      // or if the user is a system admin
      console.log('sss', state)
      return UserStore.getters.isSystemAdmin(state.details.highestCompanyId) || state.details.featureAccess?.length > 0
    },
    userHasFeatureAccess: (state, getters) => featureCode => {
      // this function returns true if the user has any access level (edit, view, etc)
      // or if the user is a system admin (send 'SYSTEM' as the feature code if you only care it is a system admin)
      return getters.isSystemAdmin(state.details.highestCompanyId) || (state.details.featureAccess?.length > 0 && state.details.featureAccess.some(fa => fa.featureCode === featureCode))
    },
    isFullAdmin: state => {
      // 1 is the master company id
      return state.details.highestCompanyId === 1
    },
    isParent: state => parentId => {
      return parentId === 1 || parentId == null
    },
    isCompanyRoot: state => companyId => {
      return companyId === 1
    },
    isSystemAdmin: state => highestCompanyId => {
      return highestCompanyId === 1
    },
    userHasFeatureAccessLevel: state => (featureCode, accessCode) => {
      // this function only returns true if the user a specific access level to a feature (or is a system admin)
      return true
    }
  }
}
