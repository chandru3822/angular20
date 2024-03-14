<template>
  <div>
    <div :id="`quarter-${quarter.value}`" class="milestone"
         :class="{
                        'align-items-center': windowInnerWidth < 1135,
                        'align-items-flex-start': windowInnerWidth >= 1135,
                        'active-milestone': active
                        }"
         @click="milestoneDrilldown(quarter.value)">
      <span class="milestone-top-label">{{ upperLabel }}</span>
      <div class="milestone-content mt-1" :class="colorClass">
        <div class="milestone-content-left-side d-flex align-items-flex-end"><trophy-dynamic :color="colorClass" :active="active"></trophy-dynamic></div>
        <div class="milestone-content-right-side">
          <span class="milestone-top-right-label" :class="colorClass">{{ currentQuarterCount }} {{dashboardType.milestoneUnits}}</span>
        </div>
      </div>
      <span class="milestone-bottom-label">{{ lowerLabel }}</span>
    </div>
    <SetterMilestoneDrilldown v-if="isSetter" :selected-quarter="quarter.value" :is-open="milestoneDialog" :drilldown-data="drilldownData" @close-drilldown="closeMilestoneDialog"></SetterMilestoneDrilldown>
    <CloserMilestoneDrilldown v-if="isCloser" :selected-quarter="quarter.value" :is-open="milestoneDialog" :drilldown-data="drilldownData" @close-drilldown="closeMilestoneDialog"></CloserMilestoneDrilldown>
  </div>
</template>

<script setup>
import {DashboardTypeEnum, incentive_constants} from "@/views/blueraven/closerDashboard/incentive_constants";
import {MilestoneEnum, QuarterEnum} from "@/views/blueraven/closerDashboard/MilestoneEnum";
import {AppMutations} from "@/stores/AppStore";
import {getRequestWithParams, getSnackbar} from "@/helpers/helpers";
import cloneDeep from "lodash.clonedeep";
import TrophyDynamic from "@/assets/blueraven/trophy-dynamic";
import moment from "moment";
import SetterMilestoneDrilldown from "@/views/blueraven/setterDashboard/SetterMilestoneDrilldown";
import CloserMilestoneDrilldown from "@/views/blueraven/closerDashboard/CloserMilestoneDrilldown";
import {getCurrentInstance, watch, toRefs, ref, computed, onMounted} from "vue";

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const props = defineProps({
    quarter: QuarterEnum,
    milestoneLevel: MilestoneEnum,
    dashboardType: DashboardTypeEnum,
    currentQuarterCount: Number
})
const { quarter, milestoneLevel, dashboardType, currentQuarterCount } = toRefs(props)

const milestoneDialog = ref(false)
const selectedQuarter = ref(1)
const currentQuarter = ref(moment().quarter())
const drilldownData = ref([])
const upperLabel = ref('')
const lowerLabel = ref('')

const currentUserId = computed(() => {
  return store.state.user.details.id
})
    const windowInnerWidth = computed(() => {
      return window.innerWidth
    })
    const milestoneUnits = computed(() => {
      return dashboardType.value.milestoneUnits
    })
    const colorClass = computed(() => {
      return {
        'bronze': milestoneLevel.value === MilestoneEnum.LEVEL1,
        'silver': milestoneLevel.value === MilestoneEnum.LEVEL2,
        'gold': milestoneLevel.value === MilestoneEnum.LEVEL3,
        'platinum': milestoneLevel.value === MilestoneEnum.LEVEL4
      }
    })
    const active = computed(() => {
      return currentQuarter.value === quarter.value.value
    })
    const isSetter = computed(() => {
      return dashboardType.value === DashboardTypeEnum.SETTER || dashboardType.value === DashboardTypeEnum.SETTERMGR
    })
    const isCloser = computed(() => {
      return dashboardType.value === DashboardTypeEnum.CLOSER
    })

watch(currentQuarterCount, async() => {
    setLabels()
})

