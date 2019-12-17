<template>
  <v-container id="positions-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Positions</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text to="/newPositions" color="primary">
              <v-icon>add</v-icon>
              Add Position
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="positions"
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
            <tr class="clickable" :class="{'shaded-row': index % 2}" @click="clickRow(item.id)">
              <td class="text-left">{{item.position}}</td>
              <td class="text-left">{{item.orgType}}</td>
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
  import {getRequest, getRequestWithParams, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import debounce from 'lodash.debounce'
  import {saveAs} from 'file-saver'

  export default {
    name: 'Positions',
    components: {
      Snackbar
    },
    data() {
      return {
        delay: 500,
        dialog: false,
        snackbar: {},
        positions: [],
        descending: true,
        dataLoading: true,
        headers: [
          {text: 'Position Name', value: 'positionName', show: true},
          {text: 'Org Type', value: 'orgType', show: true},
        ],
      }
    },
    created () {
      this.getPositions()
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
      }
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

