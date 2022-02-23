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
.align-items-center {
  align-items: center;
}

.align-items-flex-start {
  align-items: flex-start;
}

.align-items-flex-end {
  align-items: flex-end;
}

#setter-dash-container {
  font-family: 'Roboto Condensed', sans-serif !important;
  letter-spacing: 0.02em !important;
  overflow: auto;
}

#setter-dash-container.incentive-tab-override {
  padding: 0 !important;

  #setter-dash-toolbar-container {
    margin: 0 !important;

    #setter-dash-toolbar {
      padding: 0 !important;
    }
  }
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

#incentive-container {
  background: black url("../../../assets/blueraven/title_pilot.jpg") no-repeat fixed center;
  background-size: cover;
  display: flex;
  flex-flow: column nowrap;
  align-items: center;

  #incentive-banner {
    padding-top: 15px;
    margin-bottom: -50px;
    width: 100%;
    max-width: 350px;
  }
}

#milestones-container {
  display: flex;
  flex-flow: column nowrap;
  justify-content: center;
  width: 100%;

  .milestone {
    display: flex;
    flex-flow: column nowrap;
    justify-content: center;
    align-items: center;
    width: 100%;
    margin-top: 15px;

    .milestone-top-label {
      display: inline-block;
      text-align: center;
      color: #fff;
      font-size: 12px;
      font-weight: bold;
      width: 220px;
    }

    .milestone-bottom-label {
      display: inline-block;
      text-align: center;
      color: #fff;
      font-size: 10px;
      margin-top: 3px;
      width: 220px;
    }

    .milestone-content {
      cursor: pointer;
      border: 3px solid white;
      display: flex;
      flex-flow: row nowrap;
      padding: 5px;
      width: 220px;
      height: 110px;

      .milestone-content-left-side {
        align-self: center;
        width: 50%;
        height: 80%;
      }

      .milestone-content-right-side {
        display: flex;
        flex-flow: column nowrap;
        width: 50%;

        .milestone-top-right-label {
          color: white;
          text-align: right;
          font-size: 10px;
        }

        .milestone-stars-container {
          display: flex;
          flex-flow: row wrap;
          justify-content: center;
          align-items: center;
          align-content: center;
          width: 100%;
          height: 70%;

          .milestone-star {
            font-size: 22px;
            color: rgba(255, 255, 255, 0.3) !important;
            text-shadow: 0 0 0 rgba(255, 255, 255, 0.5);
            background: #222 -webkit-gradient(linear, left top, right top, from(#222), to(#222), color-stop(0.5, #fff)) 0 0 no-repeat;
            background-size: 25px;
            -webkit-background-clip: text;
            animation-name: shine;
            animation-duration: 5s;
            animation-iteration-count: infinite;
          }

          @keyframes shine {
            0% {
              background-position-x: -50px;
            }
            100% {
              background-position-x: 50px;
            }
          }

          .three-stars-padding-override {
            padding: 0 20px;
          }
        }

        .four-stars-padding-override {
          padding: 0 20px;
        }

        .five-stars-padding-override {
          padding: 0 10px;
        }
      }
    }
  }

  .active-milestone {
    .milestone-top-label,
    .milestone-bottom-label {
      width: 260px;
    }

    .milestone-top-label {
      font-size: 13px;
    }

    .milestone-bottom-label {
      font-weight: bold;
      font-size: 11px;
    }

    .milestone-content {
      border: 3px solid white;
      width: 260px;
      height: 130px;

      .milestone-content-right-side {
        .milestone-top-right-label {
          font-weight: bold;
          font-size: 11px;
        }

        .milestone-stars-container {
          .milestone-star {
            font-size: 28px;
          }

          .three-stars-padding-override {
            padding: 0 20px;
          }
        }

        .four-stars-padding-override {
          padding: 0 20px;
        }

        .five-stars-padding-override {
          padding: 0 10px;
        }
      }
    }
  }

  #swim-phase.active-milestone img {
    max-width: 200px;
    max-height: 173px;
    top: 30px;
    left: 45px;
  }

  #bike-phase.active-milestone img {
    max-width: 260px;
    max-height: 120px;
    top: 29px;
    left: 18px;
  }

  #run-phase.active-milestone img {
    max-width: 250px;
    max-height: 129px;
    top: 20px;
    left: 53px;
  }

  #finish-phase.active-milestone img {
    max-width: 280px;
    max-height: 138px;
    top: 13px;
    left: 80px;
  }
}

.no-medal {
  background: url('../../../assets/blueraven/no_medal_icon_white.svg') no-repeat scroll center;
  background-size: contain;
}

.a-10-level {
  background: url('../../../assets/blueraven/a10_warthog.png') no-repeat scroll center;
  background-size: contain;
}

.f-14-level {
  background: url('../../../assets/blueraven/f14_tomcat.png') no-repeat scroll center;
  background-size: contain;
}

