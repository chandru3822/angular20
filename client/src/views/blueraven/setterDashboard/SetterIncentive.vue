<template>
  <v-container id="setter-dash-container" class="incentive-tab-override" ref="setterDashContainer">
    <Incentive :dashboard-type="dashboardType" :counts="pitchCounts" :yearly-point-total="yearlyPointTotal" :incentive-data-loaded="incentiveDataLoaded"></Incentive>
  </v-container>
</template>

<script setup>
import moment from 'moment'
import constants from '@/helpers/constants'
import { getRequestWithParams } from '@/helpers/helpers'

import {MilestoneEnum} from "@/views/blueraven/closerDashboard/MilestoneEnum";
import {incentive_constants, DashboardTypeEnum} from "@/views/blueraven/closerDashboard/incentive_constants";
import Incentive from "@/views/blueraven/closerDashboard/Incentive";

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const incentiveDataLoaded = ref(false)
const currentQuarter = ref(moment().quarter())
const pitchCounts = ref({q1: 0, q2: 0, q3: 0, q4: 0})
const isSetterMgr = ref(false)
const setterDashContainer = ref(null)

const currentUserId = computed(() => {
  return userStore.details.id
})

const windowInnerWidth = computed(() => {
  return window.innerWidth
})
const dashboardType = computed(() => {
  return isSetterMgr.value ? DashboardTypeEnum.SETTERMGR : DashboardTypeEnum.SETTER
})
const yearlyPointTotal = computed(() => {
  // Calculate points for each quarter
  const q1_points= calcPointsForQuarter(pitchCounts.value.q1),
      q2_points= calcPointsForQuarter(pitchCounts.value.q2),
      q3_points= calcPointsForQuarter(pitchCounts.value.q3),
      q4_points= calcPointsForQuarter(pitchCounts.value.q4)
  //return total
  return q1_points + q2_points + q3_points + q4_points
})

onMounted(async() => {
  let userPositions = userStore.details.userPositions
  if (userPositions?.length > 0) {
    userOfficeId.value = userPositions.filter(position => position.primaryFlag && !position.endDate)[0].orgId
    userOffice.value = userPositions.filter(position => position.orgId === userOfficeId.value)[0].hierarchy.filter(orgLevel => orgLevel.orgId === userOfficeId.value)[0].orgName
    isSetter.value = userPositions.filter(position => (position.positionId === 4) && !position.endDate && !position.archived && position.primaryFlag).length > 0
    isSetterMgr.value = userPositions.filter(position => (position.positionId === 5) && !position.endDate && !position.archived && position.primaryFlag).length > 0
    isSetterRegional.value = userPositions.filter(position => (position.positionId === 6) && !position.endDate && !position.archived && position.primaryFlag).length > 0
  }

  await loadIncentive()

})

const resetScrollBarPosition = () => {
  // reset scroll bar positioning to top
  setterDashContainer.value.scrollTop = 0
}
const loadIncentive = async() => {
  incentiveDataLoaded.value = false

  appStore.loading = true
  try {
    const params = {
      isSetterMgr: isSetterMgr.value,
      setterMgrOfficeId: isSetterMgr.value && userOfficeId.value ? userOfficeId.value : null
    }

    getRequestWithParams('/setterDashboard/getIncentivePitchCounts', {params}, 'blueraven').then(res => {
      pitchCounts.value = res.data

      incentiveDataLoaded.value = true
      appStore.loading = false
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving incentive data')

    incentiveDataLoaded.value = true
    appStore.loading = false
  }
}
const calcPointsForQuarter = (pitchCount) => {
  if(pitchCount >= dashboardType.value.milestoneGoalMap[MilestoneEnum.LEVEL1] && pitchCount < dashboardType.value.milestoneGoalMap[MilestoneEnum.LEVEL2]){
    return 1
  } else if (pitchCount >= dashboardType.value.milestoneGoalMap[MilestoneEnum.LEVEL2] && pitchCount < dashboardType.value.milestoneGoalMap[MilestoneEnum.LEVEL3]){
    return 2
  } else if (pitchCount >= dashboardType.value.milestoneGoalMap[MilestoneEnum.LEVEL3] && pitchCount < dashboardType.value.milestoneGoalMap[MilestoneEnum.LEVEL4]){
    return 3
  } else if (pitchCount >= dashboardType.value.milestoneGoalMap[MilestoneEnum.LEVEL4]){
    return 4
  }
  else return 0
}

</script>

<style lang="scss" scoped>
#setter-dash-container {
  font-family: 'Roboto Condensed', sans-serif !important;
  letter-spacing: 0.02em !important;
  overflow: auto;
}

#setter-dash-container.incentive-tab-override {
  padding: 0 !important;
}

#setter-dash-tabs.incentive-tab-overrides {
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
  #setter-dash-toolbar-container #setter-dash-toolbar .v-toolbar .v-toolbar__content .v-toolbar__title {
    font-size: 16px;
  }
}

@media (min-width: 1070px) {

  #setter-dash-tabs .col-12 span {
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
