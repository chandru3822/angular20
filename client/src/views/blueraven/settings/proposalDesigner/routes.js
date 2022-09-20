export default {
  name: 'proposalDesigner',
  path: 'proposalDesigner',
  meta: { title: 'Albatross - Proposal Designer' },
  component: () =>
    import(/* webpackChunkName: "proposalDesigner" */ './ProposalDesigner.vue')
}
