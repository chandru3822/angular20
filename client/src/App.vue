<template>
  <v-app id="app">
    <ReloadPrompt v-if="vueInstance.$route.name !== 'login'"/>
    <AppNav v-if="!noNavRoutes.includes(vueInstance.$route.name) && !hideHeader"/>
    <v-main>
      <v-container
          class="router-container"
          :class="{ 'extra-banner': userIsMasquerading }"
      >
        <Spinner
            v-if="store.state.app.loading"
            spinnerColor="primary"
            :size="100"
        />
        <router-view class="router-view"/>
      </v-container>
    </v-main>
    <Snackbar/>
    <AnnouncementAlert/>
  </v-app>
</template>

<script setup>
import {AppMutations} from '@/stores/AppStore'
import AppNav from '@/components/AppNav'
import Snackbar from '@/components/Snackbar'
import Spinner from '@/components/Spinner'
import AnnouncementAlert from '@/components/AnnouncementAlert.vue'
import ReloadPrompt from '@/components/ReloadPrompt.vue'
import {NotificationActions} from '@/plugins/notifications/NotificationStore'
import {UserActions} from '@/stores/UserStore'

import {getCurrentInstance, onMounted, ref, computed, watch} from 'vue'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const router = vueInstance.$router

const hideHeader = ref(store.state.user.hideHeader || false)
const userIsMasquerading = ref(store.state.user?.details?.masqueradingUserId != null)
const userId = ref(store.state.user?.details?.id)
const noNavRoutes = ref([
  'login',
  'forgotPassword',
  'forgotPasswordReset',
  'resetPassword',
  'siteUnderMaintenance',
  'stripeSuccess'
])

const revokeAccessEvents = computed(() => {
  return store.getters
      .getEventsByTopic('revoke_access')
      ?.filter((e) => e.userId === userId.value)
})

watch(revokeAccessEvents, async () => {
      //will kick a user out immediately if their access is revoked (only works for web users)
      if (revokeAccessEvents.value?.length > 0) {
        await store.dispatch(UserActions.LOGOUT)
        //i tried dispatch after 'await' but it didn't work. dont know why
        router.push('/login').then(() => {
          store.dispatch(
              NotificationActions.PROCESS_REVOKE_ACCESS,
              userId.value
          )
        })
      }
    }
)

onMounted(() => {
  //set the theme which will use the default until one load from company
  store.commit(AppMutations.SET_INITIAL_THEME)
  vueInstance.$vuetify.theme.themes.light = store.state.app.theme
})
</script>

<style scoped lang="scss">
@media (min-width: 769px) {
  #app {
    .app-title {
      font-size: 35px;
    }
  }
}
</style>
<style lang="scss">
#app > div > header.app-link-header > div {
  height: 32px !important;
}
</style>
