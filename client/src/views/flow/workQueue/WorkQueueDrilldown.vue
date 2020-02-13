<template>
  <v-container class="app-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title" v-if="results.length > 0">{{results[0].workQueueType}}</v-toolbar-title>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="results"
            :fixed-header="true"
            :items-per-page="-1"
            hide-default-footer
            disable-sort
            class="elevation-1 mt-1"
            @click:row="clickRow"
        >
          <template #no-data>
            No available results
          </template>

          <template #no-results>
            No available results
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
  import {getRequest, getRequestWithParams, deleteRequest, putRequest, postRequest, getSnackbar, IS_MOBILE} from '@/helpers/helpers'

  export default {
    name: 'WorkQueueDrilldown',
    components: {
      Snackbar
    },
    data() {
      return {
        snackbar: {},
        IS_MOBILE,
        workQueueTypeId: this.$route.params.id,
        userPositionId: this.$route.query.upId,
        results: [],
        headers: [
          { text: 'Project', value: 'projectName', show: true },
          { text: 'Process Step', value: 'processStepName', show: true },
          { text: 'Owner', value: 'owner', show: true },
        ],
      }
    },
    computed: {},
    async created() {
      this.getWorkDetails()
    },
    methods: {
      async getWorkDetails() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequestWithParams(`/workQueue/${this.workQueueTypeId}`, { params: {
              userPositionId: this.userPositionId
            }})
          this.results = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Results')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      clickRow(row) {
        this.$router.push({path: `/project/${row.projectId}/processStep/${row.projectProcessStepId}?processStepId=${row.processStepId}&customerId=${row.customerId}`})
      }
    },

  }
</script>

<style scoped lang="scss">

.card-main {
  /* @click adds the pointer but i didnt want the pointer on count == 0 */
  cursor: default;
}
.card-accent {
  height: 100%;
  width: 5px;
  /*border-radius: 4px 0 0 4px !important;*/
}
.card-count {
  line-height: 2;
  font-size: 30px;
  font-weight: 600;
}
</style>
