import store from '@/store'

const settingsBeforeEnter = (to, from, next) => {
  if (!store.getters.userHasFeature('SETTINGS') && !store.getters.userHasFeatureAccessLevel('PROPOSALS', 'ADMIN')) {
    next({name: 'AccessDenied'})
  } else {
    next()
  }
}

export default {
  path: 'proposals',
  meta: {title: 'Albatross - Settings - Proposals'},
  component: () => import( './ProposalVersions.vue'),
  children: [
    {
      name: 'proposalList',
      path: '',
      meta: {title: 'Albatross - Settings - Proposals'},
      beforeEnter: settingsBeforeEnter,
      component: () => import( './ProposalList.vue'),
    },
    {
      name: 'proposalDetail',
      path: ':id',
      props: route => ({id: route.params.id}),
      meta: {title: 'Albatross - Settings - Proposals'},
      beforeEnter: settingsBeforeEnter,
      component: () => import( './ProposalDetail.vue'),
    }
  ]
}

