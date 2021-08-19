<template>
  <v-container class="wq-container">
    <v-row>
      <v-col cols="12" class="px-0 pt-3">
        <v-autocomplete v-model="selectedWorkQueueCategory"
                        :items="workQueueCategories"
                        label="Work Queue Category"
                        item-text="workQueueCategory"
                        item-value="id"
                        return-object
                        solo
                        hide-details
                        dark
                        background-color="primaryCustom"
                        class="white--text work-queue-selector d-inline-block clickable"
                        @input="getWorkQueues()"
        ></v-autocomplete>
<!--        <v-select v-model="selectedUserPosition"-->
<!--                  :items="workQueueOwners"-->
<!--                  label="Assigned to"-->
<!--                  class="work-queue-selector d-inline-block pl-3"-->
<!--                  item-text="fullName"-->
<!--                  hide-details-->
<!--                  return-object-->
<!--                  @input="getWorkQueues(false)"-->
<!--        ></v-select>-->
        <div class="radio-group-container mt-0 mb-5">
          <v-radio-group id="wqt-view-type-selector" hide-details v-model="selectedViewType" column>
            <v-radio class="d-inline-block mx-4"
                     label="% Completed On Time"
                     :value="0"
                     :class="{'inactive-radio': selectedViewType !== 0}"
            ></v-radio>
            <v-radio class="d-inline-block mx-4"
                     label="Total Completed Tasks"
                     :value="1"
                     :color="selectedViewType === 1 ? 'primaryCustom' : '#808588'"
                     :class="{'inactive-radio': selectedViewType !== 1}"></v-radio>
            <v-radio class="d-inline-block mx-4"
                     label="Change in WIP"
                     :value="2"
                     :class="{'inactive-radio': selectedViewType !== 2}"></v-radio>
          </v-radio-group>
        </div>
        <v-row class="ma-0">
          <v-card tile v-for="wq in workQueues" class="flex-display card-main"
                  :class="{'clickable': wq.workQueueCount > 0}"
                  :key="wq.id"
                  width="288" :height="wqHasMetrics(wq) ? 223 : 121">
            <v-card-text class="pa-0">
              <router-link class="no-text-decoration card-link"
                           :to="{name: 'workQueueDrilldown', params: {id: wq.workQueueTypeId}, query: { smartlistId: wq.smartlistId, upId: selectedUserPosition.userId, unassigned: selectedUserPosition.unassigned}}">
                <div v-if="null != wq.expectedTarget"
                    class="expected-target-banner"
                    :style="{'background-color': wq.color, 'color': getTargetColor(wq.color)}">
                  {{wq.expectedTarget * 100 | currency('', 0)}}%
                </div>
                <div class="card-title-container text-left" :style="{'background-color': wq.color + '15' }">
                  <div class="card-title ellipse two-lines">{{ wq.workQueueType }}</div>
                  <div class="card-count">{{ wq.workQueueCount }}</div>
                </div>

                <div class="card-metrics-container"
                     :class="{'card-metrics-container-secondary-view': selectedViewType !== 0}"
                     v-if="wqHasMetrics(wq)">
                  <div class="card-metrics-expected-cycle" v-if="selectedViewType === 0">
                    Completed within expected time of <strong>{{ wq.expectedCycle }}
                    {{ getDurationTypePluralization(wq.expectedCycle, wq.expectedCycleDurationType) }}</strong>
                  </div>
                  <div class="card-metric card-metric-left"
                      :class="{'card-metric-extra-padding': selectedViewType === 0}">
                    <div class="card-metric-percent"
                         v-if="selectedViewType === 0"
                         :class="getMetricPercentColor(wq.shortWindowPercentage, wq.expectedTarget, wq.inverseExpectation)">
                      {{ wq.shortWindowPercentage * 100 | currency('', 0)}}%
<!--                      <span class="card-metric-difference">-->
<!--                          {{ getMetricDifference(wq.shortWindowPercentage, wq.expectedTarget, wq.inverseExpectation) }}-->
<!--                        </span>-->
                    </div>
                    <div class="card-metric-percent"
                         v-else-if="selectedViewType === 1">
                      {{ wq.shortWindowExited }}
                    </div>
                    <div class="card-metric-percent"
                         v-else-if="selectedViewType === 2">
                      {{ wq.shortWip >= 0 ? '+' : '' }}{{ wq.shortWip }}
                    </div>
                    {{ wq.shortWindow }} {{ getDurationTypePluralization(wq.shortWindow, wq.shortWindowDurationType) }}
                  </div>
                  <div class="card-metric-divider"></div>
                  <div class="card-metric">
                    <div class="card-metric-percent"
                         v-if="selectedViewType === 0"
                         :class="getMetricPercentColor(wq.longWindowPercentage, wq.expectedTarget, wq.inverseExpectation)">
                      {{ wq.longWindowPercentage * 100 | currency('', 0)}}%