onMounted(() => {
  setLabels()
})


    const setLabels = () => {
      const diff = getNextMilestoneGoal() - currentQuarterCount.value
      upperLabel.value = quarter.value.label
      if(quarter.value.value < currentQuarter.value && milestoneLevel.value === MilestoneEnum.LEVEL0){
        //if the quarter is over and no milestone was reached
        lowerLabel.value = "No milestone reached"
      }
      else if(milestoneLevel.value === MilestoneEnum.LEVEL4 || (quarter.value.value < currentQuarter.value)) {
        //if they reached the highest level OR the Quarter is over and one of the other milestones was reached
        lowerLabel.value = `${incentive_constants.milestoneMap.get(milestoneLevel.value)} Achieved`
      } else {
        lowerLabel.value = `${diff} ${milestoneUnits.value} to ${incentive_constants.milestoneMap.get(getNextMilestone())}`
      }
    }
    const getNextMilestoneGoal =() => {
      const nextMilestone = getNextMilestone();
      return nextMilestone ? dashboardType.value.milestoneGoalMap[getNextMilestone()]: undefined
    }
    const getNextMilestone =() => {
      switch (milestoneLevel.value){
        case MilestoneEnum.LEVEL0:
          return MilestoneEnum.LEVEL1
        case MilestoneEnum.LEVEL1:
          return MilestoneEnum.LEVEL2
        case MilestoneEnum.LEVEL2:
          return MilestoneEnum.LEVEL3
        case MilestoneEnum.LEVEL3:
          return MilestoneEnum.LEVEL4
        default:
          return undefined
      }
    }
    const resetScrollBarPosition = () => {
      // reset scroll bar position to top
      //document.getElementsByClassName('v-data-table__wrapper').forEach(table => table.scrollTop = 0)
    }

    /* Drilldown CODE START */
    const milestoneDrilldown = async (quarter) => {
      store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {}
        if(dashboardType.value === DashboardTypeEnum.SETTERMGR){
          let userPositions = store.state.user.details.userPositions
          let userOffice = userPositions.filter(position => position.primaryFlag && !position.endDate)[0]
          let userOfficeId = userOffice ? userOffice.orgId : null

          params = {
            quarter,
            isSetterMgr: true,
            setterMgrOfficeId: userOfficeId ? userOfficeId : null
          }
        } else if (dashboardType.value === DashboardTypeEnum.SETTER){
          let userPositions = store.state.user.details.userPositions
          let userOffice = userPositions.filter(position => position.primaryFlag && !position.endDate)[0]
          let userOfficeId = userOffice ? userOffice.orgId : null

          params = {
            quarter,
            isSetterMgr: false,
            setterMgrOfficeId: userOfficeId
          }
        } else {
          params = {quarter}
        }
        const {data} = await getRequestWithParams(dashboardType.value.drilldown.path, {params}, 'blueraven')
        drilldownData.value = cloneDeep(data)
        if (drilldownData.value.length > 0) {
          drilldownData.value.forEach(row => {
            if (row.customer_name) {
              row.customer_name = row.customer_name.toLowerCase()
            }
          })
        } else {
          drilldownData.value = []
        }

        milestoneDialog.value = true
        store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar.value = getSnackbar('ERROR', 'Error retrieving drilldown data')
        store.commit(AppMutations.SHOW_SNACK, snackbar.value)
        store.commit(AppMutations.SET_LOADING, false)
      }
    }
    const closeMilestoneDialog = () => {
      milestoneDialog.value = false
      resetScrollBarPosition()
    }

</script>

<style lang="scss" scoped>
.align-items-center {
  align-items: center;
}

.align-items-flex-start {
  align-items: flex-start;
}

.align-items-flex-end {
  align-items: flex-end;
}

