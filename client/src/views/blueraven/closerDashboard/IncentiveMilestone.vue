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

<script>
import {DashboardTypeEnum, incentive_constants} from "@/views/blueraven/closerDashboard/incentive_constants";
import {MilestoneEnum, QuarterEnum} from "@/views/blueraven/closerDashboard/MilestoneEnum";
import {AppMutations} from "@/stores/AppStore";
import {getRequestWithParams, getSnackbar} from "@/helpers/helpers";
import cloneDeep from "lodash.clonedeep";
import TrophyDynamic from "@/assets/blueraven/trophy-dynamic";
import moment from "moment";
import SetterMilestoneDrilldown from "@/views/blueraven/setterDashboard/SetterMilestoneDrilldown";
import CloserMilestoneDrilldown from "@/views/blueraven/closerDashboard/CloserMilestoneDrilldown";

export default {
  name: "IncentiveMilestone",
  components: {
    SetterMilestoneDrilldown,
    CloserMilestoneDrilldown,
    TrophyDynamic
  },
  props: {
    quarter: QuarterEnum,
    milestoneLevel: MilestoneEnum,
    dashboardType: DashboardTypeEnum,
    currentQuarterCount: Number
  },
  data() {
    return {
      incentive_constants,
      milestoneDialog: false,
      currentUserId: null,
      currentQuarter: moment().quarter(),
      drilldownData: [],
      upperLabel: '',
      lowerLabel:''
    }
  },
  computed: {
    windowInnerWidth () { return window.innerWidth},
    milestoneUnits () {
      return this.dashboardType.milestoneUnits
    },
    colorClass: function () {
      return {
        'bronze': this.milestoneLevel === MilestoneEnum.LEVEL1,
        'silver': this.milestoneLevel === MilestoneEnum.LEVEL2,
        'gold': this.milestoneLevel === MilestoneEnum.LEVEL3,
        'platinum': this.milestoneLevel === MilestoneEnum.LEVEL4
      }
    },
    active () {
      return this.currentQuarter === this.quarter.value
    },
    isSetter() {
      return this.dashboardType === DashboardTypeEnum.SETTER || this.dashboardType === DashboardTypeEnum.SETTERMGR
    },
    isCloser() {
      return this.dashboardType === DashboardTypeEnum.CLOSER
    }
  },
  watch: {
    currentQuarterCount () {
      this.setLabels()
    }
  },
  methods: {
    setLabels () {
      const diff = this.getNextMilestoneGoal() - this.currentQuarterCount
      this.upperLabel = this.quarter.label
      if(this.quarter.value < this.currentQuarter && this.milestoneLevel === MilestoneEnum.LEVEL0){
        //if the quarter is over and no milestone was reached
        this.lowerLabel = "No milestone reached"
      }
      else if(this.milestoneLevel === MilestoneEnum.LEVEL4 || (this.quarter.value < this.currentQuarter)) {
        //if they reached the highest level OR the Quarter is over and one of the other milestones was reached
        this.lowerLabel = `${this.incentive_constants.milestoneMap.get(this.milestoneLevel)} Achieved`
      } else {
        this.lowerLabel = `${diff} ${this.milestoneUnits} to ${this.incentive_constants.milestoneMap.get(this.getNextMilestone())}`
      }
    },
    getNextMilestoneGoal() {
      const nextMilestone = this.getNextMilestone();
      return nextMilestone ? this.dashboardType.milestoneGoalMap[this.getNextMilestone()]: undefined
    },
    getNextMilestone() {
      switch (this.milestoneLevel){
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
    },
    resetScrollBarPosition () {
      // reset scroll bar position to top
      //document.getElementsByClassName('v-data-table__wrapper').forEach(table => table.scrollTop = 0)
    },

    /* Drilldown CODE START */
    async milestoneDrilldown (quarter) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {}
        if(this.dashboardType === DashboardTypeEnum.SETTERMGR){
          let userPositions = this.$store.state.user.details.userPositions
          let userOffice = userPositions.filter(position => position.primaryFlag && !position.endDate)[0]
          let userOfficeId = userOffice ? userOffice.orgId : null

          params = {
            quarter,
            isSetterMgr: true,
            setterMgrOfficeId: userOfficeId ? userOfficeId : null
          }
        } else if (this.dashboardType === DashboardTypeEnum.SETTER){
          let userPositions = this.$store.state.user.details.userPositions
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
        const {data} = await getRequestWithParams(this.dashboardType.drilldown.path, {params}, 'blueraven')
        this.drilldownData = cloneDeep(data)
        if (this.drilldownData.length > 0) {
          this.drilldownData.forEach(row => {
            if (row.customer_name) {
              row.customer_name = row.customer_name.toLowerCase()
            }
          })
        } else {
          this.drilldownData = []
        }

        this.milestoneDialog = true
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving drilldown data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },

    closeMilestoneDialog () {
      this.milestoneDialog = false
      this.resetScrollBarPosition()
    },
    /* Drilldown CODE END */
  },

  async created () {
    this.currentUserId = this.$store.state.user.details.id
    this.setLabels()
  }
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

