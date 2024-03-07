<template>
  <v-container id="incentive-container">
    <v-row>
      <v-col cols="12"  class="pt-0 px-0">
        <v-data-table
          :headers="headers"
          :items="filteredIncentives"
          :loading="dataLoading"
          :items-per-page="100"
          :mobile-breakpoint="0"
          fixed-header
          :footer-props="footerProps"
          class="elevation-1 incentive-table"
        >
          <template #header.icons="{}">
            <div class="text-right mr-2">
              <v-btn text @click="addItem" color="primary"
                     v-if="userStore.userHasFeatureAccessLevel('INCENTIVE', 'ADD')">
                <v-icon>add</v-icon>
                <span v-if="!constants.IS_MOBILE">Add New</span>
              </v-btn>
            </div>
          </template>

          <template #header="{ props: { headers } }">
            <tr>
              <th v-for="header in headers" :key="header.text"
                  :style="{'min-width': header.text === 'Metro Area' ? '120px' : ''}"
              >
                <div v-if="incentiveFilters[header.value]" class="pt-2 table-filter">
                  <v-text-field v-if="incentiveFilters[header.value].type === 'text'"
                                v-model="incentiveFilters[header.value].value"
                                :placeholder="'Enter a ' + header.text.toLowerCase()"
                                clearable
                                filled
                                dense
                                hide-details
                  ></v-text-field>
                  <v-autocomplete v-else-if="incentiveFilters[header.value].type === 'select' && header.value === 'state'"
                                  :items="states"
                                  v-model="incentiveFilters[header.value].value"
                                  :placeholder="'Select a ' + header.text.toLowerCase()"
                                  clearable
                                  filled
                                  :item-text=header.value
                                  dense
                                  type="search"
                                  autocomplete="off"
                                  hide-details
                  ></v-autocomplete>
                  <v-autocomplete v-else-if="incentiveFilters[header.value].type === 'select' && header.value === 'type'"
                                  :items="types"
                                  v-model="incentiveFilters[header.value].value"
                                  :placeholder="'Select a ' + header.text.toLowerCase()"
                                  clearable
                                  filled
                                  :item-text=header.value
                                  item-value="type"
                                  dense
                                  type="search"
                                  autocomplete="off"
                                  hide-details
                  ></v-autocomplete>
                  <v-autocomplete v-else-if="incentiveFilters[header.value].type === 'select' && header.value === 'status'"
                                  :items="statuses"
                                  v-model="incentiveFilters[header.value].value"
                                  :placeholder="'Select a ' + header.text.toLowerCase()"
                                  clearable
                                  filled
                                  :item-text=header.value
                                  item-value="status"
                                  dense
                                  type="search"
                                  autocomplete="off"
                                  hide-details
                  ></v-autocomplete>
                </div>
              </th>
            </tr>
          </template>

          <template #item="{ item, index }">
            <tr :class="['text-sm-left', {'shaded-row': !(index % 2)}]">
              <td class="text-left clickable" @click="$router.push({ path: `incentive/${item.id}/details` })">
                {{ item.name || '' }}
              </td>
              <td class="text-left clickable" @click="$router.push({ path: `incentive/${item.id}/details` })">
                {{ item.state || '' }}
              </td>
              <td class="text-left clickable" @click="$router.push({ path: `incentive/${item.id}/details` })">
                {{ item.type || '' }}
              </td>
              <td class="text-left clickable" @click="$router.push({ path: `incentive/${item.id}/details` })">
                {{ item.status || '' }}
              </td>
              <td class="text-right">
                <v-btn :to="`/database/incentive/${item.id}/details`" text x-small fab>
                  <v-icon>mdi-arrow-right</v-icon>
                </v-btn>
                <v-icon v-if="userStore.userHasFeatureAccessLevel('INCENTIVE', 'EDIT')" small color="primary"
                        class="mr-3 feat-db-link-icon" @click="editIncentive(item)">
                  edit
                </v-icon><v-icon v-if="userStore.userHasFeatureAccessLevel('INCENTIVE', 'DELETE')" small color="primary"
                        class="mr-3 feat-db-link-icon" @click="deleteIncentive(item)">
                  delete
                </v-icon>
              </td>
            </tr>
          </template>

          <template #no-data>
            <div class="mt-2 mb-4 default-text-color">No records found</div>
          </template>

          <template #no-results>
            <div class="mt-2 mb-4 default-text-color">No records found</div>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
