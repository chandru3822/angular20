<!-- suppress CssInvalidPseudoSelector -->
<template id="ahj-requirement-history">
  <div>
    <a class="history-link" title="View requirement history" @click="historyDialog = true">History</a>

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
                   @click="challengeForm = !challengeForm"
            >Challenge</v-btn>
          </div>

          <form class="requirement-challenge-ctrls mb-8"
                ref="challengeFrm" v-show="challengeForm">
            <span class="mb-1 d-inline-block">Challenge Requirement</span>
            <v-text-field required label="Requirement Details" auto-grow filled
                          v-model="challenge.details">
            </v-text-field>
            <div class="requirement-challenge-btns flex-display justify-end align-center">
              <a @click="hideChallengeForm" class="cancel-link text-capitalize">Cancel</a>
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
                  <td>{{ requirement.description }}</td>
                  <td v-if="!requirement.formattedDateModified && requirement.formattedDateCreated">
                    {{ requirement.createdBy }} - {{ requirement.formattedDateCreated }}
                  </td>
                  <td v-if="requirement.formattedDateModified">
                    {{ requirement.modifiedBy }} - {{ requirement.formattedDateModified }}
                  </td>
                  <td class="py-2 pr-3">
                    <v-select v-if="requirement.statusId === 1"
                              v-model="updatedRequirementStatusId"
                              :items="challengeStatuses"
                              label="Challenge Status"
                              required filled dense
                    ></v-select>
                    <span v-if="requirement.statusId === 4">Denied</span>
                  </td>
                </tr>
              </tbody>
            </v-simple-table>

            <div class="flex-display justify-end" id="requirement-status-btns">
              <a class="cancel-link mr-2 mt-2"
                 title="Cancel challenge status update"
                 @click="hideChallengeDetails">Cancel</a>
              <v-btn v-if="requirement.statusId === 1"
                     class="text-capitalize mr-3 px-2 white--text"
                     color="primaryButton"
                     style="font-size: 0.85em"
                     title="Save challenge status update"
                     @click="updateChallengeStatus">
                <v-icon class="white--text mr-1" small>save</v-icon>Save
              </v-btn>
              <v-btn v-if="requirement.statusId === 4"
                     class="text-capitalize"
                     @click="challengeDetails = false">
                <span style="font-size: 0.85em"
                      title="Hide challenge details"
                      class="font-weight-bold mr-1">×</span>Close
              </v-btn>
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
                     @click="challengeDetails = true">
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

    <Snackbar :snackbar="snackbar"></Snackbar>
  </div>
</template>

<script>
  import moment from 'moment'
  import Snackbar from '@/components/Snackbar'
  import { AppMutations } from '@/stores/AppStore'
  import { getRequest, putRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: "AhjRequirementHistory",
    components: {
      Snackbar
    },
    props: {
      itemType: {
        type: String
      },
      ahjId: {
        type: Number
      },
      requirement: {
        type: Object
      }
    },
    data () {
      return {
        originalRequirementId: this.requirement.originalRequirementId,
        historyDialog: false,
        requirementHistory: [],
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
        updatedRequirementStatusId: 3,
        snackbar: {}
      }
    },
    methods: {
      async getRequirementHistory() {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {data} = await getRequest(`/ahj/${this.ahjId}/requirement/${this.originalRequirementId}/history`, 'blueraven')

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

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving requirement history')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveRequirement() {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {data} = await putRequest(`/ahj/${this.ahjId}/${this.itemType}/requirement/${this.requirement.id}`, this.requirement, 'blueraven')
          console.log("data:", data)

          let updatedRequirementIndex = this.requirementHistory.findIndex(i => i.originalRequirementId === data.originalRequirementId)
          this.requirementHistory[updatedRequirementIndex].description = data.description

          if (data.dateModified) {
            this.requirementHistory[updatedRequirementIndex].formattedDateModified = moment(data.dateModified).format('MM/DD/YY h:mm A')
          } else {
            this.requirementHistory[updatedRequirementIndex].formattedDateCreated = moment(data.dateCreated).format('MM/DD/YY h:mm A')
          }

          this.snackbar = getSnackbar('SUCCESS', 'Requirement updated')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error updating requirement')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      hideChallengeForm() {
        this.challenge.details = ''
        this.challengeForm = false
        this.challengeDetails = false
      },
      async submitChallenge() {
        this.requirement.requirementTypeId = this.requirementTypeId
        this.requirement.description = this.challenge.details
        this.requirement.hasOpenChallenge = true
        this.requirement.status = "Open Challenge"
        this.requirement.statusId = 3
        this.requirement.archived = false

        this.hideChallengeForm()
        this.saveRequirement()
      },
      hideChallengeDetails() {
        this.challengeDetails = false
        this.updatedRequirementStatusId = 3
      },
      async updateChallengeStatus() {
        this.requirement.requirementTypeId = this.requirementTypeId
        this.requirement.statusId = this.updatedRequirementStatusId
        this.requirement.archived = false

        this.hideChallengeDetails()
        this.saveRequirement()
      },
      closeHistoryDialog() {
        this.historyDialog = false
        // TODO: Return updated requirement info to AhjRequirements parent component
      }
    },
    created() {
      this.getRequirementHistory()
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
