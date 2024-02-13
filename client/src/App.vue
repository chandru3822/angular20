<template>
  <v-app id="app">
    <ReloadPrompt v-if="$route.name !== 'login'" />
    <AppNav v-if="!noNavRoutes.includes($route.name) && !hideHeader" />
    <v-main>
      <v-container
        class="router-container"
        :class="{ 'extra-banner': userIsMasquerading }"
      >
        <Spinner
          v-if="$store.state.app.loading"
          spinnerColor="primary"
          :size="100"
        />
        <router-view class="router-view" />
      </v-container>
    </v-main>
    <Snackbar />
    <AnnouncementAlert />
  </v-app>
</template>

<script>
import { AppMutations } from '@/stores/AppStore'
import AppNav from '@/components/AppNav'
import Snackbar from '@/components/Snackbar'
import Spinner from '@/components/Spinner'
import AnnouncementAlert from '@/components/AnnouncementAlert.vue'
import ReloadPrompt from '@/components/ReloadPrompt.vue'
import { NotificationActions } from '@/plugins/notifications/NotificationStore'
import { UserActions } from '@/stores/UserStore'

export default {
  name: 'App',
  components: {
    AppNav,
    Snackbar,
    AnnouncementAlert,
    Spinner,
    ReloadPrompt
  },
  data() {
    return {
      hideHeader: this.$store.state.user.hideHeader || false,
      userIsMasquerading:
        this.$store.state.user?.details?.masqueradingUserId != null,
      userId: this.$store.state.user?.details?.id,
      noNavRoutes: [
        'login',
        'forgotPassword',
        'forgotPasswordReset',
        'resetPassword',
        'siteUnderMaintenance',
        'stripeSuccess'
      ]
    }
  },
  watch: {
    revokeAccessEvents: async function () {
      //will kick a user out immediately if their access is revoked (only works for web users)
      if (this.revokeAccessEvents?.length > 0) {
        await this.$store.dispatch(UserActions.LOGOUT)
        //i tried dispatch after 'await' but it didn't work. dont know why
        this.$router.push('/login').then(() => {
          this.$store.dispatch(
            NotificationActions.PROCESS_REVOKE_ACCESS,
            this.userId
          )
        })
      }
    }
  },
  computed: {
    revokeAccessEvents() {
      return this.$store.getters
        .getEventsByTopic('revoke_access')
        ?.filter((e) => e.userId === this.userId)
    }
  },
  created() {
    //set the theme which will use the default until one load from company
    this.$store.commit(AppMutations.SET_INITIAL_THEME)
    this.$vuetify.theme.themes.light = this.$store.state.app.theme
  }
}
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
