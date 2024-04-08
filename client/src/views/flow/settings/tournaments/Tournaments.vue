<template>
  <v-container id="tournament-admin-container" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Tournaments</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                :text="showPreviousYears ? 'HIDE PREVIOUS YEARS' : 'SHOW PREVIOUS YEARS'"
                @click="showPreviousYears = !showPreviousYears">
            </a-btn>

            <a-btn
                variant="text"
                color="primary"
                v-if="userCanAdd"
                text="ADD NEW"
                @click="[addNew = !addNew, newTournament = { tournamentFormulaFields: [] }]">
            </a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card color="transparent" flat v-if="addNew" class="mb-2">
            <a-text-field
                label="Tournament Name"
                tabindex=1
                v-model="newTournament.tournamentName"
            ></a-text-field>
            <v-autocomplete
              v-model="newTournament.tournamentOwnerTypeId"
              :items="ownerTypes"
              label="Owner Type"
              @change="getTournamentFormulas()"
              item-text="ownerType"
              item-value="id"
              :attach="true"
            ></v-autocomplete>
            <v-autocomplete
              v-model="newTournament.tournamentFormulaId"
              :items="formulas"
              label="Scoring Formula"
              item-text="formulaTitle"
              item-value="id"
              :attach="true"
              @change="getTournamentFormulaFields"
            ></v-autocomplete>

            <div v-if="newTournament.tournamentFormulaFields && newTournament.tournamentFormulaFields.length > 0"
                 v-for="tff in newTournament.tournamentFormulaFields">
              <TournamentCustomField
                :field="tff"
                :callback="() => {}">
              </TournamentCustomField>

            </div>
            <DatetimePickerInput
              v-model="newTournament.startDate"
              :timezone="timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="Start Date"
            />
            <DatetimePickerInput
              v-model="newTournament.endDate"
              :timezone="timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="End Date"
            />
            <a-btn
                color="primary"
                :disabled="!newTournament.tournamentName || !newTournament.startDate || !newTournament.endDate
                   || (newTournament.startDate >= newTournament.endDate) || !newTournament.tournamentOwnerTypeId || !newTournament.tournamentFormulaId
                   || validateCustomFields()"
                text="Save"
                @click="addTournament">
            </a-btn>
            <a-btn
                variant="text"
                color="primary"
                text="Cancel"
                class="ml-2"
                @click="[newTournament = { tournamentFormulaFields: [] }, addNew = false]">
            </a-btn>
          </v-card>
          <v-divider v-if="addNew"></v-divider>
          <v-card class="square-card">
            <v-data-table id="tournaments-table"
                :headers="headers"
                :items="filterTournaments()"
                :fixed-header="true"
                :items-per-page="100"
                :loading="dataLoading"
                class="elevation-1 round-robin-table table-striped"
            >
              <template #item.tournamentName="{item}" class="text-left clickable">
                <router-link :to="`${goToTournament(item.id)}`" class="router-link-td elevation-0">
                  {{item.tournamentName}}
                </router-link>
              </template>
              <template #item.startDate="{item}" class="text-left clickable">
                <router-link :to="`${goToTournament(item.id)}`" class="router-link-td elevation-0">
                  {{item.startDate | formatDate('date', 'M/D/YYYY')}}
                </router-link>
              </template>
              <template #item.endDate="{item}" class="text-left clickable">
                <router-link :to="`${goToTournament(item.id)}`" class="router-link-td elevation-0">
                  {{item.endDate | formatDate('date', 'M/D/YYYY')}}
                </router-link>
              </template>
              <template #item.active="{item}" class="text-left clickable">
                <router-link :to="`${goToTournament(item.id)}`" class="router-link-td elevation-0">
                  <input type="checkbox" v-model="item.active" readonly disabled>
                </router-link>
              </template>
              <template #item.icons="{item}" class="text-right">
                <a-btn
                    :size="$vuetify.breakpoint.smAndDown ? 'large' : 'small'"
                    icon
                    color="primary"
                    prepend-icon="edit"
                    @click="router.push(goToTournament(item.id))  ">
                </a-btn>

                <a-btn
                    v-if="userCanDelete"
                    size="small"
                    variant="text"
                    color="primary"
                    prepend-icon="delete"
                    @click="tournamentToDelete=item">
                </a-btn>
              </template>

            </v-data-table>
          </v-card>
          <ConfirmationDialog :open-dialog="!!tournamentToDelete" @confirm="[tournamentToDelete.archived = true, deleteTournament()]" @close-dialog="tournamentToDelete=null">
            Are you sure you want to delete this tournament: <strong>{{tournamentToDeleteName}}</strong>?
          </ConfirmationDialog>
        </v-container>
      </v-col>

    </v-row>
  </v-container>
</template>

