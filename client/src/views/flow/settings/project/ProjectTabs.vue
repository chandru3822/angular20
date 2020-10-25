<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col class="shrink pt-0" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Tabs</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newTab ={}]">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <div v-if="addNew" class="mb-2">
            <v-text-field v-model="newTab.tabName"
                          placeholder=" "
                          label="Tab Label">
            </v-text-field>
            <v-btn :disabled="!newTab.tabName" @click="saveTab(newTab)">Save</v-btn>
          </div>
          <v-data-table
              :headers="headers"
              :items="filterTabs()"
              :items-per-page="-1"
              :sort-desc="[false]"
              :sort-by="['displayOrder']"
              hide-default-footer
              fixed-header
              single-expand
              :expanded.sync="expanded"
              class="elevation-1"
          >
            <template #no-data>
              No available tabs
            </template>

            <template #no-results>
              No available tabs
            </template>

            <template #item="{ item, index }">
              <tr :class="{'shaded-row': tabs.indexOf(item) % 2}">
                <td style="width: 50px">
                  <v-btn text icon small class="handle">
                    <v-icon>drag_handle</v-icon>
                  </v-btn>
                </td>
                <td class="text-left">
                  <v-text-field class="one-hunned" v-if="selectedTabId === item.id" v-model="item.tabName"></v-text-field>
                  <span v-else>{{item.tabName}}</span>
                </td>
                <td class="text-right">
                  <div class="item-icons">
                    <v-btn class="clickable" small text>
                      <v-icon v-if="selectedTabId === item.id" @click="saveTab(item)">save</v-icon>
                      <v-icon v-else @click="selectedTabId = item.id">edit</v-icon>
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
                          Are you sure you want to delete this tab: <strong>{{ item.tabName }}</strong>?
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
                              @click="[item.archived = true, deleteTab(item.id)]">
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
  import Snackbar from '@/components/Snackbar.vue'
  import orderBy from 'lodash.orderby'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import Sortable from "sortablejs";
  import cloneDeep from "lodash.clonedeep";

  export default {
    name: 'ProjectTabs',
    mixins: [Vue2Filters.mixin],
    components: {
      Snackbar
    },
    mounted() {
      let table = document.querySelector('tbody')
      const _self = this
      Sortable.create(table, {
        handle: '.handle',
        onEnd({ newIndex, oldIndex }) {
          const rowSelected = _self.tabs.splice(oldIndex, 1)[0]
          _self.tabs.splice(newIndex, 0, rowSelected)
          let rowsClone = cloneDeep(_self.tabs)

          let rowsToSave = []
          rowsClone.forEach((r, idx) => {
            //check if the row needs to be saved before updating display order
            //todo: vuetify table sorting is doing something weird where it won't sort right if i update the actual display order. hacked around it for now _rn
            let save = r.newDisplayOrder === undefined ? r.displayOrder !== idx : r.newDisplayOrder !== idx
            //update display order
            r.displayOrder = idx
            //save only rows that changed
            if(save) {
              _self.tabs[idx].newDisplayOrder = idx
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
        tabs: [],
        addNew: false,
        newTab: {},
        selectedTabId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        expanded: [],
        headers: [
          { text: null, value: 'draggable', width: '50px', show: true, sortable: false },
          { text: 'Tab Label', value: 'tabName', show: true },
          { text: null, value: 'icons', show: true }
        ],
      }
    },
    computed: {},
    methods: {
      async getTabs() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/objectTypeTab/project`)
          this.tabs = data

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Tabs')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteTab(tabId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/objectTypeTab/${tabId}`)
          this.snackbar = getSnackbar('SUCCESS', 'Successfully Deleted Tab')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Tab')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveTab(tab) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/objectTypeTab/project`, tab)
          this.snackbar = getSnackbar('SUCCESS', 'Tab Added')
          if(!tab.id) {
            // add it to the records already on the screen
            this.tabs.push(data)
          }

          // reset the new process fields
          this.addNew = false
          this.newTab = {}

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Tab')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveRowChanges(rows) {
        if(rows?.length > 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data} = await putRequest(`/objectTypeTab/order`, rows)
            this.snackbar = getSnackbar('SUCCESS', 'Tab Order Saved')
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Saving Tab Order')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      filterTabs () {
        return this.tabs.filter(t => { return !t.archived})
      },
    },
    async created() {
      this.getTabs()
    }
  }
</script>

<style scoped lang="scss">

</style>
