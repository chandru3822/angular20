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
            v-if="appStore.loading"
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
import AppNav from '@/components/AppNav'
import Snackbar from '@/components/Snackbar'
import Spinner from '@/components/Spinner'
import AnnouncementAlert from '@/components/AnnouncementAlert.vue'
import ReloadPrompt from '@/components/ReloadPrompt.vue'
import {getCurrentInstance, onMounted, ref, computed, watch} from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStorePinia.js'
import theme from '@/helpers/defaultTheme.js'
import { useNotificationStore } from '@/stores/NotificationStorePinia.js'
import cloneDeep from 'lodash.clonedeep'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const router = vueInstance.$router
const userStore = useUserStore()
const appStore = useAppStore()
const notificationStore = useNotificationStore()

// In moving this from vuex to pinia, I noticed `hideHeader` never exists in
// the user store. Still keeping this logic here though in case of a breaking
// change I can't see right now
const hideHeader = ref(userStore.hideHeader || false)
const userIsMasquerading = ref(userStore?.details?.masqueradingUserId != null)
const noNavRoutes = ref([
  'login',
  'forgotPassword',
  'forgotPasswordReset',
  'resetPassword',
  'siteUnderMaintenance',
  'stripeSuccess'
])

const userId = computed(() => {
  return userStore.details.id
})

const revokeAccessEvents = computed(() => {
  return notificationStore.getEventsByTopic('revoke_access')?.filter((e) => e.userId === userId.value)
})

watch(revokeAccessEvents, async () => {
      //will kick a user out immediately if their access is revoked (only works for web users)
      if (revokeAccessEvents.value?.length > 0) {
        userStore.logout()
        //i tried dispatch after 'await' but it didn't work. dont know why
        router.push('/login').then(() => {
          notificationStore.processRevokeAccess(userId.value)
        })
      }
    }
)

onMounted(() => {
  //set the theme which will use the default until one load from company
  appStore.theme = cloneDeep(theme.LIGHT)
  vueInstance.$vuetify.theme.themes.light = cloneDeep(theme.LIGHT)
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
