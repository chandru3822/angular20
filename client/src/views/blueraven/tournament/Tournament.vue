<template>
  <v-container v-if="tournamentLoaded"
               :style="{'background-image': null != tournament.backgroundAttachmentPresignedUrl
                  ? `url(${tournament.backgroundAttachmentPresignedUrl})` : ''}"
               class="home-page home-background">

    <v-toolbar flat class="app-toolbar" height="56px">
      {{  tournament.tournamentName }}
      <v-spacer></v-spacer>
      <v-toolbar-items :slot="constants.IS_MOBILE ? 'extension' : 'default'">
        <v-tabs>
          <!--   todo: turn this into v-tabs in extension if constants.IS_MOBILE           -->
          <v-tab :to="`/tournament/${tournamentId}/qualifying`">
            Qualifying
          </v-tab>
          <v-tab :to="`/tournament/${tournamentId}/bracket`">
            Bracket
          </v-tab>
          <v-tab :to="`/tournament/${tournamentId}/lastChance`">
            Last Chance Pool
          </v-tab>
          <v-tab :to="`/tournament/${tournamentId}/winners`">
            Winners Pool
          </v-tab>
        </v-tabs>
      </v-toolbar-items>
    </v-toolbar>
    <router-view/>


  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'Tournament',
    data() {
      return {
        constants,
        snackbar: {},
        tournament: {},
        tournamentLoaded: false,
        tournamentId: this.$route.params.id
      }
    },
    watch: {
      // whenever tournament_id changes, this function will run
      '$route.params.id': function () {
        // reset the selected group when the object type changes
        this.tournamentId = this.$route.params.id
        this.tournament = {}
        this.getTournament()
      }
    },
    async created () {
      this.getTournament()
    },
    methods: {
      async getTournament() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/tournament/${this.tournamentId}`, 'blueraven')
          this.tournament = data
          document.title = this.tournament.tournamentName || 'Albatross'
          this.tournamentLoaded = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Tournament')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>
.home-page {
  padding: 0 !important;
  height: 100%;
  width: 100%;
}

.home-background {
  background-repeat: no-repeat;
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
}
</style>

