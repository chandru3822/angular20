<template>
  <v-container class="wq-container">
    <v-row>
      <v-col cols="12" class="pt-3">
        <v-card color="white" class="square-card work-queue-container-top">
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
          <v-row>
            <v-col cols="12" md="6" class="py-0">
              <div class="radio-group-container mt-0">
                <v-radio-group id="wqt-view-type-selector" hide-details v-model="selectedViewType" column>
                  <v-radio class="d-inline-block mx-4 wq-radio-label"
                           label="% Completed On Time"
                           small
                           :value="0"
                           :class="{'inactive-radio': selectedViewType !== 0}"
                  ></v-radio>
                  <v-radio class="d-inline-block mx-4 wq-radio-label"
                           label="Projects Completed"
                           :value="1"
                           :color="selectedViewType === 1 ? 'primaryCustom' : '#808588'"
                           :class="{'inactive-radio': selectedViewType !== 1}"></v-radio>
                  <v-radio class="d-inline-block mx-4 wq-radio-label"
                           label="Change in WIP"
                           :value="2"
                           :class="{'inactive-radio': selectedViewType !== 2}"></v-radio>
                </v-radio-group>
              </div>
            </v-col>
            <v-col cols="12" md="6" class="py-0 future-follow-ups-column">
              <v-switch
                dense
                hide-details
                color="primaryCustom"
                v-model="hideFutureFollowUps"
                class="mx-2 mt-5 wq-follow-up-switch"
                label="Hide work with a next follow-up date in the future"
                @change="getWorkQueues()"
              />
            </v-col>
          </v-row>
        </v-card>
        <v-card color="white" class="square-card work-queue-container-bottom mt-3">
          <v-row class="cards my-0">
            <v-card flat color="transparent" class="ml-8"
                    v-if="!selectedWorkQueueCategory || !selectedWorkQueueCategory.id">
              Please select a Work Queue Category
            </v-card>
            <v-card flat tile v-for="wq in workQueues" class="flex-display card-main"
                    :class="{'clickable': wq.workQueueCount > 0}"
                    :key="wq.id"
                    width="288" :height="wqHasMetrics(wq) ? 223 : 108">
              <v-card-text class="pa-0">
                <div class="no-text-decoration card-link"
                     :class="{'clickable': wq.workQueueCount > 0}"
                     @click="goToRoute(wq.workQueueCount > 0, 'workQueueDrilldown',  {id: wq.workQueueTypeId}, { smartlistId: wq.smartlistId, upId: selectedUserPosition.userId, unassigned: selectedUserPosition.unassigned})">
                  <div class="card-title-container text-left"
                       :class="{'card-title-container-no-metrics': !wqHasMetrics(wq)}"
                       :style="{'background-color': wq.color + '20' }">
                    <div class="card-title ellipse two-lines">{{ wq.workQueueType }}</div>
                    <div class="card-count">{{ wq.workQueueCount }}</div>
                  </div>
                  <div v-if="null != wq.expectedTarget && selectedViewType === 0"
                       class="expected-target-banner"
                       :style="{'background-color': wq.color, 'color': getTargetColor(wq.color)}">
                    {{ wq.expectedTarget * 100 | currency('', 0) }}%
                  </div>

                  <div class="card-metrics-container"
                       :class="{'card-metrics-container-secondary-view': selectedViewType !== 0}"
                       v-if="wqHasMetrics(wq)">
                    <div class="one-hunned">
                      <div class="card-metric card-metric-left">
                        <div class="card-metric-percent"
                             v-if="selectedViewType === 0"
                             :class="getMetricPercentColor(wq.shortWindowPercentage, wq.expectedTarget, wq.inverseExpectation)">
                          {{ wq.shortWindowPercentage * 100 | currency('', 0) }}%
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
                        {{ wq.shortWindow }} {{
                          getDurationTypePluralization(wq.shortWindow, wq.shortWindowDurationType)
                        }}
                      </div>
                      <div class="card-metric-divider"></div>
                      <div class="card-metric">
                        <div class="card-metric-percent"
                             v-if="selectedViewType === 0"
                             :class="getMetricPercentColor(wq.longWindowPercentage, wq.expectedTarget, wq.inverseExpectation)">
                          {{ wq.longWindowPercentage * 100 | currency('', 0) }}%
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
                    <div class="card-metrics-expected-cycle" v-if="selectedViewType === 0">
                      Completed within expected time of <strong>{{ wq.expectedCycle }}
                      {{ getDurationTypePluralization(wq.expectedCycle, wq.expectedCycleDurationType) }}</strong>
                    </div>
                  </div>
                </div>
              </v-card-text>
            </v-card>
          </v-row>
        </v-card>
      </v-col>
    </v-row>

    <v-dialog v-model="showMetricsDialog" max-width="330" class="wq-metrics-dialog">
      <v-card>
        <span class="flex-display wq-metrics-dialog-text pl-4">
          Thank you for your interest! More<br>
          information about work queue metrics,<br>
          what they mean, and when they are<br>
          tracked will be coming up soon!
        </span>
        <v-card-actions class="flex-display justify-end">
          <v-btn
            @click="showMetricsDialog = false">
            Close
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'

