<template>
  <v-container class="pa-0" id="commission-overrides-container">
    <v-row>
      <v-col>
        <v-data-table
            :headers="headers"
            :items="overridePlans"
            :fixed-header="true"
            disable-sort
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            No available override plans
          </template>

          <template #no-results>
            No available override plans
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">
                <v-btn text @click="goToDetails(item)">
                  {{item.name}}
                </v-btn>
              </td>
              <td class="text-left">{{item.description}}</td>
              <td class="text-left">{{item.status}}</td>
              <td class="text-left">{{item.total}}</td>
              <td class="text-left">{{item.activeAssignedUsers}}</td>
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
    name: 'Overrides',
    components: {
      Snackbar
    },
    created() {
      this.getOverridePlans()
    },
    data() {
      return {
        snackbar: {},
        dataLoading: true,
        headers: [
          {text: 'Name', value: 'name', show: true},
          {text: 'Description', value: 'description', show: true},
          {text: 'Status', value: 'status', show: true},
          {text: 'Total', value: 'total', show: true},
          {text: 'Active Assigned Users', value: 'activeAssignedUsers', show: true},
        ],
        overridePlans: []
      }
    },
    methods: {
      async getOverridePlans () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/commissionManagement/overrides`, 'blueraven')
          this.overridePlans = data
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Override Plans')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      goToDetails (item) {
        this.$router.push({name: 'override', params: {id: item.id}})
      }
    }
  }
</script>

<style lang="scss">
#commission-overrides-container .v-data-table__wrapper {
  height: calc(100vh - 350px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}
</style>

