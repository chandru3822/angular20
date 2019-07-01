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
          <v-card-title class="info white--text font-weight-bold">
            Submission Details
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
            <v-text-field v-model="ahjPermit.submissionDetails.depositAmount" type="number"
                          label="Deposit Amount" prefix="$" box step="0.01" min="0.00"
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
                <v-menu v-model="contractorLicenseMenu" :close-on-content-click="false"
                        :nudge-right="40" lazy transition="scale-transition" offset-y
                        full-width min-width="290px">
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
                <v-menu v-model="otherLicenseMenu" :close-on-content-click="false"
                        :nudge-right="40" lazy transition="scale-transition"
                        offset-y full-width min-width="290px">
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
                <v-toolbar-title class="white--text font-weight-bold" title="Submission Checklist">
                  Submission Checklist
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
                  <v-btn @click="saveSubmissionChecklistItem()" class="info" :dark="editedSubmissionChecklistItem.details !== ''"
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
              <div class="empty-list"
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
          <v-card-title class="info white--text font-weight-bold">
            Revision Submission Details
          </v-card-title>
          <v-card-text>
            <v-select label="Submittal Method" :items="submittalMethods" box
                      v-model="ahjPermit.revisionSubmissionDetails.submittalMethod"
            ></v-select>
            <v-text-field label="Fee Amount" prefix="$" box type="number" step="0.01" min="0.00"
                          v-model="ahjPermit.revisionSubmissionDetails.feeAmount"
            ></v-text-field>
            <v-select label="Payment Method" :items="submittalMethods" box
                      v-model="ahjPermit.revisionSubmissionDetails.paymentMethod"
            ></v-select>
            <v-card>
              <v-toolbar class="info">
                <v-toolbar-title class="white--text font-weight-bold"
                                 title="Revision Submission Checklist">
                  Revision Submission Checklist
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
                  <v-btn @click="saveSubmissionChecklistItem()" class="info white--text"
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
              <div class="empty-list"
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
          <v-card-title class="info white--text font-weight-bold">
            As-Built Submission Details
          </v-card-title>
          <v-card-text>
            <v-select label="Submittal Method" :items="submittalMethods" box
                      v-model="ahjPermit.asBuiltSubmissionDetails.submittalMethod"
            ></v-select>
            <v-text-field label="Fee Amount" prefix="$" box type="number" step="0.01" min="0.00"
                          v-model="ahjPermit.asBuiltSubmissionDetails.feeAmount"
            ></v-text-field>
            <v-select label="Payment Method" :items="submittalMethods" box
                      v-model="ahjPermit.asBuiltSubmissionDetails.paymentMethod"
            ></v-select>
            <v-card>
              <v-toolbar class="info">
                <v-toolbar-title class="white--text font-weight-bold"
                                 title="As-Built Submission Checklist">
                  As-Built Submission Checklist
                </v-toolbar-title>
                <v-spacer></v-spacer>
                <v-btn icon color="#ddd" style="border-radius: 3px"
                       @click="addSubmissionChecklistItem()">
                  <v-icon>add</v-icon>
                </v-btn>
              </v-toolbar>
              <div class="checklist-item-edit-ctrls"
                   v-show="asBuiltSubmissionChecklistAddCtrls || asBuiltSubmissionChecklistEditCtrls">
                <v-textarea required label="Details" auto-grow box
                            style="margin: 15px 0 -15px 0"
                            v-model="editedAsBuiltSubmissionChecklistItem.details">
                </v-textarea>
                <div class="checklist-btns">
                  <a @click="hideSubmissionChecklistCtrls()"
                     class="cancel-link">Cancel</a>
                  <v-btn v-show="asBuiltSubmissionChecklistEditCtrls" dark
                         @click="deleteSubmissionChecklistItem()" class="error">
                    Delete
                  </v-btn>
                  <v-btn @click="saveSubmissionChecklistItem()" class="info white--text"
                         v-bind:disabled="editedAsBuiltSubmissionChecklistItem.details === ''">
                    {{asBuiltSubmissionChecklistEditCtrls ? 'Update' : 'Add'}}
                  </v-btn>
                </div>
              </div>
              <draggable v-model="ahjPermit.asBuiltSubmissionDetails.asBuiltSubmissionChecklistItems"
                         group="submissionChecklist" @start="drag=true" @end="drag=false">
                <v-list v-for="item in ahjPermit.asBuiltSubmissionDetails.asBuiltSubmissionChecklistItems"
                        :key="item.id">
                  <v-list-tile v-show="ahjPermit.asBuiltSubmissionDetails.asBuiltSubmissionChecklistItems.length > 0"
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
              <div class="empty-list"
                   v-show="ahjPermit.asBuiltSubmissionDetails.asBuiltSubmissionChecklistItems.length < 1">
                This checklist doesn't have any items
              </div>
            </v-card>
            <v-textarea label="As-Built Submission Instructions" box auto-grow
                        style="margin-top: 30px"
                        v-model="ahjPermit.asBuiltSubmissionDetails.submittalMethod">
            </v-textarea>
          </v-card-text>
        </v-card>
      </v-flex>

      <!-- FOURTH COLUMN -->
      <v-flex xs12 md3 mb-3 class="padded-sides">
        <!-- FOLLOW-UP / APPROVAL DETAILS -->
        <v-card class="mb-3">
          <v-card-title class="info white--text font-weight-bold">
            Follow-up / Approval Details
          </v-card-title>
          <v-card-text>
            <v-text-field v-model="ahjPermit.followUpApprovalDetails.approvalTimeline"
                          label="Approval Timeline" box></v-text-field>
            <v-text-field label="Fee Amount" prefix="$" box type="number" step="0.01" min="0.00"
                          v-model="ahjPermit.followUpApprovalDetails.feeAmount"
            ></v-text-field>
            <v-select label="Payment Method" :items="submittalMethods" box
                      v-model="ahjPermit.followUpApprovalDetails.paymentMethod"
            ></v-select>
            <v-text-field v-model="ahjPermit.followUpApprovalDetails.documentsAvailability"
                          label="When are documents available?" box></v-text-field>
          </v-card-text>
        </v-card>

        <!-- DELIVERY DETAILS -->
        <v-card class="mb-3">
          <v-card-title class="info white--text font-weight-bold">
            Delivery Details
          </v-card-title>
          <v-card-text>
            <v-select label="Pickup Method" :items="submittalMethods" box
                      v-model="ahjPermit.deliveryDetails.pickupMethod"
            ></v-select>
            <v-text-field label="Fee Amount" prefix="$" box type="number" step="0.01" min="0.00"
                          v-model="ahjPermit.deliveryDetails.feeAmount"
            ></v-text-field>
            <v-select label="Payment Method" :items="submittalMethods" box
                      v-model="ahjPermit.deliveryDetails.paymentMethod"
            ></v-select>
            <v-card class="mb-4">
              <v-toolbar class="info">
                <v-toolbar-title class="white--text font-weight-bold"
                                 title="Documents Required for Inspection">
                  Documents Required for Inspection
                </v-toolbar-title>
                <v-spacer></v-spacer>
                <v-btn icon color="#ddd" style="border-radius: 3px"
                       @click="addInspectionDocument()">
                  <v-icon>add</v-icon>
                </v-btn>
              </v-toolbar>
              <v-list v-show="ahjPermit.deliveryDetails.documents.length > 0"
                      v-for="document in ahjPermit.deliveryDetails.documents"
                      :key="document.id">
                <v-list-tile v-bind:title="document.name">
                  <v-list-tile-content>
                    <v-list-tile-title>
                      <a @click="downloadInspectionDocument(document.id)" class="list-link">{{document.name}}</a>
                    </v-list-tile-title>
                  </v-list-tile-content>
                  <v-list-tile-action>
                    <v-icon small class="mr-3" @click="deleteInspectionDocument(document.id)">delete</v-icon>
                  </v-list-tile-action>
                </v-list-tile>
              </v-list>
              <div class="empty-list" v-show="ahjPermit.deliveryDetails.documents.length < 1">
                No documents uploaded
              </div>
            </v-card>
            <v-textarea v-model="ahjPermit.deliveryDetails.deliveryInstructions"
                        label="Delivery Instructions" auto-grow box></v-textarea>
          </v-card-text>
        </v-card>

        <!-- PERMITTING CYCLE TIMES -->
        <v-card style="overflow-x: auto">
          <v-card-title class="info white--text font-weight-bold">
            Permitting Cycle Times
          </v-card-title>
          <v-card-text>
            <v-select label="Viewing Data For:" :items="timePeriods" box
                      v-model="permittingCycleTimes.timePeriod"
                      @change="setTimePeriodDates()"
            ></v-select>
            <p style="margin: -15px 0">{{permittingCycleTimes.startDate}} to {{permittingCycleTimes.endDate}}</p>
          </v-card-text>
          <table class="pa-3" style="width: 100%">
            <thead>
              <tr>
                <th>{{ permittingCycleTimes.headers.approvedHeaders[0] }}</th>
                <th style="text-align: center" class="pr-1">{{ permittingCycleTimes.headers.approvedHeaders[1] }}</th>
                <th style="text-align: center">{{ permittingCycleTimes.headers.approvedHeaders[2] }}</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>{{ permittingCycleTimes.headers.approvedSubheaders[0] }}</td>
                <td style="text-align: center">{{ permittingCycleTimes.data.approvedPermits.permits.avgTime }}</td>
                <td style="text-align: center">{{ permittingCycleTimes.data.approvedPermits.asBuilts.avgTime }}</td>
              </tr>
              <tr>
                <td>{{ permittingCycleTimes.headers.approvedSubheaders[1] }}</td>
                <td style="text-align: center">{{ permittingCycleTimes.data.approvedPermits.permits.medianTime }}</td>
                <td style="text-align: center">{{ permittingCycleTimes.data.approvedPermits.asBuilts.medianTime }}</td>
              </tr>
              <tr>
                <td>{{ permittingCycleTimes.headers.approvedSubheaders[2] }}</td>
                <td style="text-align: center">{{ permittingCycleTimes.data.approvedPermits.permits.approvals }}</td>
                <td style="text-align: center">{{ permittingCycleTimes.data.approvedPermits.asBuilts.approvals }}</td>
              </tr>
            </tbody>
            <thead>
              <tr>
                <th>{{ permittingCycleTimes.headers.pendingHeaders[0] }}</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>{{ permittingCycleTimes.headers.pendingSubheaders[0] }}</td>
                <td style="text-align: center">{{ permittingCycleTimes.data.pendingPermits.permits.avgAge }}</td>
                <td style="text-align: center">{{ permittingCycleTimes.data.pendingPermits.asBuilts.avgAge }}</td>
              </tr>
              <tr>
                <td>{{ permittingCycleTimes.headers.pendingSubheaders[1] }}</td>
                <td style="text-align: center">{{ permittingCycleTimes.data.pendingPermits.permits.medianAge }}</td>
                <td style="text-align: center">{{ permittingCycleTimes.data.pendingPermits.asBuilts.medianAge }}</td>
              </tr>
              <tr>
                <td>{{ permittingCycleTimes.headers.pendingSubheaders[2] }}</td>
                <td style="text-align: center">{{ permittingCycleTimes.data.pendingPermits.permits.maxAge }}</td>
                <td style="text-align: center">{{ permittingCycleTimes.data.pendingPermits.asBuilts.maxAge }}</td>
              </tr>
            </tbody>
          </table>
        </v-card>
      </v-flex>
    </v-layout>

    <v-layout row wrap>
      <h1 class="pb-2 mb-4" style="border-bottom: 1px solid #ccc; width: 100%;">Links and Contacts</h1>
      <!-- FIRST COLUMN -->
      <v-flex xs12 md4 mb-3 class="padded-sides">
        <v-card class="mb-4">
          <v-toolbar class="info">
            <v-toolbar-title class="white--text font-weight-bold" title="Submission Links">
              Submission Links
            </v-toolbar-title>
            <v-spacer></v-spacer>
            <v-btn icon color="#ddd" style="border-radius: 3px"
                   @click="addLink()">
              <v-icon>add</v-icon>
            </v-btn>
          </v-toolbar>
          <v-form v-show="submissionLinkAddCtrls || submissionLinkEditCtrls"
                  ref="submissionLinkForm" class="link-edit-ctrls pa-3">
            <!-- TODO: Get this working better... the dark theme isn't being applied when everything first loads -->
            <v-text-field v-model="editedLink.name" required
                          label="Name" box @keyup="checkInputs()"></v-text-field>
            <v-text-field v-model="editedLink.url" required type="url"
                          :rules="[urlRule]" @keyup="checkInputs()"
                          label="URL" box></v-text-field>
            <v-text-field v-model="editedLink.username"
                          label="Username" box></v-text-field>
            <v-text-field v-model="editedLink.password"
                          label="Password" box></v-text-field>
            <v-textarea label="Notes" auto-grow box
                        style="margin: 15px 0 -15px 0"
                        v-model="editedLink.notes">
            </v-textarea>
            <div class="link-btns">
              <a @click="resetLinkCtrls(1)"
                 class="cancel-link">Cancel</a>
              <v-btn v-show="submissionLinkEditCtrls" dark
                     @click="deleteLink(1)" class="error">
                Delete
              </v-btn>
              <!-- TODO: Get this working better... the button isn't disabled when there is just a name or just a url, but it should be disabled until both are present and the url is "valid" -->
              <v-btn @click="saveLink(1)" class="info" :dark="applyDark"
                     v-bind:disabled="!editedLink.name && !editedLink.url">
                {{submissionLinkEditCtrls ? 'Update' : 'Add'}}
              </v-btn>
            </div>
          </v-form>
          <v-list v-show="submissionLinks.length > 0" v-for="link in submissionLinks"
                  :key="link.id" class="px-2">
            <v-list-tile v-bind:title="link.name">
              <v-list-tile-content class="flex-row-center">
                <v-list-tile-action>
                  <v-icon small @click="editLink(link, 1)">edit</v-icon>
                </v-list-tile-action>
                <v-list-tile-title>
                  <a v-bind:href="link.url" class="list-link">{{link.name}}</a>
                </v-list-tile-title>
              </v-list-tile-content>
            </v-list-tile>
          </v-list>
          <div class="empty-list" v-show="submissionLinks.length < 1">
            No links found
          </div>
        </v-card>
      </v-flex>

      <!-- SECOND COLUMN -->
      <v-flex xs12 md4 mb-3 class="padded-sides">
        <v-card class="mb-4">
          <v-toolbar class="info">
            <v-toolbar-title class="white--text font-weight-bold" title="Follow-up and Delivery Links">
              Follow-up and Delivery Links
            </v-toolbar-title>
            <v-spacer></v-spacer>
            <v-btn icon color="#ddd" style="border-radius: 3px" @click="addLink(2)">
              <v-icon>add</v-icon>
            </v-btn>
          </v-toolbar>
          <v-form v-show="followUpAndDeliveryLinkAddCtrls || followUpAndDeliveryLinkEditCtrls"
                  ref="followUpAndDeliveryLinkForm" class="link-edit-ctrls pa-3">
            <v-text-field v-model="editedLink.name" required
                          label="Name" box @keyup="checkInputs()"></v-text-field>
            <v-text-field v-model="editedLink.url" required type="url"
                          :rules="[urlRule]" @keyup="checkInputs()"
                          label="URL" box></v-text-field>
            <v-text-field v-model="editedLink.username"
                          label="Username" box></v-text-field>
            <v-text-field v-model="editedLink.password"
                          label="Password" box></v-text-field>
            <v-textarea label="Notes" auto-grow box
                        style="margin: 15px 0 -15px 0"
                        v-model="editedLink.notes">
            </v-textarea>
            <div class="link-btns">
              <a @click="resetLinkCtrls(2)"
                 class="cancel-link">Cancel</a>
              <v-btn v-show="followUpAndDeliveryLinkEditCtrls" dark
                     @click="deleteLink(2)" class="error">
                Delete
              </v-btn>
              <v-btn @click="saveLink(2)" class="info" :dark="applyDark"
                     v-bind:disabled="!editedLink.name && !editedLink.url">
                {{followUpAndDeliveryLinkEditCtrls ? 'Update' : 'Add'}}
              </v-btn>
            </div>
          </v-form>
          <v-list v-show="followUpAndDeliveryLinks.length > 0" v-for="link in followUpAndDeliveryLinks"
                  :key="link.id" class="px-2">
            <v-list-tile v-bind:title="link.name">
              <v-list-tile-content class="flex-row-center">
                <v-list-tile-action>
                  <v-icon small @click="editLink(link, 2)">edit</v-icon>
                </v-list-tile-action>
                <v-list-tile-title>
                  <a v-bind:href="link.url" class="list-link">{{link.name}}</a>
                </v-list-tile-title>
              </v-list-tile-content>
            </v-list-tile>
          </v-list>
          <div class="empty-list" v-show="followUpAndDeliveryLinks.length < 1">
            No links found
          </div>
        </v-card>
      </v-flex>

      <!-- THIRD COLUMN -->
      <v-flex xs12 md4 mb-3 class="padded-sides">
        <v-card class="mb-4">
          <v-toolbar class="info">
            <v-toolbar-title class="white--text font-weight-bold" title="Servicing FOT's">
              Servicing FOT's
            </v-toolbar-title>
          </v-toolbar>
          <v-list v-show="servicingFots.length > 0" v-for="fot in servicingFots"
                  :key="fot.officeId" class="px-2">
            <v-list-tile v-bind:title="fot.office">
              <v-list-tile-content class="flex-row-center">
                <v-list-tile-title>
                  <a class="list-link">{{fot.office}}</a>
                </v-list-tile-title>
              </v-list-tile-content>
            </v-list-tile>
          </v-list>
          <div class="empty-list" v-show="servicingFots.length < 1">
            No Servicing FOT's found
          </div>
        </v-card>
      </v-flex>
    </v-layout>

  </v-layout>
