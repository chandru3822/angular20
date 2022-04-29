export default {
  path: 'proposalDesigner',
  meta: { title: 'Albatross - Settings - Proposal Designer' },
  component: () =>
    import(/* webpackChunkName: "proposalDesigner" */ './ProposalDesigner')
}
