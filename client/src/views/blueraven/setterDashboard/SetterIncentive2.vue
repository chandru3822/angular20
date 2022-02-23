<template>
  <v-container id="setter-dash-container" class="incentive-tab-override">
    <Incentive :dashboard-type="dashboardType" :counts="pitchCounts" :yearly-point-total="yearlyPointTotal" :incentive-data-loaded="incentiveDataLoaded"></Incentive>
  </v-container>
</template>

<script>
import moment from 'moment'
import constants from '@/helpers/constants'
import { getRequestWithParams, getSnackbar } from '@/helpers/helpers'
import { AppMutations } from '@/stores/AppStore'
import {MilestoneEnum} from "@/views/blueraven/closerDashboard/MilestoneEnum";
import {incentive_constants, DashboardTypeEnum} from "@/views/blueraven/closerDashboard/incentive_constants";
import Incentive from "@/views/blueraven/closerDashboard/Incentive";

export default {
  name: 'setterIncentive2',
  components: {
    Incentive
  },
  data: () => ({
    snackbar: {},
    constants,
    incentive_constants,
    currentUserId: null,
    incentiveDataLoaded: false,
    currentQuarter: moment().quarter(),
    pitchCounts: {q1: 0, q2: 0, q3: 0, q4: 0},
    isSetterMgr: false,
  }),
  computed: {
    windowInnerWidth () { return window.innerWidth},
    dashboardType() {
      return this.isSetterMgr ? DashboardTypeEnum.SETTERMGR : DashboardTypeEnum.SETTER
    },
    yearlyPointTotal () {
      // Calculate points for each quarter
      const q1_points= this.calcPointsForQuarter(this.pitchCounts.q1),
          q2_points= this.calcPointsForQuarter(this.pitchCounts.q2),
          q3_points= this.calcPointsForQuarter(this.pitchCounts.q3),
          q4_points= this.calcPointsForQuarter(this.pitchCounts.q4)
      //return total
      return q1_points + q2_points + q3_points + q4_points
    }
  },
  /* INCENTIVE-RELATED CODE END */
  async created() {
    this.currentUserId = this.$store.state.user.details.id
    let userPositions = this.$store.state.user.details.userPositions
    if (userPositions?.length > 0) {
      this.userOfficeId = userPositions.filter(position => position.primaryFlag && !position.endDate)[0].orgId
      this.userOffice = userPositions.filter(position => position.orgId === this.userOfficeId)[0].hierarchy.filter(orgLevel => orgLevel.orgId === this.userOfficeId)[0].orgName
      this.isSetter = userPositions.filter(position => (position.positionId === 4) && !position.endDate && !position.archived && position.primaryFlag).length > 0
      this.isSetterMgr = true //userPositions.filter(position => (position.positionId === 5) && !position.endDate && !position.archived && position.primaryFlag).length > 0
      this.isSetterRegional = userPositions.filter(position => (position.positionId === 6) && !position.endDate && !position.archived && position.primaryFlag).length > 0
    }

    await this.loadIncentive()

  },
  watch: {},
  methods: {
    resetScrollBarPosition() {
      // reset scroll bar positioning to top
      document.getElementsByClassName('v-data-table__wrapper').forEach(table => table.scrollTop = 0)
    },

    /* INCENTIVE-RELATED CODE START */
    async loadIncentive() {
      this.incentiveDataLoaded = false

      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const params = {
          isSetterMgr: this.isSetterMgr,
          setterMgrOfficeId: this.isSetterMgr && this.userOfficeId ? this.userOfficeId : null
        }

        getRequestWithParams('/setterDashboard/getIncentivePitchCounts', {params}, 'blueraven').then(res => {
          this.pitchCounts = res.data

          this.incentiveDataLoaded = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving incentive data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.incentiveDataLoaded = true
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },

    calcPointsForQuarter(pitchCount) {
      if(pitchCount >= this.dashboardType.milestoneGoalMap[MilestoneEnum.LEVEL1] && pitchCount < this.dashboardType.milestoneGoalMap[MilestoneEnum.LEVEL2]){
        return 1
      } else if (pitchCount >= this.dashboardType.milestoneGoalMap[MilestoneEnum.LEVEL2] && pitchCount < this.dashboardType.milestoneGoalMap[MilestoneEnum.LEVEL3]){
        return 2
      } else if (pitchCount >= this.dashboardType.milestoneGoalMap[MilestoneEnum.LEVEL3] && pitchCount < this.dashboardType.milestoneGoalMap[MilestoneEnum.LEVEL4]){
        return 3
      } else if (pitchCount >= this.dashboardType.milestoneGoalMap[MilestoneEnum.LEVEL4]){
        return 4
      }
      else return 0
    }
  }
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
