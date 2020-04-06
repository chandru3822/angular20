<template>
  <v-container id="financiers-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Financiers</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="addNew = !addNew; newFinancier = {}" color="primary">
              <v-icon>add</v-icon>
              Add New
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="pa-4 mt-1" v-if="addNew">
          <v-text-field v-model="newFinancier.name"
                        label="Financier Name">
          </v-text-field>
          <v-radio-group v-model="newFinancier.active" column>
            <v-radio label="Active" :value="true"></v-radio>
            <v-radio label="Inactive" :value="false"></v-radio>
          </v-radio-group>
          <v-btn :disabled="!newFinancier.name || newFinancier.active == null" @click="saveFinancier(newFinancier)">Save</v-btn>
        </v-card>
        <v-divider v-if="addNew"></v-divider>
        <v-data-table
            :headers="headers"
            :items="filterFinanciers()"
            :items-per-page="-1"
            :mobile-breakpoint="0"
            single-expand
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1 fix-column-width-bug financiers-table"
        >
          <template #no-data>
            No available financiers
          </template>

          <template #no-results>
            No available financiers
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': selectedIndex % 2}">
              <v-text-field v-model="item.name"
                            label="Financier">
              </v-text-field>
              <v-radio-group v-model="item.active" column>
                <v-radio label="Active" :value="true"></v-radio>
                <v-radio label="Inactive" :value="false"></v-radio>
              </v-radio-group>
              <v-btn :disabled="!item.name" @click="saveFinancier(item)">Save</v-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.name}}</td>
              <td class="text-left">{{item.active ? 'Active' : 'Inactive'}}</td>
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
                        Are you sure you want to delete this financier?
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
                            @click="item.archived = true; deleteFinancier(item.id)">
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
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import orderBy from "lodash.orderby";

  export default {
    name: 'Financiers',
    components: {
      Snackbar
    },
    data() {
      return {
        delay: 500,
        dialog: false,
        snackbar: {},
        financiers: [],
        expanded: [],
        dataLoading: true,
        selectedIndex: null,
        newFinancier: {},
        addNew: false,
        headers: [
          {text: 'Financier', value: 'name', show: true},
          {text: 'Status', value: 'active', show: true},
          {text: '', value: 'icons', show: true},
        ],
      }
    },
    created() {
      this.getFinanciers()
    },
    methods: {
      async getFinanciers() {
        try {
          const {data} = await getRequest(`/propTool/financier`)
          this.financiers = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Financiers')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteFinancier(id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/propTool/financier/${id}`)
          this.snackbar = getSnackbar('SUCCESS', 'Financier Deleted')
          this.$store.commit(AppMutations.SET_LOADING, false)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Financier')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterFinanciers() {
        return this.financiers.filter(u => {
          return !u.archived
        })
      },
      async saveFinancier(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/propTool/financier`, item)
          // add it to the records already on the screen
          if(!item.id) {
            this.financiers.push(data)
          }
          this.financiers = orderBy(this.financiers, [f => f.name.toLowerCase()])

          this.snackbar = getSnackbar('SUCCESS', item.id ? 'Financier Saved' : 'Financier Added')

          // reset the new fields
          this.addNew = false
          this.newFinancier = {}

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', item.id ? 'Error Updating Financier' : 'Error Adding Financier')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    },
  }
</script>

<style lang="scss">
  #financiers-container .v-data-table__wrapper {
    height: calc(100vh - 400px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  #financiers-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }

  .financiers-table {
    margin-top: 2px;
  }

</style>