import orderBy from 'lodash.orderby'
import {getWorkQueueCategories} from '@/services/workQueueService'
import {
  handleHidingGlobalLoader,
  getRequest,
  isLightColor,
  getRequestWithParams,
  getSnackbar
} from '@/helpers/helpers'

export default {
  name: 'WorkQueue',
  data() {
    return {
      snackbar: {},
      model: {},
      hideFutureFollowUps: false,
      showAll: false,
      selectedWorkQueueCategory: {},
      workQueueCategories: [],
      workQueues: [],
      selectedViewType: 0,
      selectedUserPosition: {},
      workQueueOwners: [],
      anyOwner: {id: -1, fullName: 'Anyone', userId: null, unassigned: false},
      noOwner: {id: -99, fullName: 'Unassigned', userId: null, unassigned: true},
      showMetricsDialog: false
    }
  },
  computed: {},
  async created() {
    this.getWorkQueueCategories()
    // this.getWorkQueueOwners()
    this.selectedWorkQueueCategory.id = parseInt(localStorage.getItem('wqCategoryId'))
    this.hideFutureFollowUps = JSON.parse(localStorage.getItem('hideFutureWqFollowUps')) || false
    if (this.selectedWorkQueueCategory.id) {
      this.getWorkQueues()
    }
  },
  methods: {
    goToRoute(changeRoute, routeName, params, query) {
      if(changeRoute) {
        console.log('we tried')
        this.$router.push({name: routeName, params, query})
      }
    },
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
      localStorage.setItem('hideFutureWqFollowUps', JSON.stringify(this.hideFutureFollowUps))
      if (this.selectedWorkQueueCategory?.id || this.showAll) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequestWithParams(`/workQueue`, {
            params: {
              workQueueCategoryId: this.selectedWorkQueueCategory.id,
              userId: this.selectedUserPosition.userId,
              unassigned: this.selectedUserPosition.unassigned,
              filterFutureFollowUps: this.hideFutureFollowUps
            }
          })
          this.workQueues = data
          handleHidingGlobalLoader(this, status)
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
    },
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

.wq-radio-label .v-icon, .wq-radio-label label {
  font-size: 14px;
}

.wq-radio-label .v-icon, .wq-radio-label label {
  font-size: 14px;
}

.wq-follow-up-switch label {
  font-size: 14px;
}

.wq-follow-up-switch .v-input--selection-controls__input {
  transform: scale(0.775);
  transform-origin: center;
}
</style>

<style scoped lang="scss">
.future-follow-ups-column {
  display: flex;
  justify-content: end;
}

.work-queue-container-top {
  padding: 26px 28px 16px 28px;
}

.work-queue-container-bottom {
  padding: 26px 28px;
}

.work-queue-selector {
  width: 50%;
  border-top-left-radius: 4px !important;
  border-top-right-radius: 4px !important;
}

.cards {
  //doing this to avoid wrapping when there is space for another card
  margin-left: -24px !important;
  margin-right: -24px !important;
}

.card-main {
  /* @click adds the pointer but i didnt want the pointer on count == 0 */
  cursor: default;
  text-align: center;
  border-radius: 11px !important;
  margin-right: 24px;
  margin-left: 24px;
  margin-bottom: 32px;
  border: 2px solid #DBE0E3;
  //box-shadow: 2px 2px 10px rgba(0, 0, 0, 0.1) !important;
}

.card-main:hover {
  filter: drop-shadow(0px 4px 4px rgba(0, 0, 0, 0.25));
  //box-shadow: 0px 4px 4px rgba(0, 0, 0, 0.25) !important;
}

.expected-target-banner {
  font-weight: 900;
  position: absolute;
  padding: 4px 8px;
  font-size: 12px;
  top: 105px;
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
  height: 105px;
  padding-right: 24px;
  padding-left: 24px;
  border-top-right-radius: 9px !important;
  border-top-left-radius: 9px !important;
  display: flex;
  align-items: center;
}

.card-title-container-no-metrics {
  border-bottom-right-radius: 9px !important;
  border-bottom-left-radius: 9px !important;
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
  height: 118px;
  width: calc(100% - 5px);
  position: absolute;
  top: 105px;
  bottom: 0;
  right: 0;
  left: 5px;
  font-size: 12px;
  display: flex;
  flex-direction: column;
  //padding-top: 24px;
  justify-content: center;
}

.card-metrics-container-secondary-view {
  display: flex;
  align-items: center;
}

.card-metrics-expected-cycle {
  height: 20px;
  font-size: 12px;
  padding-top: 8px;
}

.card-metric {
  width: calc(50% - 1px);
  height: calc(100% - 35px);
  display: inline-block;
}

.card-metric-percent {
  font-size: 18px;
  font-weight: 700;
  margin-bottom: 4px;
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
  margin-left: -20px;
}

.expectation-met {
  color: #168325;
}

.expectation-missed {
  color: #DA3434;
}

.learn-span {
  color: var(--v-primaryCustom-base);
  font-weight: bold;
  margin-top: 20px;
  cursor: pointer;
}

.wq-metrics-dialog {
  font-family: Lato;
  font-size: 12px;
  max-width: 253px;
  height: 88px;
}
</style>
