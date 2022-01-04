<template>
  <v-row style="max-width: 100%;">
    <v-col cols="12">
      <v-row id="targets-toolbar-container">
        <v-col cols="12" id="targets-toolbar">
          <v-app-bar class="elevation-1" fixed style="top: 48px">
            <v-toolbar-title>Company Dashboard Targets</v-toolbar-title>
            <div id="toolbar-right-side">
              <v-btn id="update-btn" color="primaryCustom" class="white--text text-capitalize"
                     @click="updateTargets">Update</v-btn>
            </div>
          </v-app-bar>
        </v-col>
      </v-row>

      <v-row>
        <v-col cols="12" id="targets-table-container">
          <v-data-table id="targets-table"
                        class="elevation-1"
                        :headers="headers"
                        :items="targets"
                        :loading="isLoading"
                        loading-text="Loading data..."
                        fixed-header
                        disable-sort
                        :footer-props="footerProps"
                        :items-per-page="5"
                        mobile-breakpoint=""
                        dense>
            <template #item="{ item }">
              <tr>
                <td class="fixed-col-1">{{ item.targetDate | formatDate('date', 'MM/DD/YYYY') }}</td>
                <td class="fixed-col-2">
                  <div class="row-labels-container">
                    <span class="row-label">BRS</span>
                    <span class="row-label">Partner</span>
                  </div>
                </td>
                <td>
                  <v-text-field dense type="number" min="0" pattern="[0-9]*" v-model="item.bookingsBrs" hide-details></v-text-field>
                  <v-text-field dense type="number" min="0" pattern="[0-9]*" v-model="item.bookingsPartner" hide-details></v-text-field>
                </td>
                <td>
                  <v-text-field dense type="number" min="0" pattern="[0-9]*" v-model="item.finalDesignsCompletedBrs" hide-details></v-text-field>
                  <v-text-field dense type="number" min="0" pattern="[0-9]*" v-model="item.finalDesignsCompletedPartner" hide-details></v-text-field>
                </td>
                <td>
                  <v-text-field dense type="number" min="0" pattern="[0-9]*" v-model="item.substantialCompletionsBrs" hide-details></v-text-field>
                  <v-text-field dense type="number" min="0" pattern="[0-9]*" v-model="item.substantialCompletionsPartner" hide-details></v-text-field>
                </td>
                <td>
                  <v-text-field dense type="number" min="0" pattern="[0-9]*" v-model="item.finalCompletionsBrs" hide-details></v-text-field>
                  <v-text-field dense type="number" min="0" pattern="[0-9]*" v-model="item.finalCompletionsPartner" hide-details></v-text-field>
                </td>
              </tr>
            </template>
          </v-data-table>
        </v-col>
      </v-row>
    </v-col>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-row>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import constants from '@/helpers/constants'
  import Snackbar from '@/components/Snackbar.vue'
  import { AppMutations } from '@/stores/AppStore'
  import { handleHidingGlobalLoader, getRequest, postRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: 'companyDashboardTargets',
    components: {
      Snackbar
    },
    data: () => ({
      snackbar: {},
      constants,
      headers: [
        { text: 'Week of', value: 'targetDate', width: 90, align: 'center', class: 'fixed-col-1' },
        { text: null, width: 50, class: 'fixed-col-2' },
        { text: 'Bookings', width: constants.IS_MOBILE ? 80 : 150, align: 'center' },
        { text: 'Final Designs Completed', width: constants.IS_MOBILE ? 80 : 150, align: 'center' },
        { text: 'Substantial Completions', width: constants.IS_MOBILE ? 80 : 150, align: 'center' },
        { text: 'Final Completions', width: constants.IS_MOBILE ? 80 : 150, align: 'center' }
      ],
      isLoading: true,
      targets: [],
      footerProps: {
        showFirstLastPage: !constants.IS_MOBILE,
        firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',
        lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
        'items-per-page-options': [5, 10, 25, 50, 100]
      }
    }),
    computed: {},
    watch: {},
    methods: {
      async getTargets () {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {data, status} = await getRequest('/companyDashboard/targets', 'blueraven')
          this.targets = cloneDeep(data)
          this.isLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving targets')
          this.isLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      async updateTargets () {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {status} = await postRequest('/companyDashboard/updateTargets', this.targets, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Targets have been updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.isLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error saving company targets')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.isLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async created () {
      await this.getTargets()
    }
  }
</script>

<style lang="scss" scoped>
  #targets-toolbar-container {
    #targets-toolbar {
      z-index: 1;
      display: flex;
      flex-flow: row nowrap;
      justify-content: space-between;

      ::v-deep {
        .v-toolbar__title {
          font-size: 10px;
          min-width: 40%;
        }

        #toolbar-right-side {
          display: flex;
          justify-content: flex-end;
          width: 100%;

          #update-btn {
            font-size: 8px;
          }
        }
      }
    }
  }

  .v-select ::v-deep .v-select__selection {
    color: var(--v-primaryText-base) !important;
  }

  .v-data-table {
    overflow-y: hidden !important;
  }

  .v-data-table ::v-deep .v-data-table__wrapper {
    max-height: calc(100vh - 200px);
  }

  #targets-table-container {
    #targets-table {
      border-top-left-radius: 0;
      border-top-right-radius: 0;
      overflow: auto;
      margin: 12px auto 0 auto !important;
      width: 100%;

      ::v-deep {
        tr:hover {
          background-color: transparent;
        }

        th, td, span {
          text-align: center;
          font-size: 10px;
        }

        th {
          padding: 5px;
        }

        .fixed-col-1,
        .fixed-col-2 {
          background-color: white;
          position: sticky;
          z-index: 3;
        }

        .fixed-col-1 {
          left: 0;
        }

        .fixed-col-2 {
          border-right: 1px solid rgba(0, 0, 0, 0.12);
          left: 90px;
        }

        td {
          padding: 0 10px 10px 10px;
        }

        .row-labels-container {
          display: flex;
          flex-flow: column nowrap;
          justify-content: space-around;
          align-items: flex-end;
          height: 100%;

          .row-label {
            font-weight: bold;
            font-size: 10px;
          }
        }

        .v-text-field {
          font-size: 10px;
          margin: 0 auto 5px auto;
          max-width: 40px;
        }

        .v-data-footer__select {
          .v-text-field {
            margin-left: 10px;
          }
        }
      }
    }
  }

  @media (min-width: 450px) {
    #targets-toolbar-container {
      #targets-toolbar {
        ::v-deep {
          .v-toolbar__title {
            font-size: 12px;
          }

          #toolbar-right-side {
            #update-btn {
              font-size: 10px;
            }
          }
        }
      }
    }
  }

  @media (min-width: 600px) {
    #targets-toolbar-container {
      #targets-toolbar {
        ::v-deep {
          .v-toolbar__title {
            font-size: 14px;
          }

          #toolbar-right-side {
            #update-btn {
              font-size: 12px;
            }
          }
        }
      }
    }

    #targets-table-container {
      #targets-table {
        margin: 16px auto 0 auto !important;

        ::v-deep {
          th, td, span {
            font-size: 12px !important;
          }

          th {
            padding: 5px;
          }

          td {
            padding: 5px 10px 10px 10px;
          }

          .row-labels-container {
            .row-label {
              font-size: 12px;
            }
          }

          .v-text-field {
            font-size: 12px;
            margin: 0 auto 10px auto;
            min-width: 50px;
          }
        }
      }
    }
  }

  @media (min-width: 769px) {
    #targets-toolbar-container {
      #targets-toolbar {
        ::v-deep {
          .v-toolbar__title {
            font-size: 16px;
          }

          #toolbar-right-side {
            #update-btn {
              font-size: 14px;
            }
          }
        }
      }
    }

    #targets-table-container {
      #targets-table {
        margin: 24px auto 0 auto !important;
        max-width: 750px;

        ::v-deep {
          th, td {
            max-width: 150px;
            padding: 10px;
          }
        }
      }
    }
  }

  @media (min-width: 1070px) {
    #targets-toolbar-container {
      #targets-toolbar {
        ::v-deep {
          .v-toolbar__title {
            font-size: 20px;
          }
        }
      }
    }

    #targets-table-container {
      #targets-table {
        margin: 32px auto 0 auto !important;
      }
    }
  }

  @media (min-width: 1135px) {
    #targets-table-container {
      #targets-table {
        max-width: 1130px;
      }
    }
  }
</style>
