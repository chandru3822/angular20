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
        Randa do your job already
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import {getRequest, deleteRequest, putRequest, postRequest} from '@/helpers/helpers'

export default {
  name: 'Leads',
  data () {
    return {
      leads: [],
      companyId: this.$store.state.user.details.companyId
    }
  },
  created () {
    this.getLeads()
  },
  methods: {
    async getLeads () {
      const {data} = await getRequest(`/api/v1/flow/${this.companyId}/leads`)
      this.leads = data
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

