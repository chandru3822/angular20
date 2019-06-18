<template>
  <v-layout column nowrap fill-height>
    <v-flex xs12 text-xs-right fill-height>
      <a @click="resetForm()" class="cancel-link" style="margin-right: 10px">Cancel</a>
      <v-btn id="save-btn" class="info" dark>Save</v-btn>
    </v-flex>

    <v-layout row wrap>
      <!-- FIRST COLUMN -->
      <v-flex xs12 md3 mb-3 class="padded-sides">
        <!-- SUBMISSION DETAILS -->
        <v-card>
          <v-card-title class="info">
            <h3 class="white--text">Submission Details</h3>
          </v-card-title>
          <v-card-text>
            <v-select label="Submittal Method" :items="submittalMethods" box
                      v-model="ahjPermit.submissionDetails.submittalMethod"
            ></v-select>
            <v-select label="HOA Approval Required for Submission" box
                      :items="approvalRequiredOptions"
                      v-model="ahjPermit.submissionDetails.hoaApprovalRequired"
            ></v-select>
            <v-select label="NEM Approval Required for Submission" box
                      :items="approvalRequiredOptions"
                      v-model="ahjPermit.submissionDetails.nemApprovalRequired"
            ></v-select>
            <v-text-field v-model="ahjPermit.submissionDetails.depositAmount"
                          label="Deposit Amount" prefix="$" box type="currency"
            ></v-text-field>
            <v-select label="Payment Method" :items="submittalMethods" box
                      v-model="ahjPermit.submissionDetails.paymentMethod"
            ></v-select>
            <div class="flex-row">
              <v-text-field v-model="ahjPermit.submissionDetails.businessLicense"
                            label="Business License" box
                            style="width: 50%; margin-right: 20px;"></v-text-field>
              <v-flex style="width: 50%">
                <v-menu v-model="businessLicenseMenu" :close-on-content-click="false"
                        :nudge-right="40" lazy transition="scale-transition" offset-y
                        full-width min-width="290px">
                  <template #activator="{ on }">
                    <v-text-field v-model="ahjPermit.submissionDetails.businessLicenseDate" box
                                  label="mm/dd/yyyy" append-icon="event" readonly v-on="on">
                    </v-text-field>
                  </template>
                  <v-date-picker v-model="ahjPermit.submissionDetails.businessLicenseDate" @input="businessLicenseMenu=false"></v-date-picker>
                </v-menu>
              </v-flex>
            </div>
            <div class="flex-row">
              <v-text-field v-model="ahjPermit.submissionDetails.contractorLicense"
                            label="Contractor License" box
                            style="width: 50%; margin-right: 20px;"></v-text-field>
              <v-flex style="width: 50%">
                <v-menu
                  v-model="contractorLicenseMenu" :close-on-content-click="false"
                  :nudge-right="40" lazy transition="scale-transition" offset-y
                  full-width min-width="290px"
                >
                  <template #activator="{ on }">
                    <v-text-field label="mm/dd/yyyy" append-icon="event" readonly
                                  v-on="on" box
                                  v-model="ahjPermit.submissionDetails.contractorLicenseDate"></v-text-field>
                  </template>
                  <v-date-picker v-model="ahjPermit.submissionDetails.contractorLicenseDate" @input="contractorLicenseMenu=false"></v-date-picker>
                </v-menu>
              </v-flex>
            </div>
            <div class="flex-row">
              <v-text-field v-model="ahjPermit.submissionDetails.otherLicense"
                            label="Other License" box
                            style="width: 50%; margin-right: 20px;"></v-text-field>
              <v-flex style="width: 50%">
                <v-menu
                  v-model="otherLicenseMenu" :close-on-content-click="false"
                  :nudge-right="40" lazy transition="scale-transition"
                  offset-y full-width min-width="290px"
                >
                  <template #activator="{ on }">
                    <v-text-field v-model="ahjPermit.submissionDetails.otherLicenseDate"
                                  label="mm/dd/yyyy" append-icon="event" readonly
                                  v-on="on" box></v-text-field>
                  </template>
                  <v-date-picker v-model="ahjPermit.submissionDetails.otherLicenseDate"
                                 @input="otherLicenseMenu=false"></v-date-picker>
                </v-menu>
              </v-flex>
            </div>
            <v-card>
              <v-toolbar class="info">
                <v-toolbar-title class="white--text" title="Submission Checklist">
                  <h3>Submission Checklist</h3>
                </v-toolbar-title>
                <v-spacer></v-spacer>
                <v-btn icon color="#ddd" style="border-radius: 3px"
                       @click="addSubmissionChecklistItem()">
                  <v-icon>add</v-icon>
                </v-btn>
              </v-toolbar>
              <div class="checklist-item-edit-ctrls"
                   v-show="submissionChecklistAddCtrls || submissionChecklistEditCtrls">
                <v-textarea required label="Details" auto-grow box
                            style="margin: 15px 0 -15px 0"
                            v-model="editedSubmissionChecklistItem.details">
                </v-textarea>
                <div class="checklist-btns">
                  <a @click="hideSubmissionChecklistCtrls()"
                     class="cancel-link">Cancel</a>
                  <v-btn v-show="submissionChecklistEditCtrls" dark
                         @click="deleteSubmissionChecklistItem()" class="error">
                    Delete
                  </v-btn>
                  <v-btn @click="saveSubmissionChecklistItem()" class="info" dark
                         v-bind:disabled="editedSubmissionChecklistItem.details === ''">
                    {{submissionChecklistEditCtrls ? 'Update' : 'Add'}}
                  </v-btn>
                </div>
              </div>
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
                </v-list>
              </draggable>
              <div class="empty-checklist"
                   v-show="ahjPermit.submissionDetails.submissionChecklistItems.length < 1">
                This checklist doesn't have any items
              </div>
            </v-card>
            <v-textarea label="Submission Instructions" box auto-grow
                        v-model="ahjPermit.submissionDetails.submissionInstructions"
                        style="margin-top: 30px"></v-textarea>
          </v-card-text>
        </v-card>
      </v-flex>

      <!-- SECOND COLUMN -->
      <v-flex xs12 md3 mb-3 class="padded-sides">
        <!-- REVISION SUBMISSION DETAILS -->
        <v-card>
          <v-card-title class="info">
            <h3 class="white--text">Revision Submission Details</h3>
          </v-card-title>
          <v-card-text>
            <v-select label="Submittal Method" :items="submittalMethods" box
                      v-model="ahjPermit.revisionSubmissionDetails.submittalMethod"
            ></v-select>
            <v-text-field label="Fee Amount" prefix="$" box
                          v-model="ahjPermit.revisionSubmissionDetails.feeAmount"
            ></v-text-field>
            <v-select label="Payment Method" :items="submittalMethods" box
                      v-model="ahjPermit.revisionSubmissionDetails.paymentMethod"
            ></v-select>
            <v-card>
              <v-toolbar class="info">
                <v-toolbar-title class="white--text"
                                 title="Revision Submission Checklist">
                  <h3>Revision Submission Checklist</h3>
                </v-toolbar-title>
                <v-spacer></v-spacer>
                <v-btn icon color="#ddd" style="border-radius: 3px"
                       @click="addSubmissionChecklistItem()">
                  <v-icon>add</v-icon>
                </v-btn>
              </v-toolbar>
              <div class="checklist-item-edit-ctrls"
                   v-show="revisionSubmissionChecklistAddCtrls || revisionSubmissionChecklistEditCtrls">
                <v-textarea required label="Details" auto-grow box
                            style="margin: 15px 0 -15px 0"
                            v-model="editedRevisionSubmissionChecklistItem.details">
                </v-textarea>
                <div class="checklist-btns">
                  <a @click="hideSubmissionChecklistCtrls()"
                     class="cancel-link">Cancel</a>
                  <v-btn v-show="revisionSubmissionChecklistEditCtrls" dark
                         @click="deleteSubmissionChecklistItem()" class="error">
                    Delete
                  </v-btn>
                  <v-btn @click="saveSubmissionChecklistItem()" class="info" dark
                         v-bind:disabled="editedRevisionSubmissionChecklistItem.details === ''">
                    {{revisionSubmissionChecklistEditCtrls ? 'Update' : 'Add'}}
                  </v-btn>
                </div>
              </div>
              <draggable v-model="ahjPermit.revisionSubmissionDetails.revisionSubmissionChecklistItems"
                         group="submissionChecklist" @start="drag=true" @end="drag=false">
                <v-list v-for="item in ahjPermit.revisionSubmissionDetails.revisionSubmissionChecklistItems"
                        :key="item.id">
                  <v-list-tile v-show="ahjPermit.revisionSubmissionDetails.revisionSubmissionChecklistItems.length > 0"
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
                </v-list>
              </draggable>
              <div class="empty-checklist"
                   v-show="ahjPermit.revisionSubmissionDetails.revisionSubmissionChecklistItems.length < 1">
                This checklist doesn't have any items
              </div>
            </v-card>
            <v-textarea label="Revision Submission Instructions" box auto-grow
                        style="margin-top: 30px"
                        v-model="ahjPermit.revisionSubmissionDetails.submittalMethod">
            </v-textarea>
          </v-card-text>
        </v-card>
      </v-flex>

      <!-- THIRD COLUMN -->
      <v-flex xs12 md3 mb-3 class="padded-sides">
        <!-- AS-BUILT SUBMISSION DETAILS -->
        <v-card>
          <v-card-title class="info">
            <h3 class="white--text">As-Built Submission Details</h3>
          </v-card-title>
          <v-card-text>
            <v-select label="Submittal Method" :items="submittalMethods" box
                      v-model="ahjPermit.asBuiltSubmissionDetails.submittalMethod"
            ></v-select>
          </v-card-text>
        </v-card>
      </v-flex>

      <!-- FOURTH COLUMN -->
      <v-flex xs12 md3 mb-3 class="padded-sides">
        <!-- FOLLOW-UP / APPROVAL DETAILS -->
        <v-card>
          <v-card-title class="info">
            <h3 class="white--text">Follow-up / Approval Details</h3>
          </v-card-title>
          <v-card-text>
            <v-text-field v-model="ahjPermit.followUpApprovalDetails.approvalTimeline"
                          label="Approval Timeline" box></v-text-field>
          </v-card-text>
        </v-card>
      </v-flex>
    </v-layout>

  </v-layout>
