<template>
  <v-container id="postal-codes" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-btn text class="pl-1 pr-2" :to="'/settings/tournaments'">
          <v-icon>arrow_left</v-icon>
          <span>Back</span>
        </v-btn>
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">{{tournament.tournamentName}}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-btn text @click="edit = !edit">
            <v-icon>edit</v-icon>
          </v-btn>
        </v-toolbar>
        <v-card flat class="mt-2">
          <div>
            <v-text-field
              v-if="edit"
              label="Tournament Name"
              tabindex=1
              v-model="tournament.tournamentName"
            ></v-text-field>
            <v-autocomplete
              :readonly="!edit"
              :disabled="!edit"
              v-model="tournament.tournamentOwnerTypeId"
              :items="ownerTypes"
              label="Owner Type"
              item-text="ownerType"
              item-value="id"
            ></v-autocomplete>
            <DatetimePickerInput
              v-model="tournament.startDate"
              :readonly="!edit"
              :disabled="!edit"
              :timezone="this.timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="Start Date"
            />
            <DatetimePickerInput
              v-model="tournament.endDate"
              :readonly="!edit"
              :disabled="!edit"
              :timezone="this.timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="End Date"
            />
          </div>
          <div v-if="edit">
            <v-btn :disabled="!tournament.tournamentName || !tournament.startDate || !tournament.endDate || !tournament.tournamentOwnerTypeId" @click="updateTournament">Save</v-btn>
            <v-btn class="ml-2" @click="edit = false">Cancel</v-btn>
          </div>
        </v-card>
        <v-divider></v-divider>
        

      </v-col>

    </v-row>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import { getRequest, getRequestWithParams, deleteRequest, putRequest, postRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: 'TournamentAdmin',
    mixins: [Vue2Filters.mixin],
    components: {
      DatetimePickerInput
    },
    data () {
      return {
        snackbar: {},
        edit: false,
        tournament: {},
        ownerTypes: [],
        timezone: this.$store.state.user.details.timezone.value,
        tournamentId: this.$route.params.id,
        userId: this.$store.state.user.details.id,
      }
    },
    computed: {
    },
    methods: {
      async getTournamentOwnerTypes () {
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
    },
    async created () {
      this.getTournamentOwnerTypes()
      this.getTournament()
    }
  }
</script>

<style lang="scss">
</style>

<style scoped lang="scss">


</style>
