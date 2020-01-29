<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Work Queue</v-toolbar-title>
        </v-toolbar>
        <v-divider class="mt-3"/>
        <v-row class="justify-center mt-3">
          <v-btn v-for="(c, index) in workQueueCategories" class="white--text"
                 :color="c.color" :key="index" @click="getWorkQueues(c)">
            {{c.workQueueCategory}}
          </v-btn>
        </v-row>
        <v-divider class="mt-3"/>
        <v-row>
          <v-card v-for="wq in workQueues"
                  width="200" height="100">
            <div style="height: 100px; background-color: blue; width: 20px;"></div>
            <div>{{wq.workQueueType}}</div>
            <div>{{wq.workQueueCount}}</div>
          </v-card>
        </v-row>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>


<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import orderBy from 'lodash.orderby'
  import {getWorkQueueCategories} from '@/services/workQueueService'
  import {getRequest, getRequestWithParams, deleteRequest, putRequest, postRequest, getSnackbar, IS_MOBILE} from '@/helpers/helpers'

  export default {
    name: 'WorkQueue',
    components: {
      Snackbar
    },
    data() {
      return {
        snackbar: {},
        IS_MOBILE,
        model: {},
        selectedWorkQueueCategory: {},
        workQueueCategories: [],
        workQueues: []
      }
    },
    computed: {},
    async created() {
      this.getWorkQueueCategories()
      this.getWorkQueues()
    },
    methods: {
      async getWorkQueueCategories() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getWorkQueueCategories()
          this.workQueueCategories = orderBy(data, [wqc => wqc.workQueueCategory.toLowerCase()])

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queue Categories')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getWorkQueues(c) {
        this.selectedWorkQueueCategory = c??
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequestWithParams(`/workQueue`, { params: {
              workQueueCategoryId: c?.id
            }})
          this.workQueues = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queues')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },

  }
</script>

<style scoped lang="scss">

</style>
