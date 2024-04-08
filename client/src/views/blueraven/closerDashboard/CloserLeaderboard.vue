<template>
  <v-container id="closer-dash-container" ref="closerDashContainer">
    <!---------------------------------- LEADERBOARD TAB START ---------------------------------->
    <!-- BOOKING TABLES FIRST HEADER START -->
    <div class="ranking-tables-section-header">
      Leaderboard
      <div class="expand-section">
        <a-btn
            variant="text"
            @click="showLeaderboard = !showLeaderboard"
            color="unset"
            :prepend-icon="!showLeaderboard ? 'mdi-chevron-down' : 'mdi-chevron-up'"
        ></a-btn>
      </div>
    </div>
    <!-- BOOKING TABLES FIRST HEADER END -->

    <!-- BOOKING TABLES TOP ROW START -->
    <div class="ranking-tables-section" v-if="showLeaderboard">
      <!-- BOOKINGS START -->
      <div class="ranking-table">
        <div v-if="bookingsLoading" class="section-spinner">
          <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
        </div>
        <div class="ranking-table-header user-office-ranking-table-header">
          <div class="user-office-ranking-table-header-left-side">
            <v-icon class="ranking-table-icon mr-2 default-text-color">mdi-calendar-badge</v-icon>
            <span>Closers with 2+ Bookings</span>
          </div>
          <div>
            <DatetimePickerInput
              v-model="bookingDate"
              :timezone="timezone"
              hide-details
              :change-callback="loadBookingData"
              :type="'date'"
              :format="'MM/DD/YYYY'"
              label="Date"
            />
          </div>
        </div>

        <div class="pa-5" v-if="bookingData.length === 0">
          No results found for the selected date.
        </div>
        <table v-else>
          <tr class="grey--text text--darken-2">
            <th class="center-text">Sales Consultant</th>
            <th class="left-text">Office</th>
            <th class="center-text">Metro</th>
            <th class="center-text">Bookings</th>
          </tr>

          <tr v-for="(row, index) in bookingData" :key="index"
              :class="{'highlight-user-row': row.userId === currentUserId}">
            <td class="center-text">{{ row.closerName }}</td>
            <td class="left-text">{{ row.officeName }}</td>
            <td class="center-text">{{ row.metroArea }}</td>
            <td class="center-text">{{ row.bookingCount || 0 }}</td>
          </tr>
        </table>
      </div>
      <!-- BOOKINGS END -->
    </div>
    <!-- BOOKING TABLES BOTTOM ROW END -->
    <!---------------------------------- LEADERBOARD TAB END ---------------------------------->
  </v-container>
</template>

