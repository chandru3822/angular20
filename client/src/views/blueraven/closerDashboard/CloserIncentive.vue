<template>
  <v-container id="closer-dash-container" class="incentive-tab-override" ref="closerDashContainer">
    <Incentive :dashboard-type="dashboardType" :counts="fdcCounts" :yearly-point-total="yearlyPointTotal"
               :incentive-data-loaded="incentiveDataLoaded"></Incentive>
  </v-container>
</template>

<script setup>
import moment from 'moment'
import {getRequest} from '@/helpers/helpers'
import Incentive from "@/views/blueraven/closerDashboard/Incentive";
import {DashboardTypeEnum} from "@/views/blueraven/closerDashboard/incentive_constants";
import {MilestoneEnum} from "@/views/blueraven/closerDashboard/MilestoneEnum";
import {getCurrentInstance, ref, computed, onMounted} from "vue";
import { useAppStore } from '@/stores/AppStore.js'
import {useUserStore} from "@/stores/UserStore.js";

const userStore = useUserStore()
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const incentiveDataLoaded = ref(false)
const closerDashContainer = ref(null)
const currentQuarter = ref(moment().quarter())
const fdcCounts = ref({
  q1: 0, q1QualificationMet: false,
  q2: 0, q2QualificationMet: false,
  q3: 0, q3QualificationMet: false,
  q4: 0, q4QualificationMet: false
})

const currentUserId = computed(() => {
  return userStore.details.id
})
const windowInnerWidth = computed(() => {
  return window.innerWidth
})
const dashboardType = computed(() => {
  return DashboardTypeEnum.CLOSER;
})
const yearlyPointTotal = computed(() => {
  // Calculate points for each quarter
  const q1_points = calcPointsForQuarter(fdcCounts.value.q1, fdcCounts.value.q1QualificationMet),
      q2_points = calcPointsForQuarter(fdcCounts.value.q2, fdcCounts.value.q2QualificationMet),
      q3_points = calcPointsForQuarter(fdcCounts.value.q3, fdcCounts.value.q3QualificationMet),
      q4_points = calcPointsForQuarter(fdcCounts.value.q4, fdcCounts.value.q4QualificationMet)
  //return total
  return q1_points + q2_points + q3_points + q4_points
})

onMounted(async () => {
  await loadIncentive()
})

const resetScrollBarPosition = () => {
  // reset scroll bar position to top
  closerDashContainer.value.scrollTop = 0
}
const loadIncentive = async () => {
  incentiveDataLoaded.value = false

  appStore.loading = true
  try {
    getRequest('/closerDashboard/getIncentiveFdcCounts', 'blueraven').then(res => {
      fdcCounts.value = res.data
      appStore.loading = false
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving incentive data')
    incentiveDataLoaded.value = true
    appStore.loading = false
  }
}
const calcPointsForQuarter = (fdcCount, qualificationMetForQuarter) => {
  if (qualificationMetForQuarter) {
    switch (true) {
      case fdcCount >= dashboardType.value.milestoneGoalMap[MilestoneEnum.LEVEL1] && fdcCount < dashboardType.value.milestoneGoalMap[MilestoneEnum.LEVEL2]:
        return 1 // Level 1
      case fdcCount >= dashboardType.value.milestoneGoalMap[MilestoneEnum.LEVEL2] && fdcCount < dashboardType.value.milestoneGoalMap[MilestoneEnum.LEVEL3]:
        return 2 // Level 2
      case fdcCount >= dashboardType.value.milestoneGoalMap[MilestoneEnum.LEVEL3] && fdcCount < dashboardType.value.milestoneGoalMap[MilestoneEnum.LEVEL4]:
        return 3 // Level 3
      case fdcCount >= dashboardType.value.milestoneGoalMap[MilestoneEnum.LEVEL4]:
        return 4 // Level 4
      default:
        return 0 // No medal
    }
  } else {
    return 0 // No medal
  }
}


</script>

<style lang="scss" scoped>
#closer-dash-container {
  letter-spacing: 0.02em !important;
  overflow: auto;
}

#closer-dash-container.incentive-tab-override {
  padding: 0 !important;
}

#closer-dash-tabs.incentive-tab-overrides {
  position: relative;
  z-index: 1;
  color: #fff;
  margin-bottom: -30px !important;
  padding-top: 8px;
  padding-right: 15px;

  .tab-separator {
    border-color: #fff;
  }
}

@media (min-width: 500px) {
  #closer-dash-toolbar-container #closer-dash-toolbar .v-toolbar .v-toolbar__content .v-toolbar__title {
    font-size: 16px;
  }
}

@media (min-width: 1070px) {

  #closer-dash-tabs .col-12 span {
    font-size: 13px;
  }
}

@media (min-width: 1187px) {
  #appts-to-fdc-pipeline-funnel-background {
    border-top-width: 900px;
  }

  #appts-to-fdc-pipeline-container {
    .funnel-container {
      .funnel-table {
        .checked-in-column-top {
          padding: 17px 3px;
        }
      }
    }
  }
}

</style>
