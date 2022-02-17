<template>
  <v-row justify="center" no-gutters>
    <v-col cols="12" id="incentive-container" class="justify-end">
      <div id="milestones-container">
        <incentive-milestone
            :milestone-level="MilestoneEnum.LEVEL1"
            :currentQuarterCount = "currentQuarterCount"
            :milestone-goal="incentive_constants.firstMilestoneGoalCloser"
            :milestone-label="incentive_constants.firstMilestone"
            :milestone-units="incentive_constants.milestoneUnitsCloser"
        ></incentive-milestone>
        <incentive-milestone
            :milestone-level="MilestoneEnum.LEVEL2"
            :currentQuarterCount = "currentQuarterCount"
            :milestone-goal="incentive_constants.secondMilestoneGoalCloser"
            :milestone-label="incentive_constants.secondMilestone"
            :milestone-units="incentive_constants.milestoneUnitsCloser"
        ></incentive-milestone>
        <incentive-milestone
            :milestone-level="MilestoneEnum.LEVEL3"
            :currentQuarterCount = "currentQuarterCount"
            :milestone-goal="incentive_constants.thirdMilestoneGoalCloser"
            :milestone-label="incentive_constants.thirdMilestone"
            :milestone-units="incentive_constants.milestoneUnitsCloser"
        ></incentive-milestone>
        <incentive-milestone
            :milestone-level="MilestoneEnum.LEVEL4"
            :currentQuarterCount = "currentQuarterCount"
            :milestone-goal="incentive_constants.fourthMilestoneGoalCloser"
            :milestone-label="incentive_constants.fourthMilestone"
            :milestone-units="incentive_constants.milestoneUnitsCloser"
        ></incentive-milestone>
      </div>

      <div id="progress-bar-container">
        <span>Yearly Point Total</span>
        <div id="progress-bar">
          <div v-for="i in incentive_constants.totalPointsPossible" class="progress-bar-segment"></div>
          <div id="progress-bar-fill"
               :style="{borderRadius: progressBarIsFull ? '3px' : '3px 8px 8px 3px',
                          width: this.percentAchieved + '%'}"></div>
        </div>
      </div>
    </v-col>
  </v-row>

</template>

<script>
import constants from '@/helpers/constants'
import incentive_constants from './incentive_constants'
import MilestoneEnum from "@/views/blueraven/closerDashboard/MilestoneEnum";
import IncentiveMilestone from "@/views/blueraven/closerDashboard/IncentiveMilestone";
export default {
  name: "Incentive",
  components: {
    IncentiveMilestone
  },
  props: {
    currentQuarterCount: Number,
    yearlyPointTotal: Number
  },
  data () {
    return {
      constants,
      incentive_constants,
      MilestoneEnum,
      percentAchieved: 0,
      progressBarIsFull: false,
    }
  },
  computed: {
    windowInnerWidth () { return window.innerWidth},
  },
  methods: {
    calcYearPercentage () {
      // Fill progress bar based on closer's points for the year
      this.percentAchieved = (this.yearlyPointTotal / this.incentive_constants.totalPointsPossible) * 100
      this.percentAchieved = this.percentAchieved > 100 ? 100 : this.percentAchieved
      this.progressBarIsFull = this.percentAchieved === 100
    }
  }
}
</script>

<style lang="scss" scoped>
#incentive-container {
  background: black url("../../../assets/blueraven/Ravens_Cup_Albatross.svg") no-repeat fixed center;
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
}

#progress-bar-container {
  display: flex;
  flex-flow: column nowrap;
  justify-content: space-between;
  margin: 30px auto 120px auto;
  width: calc(100% - 50px);
  height: 37px;

  span {
    display: inline-block;
    text-align: left;
    font-weight: bold;
    font-size: 11px;
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
    background: #1D9ADD;
    transition: width 1s ease-out;
    opacity: 0.9;
    border-radius: 4px 0 0 4px;
    width: 0;
    height: 14px;
  }

  .progress-bar-segment {
    background-color: white;
    border: 0.02em solid black;
    width: 12.5%;
  }

  .progress-bar-segment:first-child {
    border-radius: 4px 0 0 4px;
    border: 0.03em solid black;
  }

  .progress-bar-segment:last-child {
    border-radius: 0 4px 4px 0;
    border: 0.03em solid black;
  }
}

@media (min-width: 500px) {
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
}

@media (min-width: 737px) {
  #incentive-container {
    background: black url("../../../assets/blueraven/Ravens_Cup_Albatross.svg") no-repeat scroll center -50px;
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
    align-items: center;
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
}

@media (min-width: 1070px) {

  #milestones-container {
    width: 65%;
  }

  #progress-bar-container {
    width: 65%;
    height: 42px;
  }

  #milestone-medals-container {
    width: 45%;
    max-width: 650px;
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
  }

  #progress-bar-container {
    width: 75%;
    max-width: 1000px;
  }
}

@media (min-width: 1410px) {
  #incentive-container {
    height: calc(100vh - 99px);

    #incentive-banner {
      margin-top: -29px;
      margin-bottom: -90px;
    }
  }
}

</style>
