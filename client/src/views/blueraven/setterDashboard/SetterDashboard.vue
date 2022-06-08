<template>
  <v-container id="setter-dash-container" ref="setterDashContainer">
    <v-row id="setter-dash-toolbar-container">
      <v-col cols="12" id="setter-dash-toolbar" class="pt-0 pb-2">
        <v-app-bar id="date-range-btns-toolbar" class="elevation-1">
          <v-toolbar-items>
            <v-btn-toggle v-model="timeIntervalBtnGroup" mandatory>
              <v-btn text @click="setTimeInterval('Today')">Today</v-btn>
              <v-btn text @click="setTimeInterval('Yesterday')">Yesterday</v-btn>
              <v-btn text @click="setTimeInterval('WTD')">Week</v-btn>
              <v-btn text @click="setTimeInterval('MTD')">Month</v-btn>
              <v-btn text @click="setTimeInterval('QTD')">Quarter</v-btn>
              <v-btn text @click="setTimeInterval('YTD')">YTD</v-btn>
            </v-btn-toggle>
          </v-toolbar-items>
        </v-app-bar>
      </v-col>
    </v-row>
    <!---------------------------------- DASHBOARD TAB START ---------------------------------->
    <!-- PERSONAL PERFORMANCE SECTION START -->
    <div class="ranking-tables-section-header">
      Personal Performance
    </div>
    <div id="personal-performance-boxes-container" class="mb-6">
      <div v-if="performanceDataLoading" class="section-spinner">
        <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
      </div>
      <div class="personal-performance-box">
        <span class="personal-performance-box-title">Total Appointments</span>
        <span class="personal-performance-box-number">
          {{ rankingData.total_appointments ? rankingData.total_appointments : 0 }}
        </span>
        <span class="personal-performance-box-subtitle">
          {{ getTimeIntervalText() }} (not cancelled)
        </span>
      </div>
      <div class="personal-performance-box">
        <span class="personal-performance-box-title">Total Pitches</span>
        <span class="personal-performance-box-number">
          {{ rankingData.total_pitches ? rankingData.total_pitches : 0 }}
        </span>
        <span class="personal-performance-box-subtitle">
          {{ getTimeIntervalText() }}
        </span>
      </div>
      <div class="personal-performance-box">
        <span class="personal-performance-box-title">Pitch %</span>
        <span class="personal-performance-box-number">
          {{ rankingData.pitch_percentage ? rankingData.pitch_percentage : 0 }}%
        </span>
        <span class="personal-performance-box-subtitle">
          {{ getTimeIntervalText() }}
        </span>
      </div>
      <div id="personal-performance-rank-box">
        <div id="rank-box-left-side">
          <span class="personal-performance-box-title">Company Rank</span>
          <span v-if="isSetterMgr" class="personal-performance-box-number">
            {{ rankBoxData.current_office_rank ? rankBoxData.current_office_rank : 'TBD' }}
          </span>
          <span v-if="!isSetterMgr" class="personal-performance-box-number">
            {{ rankBoxData.current_user_rank ? rankBoxData.current_user_rank : 'TBD' }}
          </span>
          <span class="personal-performance-box-subtitle">
            {{ getTimeIntervalText() }}
          </span>
        </div>
        <div id="rank-box-separator"></div>
        <div id="rank-box-right-side">
          <span class="personal-performance-box-title">
            {{ isSetterMgr ? 'Office' : 'Rep' }} to Beat
          </span>
          <div id="rank-box-content" :style="{'justify-content': rankBoxData.current_office_rank === '1' || rankBoxData.current_user_rank === '1' ? 'space-around' : 'space-between'}">
            <span v-if="isSetterMgr" id="office-to-beat-name"
                  :style="{'font-size': (rankBoxData.setter_office_to_beat_name && rankBoxData.current_office_rank !== '1') ? '10px' : '14px'}">
              {{ rankBoxData.setter_office_to_beat_name ? rankBoxData.setter_office_to_beat_name : 'TBD' }}
            </span>
            <v-icon v-if="isSetterMgr" class="office-to-beat-icon">mdi-office-building</v-icon>

            <span v-if="!isSetterMgr" id="rep-to-beat-name"
                  :style="{'font-size': (rankBoxData.setter_to_beat_name && rankBoxData.current_user_rank !== '1') ? '10px' : '14px'}">
              {{ rankBoxData.setter_to_beat_name ? rankBoxData.setter_to_beat_name : 'TBD' }}
            </span>
            <img v-if="!isSetterMgr && rankBoxData.imageUrl" class="rep-to-beat-img"
                 :style="{'width': rankBoxData.current_user_rank !== '1' ? '' : '50px', 'height': rankBoxData.current_user_rank !== '1' ? '' : '50px'}"
                 :alt="rankBoxData.imageAltText" :src="rankBoxData.imageUrl">
            <v-icon v-if="!isSetterMgr && !rankBoxData.imageUrl" class="rep-to-beat-icon">mdi-account</v-icon>

            <span v-if="rankBoxData.current_office_rank !== '1' && rankBoxData.current_user_rank !== '1'"
                  id="rank-box-subtitle">
              {{ rankBoxData.pitches_to_go ? rankBoxData.pitches_to_go : 0 }} {{ rankBoxData.pitches_to_go === 1 ? 'Pitch' : 'Pitches' }} to beat {{ isSetterMgr ? 'office' : 'rep' }}
            </span>
          </div>
        </div>
      </div>
    </div>
    <!-- PERSONAL PERFORMANCE SECTION END -->

    <!-- RANKING TABLES HEADER START -->
    <div class="ranking-tables-section-header">
      Company Performance
    </div>
    <!-- RANKING TABLES HEADER END -->

    <!-- RANKING TABLES SECTION START -->
    <div id="setter-ranking-tables-section">
      <!-- RANKING TABLES LEFT COLUMN START -->
      <div id="setter-ranking-tables-left-col">
        <!-- TOP OFFICES -->
        <div id="setter-ranking-top-offices-table" class="ranking-table">
          <div v-if="topOfficesLoading" class="section-spinner">
            <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
          </div>
          <div class="ranking-table-header">
            <v-icon class="ranking-table-icon mr-2">mdi-flag-variant</v-icon>
            <span>Top Offices</span>
          </div>
          <table v-if="offices.length > 0">
            <tr>
              <th class="center-text">Rank</th>
              <th class="left-text">Office</th>
              <th class="center-text">
                Total Pitched Appointments<br/>
                {{ getTimeIntervalText() }}
              </th>
            </tr>
            <tr v-for="office in offices"
                :key="office.org_id"
                :class="{'highlight-user-row': office.org_id === userOfficeId}">
              <td class="center-text">{{ office.rank }}</td>
              <td class="left-text">{{ office.name }}</td>
              <td class="center-text">{{ office.pitches }}</td>
            </tr>
          </table>
          <div v-if="offices.length === 0" class="ranking-tables-no-data">
            Data is not yet available for the selected time period. Try selecting another time period, or check back again at a later date.
          </div>
        </div>

        <!-- TOP REPS -->
        <div class="ranking-table">
          <div v-if="topRepsLoading" class="section-spinner">
            <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
          </div>
          <div class="ranking-table-header">
            <v-icon class="mr-2 ranking-table-icon">mdi-account-multiple</v-icon>
            <span>Top Reps</span>
          </div>
          <table v-if="reps.length > 0">
            <tr>
              <th class="center-text">Rank</th>
              <th></th>
              <th class="left-text">Rep</th>
              <th class="center-text">
                Total Pitched Appointments<br/>
                {{ getTimeIntervalText() }}
              </th>
            </tr>
            <tr v-for="rep in reps" :key="rep.user_id"
                :class="{'highlight-user-row': rep.user_id === currentUserId}">
              <td class="center-text">{{ rep.rank }}</td>
              <td class="user-img-col">
                <img v-if="rep.userImageUrl" class="ranking-table-img"
                     :src="rep.userImageUrl" :alt="rep.userImageAltText">
                <img v-else class="placeholder-img"
                     src="../../../assets/flow/user_img_placeholder.png" :alt="rep.userImageAltText">
              </td>
              <td class="left-text">{{ rep.name }}</td>
              <td class="center-text">{{ rep.pitches }}</td>
            </tr>
          </table>
          <div v-if="reps.length === 0" class="ranking-tables-no-data">
            Data is not yet available for the selected time period. Try selecting another time period, or check back again at a later date.
          </div>
        </div>
      </div>
      <!-- RANKING TABLES LEFT COLUMN END -->

      <!-- RANKING TABLES RIGHT COLUMN START -->
      <div id="setter-ranking-tables-right-col">
        <!-- OFFICE RANKING -->
        <div class="ranking-table">
          <div v-if="officeRankingLoading" class="section-spinner">
            <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
          </div>
          <div class="ranking-table-header">
            <v-icon class="mr-2 ranking-table-icon">mdi-office-building</v-icon>
            <span>Office Ranking</span>
          </div>
          <table v-if="officeRankingData.length > 0">
            <tr>
              <th class="center-text">Rank</th>
              <th class="left-text">Office</th>
              <th class="center-text">
                Total Appointments<br/>
                {{ getTimeIntervalText() }}
              </th>
              <th class="center-text">Pitches</th>
              <th class="center-text">Pitch %</th>
            </tr>
            <tr v-for="office in officeRankingData" :key="office.org_id"
                :class="{'highlight-user-row': office.org_id === userOfficeId}">
              <td class="center-text">{{ office.rank }}</td>
              <td class="left-text">{{ office.org }}</td>
              <td class="center-text">{{ office.total_appointments }}</td>
              <td class="center-text">{{ office.total_pitches }}</td>
              <td class="center-text">{{ office.pitch_percentage }}%</td>
            </tr>
          </table>
          <div v-if="officeRankingData.length === 0"
               class="ranking-tables-no-data">
            Data is not yet available for the selected time period. Try selecting another time period, or check back again at a later date.
          </div>
        </div>
      </div>
      <!-- RANKING TABLES RIGHT COLUMN END -->
    </div>
    <!-- RANKING TABLES SECTION END -->
    <!---------------------------------- DASHBOARD TAB END ---------------------------------->
  </v-container>
