<template>
  <v-container id="ahj-hoa-container">
    <v-row>
      <v-col cols="12"  class="pt-0 px-0">
<!--        <v-toolbar color="white" class="elevation-1">-->
<!--          <v-toolbar-title class="app-title">-->
<!--            <v-btn v-for="tab in tabs" text :to="tab.path" color="primary">-->
<!--              {{tab.label}}-->
<!--            </v-btn>-->
<!--          </v-toolbar-title>-->
<!--          <v-spacer></v-spacer>-->
<!--          <v-toolbar-items>-->
<!--            <v-btn text @click="addItem" color="primary"-->
<!--                   v-if="$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'ADD')">-->
<!--              <v-icon>add</v-icon>-->
<!--              <span v-if="!constants.IS_MOBILE">Add New</span>-->
<!--            </v-btn>-->
<!--          </v-toolbar-items>-->
<!--        </v-toolbar>-->
        <v-data-table
          :headers="headers"
          :items="filteredHoas"
          :loading="dataLoading"
          :items-per-page="100"
          :mobile-breakpoint="0"
          fixed-header
          :footer-props="footerProps"
          class="elevation-1 hoa-table"
        >
          <template #header="{ props: { headers } }">
            <tr>
              <th v-for="header in headers" :key="header.text"
                  :style="{'min-width': header.text === 'Metro Area' ? '120px' : ''}"
              >
                <div v-if="hoaFilters[header.value]" class="pt-2 table-filter">
                  <v-text-field v-if="hoaFilters[header.value].type === 'text'"
                                v-model="hoaFilters[header.value].value"
                                :placeholder="'Enter a ' + header.text.toLowerCase()"
                                clearable
                                filled
                                dense
                                hide-details
                  ></v-text-field>
                  <v-autocomplete v-else-if="hoaFilters[header.value].type === 'select'"
                                  :items="states"
                                  v-model="hoaFilters[header.value].value"
                                  :placeholder="'Select a ' + header.text.toLowerCase()"
                                  clearable
                                  filled
                                  item-text="state"
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
              <td class="text-left clickable" @click="$router.push({ path: `hoa/${item.id}/details` })">
                {{ item.name ? item.name : '' }}
              </td>
              <td class="text-left clickable" @click="$router.push({ path: `hoa/${item.id}/details` })">
                {{ item.state ? item.state : '' }}
              </td>
              <td class="text-left">
                <router-link v-if="constants.IS_MOBILE" :to="`hoa/${item.id}/details`" class="mr-3 ahj-link">
                  Details
                </router-link>
                <span v-else>
                  <router-link :to="'ahj/' + item.id + '/permit'"
                               class="mr-3 ahj-link primary--text">Permit</router-link>
                  <router-link :to="'ahj/' + item.id + '/inspection'"
                               class="mr-3 ahj-link primary--text">Inspection</router-link>
                  <!--                  <router-link :to="'ahj/' + item.id + '/design'" class="mr-3 ahj-link primary&#45;&#45;text">Design Requirements</router-link>-->
                </span>
                <v-icon v-if="$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'EDIT')" small color="primary"
                        class="mr-3 ahj-link-icon" @click="editAhj(item)">
                  edit
                </v-icon>
                <v-icon v-if="$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'DELETE')" small color="primary"
                        class="ahj-link-icon" @click="deleteItem(item)">
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
    <v-dialog v-model="ahjDialog" max-width="500px">
      <v-card>
        <v-card-title>
          <span class="text-h5">{{ ahjFormTitle }}</span>
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
          <v-autocomplete label="Management Company"
                          :items="managementCompanies"
                          v-model="editedItem.companyId"
                          item-text="management"
                          item-value="id"
                          autocomplete="off"
                          filled
                          attach
          ></v-autocomplete>

        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="primary" text @click="close">Cancel</v-btn>
          <v-btn color="primary" raised @click="saveAhj" class="white--text"
                 :disabled="!editedItem.name || !editedItem.managementCompanyId || !editedItem.companyStateId">
            {{ ahjBtnTxt }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

  </v-container>
</template>

<script>
import constants from "@/helpers/constants";
import cloneDeep from "lodash.clonedeep";
import {FILTER_DEFAULTS, AHJ_TABS} from "@/views/blueraven/ahj/AhjConstants";
import {AppMutations} from "@/stores/AppStore";
import {getRequest, getSnackbar, handleHidingGlobalLoader, postRequest, putRequest} from "@/helpers/helpers";
import {getActiveStates} from "@/services/stateService";

export default {
  name: "ahjHoas",
  data: () => ({
    constants,
    dataLoading: false,//true,
    hoaFilters: [],
    states: [],
    tabs: AHJ_TABS,
    headers: [
      {text: 'Name', value: 'name', width: constants.IS_MOBILE ? 200 : 300, show: true},
      { text: 'Metro Area', value: 'metroArea', width: constants.IS_MOBILE ? 200 : 250, show: true },
      {text: 'State', value: 'state', width: constants.IS_MOBILE ? 150 : 150, show: true},
      {text: 'Management Company', value: 'managementCompany', width: constants.IS_MOBILE ? 200 : 250, show: true},
      {text: null, value: null, sortable: false, show: true, width: 50}
    ],
    footerProps: {
      showFirstLastPage: !constants.IS_MOBILE,
      firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',
      lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
      'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
      'items-per-page-options': [25, 50, 100, 1000]
    },
    ahjDialog: false,
    editedItem: {
      name: '',
      managementCompanyId: '',
    },
    ahjHoas: [],
    managementCompanies: []
  }),
  computed: {
    filteredHoas() {
      return []
    },
    ahjFormTitle() {
      return this.addMode ? 'Create HOA' : 'Update HOA'
    },
    ahjBtnTxt() {
      return this.addMode ? 'Add' : 'Update'
    },
  },
  created() {
    this.$store.commit(AppMutations.SET_LOADING, true)
    this.currentUser = this.$store.state.user.details.id
    this.initFilters()
    this.fetchStates()
    this.fetchAhjHoas()
  },
  methods: {
    initFilters() {
      this.hoaFilters = cloneDeep(FILTER_DEFAULTS)
      this.hoaFilters = {...this.hoaFilters, managementCompany: {value: null, type: 'text', model: 'managementCompany'}}
    },
    async getActiveManagementCompanies() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest('/ahjHoa/list/companies', 'blueraven')
        this.managementCompanies = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async fetchAhjHoas() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest('/ahjHoa/list/all', 'blueraven')
        this.ahjHoas = cloneDeep(data)
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
      this.getActiveManagementCompanies()
      this.addMode = true
      this.ahjDialog = true
    },
    close() {
      this.ahjDialog = false
      this.ahjDeleteDialog = false
      this.editedItem = {}
    },
    async saveAhj() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      if (!this.editedItem.id) {
        try {
          const {status} = await postRequest('/ahj', this.editedItem, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'AHJ created')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error creating AHJ')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      } else {
        try {
          const {status} = await putRequest(`/ahj/${this.editedItem.id}`, this.editedItem, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'AHJ updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error updating AHJ')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }

      this.close()
      this.initFilters()
      await this.fetchAhjs().then(() => this.fetchStates())
      this.editedItem = {}
    },

  }
}
</script>

<style lang="scss" scoped>
#ahj-hoa-container {
  overflow: auto;
  padding-top: 0;
}

.ahj-link {
  color: var(--v-brBlue-base);
  text-decoration: none;

  &:hover {
    text-decoration: underline;
    color: var(--v-primary-base);
  }
}

.ahj-link-icon {
  &:hover {
    color: var(--v-primary-lighten1) !important;
  }
}

.hoa-table {
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
