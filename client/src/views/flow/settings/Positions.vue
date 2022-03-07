<template>
  <v-container id="positions-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Positions</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text to="/settings/position" color="primaryCustom" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              <v-icon>add</v-icon>
              Add Position
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <div class="pa-4">
          <v-text-field
            v-model="search"
            prepend-inner-icon="search"
            label="Search"
            single-line
            hide-details
          ></v-text-field>
        </div>
        <v-data-table
            :headers="headers"
            :items="filterPositions()"
            :fixed-header="true"
            :search="search"
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
              <td class="text-left" @click="clickRow(item.id)">
                {{item.position}}
              </td>
              <td class="text-left" @click="clickRow(item.id)">
                {{item.orgType}}
              </td>
              <td class="px-0">
                <v-btn small fab text class="d-inline-block" @click="clickRow(item.id)">
                  <v-icon>mdi-pencil</v-icon>
                </v-btn>
                <confirm-delete-dialog
                    v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                    label="this position: "
                    :item-to-delete="item.position"
                    @confirm-delete="deletePosition(item)"
                ></confirm-delete-dialog>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, deleteRequest, getSnackbar} from '@/helpers/helpers'
  import ConfirmDeleteDialog from "@/ConfirmDeleteDialog";

  export default {
    name: 'Positions',
    components: {ConfirmDeleteDialog},
    data() {
      return {
        delay: 500,
        addNew: false,
        snackbar: {},
        positions: [],
        descending: true,
        dataLoading: true,
        search: '',
        headers: [
          {text: 'Position Name', value: 'position', show: true},
          {text: 'Org Type', value: 'orgType', show: true},
          {text: '', value: 'icons', show: false, width: '100px'},
        ]
      }
    },
    created () {
      this.getPositions()
    },
    methods: {
      clickRow(id) {
        this.$router.push({name: 'position', params: {id: id}})
      },
      async getPositions() {
        try {
          const {data, status} = await getRequest(`/position`)
          this.positions = data
          this.dataLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deletePosition(p) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/position/${p.id}`)
          p.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'Position Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Position')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterPositions () {
        return this.positions.filter(p => { return !p.archived})
      },
    }
  }
</script>

<style lang="scss">
  #positions-container .v-data-table__wrapper {
    height: calc(100vh - 300px);
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

