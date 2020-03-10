<template>
  <v-container id="blank-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Blank</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text to="/newBlank" color="primary">
              <v-icon>add</v-icon>
              Add Blank
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-toolbar color="white" class="elevation-1 mt-3">
          <v-text-field
              class="mt-5"
              prepend-inner-icon="search"
              text
              label="Search blank..."
              v-model="search"
              @input="debounceGetBlank"
          ></v-text-field>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="totalBlank <= 100000" @click="exportBlank">Export</v-btn>
            <v-dialog
                v-model="dialog"
                width="500"
                v-else
            >
              <template v-slot:activator="{ on }">
                <v-btn text v-on="on">
                  Export
                </v-btn>
              </template>

              <v-card>
                <v-card-title>
                  Export
                </v-card-title>

                <v-card-text>
                  You are attempting to export {{totalBlank | currency('', 0)}} results.
                  This can take 1-2 minutes.
                  We recommend that you cancel and filter the result set before exporting.
                </v-card-text>

                <v-divider></v-divider>

                <v-card-actions>
                  <div class="flex-grow-1"></div>
                  <v-btn
                      color="grey"
                      text
                      @click="dialog = false"
                  >
                    Cancel
                  </v-btn>
                  <v-btn
                      color="primary"
                      text
                      @click="exportBlank"
                  >
                    Continue Anyway
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-toolbar-items>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="blank"
            :fixed-header="true"
            :options.sync="options"
            disable-sort
            :footer-props="footerProps"
            :loading="dataLoading"
            :server-items-length="totalBlank"
            class="elevation-1 fix-column-width-bug blank-table"
        >
          <template #no-data>
            No available blank
          </template>

          <template #no-results>
            No available blank
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}" @click="clickRow(item.id)">
              <td class="text-left">{{item.field}}</td>
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
  import debounce from 'lodash.debounce'
  import {saveAs} from 'file-saver'

  export default {
    name: 'Blank',
    components: {
      Snackbar
    },
    data() {
      return {
        delay: 500,
        dialog: false,
        snackbar: {},
        blank: [],
        descending: true,
        footerProps: {
          'items-per-page-options': [25, 50, 100, 1000]
        },
        options: {
          itemsPerPage: 100
        },
        totalUsers: 0,
        dataLoading: true,
        headers: [
          {text: 'Field', value: 'field', show: true},
        ],
        search: ''
      }
    },
    watch: {
      options: {
        handler() {
          this.getBlank()
        },
        deep: true,
      },
    },
    methods: {
      clickRow(id) {
        this.$router.push({name: 'blank', params: {id: id}})
      }
    },
    debounceGetBlank: debounce(function () {
      this.dataLoading = true
      this.getBlank()
    }, 500),
    async getBlank() {
      const {sortBy, sortDesc, page, itemsPerPage} = this.options
      try {
        const {data} = await getRequest(`/blank/search`, {
          params: {
            query: this.search,
            page: page - 1,
            size: itemsPerPage
          }
        })
        this.blank = data.content
        this.totalBlank = data.totalElements
        this.dataLoading = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Blank')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async exportBlank() {
      this.dialog = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/blank/exportBlank`, {
          params: {
            query: this.search
          }
        })
        let blob = new Blob([data], {
          type: 'text/csv;charset=utf-8'
        });
        saveAs(blob, "blank.csv");
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Exporting Blank')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
  }
</script>

<style lang="scss">
  #blank-container .v-data-table__wrapper {
    height: calc(100vh - 400px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  #blank-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }

  .blank-table {
    margin-top: 2px;
  }

</style>

