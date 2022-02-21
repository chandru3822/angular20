<template>
  <div>
    <div :id="`quarter-${quarter.value}`" class="milestone"
         :class="{
                        'align-items-center': windowInnerWidth < 1135,
                        'align-items-flex-start': windowInnerWidth >= 1135,
                        'active-milestone': active
                        }"
         @click="milestoneDrilldown(currentQuarter)">
      <span class="milestone-top-label">{{ upperLabel }}</span>
      <div class="milestone-content mt-1" :class="colorClass">
        <div class="milestone-content-left-side d-flex align-items-flex-end"><trophy-dynamic :color="colorClass" :active="active"></trophy-dynamic></div>
        <div class="milestone-content-right-side">
          <span class="milestone-top-right-label" :class="colorClass">{{ currentQuarterCount }} FDC</span>
        </div>
      </div>
      <span class="milestone-bottom-label">{{ lowerLabel }}</span>
    </div>
    <v-dialog v-model="milestoneDialog" max-width="950" @input="closeMilestoneDialog">
      <v-card>
        <v-card-title class="mb-1">
          <span id="drilldown-title">{{ milestoneDrilldownTitle }}</span>
          <a class="close-modal-x pb-3" title="Close" @click="closeMilestoneDialog">×</a>
        </v-card-title>

        <v-card-text>
          <v-data-table
              id="drilldown-table"
              :headers="headers"
              :items="drilldownData"
              :items-per-page="-1"
              :mobile-breakpoint="0"
              fixed-header
              dense
              hide-default-footer
              class="elevation-1"
          >
            <template v-if="drilldownData.length > 0" #item="{ item, index }">
              <tr :class="['text-sm-left', 'row-hover', {'shaded-row': !(index % 2)}]">
                <td class="text-left">{{ index + 1 }}</td>
                <td class="text-left customer-name">{{ item.customer_name || '' }}</td>
                <td class="text-left"><a :href="'/project/' + item.id">{{ item.id || '' }}</a></td>
                <td class="text-left">{{ item.source_name || '' }}</td>
                <td class="text-left">{{ item.system_size || '' }}</td>
                <td class="text-left">{{ item.final_design_complete_date | formatDate('date', 'MM/DD/YYYY') }}</td>
              </tr>
            </template>

            <template #no-data>
              <div v-if="(currentQuarter < 4) && (selectedQuarter > currentQuarter)" class="my-3">
                Data is not yet available for the selected quarter.
              </div>
              <div v-else class="my-3">
                No data is available for the selected quarter.
              </div>
            </template>
          </v-data-table>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn class="white--text text-capitalize mr-4 mb-2" color="primaryButton"
                 @click="closeMilestoneDialog">
            Close
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

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

export default {
  name: "IncentiveMilestone",
  components: {TrophyDynamic},
  props: {
    quarter: QuarterEnum,
    milestoneLevel: MilestoneEnum,
    dashboardType: DashboardTypeEnum,
    currentQuarterCount: Number,
    drilldown: Object
  },
  data() {
    return {
      incentive_constants,
      milestoneDialog: false,
      currentUserId: null,
      selectedQuarter: 1,
      headers: [
        { text: '', value: '', show: true, sortable: false },
        { text: 'Name', value: 'customer_name', show: true },
        { text: 'Project ID', value: 'id', show: true },
        { text: 'Source', value: 'source_name', show: true },
        { text: 'System Size', value: 'system_size', show: true },
        { text: 'Final Design Complete Date', value: 'final_design_complete_date', show: true }
      ],
      currentQuarter: moment().quarter(),
      drilldownData: [],
      upperLabel: '',
      lowerLabel:''
    }
  },
  computed: {
    windowInnerWidth () { return window.innerWidth},
    milestoneDrilldownTitle () {
      return this.$store.state.user.details.firstName + ' ' + this.$store.state.user.details.lastName + this.drilldown.label + this.selectedQuarter
    },
    milestoneGoal () {
      return this.dashboardType.milestoneGoalMap[this.milestoneLevel]
    },
    milestoneLabel () {
      return this.incentive_constants.milestoneMap.get(this.milestoneLevel)
    },
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
        const {data} = await getRequestWithParams(this.drilldown.path, {params: {quarter}}, 'blueraven')
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

        this.selectedQuarter = quarter
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

  #drilldown-title {
    font-size: 18px;
  }

  #drilldown-table {
    th, td {
      font-size: 12px;
    }
  }
}

@media (min-width: 1070px) {

  .milestone {
    margin-bottom: 0;
  }

  #quarter-1.milestone,
  #quarter-2.milestone {
    margin-bottom: 0;
  }

  #milestone-medals-container {
    width: 45%;
    max-width: 650px;
  }

  #drilldown-title {
    font-size: 24px;
  }
}

@media (min-width: 1135px) {

  .milestone {

    .milestone-top-label,
    .milestone-bottom-label {
      width: 156px;
    }

    .milestone-content {
      width: 156px;
      height: 104px;
    }
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

