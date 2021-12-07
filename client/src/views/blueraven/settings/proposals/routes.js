import store from '@/store'

const settingsBeforeEnter = (to, from, next) => {
  if (!store.getters.userHasFeature('SETTINGS')) {
    next({name: 'AccessDenied'})
  } else {
    next()
  }
}

export default {
  path: 'proposals',
  meta: {title: 'Albatross - Settings - Proposals'},
  component: () => import(/* webpackChunkName: "proposalVersions" */ './ProposalVersions'),
  children: [
    {
      name: 'proposalList',
      path: '',
      meta: {title: 'Albatross - Settings - Proposals'},
      beforeEnter: settingsBeforeEnter,
      component: () => import(/* webpackChunkName: "proposalVersions" */ './ProposalList'),
    },
    {
      name: 'proposalDetail',
      path: ':id',
      props: route=>({ id : route.params.id }),
      meta: {title: 'Albatross - Settings - Proposals'},
      beforeEnter: settingsBeforeEnter,
      component: () => import(/* webpackChunkName: "proposalVersions" */ './ProposalDetail'),
    }
  ]
}

