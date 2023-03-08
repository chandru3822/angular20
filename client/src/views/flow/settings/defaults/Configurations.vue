<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">Configurations</v-toolbar-title>
        </v-toolbar>

        <div class="ma-3">
          WARNING: These values can represent many data types so there is no data validation or error handling done. Please use caution when making changes.
        </div>

        <v-data-table
          :headers="headers"
          :items="configurationValues"
          :items-per-page="-1"
          :mobile-breakpoint="960"
          hide-default-footer
          class="elevation-1 square-card table-striped"
        >
          <template #no-data>
            <span class="default-text-color">No Configuration Values</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No Configuration Values</span>
          </template>

          <template #item.value="{ item, index }">
                <v-text-field text
                              style="overflow-wrap: anywhere"
                              type="text"
                              v-if="index === editIndex"
                              label="Value"
                              v-model="item.value">
                </v-text-field>
                <div v-else style="overflow-wrap: anywhere">
                  {{ item.value }}
                </div>
          </template>
              <template #item.icons = "{item, index}">
                <v-btn small :large="$vuetify.breakpoint.smAndDown" icon color="primary" @click="editIndex = index" v-if="index !== editIndex">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small :large="$vuetify.breakpoint.smAndDown" icon color="primary" @click="saveConfigurationValue(item)" v-if="index === editIndex">
                  <v-icon>save</v-icon>
                </v-btn>
                <v-btn small :large="$vuetify.breakpoint.smAndDown" icon color="primary" @click="editIndex = null" v-if="index === editIndex && $vuetify.breakpoint.smAndDown">
                  <v-icon>close</v-icon>
                </v-btn><v-btn small text color="primary" @click="editIndex = null" v-else-if="index === editIndex">
                  cancel
                </v-btn>
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
  name: 'Configurations',

  data () {
    return {
      constants,
      editIndex: null,
      snackbar: {},
      headers: [
        {text: 'Name', value: 'name', show: true},
        {text: 'Value', value: 'value', show: true},
        {text: null, value: 'icons', show: true, sortable: false}
      ],
      configurationValues: [],
      companyId: this.$store.state.user.details.companyId,
    }
  },
  computed: {
  },
  async created () {
    this.getConfigurationValues()
  },
  methods: {
    async getConfigurationValues() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/companies/${this.companyId}/configuration`)
        this.configurationValues = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveConfigurationValue(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await putRequest(`/companies/${this.companyId}/configuration`, item)
        this.editIndex = null
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Configuration Value')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  },
}
</script>
<style lang="scss">
#app > div.v-application--wrap > main > div > div > div > div > div.px-4.pt-0.main-section.col-md-9.col-12 > div > div > div > div.container > div > div > div.v-data-table.elevation-1.square-card.table-striped.theme--light.v-data-table--mobile > div > table > thead > tr > th > div > div > div > div > div.v-select__slot > div.v-select__selections > span > span > div {
  background-color: inherit !important;
}
</style>
