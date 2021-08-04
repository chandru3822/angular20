<template>
  <v-container class="app-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Work Queue</v-toolbar-title>
        </v-toolbar>
        <v-divider class="mt-3"/>
        <v-row class="justify-center">
          <v-btn class="wq-button mx-2 mt-3 white--text" color="primaryCustom"
                 :outlined="showAll && !selectedWorkQueueCategory.id"
                 @click="[showAll = !showAll, selectedWorkQueueCategory = {}, getWorkQueues()]">
            All
          </v-btn>
          <v-btn v-for="(c, index) in workQueueCategories" class="wq-button mx-2 mt-3"
                 :outlined="selectedWorkQueueCategory.id === c.id"
                 :style="{color: selectedWorkQueueCategory.id === c.id ? `${c.color} !important` : 'white !important'}"
                 :color="c.color" :key="index" @click="getWorkQueues(true, c)">
            {{ c.workQueueCategory }}
          </v-btn>
        </v-row>
        <v-divider class="mt-3"/>
        <v-row>
          <v-col cols="12" md="4" class="px-5">
            <v-select v-model="selectedUserPosition"
                      :items="workQueueOwners"
                      label="Assigned to"
                      item-text="fullName"
                      return-object
                      @input="getWorkQueues(false)"
            ></v-select>
          </v-col>
          <v-col cols="12" md="8" class="radio-group-container pr-5">
            <v-radio-group id="wqt-view-type-selector" v-model="selectedViewType" column>
              <v-radio class="d-inline-block mx-4" label="% Completed On Time" :value="0"></v-radio>
              <v-radio class="d-inline-block mx-4" label="Total Completed Tasks" :value="1"></v-radio>
              <v-radio class="d-inline-block mx-4" label="Change in WIP" :value="2"></v-radio>
            </v-radio-group>
          </v-col>
        </v-row>
        <v-row>
          <v-card tile v-for="wq in workQueues" class="ma-3 flex-display card-main elevation-0"
                  :class="{'clickable': wq.workQueueCount > 0}"
                  :style="{'border-color': wq.color}"
                  :key="wq.id"
                  width="200" :height="wqHasMetrics(wq) ? 170 : 90">
            <div class="card-accent" :style="{'background-color': wq.color}"></div>
            <v-card-text class="pt-1 px-0">
              <router-link class="no-text-decoration card-link"
                           :to="{name: 'workQueueDrilldown', params: {id: wq.workQueueTypeId}, query: { smartlistId: wq.smartlistId, upId: selectedUserPosition.userId, unassigned: selectedUserPosition.unassigned}}">
                <div class="card-title-container text-left">
                  <div class="card-title ellipse two-lines">{{ wq.workQueueType }}</div>
                  <div class="card-count">{{ wq.workQueueCount }}</div>
                </div>

                <div class="card-metrics-container"
                     :style="{'background-color': wq.color + '60' }"
                     v-if="wqHasMetrics(wq)">
                  <div class="card-metrics-expected-cycle">
                    Completed within expected time of {{ wq.expectedCycle }}
                    {{ getDurationTypePluralization(wq.expectedCycle, wq.expectedCycleDurationType) }}
                  </div>
                  <div class="card-metric card-metric-left"
                       :style="{'border-right': getBorder(wq) }">
                    {{ wq.shortWindow }} {{ getDurationTypePluralization(wq.shortWindow, wq.shortWindowDurationType) }}
                    <div class="card-metric-percent"
                         v-if="selectedViewType === 0"
                         :class="getMetricPercentColor(wq.shortWindowPercentage, wq.expectedTarget, wq.inverseExpectation)">
                      {{ wq.shortWindowPercentage * 100 | currency('', 0)}}%
                      <span class="card-metric-difference">
                          {{ getMetricDifference(wq.shortWindowPercentage, wq.expectedTarget, wq.inverseExpectation) }}
                        </span>
                    </div>
                    <div class="card-metric-percent"
                         v-else-if="selectedViewType === 1"
                         :class="getMetricPercentColor(wq.shortWindowPercentage, wq.expectedTarget, wq.inverseExpectation)">
                      ??
                    </div>
                    <div class="card-metric-percent"
                         v-else-if="selectedViewType === 2"
                         :class="getMetricPercentColor(wq.shortWindowPercentage, wq.expectedTarget, wq.inverseExpectation)">
                      {{ wq.shortWip >= 0 ? '+' : '-' }}{{ wq.shortWip }}
                    </div>
                  </div>
                  <div class="card-metric">
                    {{ wq.longWindow }} {{ wq.longWindowDurationType }}
                    <div class="card-metric-percent"
                         v-if="selectedViewType === 0"
                         :class="getMetricPercentColor(wq.longWindowPercentage, wq.expectedTarget, wq.inverseExpectation)">
                      {{ wq.longWindowPercentage * 100 | currency('', 0)}}%
                      <span class="card-metric-difference">
                          {{ getMetricDifference(wq.longWindowPercentage, wq.expectedTarget, wq.inverseExpectation) }}
                        </span>
                    </div>
                    <div class="card-metric-percent"
                         v-else-if="selectedViewType === 1"
                         :class="getMetricPercentColor(wq.longWindowPercentage, wq.expectedTarget, wq.inverseExpectation)">
                      ??
                    </div>
                    <div class="card-metric-percent"
                         v-else-if="selectedViewType === 2"
                         :class="getMetricPercentColor(wq.longWindowPercentage, wq.expectedTarget, wq.inverseExpectation)">
                      {{ wq.longWip >= 0 ? '+' : '-' }}{{ wq.longWip }}
                    </div>
                  </div>
                </div>
              </router-link>
            </v-card-text>
          </v-card>
        </v-row>
      </v-col>
    </v-row>

  </v-container>
</template>


