import store from '@/store'

export default class Smartlist {

  /**
   * Determine if current user can edit given smartlist
   *
   * Current user can edit smartlist if smartlist is shared (with edit access) with user's primary position or an org containing user's primary position
   *
   * @param smartlist
   * @returns boolean
   */
  static userCanEdit(smartlist) {
    const primaryPositions = store.state.user.details.userPositions.filter(p => p.primaryFlag === true)

    const userPositionIds = primaryPositions.map(p => p.id)
    const orgIds = primaryPositions.map(p => p.orgId)

    return smartlist.accessControl.some(a => {
      if (a.isUser) {
        return userPositionIds.some(p => p === a.userPositionId && a.accessControlId === 2)
      } else if (a.isOrg) {
        return orgIds.some(o => o === a.orgId && a.accessControlId === 2)
      }

      return false
    })
  }
}