<script setup>

  import moment from 'moment'

  import orderBy from 'lodash.orderby'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import { handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import TournamentCustomField from '@/views/flow/settings/tournaments/TournamentCustomField.vue'
  import ConfirmationDialog from '@/components/ConfirmationDialog'
  import {computed, getCurrentInstance, onMounted, ref} from 'vue'
  import {useRouter} from 'vue-router/composables'
  import { useUserStore } from '@/stores/UserStorePinia.js'
  import { useAppStore } from '@/stores/AppStorePinia.js'
  const appStore = useAppStore()

  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store
  const snackbar = vueInstance.$snackbar
  const userStore = useUserStore()

  const router = useRouter()

  const addNew= ref(false),
        showPreviousYears= ref(false),
        search= ref(null),
        newTournament= ref({
          tournamentFormulaFields: []
        }),
        dataLoading= ref(true),
        userId=ref(userStore.details.id),
        tournaments=ref([]),
        currentYear=ref(moment().year()),
        ownerTypes=ref([]),
        formulas=ref([]),
        headers= ref([
          {text: 'Tournament', value: 'tournamentName', show: true},
          {text: 'Start', value: 'startDate', show: true},
          {text: 'End', value: 'endDate', show: true},
          {text: 'Active', value: 'active', show: true},
          {text: '', value: 'icons', show: true},
        ]),
        tournamentToDelete=ref(null)

    const tournamentToDeleteName = computed(() => {
        return tournamentToDelete.value ? tournamentToDelete.value.tournamentName : ''
      })

  const userCanAdd = computed(() => {
    return userStore.userHasFeatureAccessLevel('TOURNAMENTS', 'ADD')
  })

  const userCanEdit = computed(() => {
    return userStore.userHasFeatureAccessLevel('TOURNAMENTS', 'EDIT')
  })

  const userCanDelete = computed(() => {
    return userStore.userHasFeatureAccessLevel('TOURNAMENTS', 'DELETE')
  })

  const timezone = computed(() => {
    return userStore.timezone.value
  })

  const companyId = computed(() => {
    return userStore.details.companyId
  })

    const validateCustomFields = () => {
        let invalid = false
        if(newTournament.value.tournamentFormulaFields?.length > 0) {
          //if the tournament has custom fields then none of them can be null
          newTournament.value.tournamentFormulaFields.forEach(tff => {
            //datatype 3 = booleans can be null if they dont have a value
            if((tff.fieldValue === null || tff.fieldValue === '') && tff.dataTypeId !== 3) {
              invalid = true
            }
          })
        }
        return invalid
      },
      filterTournaments = () => {
        return orderBy(tournaments.value.filter(t => {
          return !t.archived && ( !showPreviousYears.value ? (moment(t.startDate).year() === currentYear.value || moment(t.endDate).year() === currentYear.value) : true )
        }), [ 'active', 'startDate', 'tournamentName'], ['desc','desc', 'asc'])
      },
      goToTournament = (id) => {
        return `/settings/tournaments/${id}/details`
      },
      getTournamentFormulas = async() => {
    let snackbar
        newTournament.value.tournamentFormulaId = null
        newTournament.value.tournamentFormulaFields = []
        appStore.loading = true
        try {
          const {data, status} = await getRequest(`/tournament/formulas/${newTournament.value.tournamentOwnerTypeId}`, 'blueraven')
          formulas.value = data
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          dataLoading.value = false
          snackbar('ERROR', 'Error Retrieving Data')
          appStore.loading = false
        }
      },
        getTournamentFormulaFields = async() => {
          let snackbar
          newTournament.value.tournamentFormulaFields = []
          appStore.loading = true
          try {
            const {data, status} = await getRequest(`/tournament/formula/${newTournament.value.tournamentFormulaId}/fields`, 'blueraven')
            newTournament.value.tournamentFormulaFields = data
            handleHidingGlobalLoader(status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            dataLoading.value = false
            snackbar('ERROR', 'Error Retrieving Data')
            appStore.loading = false
          }
        },
      getTournamentOwnerTypes= async() => {
        appStore.loading = true
        try {
          const {data, status} = await getRequest(`/tournament/ownerTypes`, 'blueraven')
          ownerTypes.value = data
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          dataLoading.value = false
          snackbar('ERROR', 'Error Retrieving Data')
          appStore.loading = false
        }
      },
      getTournaments = async() => {
        dataLoading.value = true
        appStore.loading = true
        try {
          const {data, status} = await getRequest(`/tournament`, 'blueraven')
          tournaments.value = data
          dataLoading.value = false
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          dataLoading.value = false
          snackbar('ERROR', 'Error Retrieving Data')
          appStore.loading = false
        }
      },
      deleteTournament = async() => {
        const id = tournamentToDelete.value.id
        appStore.loading = true
        try {
          const {status} = await deleteRequest(`/tournament/${id}`, 'blueraven')
          snackbar('SUCCESS', 'Tournament Deleted')
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Deleting Tournament')
          appStore.loading = false
        }
        tournamentToDelete.value=null
      },
      addTournament= async() => {
        let snackbar
        appStore.loading = true
        try {
          const {data, status} = await postRequest(`/tournament`, newTournament.value, 'blueraven')
          router.push({path: `/settings/tournaments/${data.id}/details`})
          snackbar('SUCCESS', 'Tournament Added')
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Adding Tournament')
          appStore.loading = false
        }
      }

    onMounted(async () => {
      await getTournaments()
      await getTournamentOwnerTypes()
    })

</script>

<style lang="scss">
  #tournament-admin-container .v-data-table__wrapper {
    max-height: calc(100vh - 250px);
    min-height: 300px;
  }

  @media (max-width: 770px) {
    #tournaments-table {
      padding-bottom: 12px;
      div.v-data-footer {
        display: inline-block;
        width: 100%;
        padding-bottom: 12px;

        div.v-data-footer__select {
          justify-content: center;
        }

        div.v-data-footer__pagination {

        }

        div.v-data-footer__icons-before {
          display: inline;
          margin-left: calc(50% - 36px);
        }

        div.v-data-footer__icons-after {
          display: inline;
        }

      }
    }
  }

</style>
