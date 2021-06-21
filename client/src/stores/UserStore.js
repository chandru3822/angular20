import {postRequest} from "@/helpers/helpers"
import moment from "moment-timezone";

export const UserActions = {
  LOGIN_SUCCESS: 'loginSuccess',
  CHANGE_CONTEXT: 'changeContext',
  LOGOUT: 'logout',
  CHANGE_TIMEZONE: 'changeTimezone',
}

export const UserMutations = {
  SET_JWT: 'setJwt',
  AUTH_STATUS: 'authStatus',
  LOGIN_ERROR: 'setLoginError',
  INIT: 'storeInt',
  SET_DETAILS: 'setDetails',
  SET_USER_IMAGE: 'setUserImage',
  SET_COMPANIES: 'setCompanies',
  RESET_STATE: 'resetState'
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
    [UserMutations.SET_COMPANIES]: (state, companies) => (state.companies = companies),
    [UserMutations.RESET_STATE]: (state) => (Object.assign(state, {
      authorized: false,
      jwt: null,
      loginError: null,
      details: {},
      userImage: {},
      companies: []
    })),
  },
  actions: {
    [UserActions.CHANGE_TIMEZONE]: async ({ commit, getters, state }, timezone) => {
      state.details.timezone = timezone
      //todo: date/time inputs don't update when the zone is changed. should we refresh?
      commit(UserMutations.SET_DETAILS, state.details)
    },
    [UserActions.LOGIN_SUCCESS]: async ({ commit, getters }, details) => {
      commit(UserMutations.LOGIN_ERROR, '')
      //pls fix the undefined timezone issue!
      if(!details.timezone) {
        details.timezone = {
          friendlyValue: moment.tz.guess(),
          value: moment.tz.guess()
        }
      }
      commit(UserMutations.SET_DETAILS, details)

      if (getters.userHasAnyFeature) {
        commit(UserMutations.AUTH_STATUS, true)
      } else {
        commit(
          UserMutations.LOGIN_ERROR,
          'You do not have permission to access this app.'
        )
      }
    },
    [UserActions.CHANGE_CONTEXT]: async ({ commit, getters, state }, params) => {
      //change context
      const {data} = await postRequest(`/user/changeContext/${params.companyId}`)

      //update vuex store - user details
      await commit(UserMutations.SET_DETAILS, data)

      //refresh entire app and go to users home page if they have one
      if(data.homePagePath) {
        window.location.href = data.homePagePath
      } else {
        window.location.href = '/'
      }
    },
    [UserActions.LOGOUT]: ({ commit }) => {
      localStorage.removeItem('store')
      commit(UserMutations.RESET_STATE)
    }
  },
  getters: {
    userHasAnyFeature: state => {
      // this function returns true if the user has any access level for any feature -
      // or if the user is a system admin
      return UserStore.getters.isSystemAdmin(state.details.highestCompanyId) || state.details.featureAccess?.length > 0
    },
    userHasFeature: (state, getters) => featureCode => {
      // this function returns true if the user has any access level (edit, view, etc)
      // or if the user is a system admin (send 'SYSTEM' as the feature code if you only care it is a system admin)
      return getters.isSystemAdmin(state.details.highestCompanyId) || (state.details.featureAccess?.length > 0 && state.details.featureAccess.some(fa => fa.featureCode === featureCode))
    },
    isFullAdmin: state => {
      // 1 is the master company id
      return state.details.highestCompanyId === 1
    },
    isParent: state => parentId => {
      // is albatross or parentId is null (no longer checking for parentId is null due to single context)
      return parentId === 1
    },
    isCompanyRoot: state => companyId => {
      return companyId === 1
    },
    isSystemAdmin: state => highestCompanyId => {
      return highestCompanyId === 1
    },
    userHasFeatureAccessLevel: (state, getters) => (featureCode, accessCode) => {
      // this function only returns true if the user a specific access level to a specific feature (or is a system admin)
      let hasFeatureAccessLevel = false
      if(state.details.featureAccess?.length > 0 ) {
        let featureMatch = state.details.featureAccess.find(fa => fa.featureCode === featureCode && fa.accessCode === accessCode)
        hasFeatureAccessLevel = featureMatch !== null && featureMatch !== undefined
      }
      return getters.isSystemAdmin(state.details.highestCompanyId) || hasFeatureAccessLevel
    },
    userHasPosition: (state, getters) => positionId => {
      // this function returns true if the any of the user's positions match the id sent in
      // or if the user is a system admin??? maybe take this out later?
      return getters.isSystemAdmin(state.details.highestCompanyId) || state.details.userPositions?.some(p => p.positionId === positionId)
    },
    userHasAnyPosition: (state, getters) => positionIds => {
      // this function returns true if the any of the user's positions match any of the ids sent in
      return getters.isSystemAdmin(state.details.highestCompanyId) || state.details.userPositions?.some(p => {
        return positionIds.includes(p.positionId)
      })
    }
  }
}