.fa-18-level {
  background: url('../../../assets/blueraven/fa18_hornet.png') no-repeat scroll center;
  background-size: contain;
}

.f-22-level {
  background: url('../../../assets/blueraven/f22_raptor.png') no-repeat scroll center;
  background-size: contain;
}

.f-35-level {
  background: url('../../../assets/blueraven/f35_lightning.png') no-repeat scroll center;
  background-size: contain;
}

#progress-bar-container {
  display: flex;
  flex-flow: column nowrap;
  justify-content: space-between;
  margin: 30px auto;
  width: calc(100% - 50px);
  height: 37px;

  span {
    display: inline-block;
    text-align: left;
    font-size: 11px;
    font-weight: bold;
    color: #fff;
  }

  #progress-bar {
    display: flex;
    flex-flow: row nowrap;
    position: relative;
    border: 0.02em solid black;
    border-radius: 4px;
    height: 15px;
  }

  #progress-bar-fill {
    position: absolute;
    top: 0.02em;
    z-index: 1;
    background: linear-gradient(to right, #164761, #2C8EC2);
    transition: width 1s ease-out;
    opacity: 0.9;
    border-radius: 4px 0 0 4px;
    width: 0;
    height: 14px;
  }

  .progress-bar-segment {
    background-color: #D8D8D8;
    border: 0.02em solid black;
    width: 11.11%;
  }

  #first-segment {
    border-radius: 4px 0 0 4px;
    border: 0.03em solid black;
  }

  #ninth-segment {
    text-align: center;
    border-radius: 0 4px 4px 0;
    border: 0.03em solid black;
  }
}

#milestone-medals-container {
  display: flex;
  flex-flow: row nowrap;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 30px;
  width: 60%;
  height: 50px;

  .milestone-medal {
    width: 18%;
    min-height: 100%;
  }
}

.v-card__title {
  display: flex;
  flex-flow: row nowrap;
  justify-content: space-between;
  align-items: center;
}

#drilldown-title {
  font-family: "Roboto Condensed", sans-serif;
  font-size: 14px;
}

.close-modal-x {
  font-size: 20px;

  &:hover {
    font-weight: bolder;
  }
}

#drilldown-table {
  ::v-deep .v-data-table__wrapper {
    max-height: calc(100vh - 250px);
  }

  th, td {
    font-family: "Roboto Condensed", sans-serif;
    font-size: 10px;
  }

  .customer-name {
    text-transform: capitalize;
  }
}

#personal-performance-boxes-container {
  display: flex;
  flex-flow: column nowrap;
  align-items: center;
  text-align: center;
  font-family: "Roboto", sans-serif;
  font-weight: bold;

  .personal-performance-box {
    display: flex;
    flex-flow: column nowrap;
    justify-content: center;
    background-color: #fff;
    color: var(--v-primaryCustom-base);
    box-shadow: 2px 2px 6px 0 rgba(0, 0, 0, 0.3);
    border-radius: 4px;
    padding: 5px 10px;
    margin: 5px 0;
    width: 100%;
    height: 130px;
  }

  .personal-performance-box-title {
    font-size: 12px;
  }

  .personal-performance-box-number {
    font-size: 50px;
  }

  .personal-performance-box-subtitle {
    font-size: 10px;
  }

  #personal-performance-rank-box {
    display: flex;
    flex-flow: row nowrap;
    background-color: #fff;
    color: var(--v-primaryCustom-base);
    box-shadow: 2px 2px 6px 0 rgba(0, 0, 0, 0.3);
    border-radius: 4px;
    padding: 5px 10px;
    margin: 5px 0;
    width: 100%;
    height: 130px;

    #rank-box-left-side {
      display: flex;
      flex-flow: column nowrap;
      align-items: center;
      padding-top: 5px;
      width: 49%;
    }

    #rank-box-separator {
      background-color: #ddd;
      margin: 0 5px;
      width: 2px;
    }

    #rank-box-right-side {
      width: 49%;

      #rank-box-content {
        display: flex;
        flex-flow: column nowrap;
        align-items: center;
        justify-content: space-between;
        height: 80px;

        #office-to-beat-name,
        #rep-to-beat-name {
          font-size: 10px;
          color: var(--v-primaryText-base) !important;
        }

        .office-to-beat-icon,
        .rep-to-beat-icon {
          color: var(--v-primaryText-base) !important;
          font-size: 30px;
        }

        .rep-to-beat-img {
          border-radius: 50%;
          margin: 5px 0;
          width: 40px;
          height: 40px;
        }

        #rank-box-subtitle {
          font-size: 9px;
        }
      }
    }
  }
}

