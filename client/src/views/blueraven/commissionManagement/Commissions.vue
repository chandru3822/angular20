<template>
  <v-container class="pa-0" id="commissions-container">
    <v-divider></v-divider>
    <v-toolbar flat color="white">
      <v-toolbar-title>
        Commission Plans
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn text @click="goToDetails({})" v-if="$store.getters.userHasFeatureAccessLevel('COMMISSIONS', 'ADD')">
          <v-icon>add</v-icon>
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <v-divider></v-divider>
    <v-row>
      <v-col class="pt-0">
        <v-card>
          <v-card-title class="pt-0">
            <v-text-field
              v-model="search"
              prepend-inner-icon="search"
              label="Search"
              single-line
              hide-details
            ></v-text-field>
          </v-card-title>
          <v-divider></v-divider>
          <v-data-table
              :headers="headers"
              :items="commissions"
              :fixed-header="true"
              :items-per-page="-1"
              :search="search"
              :loading="dataLoading"
              hide-default-footer
              class="elevation-1"
          >
            <template #no-data>
              No available commissions
            </template>

            <template #no-results>
              No available commissions
            </template>

            <template #item="{ item, index }">
              <tr class="clickable" :class="{'shaded-row': index % 2}">
                <td class="text-left">
                  <v-btn text @click="goToDetails(item)">
                    {{item.name}}
                  </v-btn>
                </td>
                <td class="text-left">{{item.description}}</td>
                <td class="text-left">{{item.statusType}}</td>
                <td class="text-left">{{item.activeUsers}}</td>
              </tr>
            </template>
          </v-data-table>
        </v-card>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Commissions',

    created() {
      this.getCommissions()
    },
    watch: {
      '$store.state.brs.commissionPositionId': function () {
        this.positionId = this.$store.state.brs.commissionPositionId
        this.getCommissions()
      }
    },
    data() {
      return {
        snackbar: {},
        dataLoading: true,
        positionId: this.$store.state.brs.commissionPositionId,
        search: '',
        headers: [
          {text: 'Plan Name', value: 'name', show: true},
          {text: 'Description', value: 'description', show: true},
          {text: 'Status', value: 'statusType', show: true},
          {text: 'Active Users', value: 'activeUsers', show: true},
        ],
        commissions: []
      }
    },
    methods: {
      async getCommissions () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/commissionManagement/plans/${this.positionId}`, 'blueraven')
          this.commissions = data
          this.dataLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Commissions')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      goToDetails (item) {
        this.$router.push({name: 'commission', params: {id: item.id}})
      }
    }
  }
</script>

<style lang="scss">
#commissions-container .v-data-table__wrapper {
  height: calc(100vh - 350px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}
</style>

