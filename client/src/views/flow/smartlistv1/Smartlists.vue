<template>
<v-container id="smartlists-container">
  <v-row>
    <v-col cols="12">
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">Smartlists</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn text to="/smartlistv1/null" color="primary">
            <v-icon>add</v-icon>
            <span v-if="!constants.IS_MOBILE">Add Smartlist</span>
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
    </v-col>

    <v-col cols="12">
      <v-card flat class="square-card pb-3 px-3" color="white">
        <v-text-field
          v-model="search"
          append-icon="mdi-magnify"
          label="Search"
          single-line
          hide-details
        ></v-text-field>
      </v-card>
      <v-divider></v-divider>
      <v-data-table
        class="elevation-1"
        :headers="headers"
        :items="smartlists"
        fixed-header
        multi-sort
        :search="search"
        :items-per-page="25"
        :footer-props="footerProps"
        :loading="isSmartlistsLoading"
      >
        <template #no-data>
          <span class="default-text-color">No available smartlists</span>
        </template>

        <template #no-results>
          <span class="default-text-color">No available smartlists</span>
        </template>

        <template #item="{item: smartlist}">
          <tr class="clickable" @click="$router.push({name: 'smartlistEditor', params: {smartlistId: smartlist.id}})">
            <td class="text-left">{{smartlist.name}}</td>
            <td class="text-left">{{smartlist.viewObjectType}}</td>
            <td class="text-left">{{smartlist.owner}}</td>
            <td class="text-left">{{smartlist.shared ? 'Yes' : 'No'}}</td>
          </tr>
        </template>
      </v-data-table>
    </v-col>
  </v-row>
</v-container>
</template>

<script>

import {getRequest, logError} from '@/helpers/helpers'
import constants from '@/helpers/constants'


export default {
  name: 'Smartlists',
  data () {
    return {
      constants,
      isSmartlistsLoading: false,
      snackbar: {},
      search: '',
      smartlists: [],
      footerProps: {
        'items-per-page-options': [25, 50, 100, 500]
      },
      headers: [
        {text: 'Name', value: 'name'},
        {text: 'Table Display View', value: 'objectType'},
        {text: 'Owner', value: 'owner'},
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
        const {data} = await getRequest(`/smartlistv1`)
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
