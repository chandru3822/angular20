<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="addNew = !addNew; newType = {}">
              <v-icon v-if="IS_MOBILE">add</v-icon>
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
            <v-select
                v-model="newType.workQueueCategoryId"
                :items="workQueueCategories"
                label="Work Queue Category"
                item-text="workQueueCategory"
                item-value="id"
            ></v-select>
            <v-btn :disabled="!newType.workQueueType || !newType.workQueueCategoryId" @click="addNewType">Save</v-btn>
          </div>
          <v-data-table
              :headers="headers"
              :items="filterWorkQueueTypes()"
              :fixed-header="true"
              :items-per-page="-1"
              single-expand
              :expanded.sync="expanded"
              hide-default-footer
              class="elevation-1 mt-1"
          >
            <template #no-data>
              No available fields
            </template>

            <template #no-results>
              No available fields
            </template>

            <template #item="{ item, index }">

              <tr class="clickable" :class="{'shaded-row': index % 2}">
                <td class="text-left">
                  <v-text-field class="one-hunned" v-if="selectedWorkQueueTypeId === item.id" v-model="item.workQueueType"></v-text-field>
                  <div v-else>{{item.workQueueType}}</div>
                </td>
                <td class="text-left">
                  <v-select
                      v-if="selectedWorkQueueTypeId === item.id"
                      v-model="item.workQueueCategoryId"
                      :items="workQueueCategories"
                      label="Work Queue Category"
                      item-text="workQueueCategory"
                      item-value="id"
                  ></v-select>
                  <div v-else>{{item.workQueueCategory}}</div>
                </td>
                <td class="text-right">
                  <div class="item-icons">
                    <v-btn class="clickable" small text>
                      <v-icon v-if="selectedWorkQueueTypeId === item.id" @click="saveType(item)">save</v-icon>
                      <v-icon v-else @click="selectedWorkQueueTypeId = item.id">edit</v-icon>
                    </v-btn>
                    <v-dialog
                        v-model="item.deleteConfirm"
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
                              color="primary"
                              text
                              @click="item.archived = true; deleteType(item.id)">
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
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>


<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import orderBy from 'lodash.orderby'
  import {getWorkQueueTypes, getWorkQueueCategories} from '@/services/workQueueService'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar, IS_MOBILE} from '@/helpers/helpers'

  export default {
    name: 'WorkQueueTypes',
    mixins: [Vue2Filters.mixin],
    components: {
      Snackbar
    },
    data() {
      return {
        snackbar: {},
        IS_MOBILE,
        workQueueTypes: [],
        workQueueCategories: [],
        addNew: false,
        newType: {},
        selectedWorkQueueTypeId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        expanded: [],
        headers: [
          { text: 'Type', value: 'workQueueType', show: true },
          { text: 'Category', value: 'workQueueCategory', show: true },
          { text: null, value: 'icons', show: true }
        ],
      }
    },
    computed: {},
    methods: {
      async getWorkQueueTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getWorkQueueTypes()
          this.workQueueTypes = orderBy(data, [wt => wt.workQueueType.toLowerCase()])

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queue Types')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getWorkQueueCategories() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getWorkQueueCategories()
          this.workQueueCategories = orderBy(data, [wt => wt.workQueueCategory.toLowerCase()])

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queue Categories')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteType(typeId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/workQueueType/type/${typeId}`)
          this.snackbar = getSnackbar('SUCCESS', 'Successfully Deleted Work Queue Type')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Work Queue Type')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addNewType() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/workQueueType/type`, this.newType)

          this.snackbar = getSnackbar('SUCCESS', 'Work Queue Type Added')

          // add it to the records already on the screen
          this.workQueueTypes.push(data)
          this.workQueueTypes = orderBy(this.workQueueTypes, [wt => wt.workQueueType.toLowerCase()])

          // reset the new process fields
          this.addNew = false
          this.newType = {}

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Work Queue Type')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveType(wt) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.selectedWorkQueueTypeId = null
          const {data} = await putRequest(`/workQueueType/type`, wt)
          wt.workQueueCategoryId = data.workQueueCategoryId
          wt.workQueueCategory = data.workQueueCategory
          wt.workQueueType = data.workQueueType
          this.snackbar = getSnackbar('SUCCESS', 'Work Queue Type Saved')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Work Queue Type')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterWorkQueueTypes () {
        return orderBy(this.workQueueTypes.filter(wqt => { return !wqt.archived}), [wqt => wqt.workQueueType.toLowerCase()])
      },
    },
    async created() {
      this.getWorkQueueTypes()
      this.getWorkQueueCategories()
    },

  }
</script>

<style scoped lang="scss">

</style>
