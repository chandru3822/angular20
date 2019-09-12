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
            :options.sync="options"
            :search="search"
            :loading="dataLoading"
            :server-items-length="totalLeads"
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
import {AppMutations} from '@/stores/AppStore'
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
      options: {
        itemsPerPage: 100
      },
      totalLeads: 0,
      dataLoading: true,
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
  watch: {
    options: {
      handler () {
        this.getLeads()
      },
      deep: true,
    },
  },
  mounted () {
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
      const { sortBy, descending, page, itemsPerPage } = this.options
      try {
        const {data} = await getRequest(`/api/v1/flow/${this.companyId}/customer/search`, { params: {
            query: '',
            page: page - 1,
            size: itemsPerPage,
        }})
        this.leads = data.content
        this.totalLeads = data.totalElements
        this.dataLoading = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Leads')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
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

