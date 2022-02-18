<template>
  <v-row justify="center" no-gutters>
    <v-col cols="12" id="incentive-container" class="justify-end">
      <div id="milestones-container">
        <incentive-milestone
            :milestone-level="MilestoneEnum.LEVEL1"
            :currentQuarterCount = "currentQuarterCount"
            :drilldown="dashboardType.drilldown"
            :dashboard-type="dashboardType"
        ></incentive-milestone>
        <incentive-milestone
            :milestone-level="MilestoneEnum.LEVEL2"
            :currentQuarterCount = "currentQuarterCount"
            :dashboard-type="dashboardType"
            :drilldown="dashboardType.drilldown"
        ></incentive-milestone>
        <incentive-milestone
            :milestone-level="MilestoneEnum.LEVEL3"
            :currentQuarterCount = "currentQuarterCount"
            :dashboard-type="dashboardType"
            :drilldown="dashboardType.drilldown"
        ></incentive-milestone>
        <incentive-milestone
            :milestone-level="MilestoneEnum.LEVEL4"
            :currentQuarterCount = "currentQuarterCount"
            :dashboard-type="dashboardType"
            :drilldown="dashboardType.drilldown"
        ></incentive-milestone>
      </div>

      <div id="progress-bar-container">
        <div class="d-flex">
          <span class="progress-bar-title">Yearly Point Total</span>
        </div>
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
import {incentive_constants, DashboardTypeEnum} from './incentive_constants'
import MilestoneEnum from "@/views/blueraven/closerDashboard/MilestoneEnum";
import IncentiveMilestone from "@/views/blueraven/closerDashboard/IncentiveMilestone";

export default {
  name: "Incentive",
  components: {
    IncentiveMilestone
  },
  props: {
    currentQuarterCount: Number,
    yearlyPointTotal: Number,
    dashboardType: DashboardTypeEnum
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
  },
  created() {
    this.calcYearPercentage()
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
}

#progress-bar-container {
  display: flex;
  flex-flow: column nowrap;
  justify-content: flex-start;
  margin: 30px auto 120px auto;
  width: calc(100% - 50px);
  height: 20%;

  span {
    display: inline-block;
    text-align: left;
    font-size: 16px;
    color: #fff;

    &.progress-bar-title {
      font-size: 20px;
    }
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
    height: 100%;
  }

  .progress-bar-segment {
    background-color: white;
    border: 0.02em solid black;
    width: 12.5%;
    height: 100%;

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

    #progress-bar {
      height: 17px;
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


  }
}

@media (min-width: 1070px) {

  #milestones-container {
    width: 65%;
  }

  #progress-bar-container {
    width: 65%;
    height: 20%;
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