.ranking-tables-section-header {
  color: var(--v-primaryCustom-base);
  text-align: left;
  font-family: "Roboto", sans-serif;
  font-weight: bold;
  font-size: 20px;
  border-bottom: 2px solid var(--v-primaryCustom-base);
  margin: 0 auto 12px auto;
  padding-bottom: 3px;
  width: 100%;
}

.ranking-tables-section {
  display: flex;
  flex-flow: column nowrap;
  align-items: center;
  margin: 0 auto 12px auto;
  width: 100%;
}

#setter-ranking-tables-section {
  display: flex;
  flex-flow: column nowrap;
  align-items: center;
  width: 100%;

  #setter-ranking-tables-left-col,
  #setter-ranking-tables-right-col {
    display: flex;
    flex-flow: column nowrap;
    align-items: center;
    width: 100%;
  }

  #setter-ranking-tables-left-col {
    margin-top: 5px;

    .ranking-table {
      margin-bottom: 10px;
    }
  }

  #setter-ranking-tables-right-col {
    .ranking-table {
      margin-bottom: 150px;
    }
  }
}

.ranking-tables-no-data {
  font-family: "Roboto", sans-serif;
  font-size: 11px;
  text-align: left;
  padding: 10px 10px 15px 10px;
}

.ranking-table {
  font-family: "Roboto", sans-serif;
  background-color: #fff;
  box-shadow: 2px 2px 6px 0 rgba(0, 0, 0, 0.3);
  border-radius: 4px;
  margin-bottom: 15px;
  overflow-x: auto;
  width: 100%;
}

.ranking-table-header {
  display: flex;
  flex-flow: row nowrap;
  color: var(--v-primaryCustom-base);
  font-weight: bold;
  font-size: 16px;
  text-align: left;
  padding: 10px 5px 5px 10px;
}

#top-reps-table-header {
  flex-wrap: wrap;
  justify-content: space-between;
  align-items: center;
}

#top-reps-table-header div {
  display: flex;
  flex-flow: row nowrap;
  align-items: center;
  padding-right: 3px;
  padding-bottom: 3px;
}

#top-reps-table-header input {
  font-weight: normal;
  border: 1px solid #ccc;
  padding-left: 3px;
  margin-right: 5px;
  max-width: 150px;
}

.ranking-table-icon {
  font-size: 24px;
  color: var(--v-primaryText-base) !important;
}

.ranking-table table {
  border-collapse: collapse;
  width: 100%;
}

.ranking-table th {
  border-bottom: 1px solid #e6eeff;
  color: var(--v-primaryCustom-base);
  font-size: 11px;
  height: 55px;
}

.ranking-table td {
  border-bottom: 1px solid #e6eeff;
  font-weight: bold;
  font-size: 10px;
  height: 41px;
}

.ranking-table th,
.ranking-table td {
  padding: 2px 4px;
}

.ranking-table .user-img-col {
  padding-top: 6px;
}

.ranking-table .center-text {
  text-align: center;
}

.ranking-table .left-text {
  text-align: left;
}

.highlight-user-row {
  background-color: var(--v-primaryCustom-base);
  color: #fff;
}

.ranking-table-img,
.placeholder-img {
  border-radius: 50%;
  padding: 1px;
  width: 28px;
  height: 28px;
}

.placeholder-img {
  background-color: #e9e9e9;
}

#funnel-background {
  display: none;
}

