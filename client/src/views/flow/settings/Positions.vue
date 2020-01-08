<template>
  <v-container id="positions-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Positions</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="addNew = !addNew" color="primary">
              <v-icon>add</v-icon>
              Add Position
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="my-1 pa-4" v-if="addNew">
          <h3>Add New Position</h3>
          <v-text-field v-model="newPosition.position"
                        placeholder="Enter a position name"
                        required
                        label="Position">
          </v-text-field>
          <v-select
              v-model="newPosition.orgTypeId"
              :items="orgTypes"
              label="Organization Type"
              item-text="orgType"
              item-value="id"
          ></v-select>
          <v-btn color="primary" class="white--text" :disabled="!newPosition.position || !newPosition.orgTypeId" @click="savePosition(newPosition, true)">
            Save
          </v-btn>
          <v-btn class="ml-3" @click="addNew = false; newPosition = {}">
            Cancel
          </v-btn>
        </v-card>
        <v-divider v-if="addNew"></v-divider>
        <v-data-table
            :headers="headers"
            :items="filterPositions()"
            :fixed-header="true"
            disable-sort
            :items-per-page="-1"
            hide-default-footer
            :loading="dataLoading"
            class="elevation-1 fix-column-width-bug positions-table"
        >
          <template #no-data>
            No available positions
          </template>

          <template #no-results>
            No available positions
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">
                <div v-if="!item.edit">{{item.position}}</div>
                <v-text-field v-else v-model="item.position"
                              placeholder="Enter a value"
                              label="Modify Position"
                              required>
                </v-text-field>
              </td>
              <td class="text-left">
                <div v-if="!item.edit">{{item.orgType}}</div>
                <v-select v-else
                    v-model="item.orgTypeId"
                    :items="orgTypes"
                    label="Organization Type"
                    item-text="orgType"
                    item-value="id"
                ></v-select>
              </td>
              <td class="px-0">
                <div v-if="item.edit">
                  <v-btn x-small fab text class="d-inline-block"
                         @click="savePosition(item, false)">
                    <v-icon>mdi-content-save</v-icon>
                  </v-btn>
                  <v-btn x-small fab text class="d-inline-block"
                         @click="item.edit = false">
                    <v-icon>mdi-close</v-icon>
                  </v-btn>
                </div>
                <div v-else>
                  <v-btn x-small fab text class="d-inline-block"
                         @click="item.edit = true">
                    <v-icon>mdi-pencil</v-icon>
                  </v-btn>
                  <v-dialog
                      v-model="item.deleteConfirm"
                      width="500">
                    <template v-slot:activator="{ on }">
                      <v-btn x-small fab text class="d-inline-block"  v-on="on">
                        <v-icon>mdi-delete</v-icon>
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
                        Are you sure you want to delete this position: <strong>{{ item.position }}</strong>?
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
                            @click="deletePosition(item)">
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
  import {getOrgTypes} from '@/services/orgService'
  import orderBy from 'lodash.orderby'
  import {getRequest, deleteRequest, putRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Positions',
    components: {
      Snackbar
    },
    data() {
      return {
        delay: 500,
        addNew: false,
        snackbar: {},
        orgTypes: [],
        newPosition: {},
        positions: [],
        descending: true,
        dataLoading: true,
        headers: [
          {text: 'Position Name', value: 'positionName', show: true},
          {text: 'Org Type', value: 'orgType', show: true},
          {text: '', value: 'icons', show: false, width: '100px'},
        ],
        expanded: []
      }
    },
    created () {
      this.getPositions()
      this.getOrgTypes()
    },
    methods: {
      clickRow(id) {
        this.$router.push({name: 'positions', params: {id: id}})
      },
      async getPositions() {
        try {
          const {data} = await getRequest(`/position`)
          this.positions = data
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getOrgTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getOrgTypes()
          this.orgTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Org Types')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async savePosition(p, isNew) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/position`, p)
          if(isNew){
            this.positions.push(data)
            this.positions = orderBy(this.positions, [p => p.position.toLowerCase()])
            this.addNew = false
            this.newPosition = {}
            this.snackbar = getSnackbar('SUCCESS', 'Position Added')
          } else {
            p.edit = false
            p.orgType = data.orgType
            this.snackbar = getSnackbar('SUCCESS', 'Position Updated')
          }
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', isNew ? 'Error Adding Position' : 'Error Updating Position')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deletePosition(p) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/position/${p.id}`)
          p.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'Position Deleted')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Position')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterPositions () {
        return orderBy(this.positions.filter(p => { return !p.archived}), [p => p.position.toLowerCase()])
      },
    }
  }
</script>

<style lang="scss">
  #positions-container .v-data-table__wrapper {
    height: calc(100vh - 400px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  #positions-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }

  .positions-table {
    margin-top: 2px;
  }

</style>

