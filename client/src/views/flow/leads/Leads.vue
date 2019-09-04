<template>
  <v-container id="leads-container">
    <v-row>
      <v-col xs-12>
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Leads</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text to="/newLead" color="primary">
              <v-icon>add</v-icon>
              Add Lead
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-toolbar color="white" class="elevation-1 mt-4">
          <v-text-field
              class="mt-4"
              prepend-inner-icon="search"
              text
              label="Search leads..."
              v-model="search"
          ></v-text-field>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="exportLeads">Export</v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="leads"
            :items-per-page="-1"
            :search="search"
            hide-default-footer
            class="elevation-1 fix-column-width-bug"
        >
          <template #no-data>
            No available leads
          </template>

          <template #no-results>
            No available leads
          </template>
          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}" @click="clickRow(item.id)">
              <td class="text-left">{{item.fullName}}</td>
              <td class="text-left">{{item.status}}</td>
              <td class="text-left">{{item.owner}}</td>
              <td class="text-left">{{item.state}}</td>
              <td class="text-left">{{item.lastActivity | formatDate('date', $store.state.user.details.timezone)}}</td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
import Snackbar from '@/components/Snackbar.vue'
import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

export default {
  name: 'Leads',
  components: {
    Snackbar
  },
  data () {
    return {
      snackbar: {},
      leads: [],
      companyId: this.$store.state.user.details.companyId,
      headers: [
        { text: 'Lead Name', value: 'fullName', show: true },
        { text: 'Status', value: 'status', show: true },
        { text: 'Owner', value: 'owner', show: true },
        { text: 'State', value: 'state', show: true },
        { text: 'Last Activity', value: 'lastActivity', show: true },
      ],
      search: ''
    }
  },
  created () {
    this.getLeads()
  },
  methods: {
    clickRow(id){
      this.$router.push({name: 'lead', params: {id}})
    },
    exportLeads() {
      console.log('EXPORT WAS CLICKED')
    },
    async getLeads () {
      // const {data} = await getRequest(`/api/v1/flow/${this.companyId}/customer`)
      // this.leads = data
      //figure out how to load this with the cool tables
      this.leads = [
        { id: 111112, fullName: 'One Two', status: 'Active', owner: 'Probincrux', state: 'Colorado', lastActivity: '2018-12-12'}
      ]
    }
  }
}
</script>

<style lang="scss" scoped>
  #leads-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }
</style>

