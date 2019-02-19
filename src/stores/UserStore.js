export const UserActions = {
  LOGIN_SUCCESS: 'loginSuccess',
  LOGOUT: 'logout'
}

export const UserMutations = {
  SET_JWT: 'setJwt',
  AUTH_STATUS: 'authStatus',
  LOGIN_ERROR: 'setLoginError',
  INIT: 'storeInt',
  SET_DETAILS: 'setDetails'
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
    [UserMutations.SET_DETAILS]: (state, details) =>
      (state.details = details)
  },
  actions: {
    [UserActions.LOGIN_SUCCESS]: async ({ commit, getters }, details) => {
      commit(UserMutations.LOGIN_ERROR, '')

      commit(UserMutations.SET_DETAILS, details)

      if (getters.hasPermission) {
        commit(UserMutations.AUTH_STATUS, true)
      } else {
        commit(
          UserMutations.LOGIN_ERROR,
          'You do not have permission to access this app.'
        )
      }
    },
    [UserActions.LOGOUT]: ({ commit }) => {
      localStorage.removeItem('store')
    }
  },
  getters: {
    hasPermission: state => {
      return state.details && state.details.permissions
        ? !!state.details.permissions.find(p => p.permissionCode === 'HR_ADMIN')
        : false
    }
  }
}
