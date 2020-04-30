<template>
<v-container id="smartlists-container">
  <v-row>
    <v-col cols="12">
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">Smartlists</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn text to="/smartlist/null" color="primary">
            <v-icon>add</v-icon>
            <span v-if="!IS_MOBILE">Add Smartlist</span>
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
    </v-col>

    <v-col cols="12">
      <v-data-table
        class="elevation-1"
        :headers="headers"
        :items="smartlists"
        fixed-header
        multi-sort
        hide-default-footer
        :loading="isSmartlistsLoading"
        disable-pagination
      >
        <template #no-data>
          No available smartlists
        </template>

        <template #no-results>
          No available smartlists
        </template>

        <template #item="{item: smartlist}">
          <tr class="clickable" @click="$router.push({name: 'smartlistEditor', params: {smartlistId: smartlist.id}})">
            <td class="text-left">{{smartlist.name}}</td>
            <td class="text-left">{{smartlist.objectType}}</td>
            <td class="text-left">{{smartlist.ownerId}}</td>
            <td class="text-left">{{smartlist.shared ? 'Yes' : 'No'}}</td>
          </tr>
        </template>
      </v-data-table>
    </v-col>
  </v-row>
  <Snackbar :snackbar="snackbar"/>
</v-container>
</template>

<script>

import {getRequest, getSnackbar, logError, IS_MOBILE} from '@/helpers/helpers'
import Snackbar from '@/components/Snackbar.vue'

export default {
  name: 'Smartlists',
  components: {
    Snackbar
  },
  data () {
    return {
      IS_MOBILE,
      isSmartlistsLoading: false,
      snackbar: {},
      smartlists: [],
      headers: [
        {text: 'Name', value: 'name'},
        {text: 'Type', value: 'companyObjectTypeId'},
        {text: 'Owner', value: 'ownerId'},
        {text: 'Public', value: 'shared'}
      ]
    }
  },
  created () {
    this.getSmartlists()
  },
  methods: {
    async getSmartlists () {
      try {
        const {data} = await getRequest(`/smartlist`)
        this.smartlists = data
      } catch (e) {
        logError(e)
      }
    }
  }
}
</script>

<style scoped lang="scss">

@import "@/styles/main.scss";

::v-deep {
  .v-data-table__wrapper {
    height: calc(100vh - 290px);
    min-height: 300px;
  }
}

tr:nth-of-type(even) {
  @extend .shaded-row;
}
</style>