#pipeline-container {
  background-color: #fff;
  box-shadow: 2px 2px 6px 0 rgba(0, 0, 0, 0.3);
  border-radius: 4px;
  width: 100%;

  .pipeline-header-container {
    display: flex;
    flex-flow: column nowrap;
    border-bottom: 1px solid var(--v-primaryCustom-base);
    width: 100%;

    #pipeline-header-top {
      display: flex;
      flex-flow: row nowrap;
      text-align: left;
      border-bottom: 1px solid var(--v-primaryCustom-base);
      padding: 5px;

      .pipeline-icon {
        color: var(--v-primaryText-base) !important;
        font-size: 24px;
      }

      .pipeline-title {
        font-size: 18px;
        font-weight: bold;
        color: var(--v-primaryCustom-base);
        margin-left: 8px;
      }
    }

    #pipeline-header-controls {
      display: flex;
      flex-flow: row wrap;
      padding: 3px 5px;
      width: 100%;

      #pipeline-header-left-side,
      #pipeline-header-right-side {
        display: flex;
        align-items: center;
      }

      #pipeline-header-left-side {
        flex-flow: row nowrap;

        .v-input {
          padding-top: 0;
          margin-top: 0;

          ::v-deep {
            .v-input__slot {
              margin-bottom: 0;
            }

            .v-input--radio-group__input {
              display: flex;
              flex-flow: row nowrap;
            }
          }
        }

        .funnel-radio-btn {
          margin: 3px 13px 3px 0;

          ::v-deep {
            .v-input--selection-controls__input {
              transform: scale(0.75);
              transform-origin: left;
              margin-right: -3px;
            }

            .v-label {
              font-size: 10px;
            }
          }
        }

        ::v-deep .v-messages {
          display: none !important;
        }
      }

      #pipeline-header-right-side {
        flex-flow: row wrap;

        .pipeline-dropdown {
          transform: scale(0.875);
          transform-origin: left;
          margin: 2px 0;
          max-width: 135px;

          ::v-deep {
            .v-input__slot {
              margin: 0;
            }

            label {
              color: #888 !important;
              font-size: 10px;
            }

            i {
              color: #888 !important;
              font-size: 16px;
            }

            .v-text-field__details {
              display: none;
            }
          }
        }

        #all-reps-btn {
          text-transform: capitalize;
          font-size: 10px;
          margin: 2px 0;
          width: 87px;
          height: 35px;
        }
      }
    }
  }

  .funnel-container {
    position: relative;

    .funnel-table {
      border-spacing: 0;
      border-bottom-left-radius: 4px;
      border-bottom-right-radius: 4px;
      overflow: hidden;
      width: 100%;

      .blue-sub-row {
        background-color: #e9f2ff;
      }

      .custom-dates-container {
        display: flex;
        flex-flow: row wrap;
        justify-content: center;
        align-items: center;
        margin: 2px auto 0 auto;

        .custom-date-input {
          font-size: 8px;
          margin-bottom: 2px;
          max-width: 40px;
          height: 12px;

          ::v-deep {
            .v-input__control {
              max-width: 40px;
              height: 14px;
            }

            .v-input__slot {
              padding: 0;
              width: 40px;
              height: 12px;
              min-height: 12px;
            }

            .v-text-field__slot input {
              text-align: center;
            }

            .v-text-field__details {
              display: none;
            }
          }
        }

        .custom-date-span {
          font-size: 8px;
          margin: 0 2px 3px 2px;
        }
      }

      .funnel-th {
        color: var(--v-primaryCustom-base);
        font-size: 8px;
        font-weight: normal;
        text-align: center;
        padding: 2px;

        .custom-dates-btn {
          display: flex;
          flex-flow: row nowrap;
          justify-content: space-between;
          align-items: center;
          font-size: 7px;
          text-transform: capitalize;
          padding: 4px 1px;
          margin: 4px auto;
          width: 100%;
          min-width: 40px;
          max-width: 70px;
          height: 20px;

          .v-icon {
            font-size: 12px;
            margin-left: 0;
          }
        }
      }

      .funnel-expectation {
        text-align: center;
        width: 75px;
      }

      .funnel-line-name {
        cursor: default !important;
        position: relative;
        z-index: 7;
        text-align: center;
        height: 38px;
      }

      #expectation-input {
        .v-input {
          transform: scale(0.75);
          transform-origin: center;
          font-size: 10px;
          margin: 0 auto;
          max-width: 50px;

          ::v-deep {
            .v-input__slot {
              margin-bottom: 0;
            }

            input {
              text-align: center;
            }

            .v-text-field__details,
            .v-messages {
              display: none;
            }
          }
        }
      }

      .funnel-td {
        font-size: 7px;
        text-align: center;

        div {
          display: flex;
          justify-content: center;
        }

        .funnel-count,
        .funnel-percentage {
          margin: 3px;
        }

        .funnel-arrow {
          font-size: 6px;
        }
      }
    }
  }
}

#funnel-drilldown {
  .missing {
    background-color: rgba(204, 0, 0, 0.5);
  }

  .v-card__title {
    display: flex;
    flex-flow: row nowrap;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 10px;
    padding: 0 24px;

    #funnel-drilldown-title {
      font-family: "Roboto Condensed", sans-serif;
      font-size: 14px;
      line-height: 24px;
      word-break: normal;
      padding-top: 5px;
    }
  }

  .close-modal-x {
    font-size: 20px;
    margin-left: 15px;

    &:hover {
      font-weight: bolder;
    }
  }

  #funnel-drilldown-search {
    display: flex;
    flex-flow: row nowrap;
    justify-content: space-between;
    align-items: center;

    ::v-deep .v-input {
      max-width: 70%;
    }

    ::v-deep input,
    #funnel-drilldown-row-count {
      font-size: 11px;
    }
  }

  #funnel-drilldown-table {
    ::v-deep .v-data-table__wrapper {
      max-height: calc(100vh - 300px);
    }

    ::v-deep th, ::v-deep td {
      font-size: 10px;
      padding: 5px;
    }

    ::v-deep th {
      line-height: 14px;

      .v-data-table-header__icon {
        font-size: 12px !important;
        padding-bottom: 2px;
      }
    }

    .customer-name {
      text-transform: capitalize;
    }

    .funnel-drilldown-no-data-msg {
      text-align: left;
      margin-left: 25px;
    }
  }

  .v-card__text {
    padding-bottom: 0;
  }

  .v-btn {
    font-size: 10px;
    width: 50px;
    min-width: 50px;
    height: 25px;
  }
}