<!--todo: update to ConfirmationDialog-->
    <v-dialog v-model="incentiveDialog" max-width="500px">
      <v-card>
        <v-card-title>
          <span class="text-h5">{{ formTitle }}</span>
        </v-card-title>

        <v-card-text>
          <v-text-field label="Name"
                        v-model="editedItem.name"
                        required
                        filled
          ></v-text-field>
          <v-autocomplete label="State"
                          :items="states"
                          v-model="editedItem.companyStateId"
                          item-text="state"
                          item-value="id"
                          autocomplete="off"
                          type="search"
                          required
                          filled
          ></v-autocomplete>
          <v-autocomplete label="Type"
                          :items="types"
                          v-model="editedItem.typeId"
                          item-text="type"
                          item-value="id"
                          autocomplete="off"
                          type="search"
                          filled
          ></v-autocomplete>
          <v-autocomplete label="Status"
                          :items="statuses"
                          v-model="editedItem.statusId"
                          item-text="status"
                          item-value="id"
                          autocomplete="off"
                          type="search"
                          filled
          ></v-autocomplete>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="primary" text @click="close">Cancel</v-btn>
          <v-btn color="primary" raised @click="newIncentiveDuplicateCheck" class="white--text"
                 :disabled="!editedItem.name?.trim() || !editedItem.companyStateId">
            {{ btnTxt }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <ConfirmationDialog :open-dialog="duplicateDialog" @confirm="saveIncentive" @close-dialog="[duplicateDialog = false, close()]">
      <template v-slot:title><span class="error--text">WARNING: Duplicate Incentive Data</span></template>
      <div class="pb-3 body-large">Are you sure you want to create a new Incentive?</div>
      <v-row>
        <v-col v-if="duplicateIncentiveMatch">
          <div class="label-large">Existing Incentive</div>
          <div class="body-medium"><span class="label-medium">Name:</span> {{duplicateIncentiveMatch.name}}</div>
          <div class="body-medium"><span class="label-medium">State:</span> {{duplicateIncentiveMatch.state}}</div>
          <div class="body-medium"><span class="label-medium">Type:</span> {{duplicateIncentiveMatch.type}}</div>
          <div class="body-medium"><span class="label-medium">Status:</span> {{duplicateIncentiveMatch.status}}</div>
          <div class="body-medium"><span class="label-medium">Date Created:</span> {{duplicateIncentiveMatch.dateCreated | formatDate('date')}}</div>
        </v-col>
        <v-col v-if="editedItem">
          <div class="label-large">New Data</div>
          <div class="body-medium"><span class="label-medium">Name:</span> {{editedItem.name}}</div>
          <div class="body-medium"><span class="label-medium">State:</span> {{editedItem.state}}</div>
          <div class="body-medium"><span class="label-medium">Type:</span> {{editedItem.type}}</div>
          <div class="body-medium"><span class="label-medium">Status:</span> {{editedItem.status}}</div>
        </v-col>
      </v-row>
      <template v-slot:yes>Create</template>
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!incentiveToDelete" @confirm="confirmDeleteIncentive" @close-dialog="incentiveToDelete=null">
    Are you sure you want to delete {{ incentiveToDeleteName }}?
    </ConfirmationDialog>
  </v-container>
</template>

<script>
import constants from "@/helpers/constants";
import cloneDeep from "lodash.clonedeep";
import {FEAT_DB_TABS} from "@/views/blueraven/featDB/FeatDbConstants";
import {AppMutations} from "@/stores/AppStore";
import {deleteRequest, getRequest, getSnackbar, handleHidingGlobalLoader, postRequest, putRequest} from "@/helpers/helpers";
import {getActiveStates} from "@/services/stateService";
import ConfirmationDialog from "@/components/ConfirmationDialog";
import { mapStores } from 'pinia'
import { useUserStore } from '@/stores/UserStorePinia.js'

export default {
  name: "incentives",
  components: {ConfirmationDialog},
  data: () => ({
    constants,
    dataLoading: true,
    incentiveFilters: {
      name: {value: '', type: 'text', model: 'name'},
      state: {value: [], type: 'select', model: 'state'},
      type: {value: [], type: 'select', model: 'type'},
      status: {value: [], type: 'select', model: 'status'}
    },
    states: [],
    statuses: [],
    types: [],
    tabs: FEAT_DB_TABS,
    headers: [
      {text: 'Name', value: 'name', width: constants.IS_MOBILE ? 200 : 300, show: true},
      {text: 'State', value: 'state', width: constants.IS_MOBILE ? 150 : 150, show: true},
      {text: 'Type', value: 'type', width: constants.IS_MOBILE ? 150 : 150, show: true},
      {text: 'Status', value: 'status', width: constants.IS_MOBILE ? 150 : 150, show: true},
      {text: null, value: 'icons', sortable: false, show: true, width: 50}
    ],
    footerProps: {
      showFirstLastPage: !constants.IS_MOBILE,
      firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',
      lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
      'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
      'items-per-page-options': [25, 50, 100, 1000]
    },
    incentiveDialog: false,
    editedItem: {
      name: '',
      statusId: '',
      typeId: '',

    },
    incentives: [],
    addMode: false,
    incentiveToDelete: null,
    duplicateDialog: false,
    duplicateIncentiveMatch: null
  }),
  computed: {
    ...mapStores(useUserStore),
    filteredIncentives() {
      return this.incentives && this.incentives.filter(incentive => {
        return Object.keys(this.incentiveFilters).every(filterName => {
          const filter = this.incentiveFilters[filterName]

          if (filter.value?.length < 1) {
            return true
          }

          if (!incentive[filterName]) {
            return false
          }

          if (filter.value !== null && filter.value !== undefined) {
            return incentive[filterName].toLowerCase().includes(filter.value.toLowerCase())
          } else if (filter.value === undefined) {
            filter.value = []
          } else {
            filter.value = ''
            // return true here or the first row in the incentive list will disappear when you clear the filters
            return true
          }
        })
      })
    },
    formTitle() {
      return this.addMode ? 'Create Incentive' : 'Update Incentive'
    },
    btnTxt() {
      return this.addMode ? 'Add' : 'Update'
    },
    incentiveToDeleteName(){
      return this.incentiveToDelete ? this.incentiveToDelete.name : ''
    },
  },
  async created() {
    this.$store.commit(AppMutations.SET_LOADING, true)
    await this.fetchStates()
    await this.getTypes()
    await this.getStatuses()
    await this.fetchIncentives()
  },
  methods: {
    async getTypes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest('/featDb/incentive/list/type', 'blueraven')
        this.types = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getStatuses() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest('/featDb/incentive/list/status', 'blueraven')
        this.statuses = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Status\'')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async fetchIncentives() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest('/featDb/incentive/list/all', 'blueraven')
        this.incentives = cloneDeep(data).filter(incentive => incentive.archived === false)
        this.dataLoading = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.dataLoading = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },

    async fetchStates() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getActiveStates()
        this.states = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    addItem() {
      this.getTypes()
      this.getStatuses()
      this.addMode = true
      this.incentiveDialog = true
    },
    editIncentive (item) {
      this.editedItem = Object.assign({}, item)
      this.getTypes()
      this.getStatuses()
      this.addMode = false
      this.incentiveDialog = true
    },
    close() {
      this.incentiveDialog = false
      this.editedItem = {}
    },
    deleteIncentive(item) {
      this.incentiveToDelete = {
        id: item.id,
        name: item.name
      }
    },
    async confirmDeleteIncentive() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await deleteRequest(`/featDb/incentive/${this.incentiveToDelete.id}`, 'blueraven')
        this.snackbar = getSnackbar('SUCCESS', 'Incentive deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        await this.fetchIncentives().then(() => this.fetchStates())
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error deleting Incentive')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.incentiveToDelete = null
    },

    newIncentiveDuplicateCheck() {
      this.duplicateIncentiveMatch = this.incentives.find(incentive => {

        return this.doNamesMatch(this.editedItem.name, incentive.name) &&
            this.editedItem.companyStateId === incentive.companyStateId
      })
      if(this.duplicateIncentiveMatch){
        this.incentiveDialog = false
        //add state name for display purposes
        this.editedItem.state = this.states.find(state => state.id === this.editedItem.companyStateId)?.state
        this.editedItem.type = this.types.find(type => type.id === this.editedItem.typeId)?.type
        this.editedItem.status = this.statuses.find(status => status.id === this.editedItem.statusId)?.status
        this.duplicateDialog = true
      } else {
        this.saveIncentive()
      }
    },

    doNamesMatch(name1, name2){
      //step 1: remove all punctuation and whitespaces (we don't care if those match)
      const name1Clean = this.cleanName(name1)
      const name2Clean = this.cleanName(name2)
      //step 2: check if name1 contains name2 or vice versa, if so they match.
      //This is kind of weird but blue raven requested this behavior specifically
      return name2Clean && name1Clean &&
          ((name2Clean.length > 0 && name1Clean.indexOf(name2Clean) >= 0)
          || (name1Clean && name1Clean.length > 0 && name2Clean.indexOf(name1Clean) >= 0))
    },

    cleanName(name){
      return name && name.length > 0 ? name.replace(/[^\w]/g, '').toLowerCase() : name
    },

    async saveIncentive() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      if (this.addMode) {
        try {
          const {status} = await postRequest('/featDb/incentive', this.editedItem, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Incentive created')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error creating Incentive')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      } else {
        try {
          const {status} = await putRequest(`/featDb/incentive/simpleUpdate`, this.editedItem, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Incentive updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error updating Incentive')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }

      this.close()
      await this.fetchIncentives()
      this.editedItem = {}
    },
  }
}
</script>

<style lang="scss" scoped>
#incentive-container {
  overflow: auto;
  padding-top: 0;
}

.feat-db-link {
  color: var(--v-brBlue-base);
  text-decoration: none;

  &:hover {
    text-decoration: underline;
    color: var(--v-primary-base);
  }
}

.feat-db-link-icon {
  &:hover {
    color: var(--v-primary-lighten1) !important;
  }
}

.incentive-table {
  margin-top: 2px;
}

.v-data-table ::v-deep .v-data-table__wrapper {
  max-height: calc(100vh - 240px);

  .table-filter {
    font-weight: normal;
    margin-bottom: 10px;

    .v-text-field,
    .v-select {
      font-size: 0.875rem;
      margin-left: 15px;
    }
  }
}

@media (min-width: 769px) {
  .v-data-table ::v-deep .v-data-table__wrapper {
    max-height: calc(100vh - 202px);
  }
}
</style>