<!--                      <span class="card-metric-difference">-->
<!--                          {{ getMetricDifference(wq.longWindowPercentage, wq.expectedTarget, wq.inverseExpectation) }}-->
<!--                        </span>-->
                    </div>
                    <div class="card-metric-percent"
                         v-else-if="selectedViewType === 1">
                      {{ wq.longWindowExited }}
                    </div>
                    <div class="card-metric-percent"
                         v-else-if="selectedViewType === 2">
                      {{ wq.longWip >= 0 ? '+' : '' }}{{ wq.longWip }}
                    </div>
                    {{ wq.longWindow }} {{ wq.longWindowDurationType }}
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
import {getRequest, isLightColor, getRequestWithParams, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

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
    // this.getWorkQueueOwners()
    this.selectedWorkQueueCategory.id = parseInt(localStorage.getItem('wqCategoryId'))
    if (this.selectedWorkQueueCategory.id) {
      this.getWorkQueues()
    }
  },
  methods: {
    getTargetColor(color) {
      return isLightColor(color) ? '#363636' : '#ffffff'
    },
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
    async getWorkQueues() {
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

.inactive-radio .v-icon {
  color: #808588 !important;
}

.inactive-radio > label {
  color: #808588 !important;
}

.work-queue-selector .v-input__slot, .work-queue-selector input {
  cursor: pointer !important
}
</style>

<style scoped lang="scss">
.wq-container {
  margin-left: 32px !important;
  margin-right: 32px !important;
}

.work-queue-selector {
  width: 50%;
}



.card-main {
  /* @click adds the pointer but i didnt want the pointer on count == 0 */
  cursor: default;
  text-align: center;
  border-top-right-radius: 9px !important;
  border-bottom-right-radius: 9px !important;
  border-bottom-left-radius: 9px !important;
  margin-right: 48px;
  margin-bottom: 32px;
  box-shadow: 2px 2px 10px rgba(0, 0, 0, 0.1) !important;
}

.card-main:hover {
  box-shadow: 0px 0px 6px rgba(0, 0, 0, 0.15) !important;
}

.expected-target-banner {
  font-weight: 900;
  position: absolute;
  padding: 4px 8px;
  font-size: 12px;
  top: 0;
  left: 0;
  z-index: 2 !important;
  width: 35px;
  height: 22px;
  display: flex;
  align-items: center;
  justify-content: center;
  //filter: drop-shadow(0px 4px 4px rgba(0, 0, 0, 0.25))
}

.expected-target-banner:after {
  content: " ";
  position: absolute;
  display: block;
  width: 100%;
  height: 100%;
  top: 0;
  left: 0;
  z-index: -1;
  background: inherit;
  transform-origin: bottom left;
  -ms-transform: skew(-15deg, 0deg);
  -webkit-transform: skew(-15deg, 0deg);
  transform: skew(-15deg, 0deg);
}

.card-count {
  width: 40%;
  display: inline-block;
  line-height: 2;
  color: #363636;
  text-align: right;
  font-size: 32px;
  font-weight: 600;
  white-space: nowrap;
}

.card-link {
  display: flex;
  position: relative;
  color: #808588;
}

.card-title-container {
  width: 100%;
  height: 121px;
  padding-right: 24px;
  padding-left: 24px;
  border-top-right-radius: 9px !important;
  display: flex;
  align-items: center;
}

.card-title {
  width: 60%;
  color: #363636;
  font-size: 16px;
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
  height: 102px;
  width: calc(100% - 5px);
  position: absolute;
  top: 121px;
  bottom: 0;
  right: 0;
  left: 5px;
  font-size: 12px;
}

.card-metrics-container-secondary-view {
  display: flex;
  align-items: center;
}

.card-metrics-expected-cycle {
  height: 20px;
  font-size: 12px;
  padding-top: 14px;
}

.card-metric {
  width: calc(50% - 1px);
  height: calc(100% - 25px);
  display: inline-block;
}

.card-metric-extra-padding {
  padding-top: 16px;
}

.card-metric-percent {
  font-size: 18px;
  font-weight: bold;
  margin-top: 14px;
  margin-bottom: 3px;
}

.card-metric-difference {
  font-size: 11px;
  font-weight: normal;
}

.card-metric-divider {
  display: inline-block;
  background: #808588;
  width: .5px;
  height: 40px;
}

.radio-group-container {
  display: flex;
}

.expectation-met {
  color: #168325;
}

.expectation-missed {
  color: #DA3434;
}
</style>
