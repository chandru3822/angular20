<template>
  <v-container class="pa-0" id="commissions-container">
    <v-row>
      <v-col>
        <v-data-table
            :headers="headers"
            :items="commissions"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
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
    name: 'Commissions',
    components: {
      Snackbar
    },
    created() {
      this.getCommissions()
    },
    data() {
      return {
        snackbar: {},
        dataLoading: true,
        headers: [
          {text: 'Plan Name', value: 'name', show: true},
          {text: 'Description', value: 'description', show: true},
          {text: 'Status', value: 'status', show: true},
          {text: 'Active Users', value: 'activeUsers', show: true},
        ],
        commissions: []
      }
    },
    methods: {
      async getCommissions () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/commissionManagement/commissionPlans`, 'blueraven')
          this.commissions = data
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Commissions')
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