.milestone {
  display: flex;
  flex-flow: column nowrap;
  justify-content: center;
  align-items: center;
  width: 100%;
  margin-top: 15px;
  padding-left: 28px;
  padding-right: 28px;

  .milestone-top-label {
    display: inline-block;
    text-align: center;
    color: #fff;
    font-size: 14px;
    font-weight: bold;
    width: 156px;
  }

  .milestone-bottom-label {
    display: inline-block;
    text-align: center;
    color: #fff;
    font-size: 14px;
    margin-top: 3px;
    width: 220px;
  }

  .milestone-content {
    cursor: pointer;
    color: white;
    background-color: transparent;
    border: 4px solid white;
    display: flex;
    flex-flow: row nowrap;
    padding: calc(1em - 4px);
    width: 156px;
    height: 104px;

    .milestone-content-left-side {
      align-self: flex-end;
      width: 40%;
      height: 60%;
    }

    .milestone-content-right-side {
      display: flex;
      flex-flow: column nowrap;
      width: 60%;

      .milestone-top-right-label {
        text-align: right;
        font-size: 14px;
      }
    }
  }
}

#quarter-1.milestone,
#quarter-2.milestone {
  margin-bottom: 20px;
}

.active-milestone {
  .milestone-top-label,
  .milestone-bottom-label {
    width: 260px;
  }

  .milestone-top-label {
    font-size: 16px;
  }

  .milestone-bottom-label {
    font-weight: bold;
    font-size: 16px;
  }

  .milestone-content {
    border: 3px solid white;
    width: 180px;
    height: 130px;

    .milestone-content-right-side {
      .milestone-top-right-label {
        font-weight: bold;
        font-size: 14px;
      }
    }
  }
}

@media (min-width: 500px) {
}

@media (min-width: 737px) {
  .milestone {
    margin-top: 0;
    margin-bottom: 10px;


    .milestone-top-label,
    .milestone-bottom-label {
      width: 200px;
    }

    .milestone-top-label {
      font-size: 14px;
    }

    .milestone-bottom-label {
      font-size: 13px;
    }

    .milestone-content {
      width: 156px;
      height: 104px;

      .milestone-content-right-side {
        .milestone-top-right-label {
          font-size: 12px;
        }
      }
    }
  }

  .active-milestone {
    .milestone-top-label,
    .milestone-bottom-label {
      width: 200px;
    }

    .milestone-top-label {
      font-size: 16px;
    }

    .milestone-bottom-label {
      font-size: 16px;
    }

    .milestone-content {
      width: 180px;
      height: 130px;

      .milestone-content-left-side {
        height: 100%;
      }

      .milestone-content-right-side {
        .milestone-top-right-label {
          font-size: 14px;
        }
      }
    }
  }


  #milestone-medals-container {
    width: 50%;
    height: 60px;
  }

}

@media (min-width: 1070px) {

  .milestone {
    margin-bottom: 0;
  }

  #quarter-1.milestone,
  #quarter-2.milestone {
    margin-bottom: 16px;
  }

  #milestone-medals-container {
    width: 45%;
    max-width: 650px;
  }
}

@media (min-width: 1135px) {

  .milestone {

    .milestone-top-label,
    .milestone-bottom-label {
      width: 164px;
    }

    .milestone-content {
      width: 156px;
      height: 104px;
    }
  }
  #quarter-1.milestone,
  #quarter-2.milestone {
    margin-bottom: 0;
  }

  .active-milestone {
    .milestone-top-label,
    .milestone-bottom-label {
    }

    .milestone-content {
      background-color: transparent;
      border: 4px solid white;
      width: 180px;
      height: 130px;
    }
  }
}

//color classes
.bronze {
  color: #B99A86;
}
.milestone-content.bronze {
  background-color: #191919;
  border: 4px solid #B99A86;
}
.silver {
  color: #A8A9AB;
}
.milestone-content.silver {
  background-color: #191919;
  border: 4px solid #A8A9AB;
}
.gold {
  color: #FFD700;
}
.milestone-content.gold {
  background-color: #191919;
  border: 4px solid #FFD700;
}
.platinum {
  color: #191919;
}
.milestone-content.platinum {
  background-color: white;
  border: 4px solid #191919;
}

</style>

