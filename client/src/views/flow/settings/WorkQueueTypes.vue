<template>
  <v-container id="work-queue-types-container">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-autocomplete
            v-model="selectedWorkQueueCategoryId"
            :items="filteredCategories"
            label="Work Queue Category"
            item-text="workQueueCategory"
            item-value="id"
            @input="filterCategories()"
            attach
          ></v-autocomplete>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newType = {}]" v-if="userCanAdd">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <div v-if="addNew">
            <v-text-field v-model="newType.workQueueType"
                          placeholder="Enter a type"
                          label="Work Queue Type">
            </v-text-field>
            <v-autocomplete
              v-model="newType.workQueueCategoryId"
              :items="workQueueCategories"
              label="Work Queue Category"
              item-text="workQueueCategory"
              item-value="id"
              attach
            ></v-autocomplete>
            <v-btn :disabled="!newType.workQueueType || !newType.workQueueCategoryId" @click="addNewType">Save</v-btn>
          </div>
          <v-text-field
            v-model="search"
            prepend-inner-icon="search"
            label="Search"
            single-line
            hide-details
          ></v-text-field>
          <v-data-table
            :headers="headers"
            :items="filterWorkQueueTypes()"
            :fixed-header="true"
            :items-per-page="50"
            :search="search"
            :sort-desc="[false]"
            :sort-by="['workQueueCategoryDisplayOrder','displayOrder']"
            class="elevation-1 mt-1"
          >
            <template #no-data>
              No available fields
            </template>

            <template #no-results>
              No available fields
            </template>

            <template #item="{ item, index }">

              <tr class="clickable" :class="{'shaded-row': workQueueTypes.indexOf(item) % 2}">
                <td style="width: 50px" @click="goToDetails(item)">
                  <v-btn v-if="(userCanEdit || userIsAdmin) && selectedWorkQueueCategoryId !== -1" text icon small class="handle">
                    <v-icon>drag_handle</v-icon>
                  </v-btn>
                </td>
                <td class="text-left" @click="goToDetails(item)">
                  {{item.workQueueType}}
                </td>
                <td class="text-left" @click="goToDetails(item)">
                  {{item.workQueueCategory}}
                </td>
                <td class="text-right">
                  <div class="item-icons">
                    <v-btn class="clickable" small text v-if="userCanEdit || userIsAdmin">
                      <v-icon @click="goToDetails(item)">edit</v-icon>
                    </v-btn>
                    <v-dialog
                      v-model="item.deleteConfirm"
                      v-if="userCanDelete"
                      width="500">
                      <template v-slot:activator="{ on }">
                        <v-btn small text class="clickable" v-on="on">
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
                          Are you sure you want to delete this work queue type: <strong>{{ item.workQueueType }}</strong>?
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
                            @click="[item.archived = true, deleteType(item.id)]">
                            Yes
                          </v-btn>
                        </v-card-actions>
                      </v-card>
                    </v-dialog>
                  </div>
                </td>
              </tr>
            </template>

          </v-data-table>
        </v-container>
      </v-col>
    </v-row>

  </v-container>
</template>


<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import orderBy from 'lodash.orderby'
  import cloneDeep from 'lodash.clonedeep'
  import {getWorkQueueTypes, getWorkQueueCategories} from '@/services/workQueueService'

  import { deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import Sortable from "sortablejs";

  export default {
    name: 'WorkQueueTypes',
    mixins: [Vue2Filters.mixin],

    mounted() {
      let table = document.querySelector('tbody')
      const _self = this
      Sortable.create(table, {
        handle: '.handle',
        onEnd({ newIndex, oldIndex }) {
          const rowSelected = _self.workQueueTypes.splice(oldIndex, 1)[0]
          _self.workQueueTypes.splice(newIndex, 0, rowSelected)
          let rowsClone = cloneDeep(_self.workQueueTypes)

          let rowsToSave = []
          rowsClone.forEach((r, idx) => {
            //check if the row needs to be saved before updating display order
            //todo: vuetify table sorting is doing something weird where it won't sort right if i update the actual display order. hacked around it for now _rn
            let save = r.newDisplayOrder === undefined ? r.displayOrder !== idx : r.newDisplayOrder !== idx
            //update display order
            r.displayOrder = idx
            //save only rows that changed
            if(save) {
              _self.workQueueTypes[idx].newDisplayOrder = idx
              rowsToSave.push(r)
            }
          })
          _self.saveRowChanges(rowsToSave)
        }
      })
    },
    data() {
      return {
        snackbar: {},
        constants,
        search: '',
        masterWorkQueueTypes: [],
        workQueueTypes: [],
        workQueueCategories: [],
        filteredCategories: [],
        addNew: false,
        newType: {},
        selectedWorkQueueTypeId: null,
        selectedWorkQueueCategoryId: -1,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
        userCanDelete: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE'),
        userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('WORK_QUEUE', 'ADMIN'),
        expanded: [],
        headers: [
          { text: null, value: 'draggable', width: '50px', show: true, sortable: false },
          { text: 'Type', value: 'workQueueType', show: true },
          { text: 'Category', value: 'workQueueCategory', show: true },
          { text: null, value: 'icons', show: true, width: 150 }
        ],
      }
    },
    computed: {},
    methods: {
      async getWorkQueueTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getWorkQueueTypes()
          this.workQueueTypes = data
          //make copy so filtering works later
          this.masterWorkQueueTypes = cloneDeep(this.workQueueTypes)

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queue Types')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getWorkQueueCategories() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getWorkQueueCategories()
          this.workQueueCategories = orderBy(data, [wt => wt.workQueueCategory.toLowerCase()])
          this.filteredCategories = cloneDeep(this.workQueueCategories)
          this.filteredCategories.unshift({id: -1, workQueueCategory: 'All'})
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queue Types')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterCategories() {
        this.workQueueTypes = this.selectedWorkQueueCategoryId === -1 ? this.masterWorkQueueTypes : this.masterWorkQueueTypes.filter(wqt => wqt.workQueueCategoryId === this.selectedWorkQueueCategoryId)
      },
      async deleteType(typeId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/workQueueType/type/${typeId}`)
          this.snackbar = getSnackbar('SUCCESS', 'Successfully Deleted Work Queue Type')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Work Queue Type')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addNewType() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/workQueueType/type`, this.newType)

          this.snackbar = getSnackbar('SUCCESS', 'Work Queue Type Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)

          // add it to the master list too
          this.masterWorkQueueTypes.push(data)
          this.workQueueTypes.push(data)

          // reset the new process fields
          this.addNew = false
          this.newType = {}

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Work Queue Type')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterWorkQueueTypes () {
        return this.workQueueTypes.filter(wqt => { return !wqt.archived})
      },
      async saveRowChanges (rows) {
        if(rows?.length > 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            await putRequest(`/workQueueType/order`, rows)
            this.snackbar = getSnackbar('SUCCESS', 'Order Updated')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Saving Order Changes')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      goToDetails (item) {
        this.$router.push({name: 'workQueueType', params: {id: item.id}})
      }
    },
    async created() {
      this.getWorkQueueTypes()
      this.getWorkQueueCategories()
    },

  }
</script>

<style lang="scss">
#work-queue-types-container .v-data-table__wrapper {
  max-height: calc(100vh - 350px);
  min-height: 300px;
}

#work-queue-types-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}
</style>
