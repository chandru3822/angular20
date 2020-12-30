<!-- suppress CssInvalidPseudoSelector -->
<template id="ahj-requirement-history">
  <div>
    <a class="history-link" title="View requirement history" @click="getRequirementHistory">History</a>

    <v-dialog v-model="historyDialog" max-width="800px">
      <v-card class="pt-2 pb-2 px-0">
        <v-card-title class="flex-display justify-space-between pt-0 px-4">
          <span class="font-weight-bold">Requirement History</span>
          <a class="close-modal-x pb-3" title="Close" @click="closeHistoryDialog">×</a>
        </v-card-title>
        <v-card-text class="px-4 pb-0">
          <div v-if="requirementHistory.length > 0 && requirementHistory[0].statusId !== 3"
               class="flex-display justify-end mb-4">
            <v-btn color="primaryButton" class="white--text text-capitalize"
                   @click="toggleChallengeForm"
            >Challenge</v-btn>
          </div>

          <form class="requirement-challenge-ctrls mb-8"
                ref="challengeFrm" v-show="challengeForm">
            <span class="mb-1 d-inline-block">Challenge Requirement</span>
            <v-text-field required label="Requirement Details" auto-grow filled
                          v-model="challenge.details">
            </v-text-field>
            <div class="requirement-challenge-btns flex-display justify-end align-center">
              <a @click="toggleChallengeForm" class="cancel-link text-capitalize">Cancel</a>
              <v-btn color="primaryButton" class="white--text text-capitalize py-1 px-3 ml-2"
                     :disabled="challenge.details === ''" small
                     @click="submitChallenge">
                Submit Challenge
              </v-btn>
            </div>
          </form>

          <div v-if="challengeDetails" class="mb-8">
            <v-simple-table id="requirement-status-table">
              <thead>
                <tr>
                  <th>Updated Requirement</th>
                  <th>Challenge Date</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>{{ selectedRequirement.description }}</td>
                  <td v-if="!selectedRequirement.formattedDateModified && selectedRequirement.formattedDateCreated">
                    {{ selectedRequirement.createdBy }} - {{ selectedRequirement.formattedDateCreated }}
                  </td>
                  <td v-if="selectedRequirement.formattedDateModified">
                    {{ selectedRequirement.modifiedBy }} - {{ selectedRequirement.formattedDateModified }}
                  </td>
                  <td class="py-2 pr-3">
                    <v-select v-if="selectedRequirement.statusId === 3"
                              v-model="selectedRequirementStatusId"
                              :items="challengeStatuses"
                              label="Challenge Status"
                              required filled dense
                    ></v-select>
                    <span v-if="selectedRequirement.statusId === 4">Denied</span>
                  </td>
                </tr>
              </tbody>
            </v-simple-table>

            <div class="flex-display justify-end" id="requirement-status-btns">
              <a v-if="selectedRequirement.statusId === 3"
                 class="cancel-link mr-2 mt-2"
                 title="Cancel challenge status update"
                 @click="toggleChallengeDetails">Cancel</a>
              <v-btn v-if="selectedRequirement.statusId === 3"
                     class="text-capitalize mr-3 px-2 white--text"
                     color="primaryButton"
                     style="font-size: 0.85em"
                     title="Save challenge status update"
                     @click="updateChallengeStatus">
                <v-icon class="white--text mr-1" small>save</v-icon>Save
              </v-btn>
              <v-btn v-else small class="mt-8" style="text-transform: unset; color: inherit !important;" @click="challengeDetails = false">Hide details</v-btn>
            </div>
          </div>

          <v-simple-table>
            <thead>
              <tr>
                <th>Description</th>
                <th>Modified</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="requirement in requirementHistory" :key="requirement.id">
                <td>{{ requirement.description }}</td>
                <td v-if="!requirement.formattedDateModified && requirement.formattedDateCreated">
                  {{ requirement.createdBy }} - {{ requirement.formattedDateCreated }}
                </td>
                <td v-if="requirement.formattedDateModified">
                  {{ requirement.modifiedBy }} - {{ requirement.formattedDateModified }}
                </td>
                <td>
                  <a v-if="[3,4].indexOf(requirement.statusId) !== -1"
                     title="View challenge details"
                     @click="toggleChallengeDetails(requirement)">
                    {{ requirement.status }}
                  </a>
                  <span v-if="[3,4].indexOf(requirement.statusId) === -1">
                    {{ requirement.status }}
                  </span>
                </td>
              </tr>
            </tbody>
          </v-simple-table>
        </v-card-text>
        <v-card-actions class="flex-display justify-end px-4 pt-6">
          <v-btn class="text-capitalize" @click="closeHistoryDialog">
            <span style="font-size: 20px" class="font-weight-bold mr-1">×</span>Close
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>


  </div>
</template>

