<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="wqt-header-bar">
          <v-toolbar-title class="app-title">Pool</v-toolbar-title>
        </v-toolbar>

      </v-col>

    </v-row>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {
    getRequest,
    getRequestWithParams,
    deleteRequest,
    putRequest,
    postRequest,
    getSnackbar
  } from '@/helpers/helpers'

  export default {
    name: 'PoolAdmin',
    mixins: [Vue2Filters.mixin],
    components: {
      DatetimePickerInput
    },
    data() {
      return {
        snackbar: {},
        edit: false,
        rerenderKey: 0,
        validNumUsers: [2, 4, 8, 16, 32, 64, 128],
        bracketRerenderKey: 0,
        tournament: {},
        newBracket: {},
        addBracket: false,
        bracketError: false,
        bracketErrorMsg: '',
        newRound: {},
        timezone: this.$store.state.user.details.timezone.value,
        addRound: false,
        ownerTypes: [],
        tournamentId: this.$route.params.id,
        userId: this.$store.state.user.details.id,
        headers: [
          {text: 'Round', value: 'roundNumber', show: true},
          {text: 'Start Date', value: 'startDate', show: true},
          {text: 'End Date', value: 'endDate', show: true},
          {text: null, value: 'icons', show: true}
        ]
      }
    },
    computed: {},
    methods: {
      async getTournamentOwnerTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/tournament/ownerTypes`, 'blueraven')
          this.ownerTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.dataLoading = false
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getTournament() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/tournament/${this.tournamentId}`, 'blueraven')
          this.tournament = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Tournament')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async updateTournament() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/tournament`, this.tournament, 'blueraven')
          this.tournament = data
          this.edit = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Tournament')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addNewBracket() {
        if(this.validNumUsers.includes(this.newBracket.numberOfUsers)) {
          this.bracketError = false
          this.bracketErrorMsg = ''
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            let param = {
              numberOfUsers: this.newBracket.numberOfUsers,
              tournamentId: this.tournament.id
            }
            const {data} = await postRequest(`/tournament/bracket`, param, 'blueraven')
            this.tournament.brackets.push(data)
            this.addBracket = false
            this.newBracket = {}
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Saving Tournament')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } else {
          this.bracketError = true
          this.bracketErrorMsg = 'Number of Users must be 2, 4, 8, 16, 32, 64, or 128'
        }
      },
      async deleteBracket(id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/tournament/bracket/${id}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Bracket Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Bracket')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveRound(bracket, round) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let param = {
            id: round?.id,
            tournamentBracketId: bracket.id,
            startDate: round.startDate,
            endDate: round.endDate
          }
          const {data} = await putRequest(`/tournament/round`, param, 'blueraven')
          bracket.rounds = data.rounds
          if (round.id) {
            round.edit = false
          } else {
            bracket.addRound = false
            this.newRound = {}
          }
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Round')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteRound(bracket, roundId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let param = {
            id: roundId,
            tournamentBracketId: bracket.id
          }
          const {data} = await putRequest(`/tournament/round/${roundId}/delete`, param, 'blueraven')
          bracket.rounds = data.rounds
          this.snackbar = getSnackbar('SUCCESS', 'Round Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Round')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async generateMatches(bracket) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequest(`/tournament/bracket/${bracket.id}/generateMatches`, {}, 'blueraven')
          bracket.matchesGenerated = true
          this.snackbar = getSnackbar('SUCCESS', 'Matches Generated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Generating Matches')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterRounds(bracket) {
        return bracket?.rounds.filter(r => {
          return !r.archived
        })
      },
    },
    async created() {
      this.getTournamentOwnerTypes()
      this.getTournament()
    }
  }
</script>

<style lang="scss">
</style>

<style scoped lang="scss">


</style>