<script setup>
  import constants from '@/helpers/constants'
  import { handleHidingGlobalLoader, getRequest, getRequestWithParams } from '@/helpers/helpers'
  import SpinnerInline from '@/components/SpinnerInline'
  import DatetimePickerInput from "@/components/DatetimePickerInput";
  import {getCurrentInstance, ref, computed, onMounted} from "vue";

  import { useAppStore } from '@/stores/AppStorePinia.js'
  import {useUserStore} from "@/stores/UserStorePinia.js";

  const userStore = useUserStore()
  const appStore = useAppStore()

  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store

  const currentUserId = computed(() => {
    return userStore.details.id
  })
  const timezone = computed(() => {
    return userStore.details?.timezone?.value
  })
        const currentUserOrgId = ref(null)
        const bookingDate = ref(null)
        const test1 = ref(null)
        const test2 = ref(null)
        const showLeaderboard = ref(true)
        const bookingsLoading = ref(false)
        const bookingData = ref([])

  onMounted(async () => {
    const now = new Date();
    //if it is monday, default to saturday
    let dayOffset = now.getDay() === 1 ? 2 : 1
    now.setDate(now.getDate() - dayOffset);
    bookingDate.value = new Intl.DateTimeFormat('en-CA', { year: 'numeric', month: '2-digit', day: '2-digit' }).format(now)
    await loadBookingData()
  })

      const loadBookingData = async () => {
        if(bookingDate.value != null) {
          bookingsLoading.value = true
          try {
            const {data, status} = await getRequestWithParams('/closerDashboard/leaderboardBookings', { params: {
                bookingDate: bookingDate.value
              }},'blueraven', [])
            bookingData.value = data

            bookingsLoading.value = false

            handleHidingGlobalLoader(vueInstance, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            snackbar('ERROR', `Error retrieving bookings.`)
            bookingsLoading.value = false
          }
        }
      }

</script>

<style lang="scss" scoped>
  .fix-bottom-page-issue {
    margin-bottom: 70px !important;
  }

  .expand-section {
    display: inline-block;
    position: absolute;
    right: 0;
  }

  #closer-dash-toolbar-container {
    #closer-dash-toolbar {
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
          }
        }

        .v-btn--active {
          background-color: var(--v-primary-base);
          color: #fff !important;
        }
      }
    }
  }

  .ranking-tables-section-header {
    position: relative;
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
    width: 100%;
  }

  .ranking-tables-no-data {
    font-family: "Roboto", sans-serif;
    font-size: 11px;
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
    font-weight: bold;
    font-size: 16px;
    text-align: left;
    padding: 10px 5px 5px 10px;
  }

  .user-office-ranking-table-header {
    justify-content: space-between;

    .table-header-dropdown {
      transform: scale(0.875);
      transform-origin: left;
      margin: 0 0 5px 5px;
      max-width: 120px;

      ::v-deep {
        .v-input__control {
          height: 25px;
        }

        label {
          color: #888 !important;
          font-size: 12px;
          font-weight: normal;
        }

        i {
          color: #888 !important;
          font-size: 20px;
        }

        .v-select__selections .v-select__selection {
          color: #888 !important;
          font-size: 12px;
          font-weight: normal;
        }
      }
    }
  }

  #top-reps-table {
    margin-bottom: 150px;

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
  }

  .ranking-table-icon {
    font-size: 16px;
  }

  .ranking-table table {
    border-collapse: collapse;
    width: 100%;
  }

  .ranking-table th {
    border-bottom: 1px solid #e6eeff;
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


  @media (min-width: 737px) {
    #closer-dash-toolbar-container {
      #closer-dash-toolbar {
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

    .ranking-tables-section-header {
      font-size: 26px;
      margin-bottom: 20px;
      padding-bottom: 5px;
      max-width: calc(100% - 50px);
    }

    .ranking-tables-no-data {
      font-size: 14px;
      padding: 10px 10px 15px 15px;
    }

    .ranking-table {
      margin-bottom: 30px;
      font-size: 14px;
      max-width: calc(100% - 50px);
    }

    .ranking-table-header {
      font-size: 22px;
      padding: 20px 15px 15px 15px;
    }

    .user-office-ranking-table-header {
      .table-header-dropdown {
        transform: none;
        margin: 0 0 10px 10px;
        max-width: 200px;

        ::v-deep {
          label {
            font-size: 14px;
          }

          .v-select__selections .v-select__selection {
            font-size: 14px;
          }
        }
      }
    }

    .ranking-table-icon {
      font-size: 22px;
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

    #top-reps-table {
      margin-bottom: 180px;

      #top-reps-table-header div {
        padding-right: 0;
        padding-bottom: 0;
      }

      #top-reps-table-header input {
        font-size: 14px;
        max-width: 250px;
        height: 30px;
      }
    }
  }

  @media (min-width: 1070px) {
    #closer-dash-toolbar-container {
      #closer-dash-toolbar {
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

    .ranking-tables-section-header {
      margin: 0 auto 20px auto;
      max-width: calc(100% - 50px)
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

    .ranking-table-header {
      font-size: 15px;
    }

    .user-office-ranking-table-header {
      .table-header-dropdown {
        max-width: 135px;
      }
    }

    .ranking-table-icon {
      font-size: 15px;
    }

    .ranking-table th {
      font-size: 12px;
      height: 55px;
    }

    .ranking-table td {
      font-size: 12px;
      height: 55px;
    }

    .ranking-tables-no-data {
      font-size: 12px;
    }
  }

  @media (min-width: 1135px) {
    .ranking-tables-section-header {
      max-width: 1130px;
    }

    .ranking-tables-section {
      max-width: 1130px;
      margin: 0 auto;
    }

    .ranking-table-header, .ranking-table-icon {
      font-size: 18px;
    }
  }
</style>
