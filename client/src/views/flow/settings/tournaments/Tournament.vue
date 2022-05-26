<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-btn text class="pl-1 pr-2" :to="'/settings/tournaments'">
          <v-icon>arrow_left</v-icon>
          <span>Back</span>
        </v-btn>
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">{{tournament.tournamentName}}</v-toolbar-title>
        </v-toolbar>
        <v-tabs class="tabs-bar">
          <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path"
                 class="text-capitalize ma-0"
                 :style="{'margin-left': index === 0 ? '12px !important' : '0'}">
            {{ tab.label }}
          </v-tab>
        </v-tabs>

        <router-view/>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {
    handleHidingGlobalLoader,
    getRequest,
    getSnackbar
  } from '@/helpers/helpers'

  export default {
    name: 'TournamentAdmin',
    data() {
      return {
        snackbar: {},
        tournament: {},
        timezone: this.$store.state.user.details.timezone.value,
        tournamentId: parseInt(this.$route.params.id),
        userId: this.$store.state.user.details.id,
        tabs: [
          {
            label: 'Details',
            path: `/settings/tournaments/${this.$route.params.id}/details`,
          },
          {
            label: 'Brackets',
            path: `/settings/tournaments/${this.$route.params.id}/brackets`,
          },
          {
            label: 'Qualifying',
            path: `/settings/tournaments/${this.$route.params.id}/pool/1`,
          },
          {
            label: 'Last Chance',
            path: `/settings/tournaments/${this.$route.params.id}/pool/2`,
          },
          {
            label: 'Winner',
            path: `/settings/tournaments/${this.$route.params.id}/pool/3`,
          }
        ]
      }
    },
    computed: {},
    methods: {
      async getTournament() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/tournament/${this.tournamentId}`, 'blueraven')
          this.tournament = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Tournament')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    },
    async created() {
      this.getTournament()
    }
  }
</script>

<style scoped lang="scss">
  .tabs-bar {
    top: -12px;
    border-top: 1px solid #E6E6E6;
    border-bottom: 1px solid #E6E6E6;
    .v-tab:hover {
      color: var(--v-primary-base);
    }
  }
</style>
