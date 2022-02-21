<template>
  <v-container id="closer-dash-container" class="incentive-tab-override">
    <Incentive :dashboard-type="DashboardTypeEnum.CLOSER" :counts="fdcCounts" :yearly-point-total="yearlyPointTotal" :incentive-data-loaded="incentiveDataLoaded"></Incentive>
  </v-container>
</template>

<script>
  import moment from 'moment'
  import { getRequest, getSnackbar } from '@/helpers/helpers'
  import { AppMutations } from '@/stores/AppStore'
  import Incentive from "@/views/blueraven/closerDashboard/Incentive";
  import {DashboardTypeEnum} from "@/views/blueraven/closerDashboard/incentive_constants";

  export default {
    name: 'closerIncentive',
    components: {
      Incentive
    },
    data () {
      return {
        DashboardTypeEnum,
        snackbar: {},
        currentUserId: null,
        selectedQuarter: 1,
        incentiveDataLoaded: false,
        currentQuarter: moment().quarter(),
        fdcCounts: {
          q1: 0, q1QualificationMet: false,
          q2: 0, q2QualificationMet: false,
          q3: 0, q3QualificationMet: false,
          q4: 0, q4QualificationMet: false
        },
        percentAchieved: 0,
        progressBarIsFull: false,
      }
    },
    computed: {
      windowInnerWidth () { return window.innerWidth},
      is_q1 () { return this.currentQuarter === 1 },
      is_q2 () { return this.currentQuarter === 2 },
      is_q3 () { return this.currentQuarter === 3 },
      is_q4 () { return this.currentQuarter === 4 },
      currentQuarterCount () {
        switch(this.currentQuarter){
          case 4:
            return this.fdcCounts.q4
          case 3:
            return this.fdcCounts.q3
          case 2:
            return this.fdcCounts.q2
          default:
            return this.fdcCounts.q1
        }
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
    watch: {},
    methods: {
      resetScrollBarPosition () {
        // reset scroll bar position to top
        document.getElementsByClassName('v-data-table__wrapper').forEach(table => table.scrollTop = 0)
      },

      async loadIncentive () {
        this.incentiveDataLoaded = false

        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          getRequest('/closerDashboard/getIncentiveFdcCounts', 'blueraven').then(res => {
            this.fdcCounts = res.data
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

      calcPointsForQuarter (fdcCount, qualificationMetForQuarter) {
        if (qualificationMetForQuarter) {
          switch (true) {
            case fdcCount >= 10 && fdcCount < 12:
              return 1 // A-10
            case fdcCount >= 12 && fdcCount < 15:
              return 2 // F-14
            case fdcCount >= 15 && fdcCount < 18:
              return 3 // FA-18
            case fdcCount >= 18 && fdcCount < 24:
              return 4 // F-22
            case fdcCount >= 24:
              return 5 // F-35
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
