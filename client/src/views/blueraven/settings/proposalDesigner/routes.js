import { pinia } from '@/store'
import { useUserStore } from '@/stores/UserStore.js'

const userStore = useUserStore(pinia)

export default {
  name: 'proposalDesigner',
  path: 'proposalDesigner',
  meta: { title: 'Albatross - Proposal Designer' },
  component: () => import('./ProposalDesigner.vue'),
  beforeEnter: (to, from, next) => {
    if (!userStore.userHasFeatureAccessLevel('PROPOSALS', 'ADMIN')) {
      next({ name: 'AccessDenied' })
    } else {
      next()
    }
  }
}
