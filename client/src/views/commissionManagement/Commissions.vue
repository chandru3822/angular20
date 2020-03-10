<template>
  <v-container>
    <v-row>
      <v-col>
        <v-data-table
            :headers="headers"
            :items="commissions"
            :fixed-header="true"
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
              <td class="text-left">{{item.planName}}</td>
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
          {text: 'Plan Name', value: 'planName', show: true},
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
          const {data} = await getRequest(`/commissionManagement/closers`, 'blueraven')
          this.commissions = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Commissions')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

