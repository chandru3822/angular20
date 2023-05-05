import store from '@/store'

export default class Smartlist {

  /**
   * Determine if current user can edit given smartlist
   *
   * Current user can view/edit smartlist if:
   *  1) user is owner
   *  2) user is smartlist or system admin
   *  3) smartlist is shared (with edit access) with user's primary position
   *  4) smartlist is shared (with edit access) with an org containing user's primary position
   *
   * @param smartlist
   * @param checkEditAccess
   * @returns boolean
   */
  static #isSharedWithCurrentUser (smartlist, checkEditAccess) {
    if (!smartlist || !smartlist.ownerId || !smartlist.accessControl || smartlist.accessControl.length === 0) {
      return false
    }

    const isOwner = smartlist.ownerId === store.state.user.details.id
    if (isOwner) {
      return true
    }

    const isAdmin = store.getters.userHasFeatureAccessLevel('SMARTLIST', 'ADMIN') ||
                    store.getters.isFullAdmin

    if (isAdmin) {
      return true
    }

    const primaryPositions = store.state.user.details.userPositions.filter(p => p.primaryFlag === true)

    //check access by user position first since it takes priority over org
    const userPositionIds = primaryPositions.map(p => p.id)
    let hasAccess = smartlist.accessControl.some(a => {
      if (a.isUser) {
        const isMatch = userPositionIds.find(p => p === a.userPositionId)

        if (checkEditAccess) {
          return isMatch && a.accessControlId === 2
        } else {
          return isMatch
        }
      }

      return false
    })

    if (!hasAccess) {
      const orgIds = primaryPositions.map(p => p.orgId)
      hasAccess = smartlist.accessControl.some(a => {
        if (a.isOrg) {
          const isMatch = orgIds.find(p => p === a.orgId)

          if (checkEditAccess) {
            return isMatch && a.accessControlId === 2
          } else {
            return isMatch
          }
        }

        return false
      })
    }

    return hasAccess
  }

  static userCanView(smartlist) {
    return this.#isSharedWithCurrentUser(smartlist, false)
  }

  static userCanEdit(smartlist) {
    return this.#isSharedWithCurrentUser(smartlist, true)
  }
}