<script>
  import moment from 'moment'

  import { AppMutations } from '@/stores/AppStore'
  import { getRequest, putRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: "AhjRequirementHistory",

    props: {
      itemType: {
        type: String
      },
      itemId: {
        type: Number
      },
      originalRequirement: {
        type: Object
      }
    },
    data () {
      return {
        originalRequirementId: this.originalRequirement.originalRequirementId,
        historyDialog: false,
        requirementHistory: [{ statusId: 0}],
        challengeForm: false,
        challenge: {
          details: null
        },
        challengeDetails: false,
        challengeStatuses: [
          { value: 3, text: "Open" },
          { value: 1, text: "Accepted" },
          { value: 4, text: "Denied" }
        ],
        selectedRequirement: null,
        selectedRequirementStatusId: 3,
        snackbar: {}
      }
    },
    watch: {
      historyDialog (val) {
        if (!val) {
          this.closeHistoryDialog()
        }
      }
    },
    methods: {
      async getRequirementHistory() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.historyDialog = true

        try {
          const {data} = await getRequest(`/ahj/${this.itemId}/${this.itemType}/requirement/${this.originalRequirementId}/history`, 'blueraven')

          if (data.length > 0) {
            data.forEach(requirement => {
              if (requirement.dateCreated && requirement.createdBy) {
                requirement.formattedDateCreated = moment(requirement.dateCreated).format('MM/DD/YY h:mm A')
              }

              if (requirement.dateModified && requirement.modifiedBy) {
                requirement.formattedDateModified = moment(requirement.dateModified).format('MM/DD/YY h:mm A')
              }
            })
            this.requirementHistory = data
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving requirement history')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.closeHistoryDialog()
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      async submitChallenge() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.requirementHistory[0].description = this.challenge.details
        this.requirementHistory[0].archived = false
        this.requirementHistory[0].statusId = 3

        try {
          await putRequest(`/ahj/${this.itemId}/${this.itemType}/requirement/${this.requirementHistory[0].id}`, this.requirementHistory[0], 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Challenge submitted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.originalRequirement.hasOpenChallenge = true
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error updating requirement')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
        this.closeHistoryDialog()
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      async updateChallengeStatus() {
        /* if the user selects "Open" as the status, then the dialog window just closes,                 *
         * because the status should already be set to "Open" if the user was able to get to this point, *
         * and when the user selects "Open" when that was already the status, weird things happen...     */
        if (this.selectedRequirementStatusId === 3) {
          this.closeHistoryDialog()
          return
        }

        this.$store.commit(AppMutations.SET_LOADING, true)
        this.requirementHistory[0].archived = false
        this.requirementHistory[0].statusId = this.selectedRequirementStatusId

        try {
          const {data} = await putRequest(`/ahj/${this.itemId}/${this.itemType}/requirement/${this.requirementHistory[0].id}`, this.requirementHistory[0], 'blueraven')
          this.originalRequirement.hasOpenChallenge = false
          this.originalRequirement.statusId = this.selectedRequirementStatusId

          // only runs when the challenge status isn't "Denied"
          if (this.originalRequirement.statusId !== 4) {
            this.originalRequirement.id = data?.id
            this.originalRequirement.description = this.requirementHistory[0].description
            this.originalRequirement.formattedDateModified = moment().format('MM/DD/YY hh:mm A')
            this.snackbar = getSnackbar('SUCCESS', 'Challenge accepted.')
          } else {
            this.snackbar = getSnackbar('SUCCESS', 'Challenge status updated')
          }

          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error updating challenge status')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.closeHistoryDialog()
      },
      toggleChallengeForm() {
        if (this.challengeForm) {
          this.challenge.details = ''
          this.challengeForm = false
        } else {
          this.challenge.details = this.requirementHistory[0].description
          this.challengeForm = true
        }
      },
      toggleChallengeDetails(requirement) {
        if (this.challengeDetails) {
          this.selectedRequirementStatusId = 3
          this.challengeDetails = false
        } else {
          this.challengeDetails = true
        }

        if (requirement) {
          this.selectedRequirement = requirement
        }
      },
      closeHistoryDialog() {
        this.historyDialog = false
        if (this.challengeForm) {
          this.toggleChallengeForm()
        }
        if (this.challengeDetails) {
          this.toggleChallengeDetails()
        }
      }
    }
  }
</script>

<style scoped lang="scss">
  .cancel-link {
    font-size: 0.85em !important;
    text-decoration: none;
  }
  .history-link {
    text-decoration: none;
    color: var(--v-primaryText-base) !important;
  }
  .cancel-link:hover,
  .history-link:hover {
    text-decoration: underline;
  }
  .v-card__title {
    font-size: 1em !important;
  }
  .v-text-field,
  .v-input ::v-deep label {
    font-size: 0.95em !important;
  }
  .close-modal-x {
    font-size: 20px;
    &:hover {
      font-weight: bolder;
    }
  }
  #requirement-status-table {
    tr:hover {
      background-color: initial;
    }
  }
  #requirement-status-btns {
    margin-top: -20px;
  }
  .v-data-table__wrapper {
    th {
      font-size: 1em;
    }
    td {
      color: rgba(0, 0, 0, 0.54);

      a:hover {
        text-decoration: underline;
      }
    }
  }
</style>
