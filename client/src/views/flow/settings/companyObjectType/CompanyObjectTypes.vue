<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <div v-if="!apiPath">
          No data available.
        </div>
        <v-data-table
          v-else
          :headers="headers"
          :items="companyObjectTypes"
          disable-sort
          :fixed-header="true"
          :items-per-page="-1"
          class="elevation-1">

          <template #no-data>
            No available object types
          </template>

          <template #no-results>
            No available object types
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{ item.objectType }}</td>
              <td>
                <div style="display: flex; justify-content: flex-end">
                  <v-btn small text @click="goToDetails(item)">
                    <v-icon>edit</v-icon>
                  </v-btn>
                </div>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
import constants from '@/helpers/constants'
import {getRequest, getSnackbar, logError} from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";

export default {
  name: 'CompanyObjectTypes',
  data () {
    return {
      snackbar: {},
      constants,
      companyObjectTypes: [],
      apiPath: this.$store.state.user.details.apiPath,
      headers: [
        {text: 'Object Type', value: 'objectType'},
        {text: '', value: 'icons', show: true},
      ],
    }
  },

  created () {
    if(null != this.apiPath) {
      this.getCompanyObjectTypes()
    }
  },
  methods: {
    async getCompanyObjectTypes() {
      try {
        const {data} = await getRequest(`/objectType/getCustomFieldObjectTypes`, 'blueraven')
        this.companyObjectTypes = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching object types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    goToDetails (item) {
      this.$router.push({name: 'companyObjectTypes', params: {id: item.id}})
    }
  }
}
</script>