</template>

<script>
  import moment from 'moment'
  import constants from '@/helpers/constants'
  import { handleHidingGlobalLoader, getRequestWithParams, getSnackbar } from '@/helpers/helpers'
  import { AppMutations } from '@/stores/AppStore'
  import SpinnerInline from '@/components/SpinnerInline'

  export default {
    name: 'setterDashboard',
    components: {
      SpinnerInline,
    },
    data: () => ({
      snackbar: {},
      constants,
      currentUserId: null,
      isSetter: false,
      isSetterMgr: false,
      isSetterRegional: false,
      officeRankingLoading: false,
      performanceDataLoading: false,
      topRepsLoading: false,
      topOfficesLoading: false,
      timeIntervalBtnGroup: 3,
      timeIntervalString: 'MTD', // MTD is selected by default
      timeInterval: moment().format('DD') - 1,
      tabNum: 1, // Funnel tab is selected by default
      performanceDataLoaded: false,
      rankingTablesLoaded: false,
      rankingData: {},
      rankBoxData: {},
      offices: [],
      reps: [],
      officeRankingData: [],
      userOffice: '',
      userOfficeId: null,
      userRow: [],
      userRowIndex: -1,
      numOffices: 0
    }),
    computed: {
      windowInnerWidth () { return window.innerWidth},
    },
    watch: {},
    methods: {
      resetScrollBarPosition () {
        // reset scroll bar positioning to top
        this.$refs.setterDashContainer.scrollTop = 0
      },

      /* PERSONAL PERFORMANCE-RELATED CODE START */
      async loadPersonalPerformance () {
        this.performanceDataLoading = true

        try {
          let startDate = moment().subtract(this.timeInterval, 'd').format('YYYY-MM-DD')
          //dont include today if the selected option is yesterday
          let endDate = this.timeInterval === 1 ? startDate : moment().format('YYYY-MM-DD')

          if (this.isSetterMgr) {
            let performanceData = await getRequestWithParams('/setterDashboard/getMgrPerformanceReport',
              {
                params: {
                  officeId: this.userOfficeId,
                  startDate,
                  endDate
                }
              }, 'blueraven')
            this.rankingData = performanceData.data

            let officeToBeatData = await getRequestWithParams('/setterDashboard/officeToBeat',
            {
              params: {
                officeId: this.userOfficeId,
                startDate,
                endDate
              }
            }, 'blueraven')
            this.rankBoxData = officeToBeatData.data

            if (this.rankBoxData.setter_office_to_beat_name && this.rankBoxData.current_office_rank) {
              if (this.rankBoxData.current_office_rank === "1") {
                this.rankBoxData.setter_office_to_beat_name = 'Your office is #1!'
              } else if (this.rankBoxData.current_office_rank === 'T1') {
                let tiedOffices = this.offices.filter(office => office.rank === 'T1' && office.org_id !== this.userOfficeId)

                if (tiedOffices.length > 0) {
                  let officeToBeat

                  if (tiedOffices.length === 1) {
                    officeToBeat = tiedOffices[0]
                  } else {
                    // randomly selects an office that's tied for 1st with current manager's office
                    officeToBeat = tiedOffices[Math.floor(Math.random() * tiedOffices.length)]
                  }

                  if (officeToBeat.name.includes(' ()')) {
                    officeToBeat.name = officeToBeat.name.substr(0, officeToBeat.name.length - 3)
                  }

                  this.rankBoxData.setter_office_to_beat_name = officeToBeat.name
                  this.rankBoxData.pitches_to_go = 1
                }
              } else {
                if (this.rankBoxData.setter_office_to_beat_name.includes(' ()')) {
                  this.rankBoxData.setter_office_to_beat_name = this.rankBoxData.setter_office_to_beat_name.substr(0, this.rankBoxData.setter_office_to_beat_name.length - 3)
                }
              }
            }

            this.performanceDataLoading = false
          } else {
            let performanceData = await getRequestWithParams('/setterDashboard/getPerformanceReport', {params: {startDate, endDate}}, 'blueraven')
            this.rankingData = performanceData.data

            let repToBeatData = await getRequestWithParams('/setterDashboard/repToBeat',
              {
                params: {
                  userId: this.currentUserId,
                  startDate,
                  endDate
                }
              }, 'blueraven')
            this.rankBoxData = repToBeatData.data

            if (this.rankBoxData) {
              if (this.rankBoxData.setter_to_beat_id) {
                await this.getRepToBeatImage(this.rankBoxData.setter_to_beat_id)
              } else if (!this.rankBoxData.setter_to_beat_name && this.rankBoxData.current_user_rank) {
                if (this.rankBoxData.current_user_rank === "1") {
                  this.rankBoxData.setter_to_beat_name = 'You’re #1!'
                  await this.getRepToBeatImage(this.currentUserId) // gets current user's picture
                } else if (this.rankBoxData.current_user_rank === 'T1' && this.reps.length > 0) {
                  let tiedReps = this.reps.filter(rep => rep.rank === 'T1' && rep.user_id !== this.currentUserId)

                  if (tiedReps.length > 0) {
                    let repToBeat

                    if (tiedReps.length === 1) {
                      repToBeat = tiedReps[0]
                    } else {
                      // randomly selects one of the reps who is tied for 1st with the current rep
                      repToBeat = tiedReps[Math.floor(Math.random() * tiedReps.length)]
                    }

                    await this.getRepToBeatImage(repToBeat.user_id)
                    this.rankBoxData.setter_to_beat_name = repToBeat.name
                    this.rankBoxData.pitches_to_go = 1
                  } else {
                    this.rankBoxData.imageUrl = null
                    this.rankBoxData.imageAltText = 'User photo placeholder'
                  }
                }
              }
            }

            this.performanceDataLoading = false
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving personal performance data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },

      async getRepToBeatImage (repToBeatId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const params = {sourceId: repToBeatId, attachmentTypeId: 9}
          const {data, status} = await getRequestWithParams('/attachment/getOne', {params})

          if (data?.presignedUrl) {
            this.rankBoxData.imageUrl = data.presignedUrl

            if (this.rankBoxData.setter_to_beat_name) {
              this.rankBoxData.imageAltText = 'Photo of ' + this.rankBoxData.setter_to_beat_name + ', a Blue Raven Solar employee'
            } else {
              this.rankBoxData.imageAltText = 'User photo placeholder'
            }

            handleHidingGlobalLoader(this, status)
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving rep to beat image')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      /* PERSONAL PERFORMANCE-RELATED CODE END */

      /* RANKING TABLES-RELATED CODE START */
      async getTopReps () {
        try {
          this.topRepsLoading = true
          const params = {limit: 5, days: this.timeInterval, interval: this.timeIntervalString}
          const {data} = await getRequestWithParams('/setterDashboard/topReps', {params}, 'blueraven')
          this.reps = data

          if (this.reps.length > 0) {
            let userIds = []

            this.reps.forEach(rep => {
              if (rep.user_id) {
                userIds.push(rep.user_id)
              }
            })

            if (userIds.length > 0) {
              userIds = encodeURI(userIds)

              let params = {
                sourceIds: userIds,
                attachmentTypeId: 9
              }

              const {data} = await getRequestWithParams('/attachment/getAttachmentPresignedUrlsForUserList', {params})

              if (data) {
                this.reps.forEach(rep => {
                  if (rep.user_id && data[rep.user_id]) {
                    rep.userImageUrl = data[rep.user_id]
                  }

                  if (rep.userImageUrl && rep.name) {
                    rep.userImageAltText = 'Photo of ' + rep.name + ', a Blue Raven Solar employee'
                  } else {
                    rep.userImageAltText = 'User photo placeholder'
                  }
                })
              }
            }
          }

          this.topRepsLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving top reps data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },

      async getTopOffices () {
        try {
          this.topOfficesLoading = true
          const {data} = await getRequestWithParams('/setterDashboard/topOffices',
            {
              params: {
                limit: 5,
                days: this.timeInterval,
                interval: this.timeIntervalString
              }
            }, 'blueraven', [])
          this.offices = data || []

          // removes empty parentheses from missing metro areas
          this.offices?.forEach(office => {
            if (office.name.includes(' ()')) {
              office.name = office.name.substr(0, office.name.length - 3)
            }
          })
          this.topOfficesLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving top offices data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },

      async getOfficeRanking () {
        try {
          this.officeRankingLoading = true
          const {data} = await getRequestWithParams('/setterDashboard/officeRanking',
            {
              params: {
                limit: 13,
                days: this.timeInterval,
                interval: this.timeIntervalString
              }
            }, 'blueraven', [])
          this.officeRankingData = data || []

          this.officeRankingData?.forEach(office => {
            if (office.org.includes(' ()')) {
              office.org = office.org.substr(0, office.org.length - 3)
            }
          })
          this.officeRankingLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving office ranking data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      getTimeIntervalText() {
        return this.timeInterval === 0 ? 'Today' : this.timeInterval === 1 ? 'Since yesterday' : 'Last ' + this.timeInterval + ' days'
      },
      setTimeInterval (timeIntervalString) {
        try {
          this.rankingTablesLoaded = false
          this.timeIntervalString = timeIntervalString
          this.rankingData = {}

          // let test = moment
          // debugger

          switch (timeIntervalString) {
            case 'Today':
              this.timeInterval = 0 // TODAY
              break
            case 'Yesterday':
              this.timeInterval = 1 // YESTERDAY
              break
            case 'WTD':
              //gets # day of week. -1 because BR week starts on monday
              this.timeInterval = moment().day() - 1 // WTD
              break
            case 'MTD':
              //gets current # day of month (-1 so that we dont go down to 0)
              this.timeInterval = moment().format('DD') - 1 // MTD
              break
            case 'QTD':
              this.timeInterval =  moment().diff(moment().startOf('quarter'), 'days')// QTD
              break
            case 'YTD':
              //gets current # day of year (-1 so that we dont go down to 0)
              this.timeInterval = moment().dayOfYear() - 1 // YTD
              break
          }

          //i dont think there is any reason to wait for the previous requests to finish
          this.loadPersonalPerformance()
          this.getTopReps()
          this.getTopOffices()
          this.getOfficeRanking()
          this.rankingTablesLoaded = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving ranking table data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.rankingTablesLoaded = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      /* RANKING TABLES-RELATED CODE END */
    },
    async created () {
      this.currentUserId = this.$store.state.user.details.id
      let userPositions = this.$store.state.user.details.userPositions

      if (userPositions?.length > 0) {
        this.userOfficeId = userPositions.filter(position => position.primaryFlag && !position.endDate)[0].orgId
        this.userOffice = userPositions.filter(position => position.orgId === this.userOfficeId)[0].hierarchy.filter(orgLevel => orgLevel.orgId === this.userOfficeId)[0].orgName
        this.isSetter = userPositions.filter(position => (position.positionId === 4) && !position.endDate && !position.archived && position.primaryFlag).length > 0
        this.isSetterMgr = userPositions.filter(position => (position.positionId === 5) && !position.endDate && !position.archived && position.primaryFlag).length > 0
        this.isSetterRegional = userPositions.filter(position => (position.positionId === 6) && !position.endDate && !position.archived && position.primaryFlag).length > 0
      }

      this.setTimeInterval('MTD') // MTD is the default
    },
    mounted () {},
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

  #setter-dash-toolbar-container {
    #setter-dash-toolbar {
      header {
        background-color: #fff !important;
      }

      #setter-dash-title-container ::v-deep .v-toolbar__content {
        width: 100%;

        .v-toolbar__title {
          font-size: 13px;
        }
      }

      #date-range-btns-toolbar {
        position: fixed;
        bottom: 0;
        z-index: 3;
        height: 45px !important;

        ::v-deep .v-toolbar__content {
          display: flex;
          justify-content: flex-end;
          padding: 5px 12px;
          width: 100%;
          height: 45px !important;

          .v-toolbar__items {
            display: flex;
            flex-flow: row nowrap;
            justify-content: flex-end;
            align-items: center;
            padding-right: 0;
          }
        }

        .v-btn-toggle .v-btn {
          border: 1px solid var(--v-primary-base) !important;
          font-size: 11px;
          letter-spacing: 0.02em !important;
          height: 25px;

          &:not(:last-child) {
            border-right: none !important;
          }

          &:hover {
            background-color: var(--v-primary-base);
            color: #fff !important;
            opacity: .75;
          }
        }

        .v-btn--active {
          background-color: var(--v-primary-base);
          color: #fff !important;
        }
      }
    }
  }

  #setter-dash-tabs {
    width: 100%;

    .col-12 {
      display: flex;
      flex-flow: row nowrap;
      justify-content: flex-end;

      span {
        letter-spacing: 0.02em;
        font-size: 11px;
      }

      .tab-separator {
        border-right: 1px solid var(--v-primary-base);
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
      color: var(--v-primary-base);
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
      color: var(--v-primary-base);
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
    color: var(--v-primary-base);
    text-align: left;
    font-family: "Roboto", sans-serif;
    font-weight: bold;
    font-size: 20px;
    border-bottom: 2px solid var(--v-primary-base);
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
    position: relative;
  }

  .section-spinner {
    position: absolute;
    height: 100% !important;
    width: 100%;
    text-align: center;
    opacity: .6;
    background: white;
    display: flex;
    align-items: center;
    z-index: 1000;
  }

  .ranking-table-header {
    display: flex;
    flex-flow: row nowrap;
    color: var(--v-primary-base);
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
    color: var(--v-primary-base);
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
    background-color: var(--v-primary-base);
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
      border-bottom: 1px solid var(--v-primary-base);
      width: 100%;

      #pipeline-header-top {
        display: flex;
        flex-flow: row nowrap;
        text-align: left;
        border-bottom: 1px solid var(--v-primary-base);
        padding: 5px;

        .pipeline-icon {
          color: var(--v-primaryText-base) !important;
          font-size: 24px;
        }

        .pipeline-title {
          font-size: 18px;
          font-weight: bold;
          color: var(--v-primary-base);
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
          background-color: var(--v-primary-lighten9);
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
          color: var(--v-primary-base);
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
        border-bottom: 2px solid var(--v-primary-base);

        #pipeline-header-top {
          border-bottom: 2px solid var(--v-primary-base);
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
