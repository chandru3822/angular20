<template>
  <v-container id="panels-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Panel</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="addNew = !addNew; newPanel = {}" color="primary">
              <v-icon v-if="!addNew">add</v-icon>
              {{ addNew ? 'Cancel' : 'Add New'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="pa-4 mt-1" v-if="addNew">
          <v-text-field v-model="newPanel.panelName"
                        label="Panel">
          </v-text-field>
          <v-select v-model="newPanel.states"
                    :items="states"
                    no-data-text="No States Available"
                    label="State(s)"
                    item-text="state"
                    item-value="id"
                    multiple
                    return-object
          ></v-select>
          <v-radio-group v-model="newPanel.active" column>
            <v-radio label="Active" value="true"></v-radio>
            <v-radio label="Inactive" value="false"></v-radio>
          </v-radio-group>
          <v-btn :disabled="!newPanel.panelName || (!newPanel.states || newPanel.states.length === 0) || newPanel.active == null" @click="savePanel(newPanel)">Save</v-btn>
        </v-card>
        <v-divider v-if="addNew"></v-divider>
        <v-data-table
            :headers="headers"
            :items="filterPanels()"
            :items-per-page="-1"
            :mobile-breakpoint="0"
            single-expand
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1 fix-column-width-bug panels-table"
        >
          <template #no-data>
            No available panels
          </template>

          <template #no-results>
            No available panels
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': selectedIndex % 2}">
              <v-text-field v-model="item.panelName"
                            label="Panel">
              </v-text-field>
              <v-select v-model="item.states"
                        :items="states"
                        no-data-text="No States Available"
                        label="State(s)"
                        item-text="state"
                        item-value="id"
                        multiple
                        return-object
              ></v-select>
              <v-btn :disabled="!item.panelName || (!item.states || item.state.length === 0)" @click="savePanel(item)">Save</v-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.panelName}}</td>
              <td class="text-left">
                <span v-for="(s, index) in item.states" :key="index">{{s.state}}</span>
              </td>
              <td class="text-left">{{item.status}}</td>
              <td>
                <div style="display: flex;">
                  <v-btn small text @click="expanded = [item]; selectedIndex = index"
                         v-if="!expanded.includes(item)">
                    <v-icon v-if="item.immutable">expand_more</v-icon>
                    <v-icon v-else>edit</v-icon>
                  </v-btn>
                  <v-btn small text @click="expanded = []; selectedIndex = index"
                         v-if="expanded.includes(item)">cancel
                  </v-btn>
                  <v-dialog
                      v-model="item.deleteConfirm"
                      width="500">
                    <template #activator="{ on }">
                      <v-btn small text v-on="on">
                        <v-icon>delete</v-icon>
                      </v-btn>
                    </template>
                    <v-card>
                      <v-card-title
                          class="headline grey lighten-2"
                          primary-title>
                        Confirm
                      </v-card-title>

                      <v-card-text class="pt-4">
                        Are you sure you want to delete this panel?
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
                            @click="item.archived = true; deletePanel(item.id)">
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
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getStates} from '@/services/stateService'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import orderBy from "lodash.orderby";

  export default {
    name: 'Panels',
    components: {
      Snackbar
    },
    data() {
      return {
        delay: 500,
        dialog: false,
        snackbar: {},
        panels: [],
        states: [],
        expanded: [],
        dataLoading: true,
        selectedIndex: null,
        newPanel: {},
        addNew: false,
        headers: [
          {text: 'Panel', value: 'panel', show: true},
          {text: 'States', value: 'states', show: true},
          {text: 'Status', value: 'status', show: true},
          {text: '', value: 'icons', show: true},
        ],
      }
    },
    created() {
      this.getPanels()
      this.getStates()
    },
    methods: {
      async getPanels() {
        try {
          const {data} = await getRequest(`/propTool/panel`)
          this.panels = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Panels')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deletePanel(id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/propTool/panel/${id}`)
          this.snackbar = getSnackbar('SUCCESS', 'Panel Deleted')
          this.$store.commit(AppMutations.SET_LOADING, false)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Panel')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterPanels() {
        return this.panels.filter(u => {
          return !u.archived
        })
      },
      async getStates () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getStates()
          this.states = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async savePanel(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/propTool/panel`, item)
          // add it to the records already on the screen
          if(!item.id) {
            this.panels.push(data)
          }
          this.panels = orderBy(this.panels, [p => p.panelName.toLowerCase()])

          this.snackbar = getSnackbar('SUCCESS', item.id ? 'Panel Saved' : 'Panel Added')

          // reset the new fields
          this.addNew = false
          this.newPanel = {}

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', item.id ? 'Error Updating Panel' : 'Error Adding Panel')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    },
  }
</script>

<style lang="scss">
  #panels-container .v-data-table__wrapper {
    height: calc(100vh - 400px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  #panels-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }

  .panels-table {
    margin-top: 2px;
  }

</style>