@media (min-width: 500px) {
  #setter-dash-toolbar-container #setter-dash-toolbar .v-toolbar .v-toolbar__content .v-toolbar__title {
    font-size: 16px;
  }

  #progress-bar-container {
    span {
      font-size: 14px;
    }

    #progress-bar {
      height: 17px;
    }

    #progress-bar-fill {
      height: 16px;
    }
  }

  #funnel-drilldown {
    .v-card__title {
      align-items: center;
    }

    #funnel-drilldown-search {
      ::v-deep .v-input {
        max-width: 75%;
      }
    }
  }
}

@media (min-width: 737px) {
  #setter-dash-toolbar-container {
    #setter-dash-toolbar {
      #setter-dash-title-container {
        margin: 0 auto;

        ::v-deep .v-toolbar__content {
          .v-toolbar__title {
            font-size: 18px;
          }
        }
      }

      #date-range-btns-toolbar {
        height: 60px !important;

        ::v-deep .v-toolbar__content {
          padding: 10px 12px;
          height: 60px !important;
        }

        .v-btn-toggle {
          margin-right: 0;

          .v-btn {
            font-size: 12px;
            height: 30px;
          }
        }
      }
    }
  }

  #setter-dash-tabs {
    margin: 0 auto;

    .col-12 span {
      font-size: 12px;
    }
  }

  #setter-dash-tabs.incentive-tab-overrides {
    margin-bottom: -41px !important;
  }

  #incentive-container {
    background: black url("../../../assets/blueraven/title_pilot.jpg") no-repeat scroll center -50px;
    background-size: cover;

    #incentive-banner {
      margin-bottom: -80px;
      max-width: 673px;
    }
  }

  #milestones-container {
    flex-flow: row wrap;
    margin: 0 auto;
    width: calc(100% - 110px);

    .milestone {
      margin-top: 0;
      margin-bottom: 10px;
      width: 300px;

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
        width: 200px;
        height: 130px;

        .milestone-content-right-side {
          .milestone-top-right-label {
            font-size: 12px;
          }

          .milestone-stars-container {
            .milestone-star {
              font-size: 26px;
            }

            .three-stars-padding-override {
              padding: 0 10px;
            }
          }

          .four-stars-padding-override {
            padding: 0 10px;
          }

          .five-stars-padding-override {
            padding: 0;
          }
        }
      }
    }

    .active-milestone {
      .milestone-top-label,
      .milestone-bottom-label {
        width: 240px;
      }

      .milestone-top-label {
        font-size: 15px;
      }

      .milestone-bottom-label {
        font-size: 14px;
      }

      .milestone-content {
        width: 240px;
        height: 160px;

        .milestone-content-left-side {
          height: 100%;
        }

        .milestone-content-right-side {
          .milestone-top-right-label {
            font-size: 13px;
          }

          .milestone-stars-container {
            .milestone-star {
              font-size: 32px;
            }

            .three-stars-padding-override {
              padding: 0 10px;
            }
          }

          .four-stars-padding-override {
            padding: 0 10px;
          }

          .five-stars-padding-override {
            padding: 0;
          }
        }
      }
    }
  }

  #progress-bar-container {
    width: calc(100% - 110px);

    #progress-bar {
      height: 20px;
    }

    #progress-bar-fill {
      height: 19px;
    }
  }

  #milestone-medals-container {
    width: 50%;
    height: 60px;
  }

  #drilldown-title {
    font-size: 18px;
  }

  #drilldown-table {
    th, td {
      font-size: 12px;
    }
  }

  #personal-performance-boxes-container {
    flex-flow: row wrap;
    justify-content: space-between;
    margin: -10px auto 0 auto;
    max-width: calc(100% - 50px);

    .personal-performance-box {
      margin: 15px 0;
      width: 48%;
      height: 150px;
    }

    .personal-performance-box-title {
      font-size: 16px;
    }

    .personal-performance-box-number {
      font-size: 56px;
    }

    .personal-performance-box-subtitle {
      font-size: 14px;
    }

    #personal-performance-rank-box {
      margin: 15px 0;
      width: 48%;
      height: 150px;

      #rank-box-right-side {
        padding-top: 5px;

        #rank-box-content {
          height: 95px;

          #rep-to-beat-name {
            font-size: 12px;
          }

          .office-to-beat-icon,
          .rep-to-beat-icon {
            font-size: 35px;
          }

          #rank-box-subtitle {
            font-size: 11px;
          }
        }
      }
    }
  }

  .ranking-tables-section-header {
    font-size: 26px;
    margin-bottom: 20px;
    padding-bottom: 5px;
    max-width: calc(100% - 50px);
  }

  #setter-ranking-tables-section {
    flex-flow: row wrap;
    align-items: flex-start;

    #setter-ranking-tables-left-col,
    #setter-ranking-tables-right-col {
      .ranking-table {
        font-size: 14px;
      }
    }

    #setter-ranking-tables-left-col {
      .ranking-table {
        margin-bottom: 30px;
      }
    }

    #setter-ranking-tables-right-col {
      .ranking-table {
        margin-bottom: 180px;
      }
    }
  }

  .ranking-tables-no-data {
    font-size: 14px;
  }

  .ranking-table {
    margin-bottom: 30px;
    font-size: 14px;
    max-width: calc(100% - 50px);
  }

  .ranking-table-header {
    font-size: 24px;
    padding: 20px 15px 15px 15px;
  }

  .ranking-table-icon {
    font-size: 30px;
  }

  .ranking-table th {
    height: 50px;
  }

  .ranking-table td {
    height: 53px;
  }

  .ranking-table th,
  .ranking-table td {
    font-size: 14px;
    padding: 0 5px;
  }

  .ranking-table-img,
  .placeholder-img {
    width: 40px;
    height: 40px;
  }

  #top-reps-table-header div {
    padding-right: 0;
    padding-bottom: 0;
  }

  #top-reps-table-header input {
    font-size: 14px;
    max-width: 250px;
    height: 30px;
  }

  #funnel-background {
    display: block;
    position: absolute;
    z-index: 6;
    border-top-style: solid;
    border-top-color: rgba(0, 110, 200, 0.05);
    border-right: 20px solid transparent;
    border-left: 20px solid transparent;
    margin-top: 63px;
    margin-left: 110px;
    width: 170px;
    height: 0;
  }

  #funnel-background.standard-view {
    border-top-width: 120px;
  }

  #funnel-background.cohort-view {
    border-top-width: 160px;
  }

  #pipeline-container {
    margin: 0 auto;
    max-width: calc(100% - 50px);

    .pipeline-header-container {
      border-bottom: 2px solid var(--v-primaryCustom-base);

      #pipeline-header-top {
        border-bottom: 2px solid var(--v-primaryCustom-base);
        padding: 10px;

        .pipeline-icon {
          font-size: 32px;
        }

        .pipeline-title {
          font-size: 24px;
          margin-left: 10px;
        }
      }

      #pipeline-header-controls {
        justify-content: space-between;

        #pipeline-header-left-side {
          .v-input ::v-deep .v-input--radio-group__input {
            flex-flow: column nowrap;
          }

          .funnel-radio-btn {
            ::v-deep {
              .v-input--selection-controls__input {
                transform: scale(0.8);
                margin-right: 0;
              }

              .v-label {
                font-size: 12px;
              }
            }
          }
        }

        #pipeline-header-right-side {
          flex-flow: row nowrap;
          margin-bottom: 0;

          .pipeline-dropdown {
            transform: none;
            margin: 3px;

            ::v-deep {
              label {
                font-size: 12px;
              }

              i {
                font-size: 20px;
              }
            }
          }

          #all-reps-btn {
            font-size: 12px;
            margin: 3px;
            width: 100px;
            height: 40px;
          }
        }
      }
    }

    .funnel-container {
      .funnel-table {
        .custom-dates-container {
          flex-flow: row nowrap;
          margin: 0 auto;

          .custom-date-input {
            font-size: 10px;
            margin-bottom: 1px;
            max-width: 45px;
            height: 16px;

            ::v-deep {
              .v-input__control {
                max-width: 45px;
                height: 16px;
              }

              .v-input__slot {
                width: 45px;
                height: 16px;
                min-height: 16px;
              }
            }
          }

          .custom-date-span {
            font-size: 12px;
            margin: 0 3px;
          }
        }

        .funnel-th {
          font-size: 12px;
          padding: 8px;

          .custom-dates-btn {
            font-size: 10px;
            padding: 5px 2px;
            margin: 4px auto;
            min-width: 60px;
            max-width: 100px;
            height: 38px;

            .v-icon {
              font-size: 16px;
            }
          }
        }

        .funnel-expectation {
          width: 120px;
        }

        .funnel-line-name {
          width: 150px;
          height: 40px;
        }

        #expectation-input {
          .v-input {
            transform: scale(0.8);
            font-size: 15px;
            max-width: 70px;
          }
        }

        .funnel-td {
          font-size: 12px;

          .funnel-count,
          .funnel-percentage {
            margin: 5px;
          }

          .funnel-arrow {
            font-size: 10px;
          }
        }
      }
    }
  }

  #funnel-drilldown {
    .v-card__title {
      padding: 10px 24px 0 24px;

      #funnel-drilldown-title {
        font-size: 18px;
        padding-bottom: 10px;
      }
    }

    .close-modal-x {
      font-size: 24px;
    }

    #funnel-drilldown-search {
      ::v-deep input,
      #funnel-drilldown-row-count {
        font-size: 12px;
      }

      ::v-deep .v-input {
        width: 80%;
      }

      #funnel-drilldown-row-count {
        text-align: right;
        width: 20%;
      }
    }

    #funnel-drilldown-table {
      ::v-deep th, ::v-deep td {
        font-size: 11px;
      }

      ::v-deep th {
        line-height: 16px;

        .v-data-table-header__icon {
          font-size: 14px !important;
          padding-bottom: 3px;
        }
      }
    }

    .v-card__text {
      padding-bottom: 10px;
    }

    .v-btn {
      font-size: 12px;
      width: 75px;
      height: 30px;
    }
  }
}

