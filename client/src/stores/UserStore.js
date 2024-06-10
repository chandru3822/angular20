import { defineStore } from 'pinia'
import moment from 'moment-timezone'
import { postRequest } from '@/helpers/helpers.js'

const defaultState = {
  authorized: false,
  jwt: null,
  loginError: '',
  details: null,
  userImage: {},
  companies: [],
  settingsMenuCollapsed: false
}

export const useUserStore = defineStore('user', {
  persist: true,
  state: () => ({...defaultState}),
  getters: {
    isSystemAdmin() {
      return this.details?.highestCompanyId === 1
    },
    //Keeping this for compatability with the move from vuex. But, pretty sure this functionality is superfluous
    isCompanyRoot() {
      return this.details?.companyId === 1
    },
    isParent() {
      // is albatross or parentId is null (no longer checking for parentId is null due to single context)
      return this.details?.parentCompanyId === 1
    },
    userHasAnyFeature() {
      // this function returns true if the user has any access level for any feature -
      // or if the user is a system admin
      return this.isSystemAdmin || this.details?.featureAccess?.length > 0
    },
    timezone() {
      if (!this.details?.timezone) {
        this.guessTimeZone()
      }

      return this.details.timezone
    }
  },
  actions: {
    guessTimeZone() {
      //pls fix the undefined timezone issue!
      //also trying to fix a "Cannot set properties of null (setting 'timezone')" error
      if(this.details && !this.details?.timezone) {
        this.details.timezone = {
          friendlyValue: moment.tz.guess(),
          value: moment.tz.guess()
        }
      }
    },
    async login(details) {
      this.loginError = ''

      this.details = details

      if(!this.details?.timezone) {
        this.guessTimeZone()
      }

      if (this.userHasAnyFeature) {
        this.authorized = true
      } else {
        this.loginError = 'You do not have permission to access this app.'
      }
    },
    logout() {
      this.$patch(defaultState)
    },
    async changeContext(params) {
      const {data} = await postRequest(`/user/changeContext/${params.companyId}`)

      this.details = data

      //refresh entire app and go to users home page if they have one
      if(data.homePagePath) {
        window.location.href = data.homePagePath
      } else {
        window.location.href = '/'
      }
    },
    // Maybe these shouldn't actually be an action since it's kind of a getter?
    // Technically you can't pass getters params unless you use `storeToRefs` which
    // has other issues
    userHasFeature(featureCode) {
      // this function returns true if the user has any access level (edit, view, etc)
      // or if the user is a system admin (send 'SYSTEM' as the feature code if you only care it is a system admin)
      return this.isSystemAdmin || this.details?.featureAccess?.some(fa => fa.featureCode === featureCode)
    },
    userHasFeatureAccessLevel(featureCode, accessCode) {
      // this function only returns true if the user a specific access level to a specific feature (or is a system admin)
      if (this.isSystemAdmin) {
        return true
      }

      let hasFeatureAccessLevel = false
      if(this.details?.featureAccess?.length > 0 ) {
        let featureMatch = this.details.featureAccess.find(fa => fa.featureCode === featureCode && fa.accessCode === accessCode)
        hasFeatureAccessLevel = featureMatch !== null && featureMatch !== undefined
      }
      return hasFeatureAccessLevel
    },
    userHasAnyPosition(positionIds) {
      // this function returns true if the any of the user's positions match any of the ids sent in
      return this.isSystemAdmin || this.details?.userPositions?.some(p => {
        return positionIds.includes(p.positionId)
      })
    }
  }
})