<script>
import {AppMutations} from '@/stores/AppStore'

import orderBy from 'lodash.orderby'
import {getWorkQueueCategories} from '@/services/workQueueService'
import {getRequest, getRequestWithParams, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

export default {
  name: 'WorkQueue',

  data() {
    return {
      snackbar: {},
      model: {},
      showAll: false,
      selectedWorkQueueCategory: {},
      workQueueCategories: [],
      workQueues: [],
      selectedViewType: 0,
      selectedUserPosition: {},
      workQueueOwners: [],
      anyOwner: {id: -1, fullName: 'Anyone', userId: null, unassigned: false},
      noOwner: {id: -99, fullName: 'Unassigned', userId: null, unassigned: true}
    }
  },
  computed: {},
  async created() {
    this.getWorkQueueCategories()
    this.getWorkQueueOwners()
    this.selectedWorkQueueCategory.id = parseInt(localStorage.getItem('wqCategoryId'))
    if (this.selectedWorkQueueCategory.id) {
      this.getWorkQueues()
    }
  },
  methods: {
    wqHasMetrics(wq) {
      return wq.shortWindow && wq.longWindow && wq.expectedCycle
        && wq.shortWindowDurationType && wq.longWindowDurationType && wq.expectedCycleDurationType
    },
    async getWorkQueueCategories() {
      try {
        const {data} = await getWorkQueueCategories()
        this.workQueueCategories = orderBy(data, [wqc => wqc.displayOrder])
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queue Categories')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getWorkQueueOwners() {
      try {
        const {data} = await getRequest(`/workQueue/owners`)
        this.workQueueOwners = data
        this.workQueueOwners.unshift(this.noOwner)
        this.workQueueOwners.unshift(this.anyOwner)

      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queue Owners')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getWorkQueues(reset, c) {
      if (reset) {
        this.selectedWorkQueueCategory = c && c.id !== this.selectedWorkQueueCategory.id ? c : {}
      }
      localStorage.setItem('wqCategoryId', JSON.stringify(this.selectedWorkQueueCategory.id))
      if (this.selectedWorkQueueCategory?.id || this.showAll) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequestWithParams(`/workQueue`, {
            params: {
              workQueueCategoryId: this.selectedWorkQueueCategory.id,
              userId: this.selectedUserPosition.userId,
              unassigned: this.selectedUserPosition.unassigned
            }
          })
          this.workQueues = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queues')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      } else {
        this.workQueues = []
      }
    },
    loadDrilldown(wq) {
      if (wq.workQueueCount > 0) {
        this.$router.push({
          name: 'workQueueDrilldown',
          params: {id: wq.workQueueTypeId},
          query: {upId: this.selectedUserPosition.userId, unassigned: this.selectedUserPosition.unassigned}
        })
        // this.$router.push({name: 'contact', params: {id: data.id}})
      }
    },
    getDurationTypePluralization(duration, durationType) {
      return duration === 1 ? durationType.slice(0, -1) : durationType
    },
    getMetricPercentColor(value, expectation, inverse) {
      if (inverse) {
        return value <= expectation ? 'expectation-met' : 'expectation-missed'
      } else {
        return value >= expectation ? 'expectation-met' : 'expectation-missed'
      }
    },
    getMetricDifference(valuePercent, expectationPercent, inverse) {
      if (inverse) {
        let difference = (expectationPercent - valuePercent) * 100
        let symbol = difference >= 0 ? '-' : ''
        return symbol + this.$filters.currency(difference, '', 0) + '%'
      } else {
        let difference = (valuePercent - expectationPercent) * 100
        let symbol = difference >= 0 ? '+' : ''
        return symbol + this.$filters.currency(difference, '', 0) + '%'
      }
    },
    getBorder(wq) {
      return `solid 1px ${wq.color}`
    }
  },

}
</script>

<style lang="scss">
#wqt-view-type-selector {
  display: block !important;
}
</style>

<style scoped lang="scss">
.card-main {
  /* @click adds the pointer but i didnt want the pointer on count == 0 */
  cursor: default;
  text-align: center;
  border: solid 2px;
}

.card-accent {
  height: 100%;
  width: 5px;
  /*border-radius: 4px 0 0 4px !important;*/
}

.card-count {
  width: 40%;
  display: inline-block;
  line-height: 2;
  text-align: center;
  font-size: 30px;
  font-weight: 600;
  white-space: nowrap;
}

.card-link {
  color: #666666;
}

.card-title-container {
  width: calc(100% - 5px);
  height: 85px;
  padding-right: 4px;
  padding-left: 10px;
  padding-bottom: 5px;
  display: flex;
  align-items: center;
}

.card-title {
  width: 60%;
  overflow: hidden;
  max-height: 100%;
  display: inline-block;
}

.ellipse {
  white-space: nowrap;
  display: inline-block;
  overflow: hidden;
  text-overflow: ellipsis;
}

.two-lines {
  -webkit-line-clamp: 3;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  white-space: normal;
}

.card-metrics-container {
  height: 80px;
  border-top: solid 1px #D8D9DA;
  width: calc(100% - 5px);
  position: absolute;
  bottom: 0;
  right: 0;
  left: 5px;
  font-size: 12px;
}

.card-metrics-expected-cycle {
  height: 20px;
  font-size: 9px;
}

.card-metric {
  width: 50%;
  height: calc(100% - 25px);
  display: inline-block;
}

.card-metric-percent {
  font-size: 20px;
  font-weight: 600;
  margin-top: 3px;
  margin-bottom: 3px;
}

.card-metric-difference {
  font-size: 11px;
  font-weight: normal;
}

.radio-group-container {
  display: flex;
  justify-content: flex-end;
}

.expectation-met {
  color: green;
}

.expectation-missed {
  color: red;
}
</style>