@media (min-width: 1070px) {
  #setter-dash-toolbar-container {
    #setter-dash-toolbar {
      #setter-dash-title-container {
        ::v-deep .v-toolbar__content {
          .v-toolbar__title {
            font-size: 20px;
          }
        }
      }

      #date-range-btns-toolbar {
        .v-btn-toggle {
          margin-right: 0;

          .v-btn {
            font-size: 13px;
            height: 35px;
          }
        }
      }
    }
  }

  #setter-dash-tabs .col-12 span {
    font-size: 13px;
  }

  #milestones-container {
    width: 65%;

    .milestone {
      margin-bottom: 0;
    }

    #aim-high-phase,
    #fly-phase {
      margin-bottom: 20px;
    }
  }

  #progress-bar-container {
    width: 65%;
    height: 42px;
  }

  #milestone-medals-container {
    width: 45%;
    max-width: 650px;
  }

  #drilldown-title {
    font-size: 24px;
  }

  #personal-performance-boxes-container {
    flex-flow: row nowrap;

    .personal-performance-box {
      margin: 10px 0;
      padding: 5px;
      width: calc(25% - 15px);
      height: 170px;
    }

    .personal-performance-box-title {
      font-size: 14px;
    }

    .personal-performance-box-number {
      font-size: 50px;
    }

    .personal-performance-box-subtitle {
      font-size: 12px;
    }

    #personal-performance-rank-box {
      margin: 10px 0;
      padding: 5px;
      width: calc(25% - 15px);
      height: 170px;

      #rank-box-left-side,
      #rank-box-right-side {
        padding-top: 10px;
      }

      #rank-box-right-side {
        #rank-box-content {
          .office-to-beat-icon,
          .rep-to-beat-icon {
            font-size: 40px;
          }
        }
      }
    }
  }

  .ranking-tables-section-header {
    margin: 20px auto;
    max-width: calc(100% - 50px)
  }

  #setter-ranking-tables-section {
    display: flex;
    flex-flow: row nowrap;
    justify-content: space-between;
    align-items: flex-start;
    max-width: calc(100% - 50px);
    margin: 0 auto;

    #setter-ranking-tables-left-col,
    #setter-ranking-tables-right-col {
      max-width: calc((100% / 2) - 14px);

      .ranking-table {
        width: 100%;
        max-width: 100%;
      }
    }

    #setter-ranking-tables-left-col {
      margin-top: 0;

      #setter-ranking-top-offices-table {
        margin-bottom: 33px;
      }
    }
  }

  .ranking-tables-section {
    display: flex;
    flex-flow: row nowrap;
    justify-content: space-between;
    align-items: flex-start;
    max-width: calc(100% - 50px);
    margin: 0 auto;
  }

  .ranking-table {
    width: 100%;
    max-width: calc((100% / 2) - 10px);
  }

  .ranking-table-icon {
    font-size: 35px;
  }

  .ranking-table th {
    font-size: 12px;
    height: 55px;
  }

  .ranking-table td {
    font-size: 12px;
  }

  .ranking-tables-no-data {
    font-size: 12px;
  }

  #funnel-background {
    border-right: 80px solid transparent;
    border-left: 80px solid transparent;
    margin-top: 63px;
    margin-left: 140px;
    width: 320px;
  }

  #funnel-background.standard-view {
    border-top-width: 180px;
  }

  #funnel-background.cohort-view {
    border-top-width: 240px;
  }

  #pipeline-container {
    .pipeline-header-container {
      #pipeline-header-top {
        .pipeline-icon {
          font-size: 35px;
        }

        .pipeline-title {
          margin-left: 15px;
        }
      }

      #pipeline-header-controls {
        padding: 5px 10px;

        #pipeline-header-left-side {
          .funnel-radio-btn {
            ::v-deep {
              .v-input--selection-controls__input {
                transform: none;
                margin-right: 4px;
              }

              .v-label {
                font-size: 14px;
              }
            }
          }
        }

        #pipeline-header-right-side {
          .pipeline-dropdown {
            margin: 5px;

            ::v-deep {
              label {
                font-size: 14px;
              }

              i {
                font-size: 24px;
              }
            }
          }

          #all-reps-btn {
            margin: 5px 0 5px 5px;
            font-size: 14px;
          }
        }
      }
    }

    .funnel-container {
      .funnel-table {
        .custom-dates-container {
          .custom-date-input {
            font-size: 12px;
            max-width: 55px;
            height: 18px;

            ::v-deep {
              .v-input__control {
                max-width: 55px;
                height: 18px;
              }

              .v-input__slot {
                width: 55px;
                height: 18px;
                min-height: 18px;
              }
            }
          }

          .custom-date-span {
            font-size: 13px;
            margin: 0 5px;
          }
        }

        .funnel-th {
          font-size: 14px;
          padding: 10px;

          .custom-dates-btn {
            font-size: 12px;
            padding: 8px 4px;
            margin: 5px auto 0 auto;
            min-width: 80px;
            max-width: 125px;

            .v-icon {
              font-size: 20px;
            }
          }
        }

        .funnel-expectation {
          width: 150px;
        }

        .funnel-line-name {
          width: 300px;
        }

        #expectation-input {
          .v-input {
            transform: none;
            font-size: 14px;
            max-width: 80px;
          }
        }

        .funnel-td {
          font-size: 14px;
          height: 60px;

          .funnel-count,
          .funnel-percentage {
            margin: 10px;
          }

          .funnel-arrow {
            font-size: 12px;
          }
        }
      }
    }
  }

  #funnel-drilldown {
    .v-card__title {
      #funnel-drilldown-title {
        font-size: 20px;
        line-height: 26px;
      }
    }

    #funnel-drilldown-search {
      ::v-deep input,
      #funnel-drilldown-row-count {
        font-size: 12px;
      }
    }

    .v-btn {
      font-size: 14px;
      width: 80px;
      height: 35px;
    }
  }
}

