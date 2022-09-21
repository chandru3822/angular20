<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Configurations</v-toolbar-title>
        </v-toolbar>

        <div class="ma-3">
          WARNING: These values can represent many data types so there is no data validation or error handling done. Please use caution when making changes.
        </div>

        <v-data-table
          :headers="headers"
          :items="configurationValues"
          :items-per-page="-1"
          :mobile-breakpoint="0"
          hide-default-footer
          class="elevation-1 fix-column-width-bug square-card"
        >
          <template #no-data>
            <span class="default-text-color">No Configuration Values</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No Configuration Values</span>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">
                {{item.name}}
              </td>
              <td class="text-left">
                <v-text-field text
                              type="text"
                              v-if="index === editIndex"
                              label="Value"
                              v-model="item.value">
                </v-text-field>
                <div v-else>
                  {{ item.value }}
                </div>
              </td>
              <td>
                <v-btn small text color="primary" @click="editIndex = index" v-if="index !== editIndex">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text color="primary" @click="saveConfigurationValue(item)" v-if="index === editIndex">
                  <v-icon>save</v-icon>
                </v-btn>
                <v-btn small text color="primary" @click="editIndex = null" v-if="index === editIndex">
                  cancel
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
  name: 'Configurations',

  data () {
    return {
      constants,
      editIndex: null,
      snackbar: {},
      headers: [
        {text: 'Name', value: 'name', show: true},
        {text: 'Value', value: 'value', show: true},
        {text: null, value: 'icons', show: true}
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
