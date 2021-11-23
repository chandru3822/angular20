<template>
  <v-container id="tournament-admin-container" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Tournaments</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newTournament = {}]" v-if="userCanAdd">
              {{'Add New'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card color="transparent" flat v-if="addNew" class="mb-2">
            <v-text-field
                label="Tournament Name"
                tabindex=1
                v-model="newTournament.tournamentName"
            ></v-text-field>
            <v-autocomplete
              v-model="newTournament.tournamentOwnerTypeId"
              :items="ownerTypes"
              label="Owner Type"
              @change="getTournamentFormulas()"
              item-text="ownerType"
              item-value="id"
              attach
            ></v-autocomplete>
            <v-autocomplete
              v-model="newTournament.tournamentFormulaId"
              :items="formulas"
              label="Scoring Formula"
              item-text="formulaTitle"
              item-value="id"
              attach
            ></v-autocomplete>
            <DatetimePickerInput
              v-model="newTournament.startDate"
              :timezone="this.timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="Start Date"
            />
            <DatetimePickerInput
              v-model="newTournament.endDate"
              :timezone="this.timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="End Date"
            />
            <v-btn :disabled="!newTournament.tournamentName || !newTournament.startDate || !newTournament.endDate || (newTournament.startDate >= newTournament.endDate) || !newTournament.tournamentOwnerTypeId || !newTournament.tournamentFormulaId" @click="addTournament">Save</v-btn>
            <v-btn class="ml-2" @click="[newTournament = {}, addNew = false]">Cancel</v-btn>
          </v-card>
          <v-divider v-if="addNew"></v-divider>
          <v-card class="square-card">
            <v-data-table
              :headers="headers"
              :items="filterTournaments()"
              :fixed-header="true"
              :items-per-page="100"
              disable-sort
              :loading="dataLoading"
              class="elevation-1 round-robin-table"
            >
              <template #item="{ item, index }">
                <tr :class="{'shaded-row': index % 2}">
                  <td class="text-left clickable" @click="goToTournament(item.id)">{{item.tournamentName}}</td>
                  <td class="text-left clickable" @click="goToTournament(item.id)">{{item.startDate | formatDate('date', 'M/D/YYYY')}}</td>
                  <td class="text-left clickable" @click="goToTournament(item.id)">{{item.endDate | formatDate('date', 'M/D/YYYY')}}</td>
                  <td class="text-left clickable" @click="goToTournament(item.id)">
                    <input type="checkbox" v-model="item.active" readonly disabled>
                  </td>
                  <td class="text-right">
                    <v-btn small text @click="goToTournament(item.id)">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <v-dialog
                      v-if="userCanDelete"
                      v-model="item.deleteConfirm"
                      width="500">
                      <template v-slot:activator="{ on }">
                        <v-btn small text v-on="on">
                          <v-icon>delete</v-icon>
                        </v-btn>
                      </template>
                      <v-card>
                        <v-card-title
                          class="headline grey lighten-2"
                          primary-title
                        >
                          Confirm
                        </v-card-title>

                        <v-card-text>
                          Are you sure you want to delete this tournament: <strong>{{ item.tournamentName }}</strong>?
                        </v-card-text>

                        <v-divider></v-divider>

                        <v-card-actions>
                          <v-spacer></v-spacer>
                          <v-btn
                            @click="item.deleteConfirm = false">
                            No
                          </v-btn>
                          <v-btn
                            color="primaryCustom"
                            text
                            @click="[item.archived = true, deleteTournament(item.id)]">
                            Yes
                          </v-btn>
                        </v-card-actions>
                      </v-card>
                    </v-dialog>
                  </td>

                </tr>
              </template>
            </v-data-table>
          </v-card>
        </v-container>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import { handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: 'TournamentsAdmin',
    mixins: [Vue2Filters.mixin],
    components: {
      DatetimePickerInput
    },
    data () {
      return {
        snackbar: {},
        addNew: false,
        search: null,
        newTournament: {},
        timezone: this.$store.state.user.details.timezone.value,
        dataLoading: true,
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('TOURNAMENTS', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('TOURNAMENTS', 'EDIT'),
        userCanDelete: this.$store.getters.userHasFeatureAccessLevel('TOURNAMENTS', 'DELETE'),
        companyId: this.$store.state.user.details.companyId,
        userId: this.$store.state.user.details.id,
        tournaments: [],
        ownerTypes: [],
        formulas: [],
        headers: [
          {text: 'Tournament', value: 'tournamentName', show: true},
          {text: 'Start', value: 'startDate', show: true},
          {text: 'End', value: 'endDate', show: true},
          {text: 'Active', value: 'active', show: true},
          {text: '', value: 'icons', show: true},
        ]
      }
    },
    computed: {
    },
    methods: {
      filterTournaments () {
        return this.tournaments.filter(t => { return !t.archived})
      },
      goToTournament(id) {
        this.$router.push({path: `/settings/tournaments/${id}/details`})
      },
      async getTournamentFormulas() {
        this.newTournament.tournamentFormulaId = null
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/tournament/formulas/${this.newTournament.tournamentOwnerTypeId}`, 'blueraven')
          this.formulas = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.dataLoading = false
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getTournamentOwnerTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/tournament/ownerTypes`, 'blueraven')
          this.ownerTypes = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.dataLoading = false
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getTournaments () {
        this.dataLoading = true
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/tournament`, 'blueraven')
          this.tournaments = data
          this.dataLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.dataLoading = false
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteTournament (id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/tournament/${id}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Tournament Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Tournament')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addTournament () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/tournament`, this.newTournament, 'blueraven')
          this.$router.push({path: `/settings/tournaments/${data.id}/details`})
          this.snackbar = getSnackbar('SUCCESS', 'Tournament Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Tournament')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    },
    async created () {
      this.getTournaments()
      this.getTournamentOwnerTypes()
    }
  }
</script>

<style lang="scss">
  #tournament-admin-container .v-data-table__wrapper {
    max-height: calc(100vh - 250px);
    min-height: 300px;
  }
</style>
