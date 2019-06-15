<template>
  <v-layout column nowrap fill-height>
    <v-flex xs12 text-xs-right fill-height>
      <v-btn class="info" style="margin: 10px 5px 10px 0; text-transform: capitalize;">Save</v-btn>
    </v-flex>

    <v-layout row wrap>
      <!-- FIRST COLUMN -->
      <v-flex xs3 class="padded-sides">
        <!-- SUBMISSION DETAILS -->
        <v-card>
          <v-card-title class="info">
            <h3 class="white--text">Submission Details</h3>
          </v-card-title>
          <v-card-text>
            <v-select
              label="Submittal Method"
              :items="submittalMethods"
              v-model="ahjPermit.submissionDetails.submittalMethod"
            ></v-select>
            <v-select
              label="HOA Approval Required for Submission"
              :items="approvalRequiredOptions"
              v-model="ahjPermit.submissionDetails.hoaApprovalRequired"
            ></v-select>
            <v-select
              label="NEM Approval Required for Submission"
              :items="approvalRequiredOptions"
              v-model="ahjPermit.submissionDetails.nemApprovalRequired"
            ></v-select>
            <v-text-field
              v-model="ahjPermit.submissionDetails.depositAmount"
              label="Deposit Amount"
              prefix="$"
            ></v-text-field>
            <v-select
              label="Payment Method"
              :items="submittalMethods"
              v-model="ahjPermit.submissionDetails.paymentMethod"
            ></v-select>
            <div class="flex-row">
              <v-text-field v-model="ahjPermit.submissionDetails.businessLicense" label="Business License" style="width: 50%; margin-right: 20px;"></v-text-field>
              <v-flex style="width: 50%">
                <v-menu
                  v-model="businessLicenseMenu"
                  :close-on-content-click="false"
                  :nudge-right="40"
                  lazy
                  transition="scale-transition"
                  offset-y
                  full-width
                  min-width="290px"
                >
                  <template #activator="{ on }">
                    <v-text-field
                      v-model="ahjPermit.submissionDetails.businessLicenseDate"
                      label="mm/dd/yyyy"
                      append-icon="event"
                      readonly
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="ahjPermit.submissionDetails.businessLicenseDate" @input="businessLicenseMenu = false"></v-date-picker>
                </v-menu>
              </v-flex>
            </div>
            <div class="flex-row">
              <v-text-field v-model="ahjPermit.submissionDetails.contractorLicense" label="Contractor License" style="width: 50%; margin-right: 20px;"></v-text-field>
              <v-flex style="width: 50%">
                <v-menu
                  v-model="contractorLicenseMenu"
                  :close-on-content-click="false"
                  :nudge-right="40"
                  lazy
                  transition="scale-transition"
                  offset-y
                  full-width
                  min-width="290px"
                >
                  <template #activator="{ on }">
                    <v-text-field
                      v-model="ahjPermit.submissionDetails.contractorLicenseDate"
                      label="mm/dd/yyyy"
                      append-icon="event"
                      readonly
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="ahjPermit.submissionDetails.contractorLicenseDate" @input="contractorLicenseMenu = false"></v-date-picker>
                </v-menu>
              </v-flex>
            </div>
            <div class="flex-row">
              <v-text-field v-model="ahjPermit.submissionDetails.otherLicense" label="Other License" style="width: 50%; margin-right: 20px;"></v-text-field>
              <v-flex style="width: 50%">
                <v-menu
                  v-model="otherLicenseMenu"
                  :close-on-content-click="false"
                  :nudge-right="40"
                  lazy
                  transition="scale-transition"
                  offset-y
                  full-width
                  min-width="290px"
                >
                  <template #activator="{ on }">
                    <v-text-field
                      v-model="ahjPermit.submissionDetails.otherLicenseDate"
                      label="mm/dd/yyyy"
                      append-icon="event"
                      readonly
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="ahjPermit.submissionDetails.otherLicenseDate" @input="otherLicenseMenu = false"></v-date-picker>
                </v-menu>
              </v-flex>
            </div>
            <v-card>
              <v-toolbar class="info white--text">
                <v-toolbar-title>
                  <h3>Submission Checklist</h3>
                </v-toolbar-title>
                <v-spacer></v-spacer>
                <v-btn icon color="#ddd" style="border-radius: 3px">
                  <v-icon>add</v-icon>
                </v-btn>
              </v-toolbar>
              <!-- TODO: Improve mouse cursor toggle functionality (between grab/grabbing) for when a user is clicking & dragging an item -->
              <draggable v-model="ahjPermit.submissionDetails.submissionChecklistItems"
                         group="submissionChecklist" @start="drag=true" @end="drag=false">
                <v-list v-for="item in ahjPermit.submissionDetails.submissionChecklistItems"
                        :key="item.id">
                  <v-list-tile v-show="ahjPermit.submissionDetails.submissionChecklistItems.length > 0"
                               class="grab" v-bind:title="item.details">
                    <v-list-tile-action>
                      <v-icon small class="mr-3" @click="editSubmissionChecklistItem(item)">edit</v-icon>
                    </v-list-tile-action>
                    <v-list-tile-content>
                        <v-list-tile-title v-text="item.details"></v-list-tile-title>
                    </v-list-tile-content>
                    <v-list-tile-action>
                      <v-icon>drag_handle</v-icon>
                    </v-list-tile-action>
                  </v-list-tile>
                  <v-list-tile v-show="ahjPermit.submissionDetails.submissionChecklistItems.length < 1">
                    This checklist doesn't have any items
                  </v-list-tile>
                </v-list>
              </draggable>
            </v-card>
            <v-textarea label="Submission Instructions"></v-textarea>
          </v-card-text>
        </v-card>
      </v-flex>

      <!-- SECOND COLUMN -->
      <v-flex xs3 class="padded-sides">
        <!-- REVISION SUBMISSION DETAILS -->
        <v-card>
          <v-card-title class="info">
            <h3 class="white--text">Revision Submission Details</h3>
          </v-card-title>
          <v-card-text>
            <v-select
              label="Submittal Method"
              :items="submittalMethods"
              v-model="ahjPermit.revisionSubmissionDetails.submittalMethod"
            ></v-select>
          </v-card-text>
        </v-card>
      </v-flex>

      <!-- THIRD COLUMN -->
      <v-flex xs3 class="padded-sides">
        <!-- AS-BUILT SUBMISSION DETAILS -->
        <v-card>
          <v-card-title class="info">
            <h3 class="white--text">As-Built Submission Details</h3>
          </v-card-title>
          <v-card-text>
            <v-select
              label="Submittal Method"
              :items="submittalMethods"
              v-model="ahjPermit.asBuiltSubmissionDetails.submittalMethod"
            ></v-select>
          </v-card-text>
        </v-card>
      </v-flex>

      <!-- FOURTH COLUMN -->
      <v-flex xs3 class="padded-sides">
        <!-- FOLLOW-UP / APPROVAL DETAILS -->
        <v-card>
          <v-card-title class="info">
            <h3 class="white--text">Follow-up / Approval Details</h3>
          </v-card-title>
          <v-card-text>
            <v-text-field v-model="ahjPermit.followUpApprovalDetails.approvalTimeline" label="Approval Timeline"></v-text-field>
          </v-card-text>
        </v-card>
      </v-flex>
    </v-layout>

  </v-layout>
