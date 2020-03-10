<template>
  <v-container>
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
              <td class="text-left">{{item.name}}</td>
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
          const {data} = await getRequest(`/commissionManagement/closers`, 'blueraven')
          this.overridePlans = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Override Plans')
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

