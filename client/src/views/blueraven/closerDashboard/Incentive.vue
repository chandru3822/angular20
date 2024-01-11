<template>
  <v-row justify="center" no-gutters>
    <v-col cols="12" id="incentive-container" class="justify-end" :style="{'background-image':null != backgroundImage.presignedUrl ? `url(${backgroundImage.presignedUrl})` : ''}">
      <img id="incentive-banner" v-if="headerImage.logoPresignedUrl" :src="headerImage.logoPresignedUrl" alt="incentive competition banner">
      <div id="milestones-container">
        <incentive-milestone
            :milestone-level="milestoneLevel(counts.q1)"
            :quarter="QuarterEnum.Q1"
            :currentQuarterCount = "counts.q1"
            :drilldown="dashboardType.drilldown"
            :dashboard-type="dashboardType"
        ></incentive-milestone>
        <incentive-milestone
            :milestone-level="milestoneLevel(counts.q2)"
            :quarter="QuarterEnum.Q2"
            :currentQuarterCount = "counts.q2"
            :dashboard-type="dashboardType"
            :drilldown="dashboardType.drilldown"
        ></incentive-milestone>
        <incentive-milestone
            :milestone-level="milestoneLevel(counts.q3)"
            :quarter="QuarterEnum.Q3"
            :currentQuarterCount = "counts.q3"
            :dashboard-type="dashboardType"
            :drilldown="dashboardType.drilldown"
        ></incentive-milestone>
        <incentive-milestone
            :milestone-level="milestoneLevel(counts.q4)"
            :quarter="QuarterEnum.Q4"
            :currentQuarterCount = "counts.q4"
            :dashboard-type="dashboardType"
            :drilldown="dashboardType.drilldown"
        ></incentive-milestone>
      </div>

      <div id="progress-bar-container">
        <div class="d-flex">
          <span class="progress-bar-title">Cumulative Points</span>
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
import {MilestoneEnum, QuarterEnum} from "@/views/blueraven/closerDashboard/MilestoneEnum";
import IncentiveMilestone from "@/views/blueraven/closerDashboard/IncentiveMilestone";
import {AppMutations} from "@/stores/AppStore";
import {getSnackbar} from "@/helpers/helpers";
import {Actions} from "@/store";

export default {
  name: "Incentive",
  components: {
    IncentiveMilestone
  },
  props: {
    counts: {
      q1: Number,
      q2: Number,
      q3: Number,
      q4: Number
    },
    yearlyPointTotal: Number,
    dashboardType: DashboardTypeEnum
  },
  data () {
    return {
      constants,
      incentive_constants,
      MilestoneEnum,
      QuarterEnum,
      percentAchieved: 0,
      progressBarIsFull: false,
      headerImage:{},
      headerImageTypeId: 991,
      backgroundImage:{},
      backgroundImageTypeId: 992
    }
  },
  computed: {
    windowInnerWidth () { return window.innerWidth},
  },
  watch: {
    yearlyPointTotal:  function ()  {
      this.calcYearPercentage()
    }
  },
  methods: {
    milestoneLevel(quarterCount) {
      switch(true) {
        case quarterCount >= this.dashboardType.milestoneGoalMap[MilestoneEnum.LEVEL4]:
          return this.MilestoneEnum.LEVEL4
        case quarterCount >= this.dashboardType.milestoneGoalMap[MilestoneEnum.LEVEL3]:
          return this.MilestoneEnum.LEVEL3
        case quarterCount >= this.dashboardType.milestoneGoalMap[MilestoneEnum.LEVEL2]:
          return this.MilestoneEnum.LEVEL2
        case quarterCount >= this.dashboardType.milestoneGoalMap[MilestoneEnum.LEVEL1]:
          return this.MilestoneEnum.LEVEL1
        default:
          return this.MilestoneEnum.LEVEL0
      }
    },
    calcYearPercentage () {
      // Fill progress bar based on closer's points for the year
      this.percentAchieved = (this.yearlyPointTotal / this.incentive_constants.totalPointsPossible) * 100
      this.percentAchieved = this.percentAchieved > 100 ? 100 : this.percentAchieved
      this.progressBarIsFull = this.percentAchieved === 100
    }
  },
  async loadImages(){
    const {img1} = await this.loadImage(this.headerImageTypeId, 'Header Image')
    this.headerImage = img1
    const {img2} = this.loadImage(this.backgroundImageTypeId, 'Background Image')
    this.backgroundImageTypeId = img2
  },
  async loadImage(typeId, imageType){
    let snackbar
    let image
    try {
      this.$store.commit(AppMutations.SET_LOADING, true)
      await this.$store.dispatch(Actions.FILE_GET_ONE,{
        attachmentTypeId: typeId,
        sourceId: this.companyId,
        callback: async (img) => {
          image = img
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      })
    } catch(e) {
      console.error('*** ERROR ***', e)
      snackbar = getSnackbar('ERROR', `Error Loading ${imageType}`)
      this.$store.commit(AppMutations.SHOW_SNACK, snackbar)
      this.$store.commit(AppMutations.SET_LOADING, false)
    }
  },
  async created() {
    this.calcYearPercentage()
    await this.loadImages()
  }
}
</script>

<style lang="scss" scoped>
#incentive-container {
  background: #1D9ADD no-repeat fixed center 0;
  background-size: cover;
  display: flex;
  flex-flow: column nowrap;
  align-items: center;
  height: 100vh;

  #incentive-banner {
    padding-top: 20px;
    padding-bottom: 50px;
    margin-bottom: -50px;
    width: 100%;
    max-height: 30vh;
    filter: drop-shadow(0 0 5rem rgb(0 0 0 / 0.4));
  }
}

#milestones-container {
  display: flex;
  flex-flow: column nowrap;
  justify-content: flex-start;
  width: 100%;
  overflow-y: scroll;
}

#progress-bar-container {
  display: flex;
  flex-flow: column nowrap;
  justify-content: flex-start;
  margin: 5px auto 30px auto;
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

    #incentive-banner {
      margin-bottom: -80px;
      padding-bottom: 75px;
      max-width: 673px;
      max-height: 40vh;
    }
  }

  #milestones-container {
    flex-flow: row wrap;
    justify-content: center;
    margin: 0 auto;
    width: calc(100% - 110px);
    align-items: center;
    overflow-y: unset;
  }

  #progress-bar-container {
    width: calc(100% - 110px);

    #progress-bar {
      height: 20px;
    }


  }
}

@media (min-width: 1070px) {
  #incentive-container {

    #incentive-banner {
      padding-top: 0;
      padding-bottom: 100px;
    }
  }

  #milestones-container {
    width: 65%;
  }

  #progress-bar-container {
    width: 65%;
    height: 20%;
    margin: 30px auto 10px auto;
  }

  #milestone-medals-container {
    width: 45%;
    max-width: 650px;
  }
}

@media (min-width: 1135px) {
  #incentive-container {
    height: calc(100vh - 106px);

    #incentive-banner {
      margin-top: -29px;
      margin-bottom: -90px;
      max-height: 50vh;
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
    height: calc(100vh - 106px);

    #incentive-banner {
      margin-top: -29px;
      margin-bottom: -90px;
    }
  }
}

</style>
