<template>
  <v-container>
    <v-row>
      <v-col>
        <v-data-table
            :headers="headers"
            :items="closers"
            :fixed-header="true"
            disable-sort
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            No available closers
          </template>

          <template #no-results>
            No available closers
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.closerName}}</td>
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
    name: 'Closers',
    components: {
      Snackbar
    },
    created() {
      this.getClosers()
    },
    data() {
      return {
        snackbar: {},
        dataLoading: true,
        headers: [
          {text: 'Closer Name', value: 'closerName', show: true},
          {text: 'Commissions Assigned To', value: 'assignedTo', show: true},
          {text: 'Overrides Assigned To', value: 'overridesAssignedTo', show: true},
          {text: 'Receiving Overrides From', value: 'receivingOverridesFrom', show: true},
          {text: 'Has Commission Plan Gap', value: 'planGap', show: true},
        ],
        closers: []
      }
    },
    methods: {
      async getClosers () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/commissionManagement/closers`, 'blueraven')
          this.closers = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Closers')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>
/* v-data-table is doing some weird spacing */
.container {
  padding: 0 !important;
}
.v-data-table {
  border-radius: 0;
}
</style>