@media (min-width: 1135px) {
  #incentive-container {
    #incentive-banner {
      margin-top: -29px;
      margin-bottom: -90px;
    }
  }

  #milestones-container {
    flex-flow: row nowrap;
    width: 75%;
    max-width: 1000px;

    #aim-high-phase,
    #fly-phase {
      margin-bottom: 0;
    }

    .milestone {
      width: 250px;

      .milestone-top-label,
      .milestone-bottom-label {
        width: 185px;
      }

      .milestone-content {
        width: 185px;
        height: 120px;
      }
    }

    .active-milestone {
      .milestone-top-label,
      .milestone-bottom-label {
        width: 210px;
      }

      .milestone-content {
        width: 210px;
        height: 140px;
      }
    }
  }

  #progress-bar-container {
    width: 75%;
    max-width: 1000px;
  }

  #personal-performance-boxes-container {
    max-width: 1130px;

    #personal-performance-rank-box {
      #rank-box-left-side {
        padding-top: 23px;
      }

      #rank-box-right-side {
        padding-top: 21px;
      }
    }
  }

  .ranking-tables-section-header {
    max-width: 1130px;
  }

  .ranking-tables-section {
    max-width: 1130px;
  }

  #setter-ranking-tables-section {
    max-width: 1130px;
  }

  #funnel-background {
    width: 370px;
  }

  #pipeline-container {
    .funnel-container {
      .funnel-table {
        .custom-dates-container {
          .custom-date-input {
            max-width: 60px;
            height: 20px;

            ::v-deep {
              .v-input__control {
                max-width: 60px;
                height: 20px;
              }

              .v-input__slot {
                width: 60px;
                height: 20px;
                min-height: 20px;
              }
            }
          }

          .custom-date-span {
            font-size: 14px;
            margin: 0 10px;
          }
        }

        .funnel-th {
          .custom-dates-btn {
            font-size: 14px;
            min-width: 100px;
            max-width: 143px;
          }
        }

        .funnel-expectation {
          width: 150px;
        }

        .funnel-line-name {
          width: 350px;
        }
      }
    }
  }

  #funnel-drilldown {
    .v-card__title {
      #funnel-drilldown-title {
        font-size: 24px;
        line-height: 32px;
      }
    }

    #funnel-drilldown-search {
      ::v-deep input,
      #funnel-drilldown-row-count {
        font-size: 14px;
      }
    }

    #funnel-drilldown-table {
      ::v-deep th, ::v-deep td {
        font-size: 12px;
      }

      ::v-deep th {
        line-height: 18px;

        .v-data-table-header__icon {
          font-size: 16px !important;
        }
      }
    }
  }
}

@media(min-width: 1410px) {
  #incentive-container {
    height: calc(100vh - 106px);

    #incentive-banner {
      margin-top: -29px;
      margin-bottom: -90px;
    }
  }
}
</style>
