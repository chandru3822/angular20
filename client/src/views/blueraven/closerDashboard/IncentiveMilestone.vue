<template>
  <div>
    <div id="aim-high-phase" class="milestone"
         :class="{
                        'align-items-center': windowInnerWidth < 1135,
                        'align-items-flex-start': windowInnerWidth >= 1135
                        }"
         @click="milestoneDrilldown(1)">
      <span class="milestone-top-label">{{ incentive_constants.firstMilestone }}</span>
      <div class="milestone-content mt-1">
        <div class="milestone-content-left-side"
             :class="this.getMilestoneMedal(this.q1_points)"></div>
        <div class="milestone-content-right-side">
          <span class="milestone-top-right-label bronze">{{ fdcCounts.q1 }} FDC</span>
          <div class="milestone-stars-container"
               :class="{'four-stars-padding-override': q1_points === 4, 'five-stars-padding-override': q1_points > 4}">
            <v-icon v-if="q1_points > 0" class="milestone-star">star</v-icon>
            <v-icon v-if="q1_points > 1" class="milestone-star">star</v-icon>
            <v-icon v-if="q1_points > 2" class="milestone-star"
                    :class="{'three-stars-padding-override': q1_points === 3}">star</v-icon>
            <v-icon v-if="q1_points > 3" class="milestone-star">star</v-icon>
            <v-icon v-if="q1_points > 4" class="milestone-star">star</v-icon>
          </div>
        </div>
      </div>
      <span class="milestone-bottom-label">{{ q1_lower_label }}</span>
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
import incentive_constants from "@/views/blueraven/closerDashboard/incentive_constants";
import moment from "moment";
import {AppMutations} from "@/stores/AppStore";
import {getRequest, getRequestWithParams, getSnackbar} from "@/helpers/helpers";
import cloneDeep from "lodash.clonedeep";
export default {
  name: "IncentiveMilestone",
  props: {

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
      drilldownData: [],
      incentiveDataLoaded: false,
      currentQuarter: moment().quarter(),
      fdcCounts: {
        q1: 0, q1QualificationMet: false,
        q2: 0, q2QualificationMet: false,
        q3: 0, q3QualificationMet: false,
        q4: 0, q4QualificationMet: false
      },
      q1_points: 0,
      q2_points: 0,
      q3_points: 0,
      q4_points: 0,
      q1_medal_icon: '',
      q2_medal_icon: '',
      q3_medal_icon: '',
      q4_medal_icon: '',
      q1_lower_label: '',
      q2_lower_label: '',
      q3_lower_label: '',
      q4_lower_label: ''
    }
  },
  computed: {
    windowInnerWidth () { return window.innerWidth},
    is_q1 () { return this.currentQuarter === 1 },
    is_q2 () { return this.currentQuarter === 2 },
    is_q3 () { return this.currentQuarter === 3 },
    is_q4 () { return this.currentQuarter === 4 },
    milestoneDrilldownTitle () {
      return this.$store.state.user.details.firstName + ' ' + this.$store.state.user.details.lastName + ' | Final Designs Completed - Q' + this.selectedQuarter
    },
  },
  methods: {
    resetScrollBarPosition () {
      // reset scroll bar position to top
      //document.getElementsByClassName('v-data-table__wrapper').forEach(table => table.scrollTop = 0)
    },

    /* INCENTIVE-RELATED CODE START */
    async loadIncentive () {
      this.incentiveDataLoaded = false

      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        getRequest('/closerDashboard/getIncentiveFdcCounts', 'blueraven').then(res => {
          this.fdcCounts = res.data

          // Calculate points for each quarter
          this.q1_points = this.calcPointsForQuarter(this.fdcCounts.q1, this.fdcCounts.q1QualificationMet)
          this.q2_points = this.calcPointsForQuarter(this.fdcCounts.q2, this.fdcCounts.q2QualificationMet)
          this.q3_points = this.calcPointsForQuarter(this.fdcCounts.q3, this.fdcCounts.q3QualificationMet)
          this.q4_points = this.calcPointsForQuarter(this.fdcCounts.q4, this.fdcCounts.q4QualificationMet)

          // Get lower milestone labels
          this.q1_lower_label = this.getLowerMilestoneLabel(this.fdcCounts.q1)
          this.q2_lower_label = this.getLowerMilestoneLabel(this.fdcCounts.q2)
          this.q3_lower_label = this.getLowerMilestoneLabel(this.fdcCounts.q3)
          this.q4_lower_label = this.getLowerMilestoneLabel(this.fdcCounts.q4)

          // Fill progress bar based on closer's points for the year
          this.percentAchieved = ((this.q1_points + this.q2_points + this.q3_points + this.q4_points) / this.incentive_constants.totalPointsPossible) * 100
          this.percentAchieved = this.percentAchieved > 100 ? 100 : this.percentAchieved
          this.progressBarIsFull = this.percentAchieved === 100

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

    getMilestoneMedal (pointsEarned) {
      switch (pointsEarned) {
        case 1:
          return 'a-10-level'
        case 2:
          return 'f-14-level'
        case 3:
          return 'fa-18-level'
        case 4:
          return 'f-22-level'
        case 5:
          return 'f-35-level'
        default:
          return 'no-medal'
      }
    },

    getLowerMilestoneLabel (fdcCount) {
      switch (true) {
        case fdcCount >= 10 && fdcCount < 12:
          return (12 - fdcCount) + ` FDC to ${incentive_constants.secondMilestone}`
        case fdcCount >= 12 && fdcCount < 15:
          return (15 - fdcCount) + ` FDC to ${incentive_constants.thirdMilestone}`
        case fdcCount >= 15 && fdcCount < 18:
          return (18 - fdcCount) + ` FDC to ${incentive_constants.fourthMilestone}`
        case fdcCount >= 18 && fdcCount < 24:
          return (24 - fdcCount) + ' FDC to get to Lightning'
        case fdcCount >= 24:
          return 'Lightning Achieved'
        default:
          return (10 - fdcCount) + ` FDC to ${incentive_constants.firstMilestone}`
      }
    },

    async milestoneDrilldown (quarter) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequestWithParams('/closerDashboard/finalDesignsCompletedDrilldown', {params: {quarter}}, 'blueraven')
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
    /* INCENTIVE-RELATED CODE END */
  },
  async created () {
    this.currentUserId = this.$store.state.user.details.id

    await this.loadIncentive()
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
    border: 4px solid #B99A86;
    background-color: #191919;
    display: flex;
    flex-flow: row nowrap;
    padding: calc(1em - 4px);
    width: 220px;
    height: 110px;

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
        font-size: 10px;
      }

      //.milestone-stars-container {
      //  display: flex;
      //  flex-flow: row wrap;
      //  justify-content: center;
      //  align-items: center;
      //  align-content: center;
      //  width: 100%;
      //  height: 70%;
      //
      //  .milestone-star {
      //    font-size: 22px;
      //    color: rgba(255, 255, 255, 0.3) !important;
      //    text-shadow: 0 0 0 rgba(255, 255, 255, 0.5);
      //    background: #222 -webkit-gradient(linear, left top, right top, from(#222), to(#222), color-stop(0.5, #fff)) 0 0 no-repeat;
      //    background-size: 25px;
      //    -webkit-background-clip: text;
      //    animation-name: shine;
      //    animation-duration: 5s;
      //    animation-iteration-count: infinite;
      //  }
      //
      //  @keyframes shine {
      //    0% {
      //      background-position-x: -50px;
      //    }
      //    100% {
      //      background-position-x: 50px;
      //    }
      //  }
      //
      //  .three-stars-padding-override {
      //    padding: 0 20px;
      //  }
      //}

      .four-stars-padding-override {
        padding: 0 20px;
      }

      .five-stars-padding-override {
        padding: 0 10px;
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

.no-medal {
  background: url('../../../assets/blueraven/trophy-small-bronze.svg') no-repeat scroll center;
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

  #closer-dash-tabs .col-12 span {
    font-size: 13px;
  }

  .milestone {
    margin-bottom: 0;
  }

  #aim-high-phase,
  #fly-phase {
    margin-bottom: 20px;
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

.bronze {
  color: #B99A86;
  font-color: #B99A86;
}
</style>

