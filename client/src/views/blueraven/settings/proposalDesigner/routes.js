import store from '@/store'

export default {
  name: 'proposalDesigner',
  path: 'proposalDesigner',
  meta: { title: 'Albatross - Proposal Designer' },
  component: () =>
    import(/* webpackChunkName: "proposalDesigner" */ './ProposalDesigner.vue'),
  beforeEnter: (to, from, next) => {
    if (!store.getters.userHasFeatureAccessLevel('PROPOSALS', 'ADMIN')) {
      next({ name: 'AccessDenied' })
    } else {
      next()
    }
  }
}