</template>

<script>
  import draggable from 'vuedraggable'
  import max from 'lodash.max'
  import moment from 'moment'

  export default {
    name: 'ahjPermit',
    components: {
      draggable
    },
    data: () => ({
      submittalMethods: ['', 'Online', 'In-person', 'Other'],
      approvalRequiredOptions: ['', 'No', 'Yes', 'Unknown', 'Other'],
      timePeriods: [
        'This Week',
        'This Period',
        'This Year',
        'Last Week',
        'Last Period',
        'Last Year',
        'Last Six Weeks'
      ],
      permittingCycleTimes: {
        timePeriod: 'Last Six Weeks',
        startDate: moment().subtract(6, 'w').format('MM/DD/YYYY'),
        endDate: moment().format('MM/DD/YYYY'),
        headers: {
          approvedHeaders: ['Approved Permits', 'Permits', 'As-Builts'],
          approvedSubheaders: ['Average Cycle Time', 'Median Cycle Time', '# of Approvals'],
          pendingHeaders: ['Permits Pending Approval'],
          pendingSubheaders: ['Average Age', 'Median Age', 'Max Age']
        },
        data: {
          approvedPermits: {
            permits: {
              avgTime: 0,
              medianTime: 0,
              approvals: 0
            },
            asBuilts: {
              avgTime: 0,
              medianTime: 0,
              approvals: 0
            }
          },
          pendingPermits: {
            permits: {
              avgAge: 0,
              medianAge: 0,
              maxAge: 0
            },
            asBuilts: {
              avgAge: 0,
              medianAge: 0,
              maxAge: 0
            }
          }
        }
      },
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
      asBuiltSubmissionChecklistAddCtrls: false,
      asBuiltSubmissionChecklistEditCtrls: false,
      asBuiltSubmissionChecklistEditedIndex: -1,
      editedAsBuiltSubmissionChecklistItem: {
        details: ''
      },
      asBuiltSubmissionCheckListItemToDelete: '',
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
              details: 'Fee needs to be waived'
            },
            {
              id: 2,
              details: 'Customer will pay by credit card'
            }
          ],
          revisionSubmissionInstructions: null
        },
        asBuiltSubmissionDetails: {
          submittalMethod: null,
          feeAmount: null,
          paymentMethod: null,
          asBuiltSubmissionChecklistItems: [],
          asBuiltSubmissionInstructions: null
        },
        followUpApprovalDetails: {
          approvalTimeline: null,
          feeAmount: null,
          paymentMethod: null,
          documentsAvailability: null
        },
        deliveryDetails: {
          pickupMethod: null,
          feeAmount: null,
          paymentMethod: null,
          documents: [
            {
              id: 1,
              name: 'instructions.txt'
            },
            {
              id: 2,
              name: 'importantDocument.docx'
            }
          ],
          deliveryInstructions: null
        }
      },
      applyDark: false,
      submissionLinkAddCtrls: false,
      submissionLinkEditCtrls: false,
      followUpAndDeliveryLinkAddCtrls: false,
      followUpAndDeliveryLinkEditCtrls: false,
      linkEditedIndex: -1,
      editedLink: {
        id: '',
        type: '',
        name: '',
        url: '',
        username: '',
        password: '',
        notes: ''
      },
      submissionLinks: [
        {
          id: 1,
          type: 1,
          name: 'Google',
          url: 'https://www.google.com/',
          username: 'Username',
          password: 'Password',
          notes: 'Testing'
        },
        {
          id: 2,
          type: 1,
          name: 'Outlook',
          url: 'https://www.outlook.com/',
          username: 'Username',
          password: 'Password',
          notes: 'Testing again'
        }
      ],
      followUpAndDeliveryLinks: [
        {
          id: 1,
          type: 2,
          name: 'Outlook',
          url: 'https://www.outlook.com/',
          username: 'Username',
          password: 'Password',
          notes: 'Testing again'
        },
        {
          id: 2,
          type: 2,
          name: 'Google',
          url: 'https://www.google.com/',
          username: 'Username',
          password: 'Password',
          notes: 'Testing'
        }
      ],
      servicingFots: [
        {
          id: 1,
          firstName: 'Test',
          lastName: 'Guy 1',
          fullName: 'Test Guy 1',
          office: 'Test Office 1',
          officeId: 1
        },
        {
          id: 2,
          firstName: 'Test',
          lastName: 'Guy 2',
          fullName: 'Test Guy 2',
          office: 'Test Office 2',
          officeId: 2
        },
        {
          id: 3,
          firstName: 'Test',
          lastName: 'Guy 3',
          fullName: 'Test Guy 3',
          office: 'Test Office 3',
          officeId: 3
        }
      ]
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
        this.editedSubmissionChecklistItem.details = ''
        if (this.submissionChecklistEditCtrls) {
          this.submissionChecklistEditCtrls = !this.submissionChecklistEditCtrls
        }
        this.submissionChecklistAddCtrls = true
      },
      editSubmissionChecklistItem(item) {
        if (this.submissionChecklistAddCtrls) {
          this.submissionChecklistAddCtrls = false
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
            this.ahjPermit.submissionDetails.submissionChecklistItems.forEach(item => idsArray.push(item.id))
            this.editedSubmissionChecklistItem.id = max(idsArray) + 1
          } else {
            this.editedSubmissionChecklistItem.id = 1
          }
          this.ahjPermit.submissionDetails.submissionChecklistItems.push(this.editedSubmissionChecklistItem)
          this.submissionChecklistAddCtrls = false
        }
      },
      addInspectionDocument() {
        console.log("Adding inspection document...")
      },
      deleteInspectionDocument(documentId) {
        console.log("Deleting inspection document with id " + documentId + "...")
      },
      downloadInspectionDocument(documentId) {
        console.log("Downloading inspection document with id " + documentId + "...")
      },
      setTimePeriodDates() {
        switch (this.permittingCycleTimes.timePeriod) {
          case 'This Week':
            this.permittingCycleTimes.startDate = moment().startOf('w').format('MM/DD/YYYY')
            this.permittingCycleTimes.endDate = moment().format('MM/DD/YYYY')
            break
          case 'This Period':
            this.permittingCycleTimes.startDate = moment().startOf('W').format('MM/DD/YYYY')
            this.permittingCycleTimes.endDate = moment().startOf('w').add(4, 'w').format('MM/DD/YYYY')
            break
          case 'This Year':
            this.permittingCycleTimes.startDate = moment().startOf('y').format('MM/DD/YYYY')
            this.permittingCycleTimes.endDate = moment().format('MM/DD/YYYY')
            break
          case 'Last Week':
            this.permittingCycleTimes.startDate = moment().startOf('w').subtract(1, 'w').format('MM/DD/YYYY')
            this.permittingCycleTimes.endDate = moment().endOf('W').subtract(1, 'w').format('MM/DD/YYYY')
            break
          case 'Last Period':
            this.permittingCycleTimes.startDate = moment().startOf('W').subtract(4, 'w').format('MM/DD/YYYY')
            this.permittingCycleTimes.endDate = moment().startOf('w').format('MM/DD/YYYY')
            break
          case 'Last Year':
            this.permittingCycleTimes.startDate = moment().startOf('y').subtract(1, 'y').format('MM/DD/YYYY')
            this.permittingCycleTimes.endDate = moment().endOf('y').subtract(1, 'y').format('MM/DD/YYYY')
            break
          case 'Last Six Weeks':
            this.permittingCycleTimes.startDate = moment().subtract(6, 'w').format('MM/DD/YYYY')
            this.permittingCycleTimes.endDate = moment().format('MM/DD/YYYY')
            break
          default:
            this.permittingCycleTimes.startDate = moment().subtract(6, 'w').format('MM/DD/YYYY')
            this.permittingCycleTimes.endDate = moment().format('MM/DD/YYYY')
            break
        }
      },
      resetLinkCtrls(type) {
        switch (type) {
          case 1:
            this.submissionLinkAddCtrls = false
            this.submissionLinkEditCtrls = false
            this.$refs.submissionLinkForm.reset()
            break
          case 2:
            this.followUpAndDeliveryLinkAddCtrls = false
            this.followUpAndDeliveryLinkEditCtrls = false
            this.$refs.followUpAndDeliveryLinkForm.reset()
            break
        }
      },
      addLink(type) {
        this.submissionLinkEditCtrls = false
        this.followUpAndDeliveryLinkEditCtrls = false

        switch (type) {
          case 1:
            this.submissionLinkAddCtrls = true
            this.followUpAndDeliveryLinkAddCtrls = false
            this.$refs.submissionLinkForm.reset()
            break
          case 2:
            this.submissionLinkAddCtrls = false
            this.followUpAndDeliveryLinkAddCtrls = true
            this.$refs.followUpAndDeliveryLinkForm.reset()
        }
      },
      editLink(link, type) {
        this.checkInputs()
        this.submissionLinkAddCtrls = false
        this.followUpAndDeliveryLinkAddCtrls = false

        switch (type) {
          case 1:
            this.submissionLinkEditCtrls = true
            this.followUpAndDeliveryLinkEditCtrls = false
            this.linkEditedIndex = this.submissionLinks.indexOf(link)
            break
          case 2:
            this.submissionLinkEditCtrls = false
            this.followUpAndDeliveryLinkEditCtrls = true
            this.linkEditedIndex = this.followUpAndDeliveryLinks.indexOf(link)
            break
        }
        this.editedLink = Object.assign({}, link)
        this.editedLink.type = type
      },
      deleteLink(type) {
        switch (type) {
          case 1:
            this.submissionLinks.splice(this.linkEditedIndex, 1)
            this.submissionLinkEditCtrls = false
            break
          case 2:
            this.followUpAndDeliveryLinks.splice(this.linkEditedIndex, 1)
            this.followUpAndDeliveryLinkEditCtrls = false
            break
        }
      },
      saveLink(type) {
        switch (type) {
          case 1:
            if (this.linkEditedIndex > -1) {
              Object.assign(this.submissionLinks[this.linkEditedIndex], this.editedLink)
              this.submissionLinkEditCtrls = false
            } else {
              if (this.submissionLinks.length > 0) {
                let idsArray = []
                this.submissionLinks.forEach(item => idsArray.push(item.id))
                this.editedLink.id = max(idsArray) + 1
              } else {
                this.editedLink.id = 1
              }
              this.submissionLinks.push(this.editedLink)
              this.submissionLinkAddCtrls = false
            }
            break
          case 2:
            if (this.linkEditedIndex > -1) {
              Object.assign(this.followUpAndDeliveryLinks[this.linkEditedIndex], this.editedLink)
              this.followUpAndDeliveryLinkEditCtrls = false
            } else {
              if (this.followUpAndDeliveryLinks.length > 0) {
                let idsArray = []
                this.followUpAndDeliveryLinks.forEach(item => idsArray.push(item.id))
                this.editedLink.id = max(idsArray) + 1
              } else {
                this.editedLink.id = 1
              }
              this.followUpAndDeliveryLinks.push(this.editedLink)
              this.followUpAndDeliveryLinkAddCtrls = false
            }
            break
        }
      },
      urlRule(url) {
        if (url && (!url.includes('http://') && !url.includes('https://'))) {
          return 'Valid URL is required'
        } else {
          return true
        }
      },
      checkInputs() {
        this.applyDark = this.editedLink.name !== '' || this.editedLink.url !== ''
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
  .v-card__title,
  .v-toolbar__title {
    font-size: 1em !important;
  }
  .v-text-field, .v-select, .v-input /deep/ label {
    font-size: 0.95em !important;
  }
  .v-list__tile__title {
    font-size: 0.8em !important;
  }
  .checklist-btns,
  .link-btns {
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
  .empty-list {
    padding: 20px;
    font-size: 0.95em;
  }
  .list-link {
    text-decoration: none;
  }
  .cancel-link:hover,
  .list-link:hover {
    text-decoration: underline;
  }
  .flex-row-center {
    display: flex;
    flex-flow: row nowrap;
    align-items: center;
  }
</style>