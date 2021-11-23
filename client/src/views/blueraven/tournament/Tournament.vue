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
            {{ getPoolName(1) || 'Qualifying' }}
          </v-tab>
          <v-tab :to="`/tournament/${tournamentId}/bracket`">
            Bracket
          </v-tab>
          <v-tab :to="`/tournament/${tournamentId}/lastChance`">
            {{ getPoolName(2) || 'Last Chance'}}
          </v-tab>
          <v-tab :to="`/tournament/${tournamentId}/winners`">
            {{ getPoolName(3) || 'Winners'}}
          </v-tab>
        </v-tabs>
      </v-toolbar-items>
    </v-toolbar>
    <router-view/>


  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import moment from 'moment'

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
      '$route.params.id': async function () {
        // reset the selected group when the object type changes
        this.tournamentId = this.$route.params.id
        this.tournament = {}
        await this.getTournament()
        this.goToRoute()
      }
    },
    async created () {
      await this.getTournament()
      this.goToRoute()
    },
    methods: {
      goToRoute() {
        //
        if(this.$route.name === 'tournament') {
          //go to the tab that is currently in progress
          let qualifyingPool = this.tournament?.pools?.find(p => p.tournamentPoolTypeId === 1)
          let winnersPool = this.tournament?.pools?.find(p => p.tournamentPoolTypeId === 3)
          if( moment().isBetween(moment(qualifyingPool?.startDate), moment(qualifyingPool?.endDate))) {
            this.$router.push(`/tournament/${this.tournamentId}/qualifying`)
          } else if( moment().isAfter(moment(winnersPool?.startDate))) {
            this.$router.push(`/tournament/${this.tournamentId}/winners`)
            // this.$router.push({name: 'tournamentWinners', params: { id: this.tournament.id }})
          } else {
            this.$router.push(`/tournament/${this.tournamentId}/bracket`)
            // this.$router.push({name: 'tournamentBracket', params: { id: this.tournament.id }})
          }
        }
      },
      getPoolName(typeId) {
        return this.tournament?.pools?.find(p => p.tournamentPoolTypeId === typeId)?.customName
      },
      async getTournament() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/tournament/${this.tournamentId}`, 'blueraven')
          this.tournament = data
          document.title = this.tournament.tournamentName || 'Albatross'
          this.tournamentLoaded = true
          handleHidingGlobalLoader(this, status)
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