</template>

<script>
  import draggable from 'vuedraggable'

  export default {
    name: 'ahjPermit',
    components: {
      draggable
    },
    data: () => ({
      submittalMethods: ['', 'Online', 'In-person', 'Other'],
      approvalRequiredOptions: ['', 'No', 'Yes', 'Unknown', 'Other'],
      businessLicenseMenu: false,
      contractorLicenseMenu: false,
      otherLicenseMenu: false,
      submissionChecklistEditControls: false,
      submissionChecklistEditedIndex: -1,
      editedSubmissionChecklistItem: {
        details: ''
      },
      ahjPermit: {
        submissionDetails: {
          submittalMethod: null,
          hoaApprovalRequired: null,
          nemApprovalRequired: null,
          depositAmount: null,
          paymentMethod: null,
          businessLicense: null,
          businessLicenseDate: null,
          contractorLicense: null,
          contractorLicenseDate: null,
          otherLicense: null,
          otherLicenseDate: null,
          submissionChecklistItems: [
            {
              id: 1,
              details: 'Obtain deposit from customer by 7/15/2019'
            },
            {
              id: 2,
              details: 'Make sure licenses are obtained'
            },
            {
              id: 3,
              details: 'Call customer about HOA Approval'
            },
            {
              id: 4,
              details: 'Call customer about NEM Approval'
            }
          ],
          submissionInstructions: null
        },
        revisionSubmissionDetails: {
          submittalMethod: null
        },
        asBuiltSubmissionDetails: {
          submittalMethod: null
        },
        followUpApprovalDetails: {
          approvalTimeline: null
        }
      }
    }),
    methods: {
      //TODO: Finish setting up this method (although it's just a pretend frontend method for now)
      editSubmissionChecklistItem(item) {
        this.submissionChecklistEditedIndex = this.ahjPermit.submissionDetails.submissionChecklistItems.indexOf(item)
        this.editedSubmissionChecklistItem = Object.assign({}, item)
        this.submissionChecklistEditControls = true
      }
    }
  }
</script>

<style scoped lang="scss">
  .padded-sides {
    padding: 0 5px;
  }
  .flex-row {
    display: flex;
    flex-flow: row nowrap;
  }
  .v-toolbar__title {
    font-size: 1em;
  }
  .v-text-field, .v-select, .v-input /deep/ label {
    font-size: 0.95em !important;
  }
  .v-list__tile__title {
    font-size: 0.8em !important;
  }
  .grab {
    cursor: grab;
    &:active {
      cursor: grabbing;
    }
  }
</style>