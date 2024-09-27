import pinia from '@/store'
import { useUserStore } from '@/stores/UserStore.js'

const userStore = useUserStore(pinia)

const settingsBeforeEnter = (to, from, next) => {
  if (!userStore.userHasFeature('SETTINGS') && !userStore.userHasFeatureAccessLevel('PARTS_MASTER', 'ADMIN')) {
    next({name: 'AccessDenied'})
  } else {
    next()
  }
}

export default {
  path: 'partsMaster',
  meta: {title: 'Albatross - Settings - Parts Master'},
  component: () => import( './PartsMasterVersions.vue'),
  children: [
    {
      name: 'partsMasterList',
      path: '',
      meta: {title: 'Albatross - Settings - Parts Master'},
      beforeEnter: settingsBeforeEnter,
      component: () => import( './PartsMasterList.vue'),
    },
    {
      name: 'partsMasterDetail',
      path: ':id',
      props: route => ({id: route.params.id}),
      meta: {title: 'Albatross - Settings - Parts Master'},
      beforeEnter: settingsBeforeEnter,
      component: () => import( './PartsMasterDetail.vue'),
    }
  ]
}

