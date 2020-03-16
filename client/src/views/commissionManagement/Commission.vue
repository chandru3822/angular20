<template>
  <v-container class="pa-0" id="commission-container">
    <v-toolbar flat color="transparent">
      <v-toolbar-title>
        {{commission.name}}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div class="button-container">
          <v-btn color="red" dark class="mr-2">
            Inactivate
          </v-btn>
          <v-btn color="primaryCustom" dark>
            Clone
          </v-btn>
        </div>
      </v-toolbar-items>
    </v-toolbar>


    <v-divider></v-divider>
    <v-form ref="commissionForm">
      <v-container>
        <v-row>
          <v-col cols="12" sm="6">
            <v-card flat class="pa-3" color="transparent">
              <v-text-field text
                            label="Name"
                            v-model="commission.name"></v-text-field>
              <v-text-field text
                            label="Description"
                            v-model="commission.description"></v-text-field>
              <v-text-field text
                            label="Position"
                            v-model="commission.positionType"></v-text-field>
              <v-text-field text
                            label="Rate per kW ($)"
                            v-model="commission.total"></v-text-field>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6">
            <v-card class="pa-3">
              <v-text-field text
                            label="Status"
                            v-model="commission.statusType"></v-text-field>
              <v-text-field text
                            label="Created By"
                            v-model="commission.createdName"></v-text-field>
              <v-text-field text
                            label="Approved"
                            v-model="commission.approvedDate"></v-text-field>
              <v-text-field text
                            label="Approved By"
                            v-model="commission.approvedName"></v-text-field>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <v-row>
      <v-col>
        <v-card class="square-card">
          <v-card-title>
            Source Deductions
          </v-card-title>
        </v-card>
        <v-divider></v-divider>
        <v-data-table
            :headers="sourceHeaders"
            :items="commission.source"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            No available users
          </template>

          <template #no-results>
            No available users
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.source || 'how to do?'}}</td>
              <td class="text-left">{{item.feeAmount}}</td>
              <td class="text-left">{{item.feeType}}</td>
              <td class="text-left">{{item.milestoneType}}</td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <v-row>
      <v-col>
        <v-card class="square-card">
          <v-card-title>
            Users Assigned to Plan
          </v-card-title>
        </v-card>
        <v-divider></v-divider>
        <v-data-table
            :headers="headers"
            :items="commission.users"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            No available users
          </template>

          <template #no-results>
            No available users
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.name}}</td>
              <td class="text-left">{{item.position}}</td>
              <td class="text-left">{{item.employeeId}}</td>
              <td class="text-left">{{item.startDate}}</td>
              <td class="text-left">{{item.endDate}}</td>
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
    name: 'Commission',
    components: {
      Snackbar
    },
    created() {
      this.getCommissionDetails()
    },
    data() {
      return {
        snackbar: {},
        dataLoading: true,
        planId: this.$route.params.id,
        headers: [
          {text: 'Name', value: 'name', show: true},
          {text: 'Position', value: 'Position', show: true},
          {text: 'Employee ID', value: 'employeeId', show: true},
          {text: 'Start Date', value: 'startDate', show: true},
          {text: 'End Date', value: 'endDate', show: true},
        ],
        sourceHeaders: [
          {text: 'Source', value: 'source', show: true},
          {text: 'Fee Amount', value: 'feeAmount', show: true},
          {text: 'Fee Type', value: 'feeType', show: true},
          {text: 'Deduct at Milestone', value: 'deductAtMilestone', show: true},
        ],
        commission: {}
      }
    },
    methods: {
      async getCommissionDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/commissionManagement/plan/${this.planId}`, 'blueraven')
          this.commission = data ? data[0] : []
          // temporarily only allowing closers
          this.commission.positionType = 'closers'
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Commission Details')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      goToDetails (item) {
        console.log('handle going to item', item)
      }
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}
.button-container {
  display: flex;
  align-items: center;
}
</style>

