<template>
  <v-container id="zipCodes-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Zip Codes</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="addNew = !addNew; newZipCode = {}" color="primary">
              <v-icon>add</v-icon>
              Add New
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="pa-4 mt-1" v-if="addNew">
          <v-text-field v-model="newZipCode.zipCode"
                        label="Zip Code">
          </v-text-field>
          <v-radio-group v-model="newZipCode.active" column>
            <v-radio label="Active" value="true"></v-radio>
            <v-radio label="Inactive" value="false"></v-radio>
          </v-radio-group>
          <v-btn :disabled="!newZipCode.zipCode || newZipCode.active == null" @click="saveZipCode(newZipCode)">Save</v-btn>
        </v-card>
        <v-divider v-if="addNew"></v-divider>
        <v-data-table
            :headers="headers"
            :items="filterZipCodes()"
            :items-per-page="-1"
            :mobile-breakpoint="0"
            single-expand
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1 fix-column-width-bug zipCodes-table"
        >
          <template #no-data>
            No available zip Codes
          </template>

          <template #no-results>
            No available zip Codes
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': selectedIndex % 2}">
              <v-text-field v-model="item.zipCode"
                            label="Zip Code">
              </v-text-field>
              <v-btn :disabled="!item.zipCode" @click="saveZipCode(item)">Save</v-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.zipCode}}</td>
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
                        Are you sure you want to delete this Zip Code?
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
                            @click="item.archived = true; deleteZipCode(item.id)">
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
    name: 'ZipCodes',
    components: {
      Snackbar
    },
    data() {
      return {
        delay: 500,
        dialog: false,
        snackbar: {},
        zipCodes: [],
        expanded: [],
        dataLoading: true,
        selectedIndex: null,
        newZipCode: {},
        addNew: false,
        headers: [
          {text: 'Zip Code', value: 'zipCode', show: true},
          {text: 'Status', value: 'status', show: true},
          {text: '', value: 'icons', show: true},
        ],
      }
    },
    created() {
      this.getZipCodes()
    },
    methods: {
      async getZipCodes() {
        try {
          const {data} = await getRequest(`/propTool/zipCode`)
          this.zipCodes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Zip Codes')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteZipCode(id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/propTool/zipCode/${id}`)
          this.snackbar = getSnackbar('SUCCESS', 'Zip Code Deleted')
          this.$store.commit(AppMutations.SET_LOADING, false)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Zip Code')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterZipCodes() {
        return this.zipCodes.filter(u => {
          return !u.archived
        })
      },
      async saveZipCode(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/propTool/zipCode`, item)
          // add it to the records already on the screen
          if(!item.id) {
            this.zipCodes.push(data)
          }
          this.zipCodes = orderBy(this.zipCodes, [f => f.zipCode.toLowerCase()])

          this.snackbar = getSnackbar('SUCCESS', item.id ? 'Zip Code Saved' : 'Zip Code Added')

          // reset the new fields
          this.addNew = false
          this.newZipCode = {}

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', item.id ? 'Error Updating Zip Code' : 'Error Adding Zip Code')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    },
  }
</script>

<style lang="scss">
  #zipCodes-container .v-data-table__wrapper {
    height: calc(100vh - 400px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  #zipCodes-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }

  .zipCodes-table {
    margin-top: 2px;
  }

</style>