</template>

<script>
  import draggable from 'vuedraggable'
  import forEach from 'lodash.foreach'
  import max from 'lodash.max'

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
      submissionChecklistAddCtrls: false,
      submissionChecklistEditCtrls: false,
      submissionChecklistEditedIndex: -1,
      editedSubmissionChecklistItem: {
        details: ''
      },
      submissionCheckListItemToDelete: '',
      revisionSubmissionChecklistAddCtrls: false,
      revisionSubmissionChecklistEditCtrls: false,
      revisionSubmissionChecklistEditedIndex: -1,
      editedRevisionSubmissionChecklistItem: {
        details: ''
      },
      revisionSubmissionCheckListItemToDelete: '',
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
          submittalMethod: null,
          feeAmount: null,
          paymentMethod: null,
          revisionSubmissionChecklistItems: [
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
          revisionSubmissionInstructions: null
        },
        asBuiltSubmissionDetails: {
          submittalMethod: null,
          feeAmount: null,
          paymentMethod: null,
          revisionSubmissionChecklistItems: [
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
          revisionSubmissionInstructions: null
        },
        followUpApprovalDetails: {
          approvalTimeline: null
        }
      }
    }),
    methods: {
      resetForm() {
        /* TODO: Once the form data is being retrieved from the database, copy it to reset the form when the user clicks the "Cancel" link on the top right of the page
        */
        console.log("Resetting the form...")
      },
      hideSubmissionChecklistCtrls() {
        if (this.submissionChecklistAddCtrls) {
          this.submissionChecklistAddCtrls = false
        } else {
          this.submissionChecklistEditCtrls = false
        }
      },
      addSubmissionChecklistItem() {
        if (this.editedSubmissionChecklistItem.details !== '') {
          this.editedSubmissionChecklistItem.details = ''
        }
        if (this.submissionChecklistEditCtrls) {
          this.submissionChecklistEditCtrls = !this.submissionChecklistEditCtrls
        }
        this.submissionChecklistAddCtrls = true
      },
      editSubmissionChecklistItem(item) {
        if (this.submissionChecklistAddCtrls) {
          this.submissionChecklistAddCtrls = !this.submissionChecklistAddCtrls
        }
        this.submissionChecklistEditedIndex = this.ahjPermit.submissionDetails.submissionChecklistItems.indexOf(item)
        this.editedSubmissionChecklistItem = Object.assign({}, item)
        this.submissionChecklistEditCtrls = true
      },
      deleteSubmissionChecklistItem() {
        this.ahjPermit.submissionDetails.submissionChecklistItems.splice(this.submissionChecklistEditedIndex, 1)
        this.submissionChecklistEditCtrls = false
      },
      saveSubmissionChecklistItem() {
        if (this.submissionChecklistEditedIndex > -1) {
          Object.assign(this.ahjPermit.submissionDetails.submissionChecklistItems[this.submissionChecklistEditedIndex], this.editedSubmissionChecklistItem)
          this.submissionChecklistEditCtrls = false
        } else {
          if (this.ahjPermit.submissionDetails.submissionChecklistItems.length > 0) {
            let idsArray = []
            forEach(this.ahjPermit.submissionDetails.submissionChecklistItems, item => idsArray.push(item.id))
            this.editedSubmissionChecklistItem.id = max(idsArray) + 1
          } else {
            this.editedSubmissionChecklistItem.id = 1
          }
          this.ahjPermit.submissionDetails.submissionChecklistItems.push(this.editedSubmissionChecklistItem)
          this.submissionChecklistAddCtrls = false
        }
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
  .checklist-btns {
    display: flex;
    flex-flow: row nowrap;
    justify-content: flex-end;
    align-items: center;
    button {
      margin: 0 0 0 7px;
    }
  }
  #save-btn {
    margin: 10px 5px 10px 0;
    text-transform: capitalize;
  }
  .checklist-item-edit-ctrls {
    margin: 5px;
    display: flex;
    flex-flow: column nowrap;
  }
  .empty-checklist {
    padding: 20px;
  }
  .cancel-link:hover {
    text-decoration: underline;
  }
</style>