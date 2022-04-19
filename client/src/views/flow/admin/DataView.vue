<template>
  <v-container id="data-view-container">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">
            {{dataView.displayName}} ({{dataView.viewName}})
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newField = {}]">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-text-field
          v-model="search"
          class="mb-2 px-4 py-2"
          prepend-inner-icon="search"
          label="Search"
          single-line
          hide-details
        ></v-text-field>
        <v-divider></v-divider>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat >
          <h3>Add Field Config</h3>
          i dont know what to do here
          <v-btn :disabled="true"
                 color="primaryCustom" class="white--text mr-2"
                 @click="">
            Save
          </v-btn>
          <v-btn @click="[addNew = !addNew, newField = {}]">Cancel</v-btn>
        </v-card>

        <v-data-table
          v-if="dataView.dataViewFieldConfigs"
          :headers="headers"
          :items="dataView.dataViewFieldConfigs"
          :fixed-header="true"
          :items-per-page="100"
          :search="search"
          class="elevation-1"
        >
          <template #no-data>
            NO DATA HERE!
          </template>

          <template #no-results>
            No fields assigned
          </template>

          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': dataView.dataViewFieldConfigs.indexOf(item) % 2}">
              <td class="text-left">{{ item.fieldName }}</td>
              <td class="text-left">{{ item.fieldToUpdate }}</td>
              <td>
                <v-btn small text @click="">
                  <v-icon>edit</v-icon>
                </v-btn>

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
  import {handleHidingGlobalLoader, getRequest, putRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'DataView',

    data() {
      return {
        snackbar: {},
        constants,
        search: '',
        addNew: false,
        newField: {},
        viewId: parseInt(this.$route.params.id),
        dataView: {},
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        headers: [
          { text: 'Field Name', value: 'fieldName', show: true },
          { text: 'Field to Update', value: 'fieldToUpdate', show: true },
          { text: null, value: 'icons', show: true, sortable: false }
        ]
      }
    },
    async created () {
      this.getDataView()
    },
    methods: {
      async getDataView() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/dataView/${this.viewId}`)
          this.dataView = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>

<style lang="scss">
#data-view-container .v-data-table__wrapper {
  max-height: calc(100vh - 300px);
  min-height: 300px;
}
</style>
