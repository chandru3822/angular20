<template>
  <v-container class="app-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Work Queue</v-toolbar-title>
        </v-toolbar>
        <v-divider class="mt-3"/>
        <v-row class="justify-center mt-3">
          <v-btn v-for="(c, index) in workQueueCategories" class="wq-button mx-2"
                 :outlined="selectedWorkQueueCategory.id === c.id"
                 :style="{color: selectedWorkQueueCategory.id === c.id ? `${c.color} !important` : 'white !important'}"
                 :color="c.color" :key="index" @click="getWorkQueues(true, c)">
            {{c.workQueueCategory}}
          </v-btn>
        </v-row>
        <v-divider class="mt-3"/>
        <v-row class="px-4">
          <div style="width: 250px">
            <v-select v-model="selectedUserPositionId"
                      :items="workQueueOwners"
                      label="Assigned to"
                      item-text="fullName"
                      item-value="userPositionId"
                      @input="getWorkQueues(false)"
            ></v-select>
          </div>
        </v-row>
        <v-row>
          <v-card tile v-for="wq in workQueues" class="ma-3 flex-display card-main"
                  :class="{'clickable': wq.workQueueCount > 0}"
                  @click="loadDrilldown(wq)"
                  width="200" height="100" >
            <div class="card-accent" :style="{'background-color': wq.color}"></div>
            <v-card-text class="pt-1 pr-0">
              <div class="text-left">{{wq.workQueueType}}</div>
              <div class="card-count">{{wq.workQueueCount}}</div>
            </v-card-text>
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
        workQueues: [],
        selectedUserPositionId: null,
        workQueueOwners: [],
        anyOwner: { id: -1, fullName: 'Anyone', userPositionId: null}
      }
    },
    computed: {},
    async created() {
      this.getWorkQueueCategories()
      this.getWorkQueueOwners()
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
      async getWorkQueueOwners() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/workQueue/owners`)
          this.workQueueOwners = data
          this.workQueueOwners.unshift(this.anyOwner)

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queue Owners')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getWorkQueues(reset, c) {
        if(reset) {
          this.selectedWorkQueueCategory = c && c.id !== this.selectedWorkQueueCategory.id ? c : {}
        }
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequestWithParams(`/workQueue`, { params: {
              workQueueCategoryId: this.selectedWorkQueueCategory.id,
              userPositionId: this.selectedUserPositionId
            }})
          this.workQueues = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queues')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      loadDrilldown(wq) {
        if(wq.workQueueCount > 0) {
          this.$router.push({name: 'workQueueDrilldown', params: {id: wq.workQueueTypeId}, query: { upId: this.selectedUserPositionId}})
          // this.$router.push({name: 'customer', params: {id: data.id}})
        }
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
