<template>
  <v-container id="closer-dash-container" class="incentive-tab-override" ref="closerDashContainer">
    <Incentive :dashboard-type="dashboardType" :counts="fdcCounts" :yearly-point-total="yearlyPointTotal" :incentive-data-loaded="incentiveDataLoaded"></Incentive>
  </v-container>
</template>

<script>
  import moment from 'moment'
  import { getRequest, getSnackbar } from '@/helpers/helpers'
  import { AppMutations } from '@/stores/AppStore'
  import Incentive from "@/views/blueraven/closerDashboard/Incentive";
  import {DashboardTypeEnum} from "@/views/blueraven/closerDashboard/incentive_constants";
  import {MilestoneEnum} from "@/views/blueraven/closerDashboard/MilestoneEnum";

  export default {
    name: 'closerIncentive',
    components: {
      Incentive
    },
    data () {
      return {
        snackbar: {},
        currentUserId: null,
        incentiveDataLoaded: false,
        currentQuarter: moment().quarter(),
        fdcCounts: {
          q1: 0, q1QualificationMet: false,
          q2: 0, q2QualificationMet: false,
          q3: 0, q3QualificationMet: false,
          q4: 0, q4QualificationMet: false
        },
      }
    },
    computed: {
      windowInnerWidth () { return window.innerWidth},
      dashboardType() {
        return DashboardTypeEnum.CLOSER;
      },
      yearlyPointTotal () {
        // Calculate points for each quarter
        const q1_points= this.calcPointsForQuarter(this.fdcCounts.q1, this.fdcCounts.q1QualificationMet),
            q2_points= this.calcPointsForQuarter(this.fdcCounts.q2, this.fdcCounts.q2QualificationMet),
            q3_points= this.calcPointsForQuarter(this.fdcCounts.q3, this.fdcCounts.q3QualificationMet),
            q4_points= this.calcPointsForQuarter(this.fdcCounts.q4, this.fdcCounts.q4QualificationMet)
        //return total
        return q1_points + q2_points + q3_points + q4_points
      }
    },
    methods: {
      resetScrollBarPosition () {
        // reset scroll bar position to top
        this.$refs.closerDashContainer.scrollTop = 0
      },

      async loadIncentive () {
        this.incentiveDataLoaded = false

        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          getRequest('/closerDashboard/getIncentiveFdcCounts', 'blueraven').then(res => {
            this.fdcCounts = res.data
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

      calcPointsForQuarter (fdcCount, qualificationMetForQuarter) {
        if (qualificationMetForQuarter) {
          switch (true) {
            case fdcCount >= this.dashboardType.milestoneGoalMap[MilestoneEnum.LEVEL1] && fdcCount < this.dashboardType.milestoneGoalMap[MilestoneEnum.LEVEL2]:
              return 1 // Level 1
            case fdcCount >= this.dashboardType.milestoneGoalMap[MilestoneEnum.LEVEL2] && fdcCount < this.dashboardType.milestoneGoalMap[MilestoneEnum.LEVEL3]:
              return 2 // Level 2
            case fdcCount >= this.dashboardType.milestoneGoalMap[MilestoneEnum.LEVEL3] && fdcCount <this.dashboardType.milestoneGoalMap[MilestoneEnum.LEVEL4]:
              return 3 // Level 3
            case fdcCount >= this.dashboardType.milestoneGoalMap[MilestoneEnum.LEVEL4]:
              return 4 // Level 4
            default:
              return 0 // No medal
          }
        } else {
          return 0 // No medal
        }
      },
    },
    async created () {
      this.currentUserId = this.$store.state.user.details.id
      await this.loadIncentive()
    },
    mounted () {}
  }
</script>

<style lang="scss" scoped>
  #closer-dash-container {
    font-family: 'Roboto Condensed', sans-serif !important;
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
