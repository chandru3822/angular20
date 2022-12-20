<template>
  <v-container id="ahj-list-container">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">

        <v-data-table
          :headers="headers"
          :items="filteredAhjs"
          :loading="dataLoading"
          :items-per-page="100"
          :mobile-breakpoint="0"
          fixed-header
          :footer-props="footerProps"
          class="elevation-1 ahj-table"
        >
          <template #header.icons="{}">
            <div class="text-right mr-2">
              <v-btn text @click="addItem" color="primary" v-if="$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'ADD')">
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
                <div v-if="ahjFilters[header.value]" class="pt-2 table-filter">
                  <v-text-field v-if="ahjFilters[header.value].type === 'text'"
                                v-model="ahjFilters[header.value].value"
                                :placeholder="'Enter a ' + header.text.toLowerCase()"
                                clearable
                                filled
                                dense
                                hide-details
                  ></v-text-field>
                  <v-autocomplete v-else-if="ahjFilters[header.value].type === 'select'"
                            :items="states"
                            v-model="ahjFilters[header.value].value"
                            :placeholder="'Select a ' + header.text.toLowerCase()"
                            clearable
                            filled
                            item-text="state"
                            dense
                            hide-details
                                  attach
                  ></v-autocomplete>
                </div>
              </th>
            </tr>
          </template>

          <template #item="{ item, index }">
            <tr :class="['text-sm-left', {'shaded-row': !(index % 2)}]">
              <td class="text-left clickable" @click="$router.push({ path: `ahj/${item.id}/permit` })">{{ item.name ? item.name : '' }}</td>
              <td class="text-left clickable" @click="$router.push({ path: `ahj/${item.id}/permit` })">{{ item.metroArea ? item.metroArea : '' }}</td>
              <td class="text-left clickable" @click="$router.push({ path: `ahj/${item.id}/permit` })">{{ item.state ? item.state : '' }}</td>
              <td class="text-right">
                <router-link v-if="constants.IS_MOBILE" :to="'ahj/' + item.id + '/permit'" class="mr-3 ahj-link">Details</router-link>
                <span v-else>
                  <router-link :to="`ahj/${item.id}/permit`" class="mr-3 ahj-link primary--text">Permit</router-link>
                  <router-link :to="`ahj/${item.id}/inspection`" class="mr-3 ahj-link primary--text">Inspection</router-link>
                  <router-link :to="`ahj/${item.id}/design`" class="mr-3 ahj-link primary--text">Design</router-link>
                </span>
                <v-icon v-if="$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'EDIT')" small color="primary" class="mr-3 ahj-link-icon" @click="editAhj(item)">
                  edit
                </v-icon>
                <v-icon v-if="$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'DELETE')" small color="primary" class="ahj-link-icon" @click="deleteItem(item)">
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
              <v-autocomplete label="Metro Area"
                        :items="metroAreas"
                        v-model="editedItem.metroAreaId"
                        item-text="metroArea"
                        item-value="id"
                        required
                        filled
                              attach
              ></v-autocomplete>
              <v-autocomplete label="State"
                              :items="states"
                              v-model="editedItem.companyStateId"
                              item-text="state"
                              item-value="id"
                              autocomplete="off"
                              required
                              filled
                              attach
              ></v-autocomplete>

            </v-card-text>

            <v-card-actions>
              <v-spacer></v-spacer>
              <v-btn color="primary" text @click="close">Cancel</v-btn>
              <v-btn color="primary" raised @click="saveAhj" class="white--text"
                     :disabled="!editedItem.name || !editedItem.metroAreaId || !editedItem.companyStateId">
                {{ ahjBtnTxt }}
              </v-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!ahjToDelete" @confirm="deleteAhj" @close-dialog="ahjToDelete=null">
      Are you sure you want to delete the AHJ for {{ ahjToDeleteName }}?

    </ConfirmationDialog>
  </v-container>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import { handleHidingGlobalLoader, getRequest, deleteRequest, putRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import {getActiveStates} from '@/services/stateService'
  import { AppMutations } from '@/stores/AppStore'
  import ConfirmationDialog from "@/ConfirmationDialog.vue";
  import {FEAT_DB_TABS, FILTER_DEFAULTS} from "@/views/blueraven/featDB/FeatDbConstants";

  export default {
    name: 'ahjs',
    components: {ConfirmationDialog},
    data: () => ({
      snackbar: {},
      constants, initFilters () {
        this.ahjFilters = cloneDeep(FILTER_DEFAULTS)
      },
      dataLoading: true,
      tabs: FEAT_DB_TABS,
      headers: [
        { text: 'Name', value: 'name', width: constants.IS_MOBILE ? 200 : 300, show: true },
        { text: 'Metro Area', value: 'metroArea', width: constants.IS_MOBILE ? 200 : 250, show: true },
        { text: 'State', value: 'state', width: constants.IS_MOBILE ? 200 : 200, show: true },
        { text: null, value: 'icons', sortable: false, show: true, width: constants.IS_MOBILE ? 135 : 300 }
      ],
      ahjs: [],
      editedItem: {
        name: '',
        metroAreaId: ''
      },
      ahjDialog: false,
      ahjDeleteDialog: false,
      addMode: false,
      ahjFilters: [],
      states: [],
      metroAreas: [],
      ahjToDelete: null,
      footerProps: {
        showFirstLastPage: !constants.IS_MOBILE,
        firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',
        lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
        'items-per-page-options': [25, 50, 100, 1000]
      }
    }),
    computed: {
      filteredAhjs () {
        return this.ahjs && this.ahjs.filter(ahj => {
          return Object.keys(this.ahjFilters).every(filterName => {
            const filter = this.ahjFilters[filterName]

            if (filter.value?.length < 1) {
              return true
            }

            if (!ahj[filterName]) {
              return false
            }

            if (filter.value !== null && filter.value !== undefined) {
              return ahj[filterName].toLowerCase().includes(filter.value.toLowerCase())
            } else if (filter.value === undefined) {
              filter.value = []
            } else {
              filter.value = ''
            }
          })
        })
      },
      ahjFormTitle () {
        return this.addMode ? 'Create AHJ' : 'Update AHJ'
      },
      ahjBtnTxt () {
        return this.addMode ? 'Add' : 'Update'
      },
      ahjToDeleteName(){
        return this.ahjToDelete ? this.ahjToDelete.name : ''
      }
    },
    watch: {
      ahjDialog (val) {
        val || this.close()
      }
    },
    methods: {
      async fetchAhjs () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest('/featDb/ahj', 'blueraven')
          this.ahjs = cloneDeep(data)
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
      async getActiveMetroAreas () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest('/metro/getActive', 'blueraven')
          this.metroAreas = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      addItem () {
        this.getActiveMetroAreas()
        this.addMode = true
        this.ahjDialog = true
      },
      editAhj (item) {
        this.editedItem = Object.assign({}, item)
        this.getActiveMetroAreas()
        this.addMode = false
        this.ahjDialog = true
      },
      deleteItem (item) {
        this.ahjToDelete = {
          id: item.id,
          name: item.name
        }
      },
      close () {
        this.ahjDialog = false
        this.ahjDeleteDialog = false
        this.editedItem = {}
      },
      async saveAhj () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        if (!this.editedItem.id) {
          try {
            const {status} = await postRequest('/featDb/ahj', this.editedItem, 'blueraven')
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
            const {status} = await putRequest(`/featDb/ahj/${this.editedItem.id}`, this.editedItem, 'blueraven')
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
      async deleteAhj () {
        const id = this.ahjToDelete.id
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/featDb/ahj/${id}`, 'blueraven')
          this.close()
          this.initFilters()
          await this.fetchAhjs().then(() => this.fetchStates())
          this.snackbar = getSnackbar('SUCCESS', 'AHJ deleted')
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error deleting AHJ')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
        this.ahjToDelete = null
      },
      async fetchStates () {
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
      }
    },
    created () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.currentUser = this.$store.state.user.details.id
      this.initFilters()
      this.fetchAhjs().then(() => {
        if (this.ahjs.length > 0) {
          this.fetchStates()
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      })
    }
  }
</script>

<style lang="scss" scoped>
  #ahj-list-container {
    overflow: auto;
    padding-top: 0;
  }

  .ahj-link {
    color: purple;
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

  .ahj-table {
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
