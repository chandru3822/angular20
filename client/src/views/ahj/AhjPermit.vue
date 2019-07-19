<!--suppress CssInvalidPseudoSelector -->
<template>
  <v-layout column nowrap fill-height>
    <v-flex xs12 text-xs-right fill-height>
      <a @click="resetForm()" class="cancel-link" style="margin-right: 10px">Cancel</a>
      <v-btn id="save-btn" color="primaryButton" class="white--text" @click="saveAhjPermit()">Save</v-btn>
    </v-flex>

    <v-layout row wrap>
      <!-- FIRST COLUMN -->
      <v-flex xs12 md3 mb-3 class="padded-sides">
        <!-- SUBMISSION DETAILS -->
        <v-card>
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Submission Details
          </v-card-title>
          <v-card-text class="mt-4">
            <v-select label="Submittal Method" :items="submittalMethods" filled
                      v-model="ahjPermit.submittalTypeId"
            ></v-select>
            <v-select label="HOA Approval Required for Submission" filled
                      :items="approvalRequiredOptions"
                      v-model="ahjPermit.hoaApprovalRequiredTypeId"
            ></v-select>
            <v-select label="NEM Approval Required for Submission" filled
                      :items="approvalRequiredOptions"
                      v-model="ahjPermit.nemApprovalRequiredTypeId"
            ></v-select>
            <v-text-field v-model="ahjPermit.depositAmount" type="number"
                          label="Deposit Amount" prepend-inner-icon="attach_money"
                          filled step="0.01" min="0.00"
            ></v-text-field>
            <v-select label="Payment Method" :items="submittalMethods" filled
                      v-model="ahjPermit.submissionPaymentTypeId"
            ></v-select>
            <div class="flex-row">
              <v-text-field v-model="ahjPermit.businessLicense"
                            label="Business License" filled
                            style="width: 50%; margin-right: 20px;"></v-text-field>
              <v-flex style="width: 50%">
                <v-menu v-model="businessLicenseMenu" :close-on-content-click="false"
                        :nudge-right="40" transition="scale-transition" offset-y
                        full-width min-width="290px">
                  <template #activator="{on}">
                    <v-text-field v-model="ahjPermit.businessLicenseExpirationDate" filled
                                  label="mm/dd/yyyy" append-icon="event" readonly v-on="on">
                    </v-text-field>
                  </template>
                  <v-date-picker v-model="ahjPermit.businessLicenseExpirationDate" @input="businessLicenseMenu=false"></v-date-picker>
                </v-menu>
              </v-flex>
            </div>
            <div class="flex-row">
              <v-text-field v-model="ahjPermit.contractorLicense"
                            label="Contractor License" filled
                            style="width: 50%; margin-right: 20px;"></v-text-field>
              <v-flex style="width: 50%">
                <v-menu v-model="contractorLicenseMenu" :close-on-content-click="false"
                        :nudge-right="40" transition="scale-transition" offset-y
                        full-width min-width="290px">
                  <template #activator="{on}">
                    <v-text-field label="mm/dd/yyyy" append-icon="event" readonly
                                  v-on="on" filled
                                  v-model="ahjPermit.contractorLicenseExpirationDate"></v-text-field>
                  </template>
                  <v-date-picker v-model="ahjPermit.contractorLicenseExpirationDate" @input="contractorLicenseMenu=false"></v-date-picker>
                </v-menu>
              </v-flex>
            </div>
            <div class="flex-row">
              <v-text-field v-model="ahjPermit.otherLicense"
                            label="Other License" filled
                            style="width: 50%; margin-right: 20px;"></v-text-field>
              <v-flex style="width: 50%">
                <v-menu v-model="otherLicenseMenu" :close-on-content-click="false"
                        :nudge-right="40" transition="scale-transition"
                        offset-y full-width min-width="290px">
                  <template #activator="{on}">
                    <v-text-field v-model="ahjPermit.otherLicenseExpirationDate"
                                  label="mm/dd/yyyy" append-icon="event" readonly
                                  v-on="on" filled></v-text-field>
                  </template>
                  <v-date-picker v-model="ahjPermit.otherLicenseExpirationDate"
                                 @input="otherLicenseMenu=false"></v-date-picker>
                </v-menu>
              </v-flex>
            </div>
            <AhjChecklist
              title="Submission Checklist"
              :typeId="1"
              :permitId="ahjPermit.id"
              :checklistItems="ahjPermit.submissionChecklist"
            ></AhjChecklist>
            <v-textarea label="Submission Instructions" filled auto-grow
                        v-model="ahjPermit.submissionNote"
                        style="margin-top: 30px"></v-textarea>
          </v-card-text>
        </v-card>
      </v-flex>

      <!-- SECOND COLUMN -->
      <v-flex xs12 md3 mb-3 class="padded-sides">
        <!-- REVISION SUBMISSION DETAILS -->
        <v-card>
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Revision Submission Details
          </v-card-title>
          <v-card-text class="mt-4">
            <v-select label="Submittal Method" :items="submittalMethods" filled
                      v-model="ahjPermit.revisionSubmittalTypeId"
            ></v-select>
            <v-text-field label="Fee Amount" prepend-inner-icon="attach_money"
                          filled type="number" step="0.01" min="0.00"
                          v-model="ahjPermit.revisionFeeAmount"
            ></v-text-field>
            <v-select label="Payment Method" :items="submittalMethods" filled
                      v-model="ahjPermit.revisionPaymentTypeId"
            ></v-select>
            <AhjChecklist
              title="Revision Submission Checklist"
              :typeId="2"
              :permitId="ahjPermit.id"
              :checklist-items="ahjPermit.revisionChecklist"
            ></AhjChecklist>
            <v-textarea label="Revision Submission Instructions" filled auto-grow
                        style="margin-top: 30px"
                        v-model="ahjPermit.revisionNote">
            </v-textarea>
          </v-card-text>
        </v-card>
      </v-flex>

      <!-- THIRD COLUMN -->
      <v-flex xs12 md3 mb-3 class="padded-sides">
        <!-- AS-BUILT SUBMISSION DETAILS -->
        <v-card>
          <v-card-title class="primaryCustom white--text font-weight-bold">
            As-Built Submission Details
          </v-card-title>
          <v-card-text class="mt-4">
            <v-select label="Submittal Method" :items="submittalMethods" filled
                      v-model="ahjPermit.asBuiltSubmittalTypeId"
            ></v-select>
            <v-text-field label="Fee Amount" prepend-inner-icon="attach_money"
                          filled type="number" step="0.01" min="0.00"
                          v-model="ahjPermit.asBuiltFeeAmount"
            ></v-text-field>
            <v-select label="Payment Method" :items="submittalMethods" filled
                      v-model="ahjPermit.asBuiltPaymentTypeId"
            ></v-select>
            <AhjChecklist
              title="As-Built Submission Checklist"
              :typeId="3"
              :permitId="ahjPermit.id"
              :checklist-items="ahjPermit.asBuiltChecklist"
            ></AhjChecklist>
            <v-textarea label="As-Built Submission Instructions" filled auto-grow
                        style="margin-top: 30px"
                        v-model="ahjPermit.asBuiltNote">
            </v-textarea>
          </v-card-text>
        </v-card>
      </v-flex>

      <!-- FOURTH COLUMN -->
      <v-flex xs12 md3 mb-3 class="padded-sides">
        <!-- FOLLOW-UP / APPROVAL DETAILS -->
        <v-card class="mb-3">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Follow-up / Approval Details
          </v-card-title>
          <v-card-text class="mt-4">
            <v-text-field v-model="ahjPermit.approvalTimeline"
                          label="Approval Timeline" filled></v-text-field>
            <v-text-field label="Fee Amount" prepend-inner-icon="attach_money"
                          filled type="number" step="0.01" min="0.00"
                          v-model="ahjPermit.followUpFeeAmount"
            ></v-text-field>
            <v-select label="Payment Method" :items="submittalMethods" filled
                      v-model="ahjPermit.followUpPaymentTypeId"
            ></v-select>
            <v-text-field v-model="ahjPermit.documentsAvailable"
                          label="When are documents available?" filled></v-text-field>
          </v-card-text>
        </v-card>

        <!-- DELIVERY DETAILS -->
        <v-card class="mb-3">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Delivery Details
          </v-card-title>
          <v-card-text class="mt-4">
            <v-select label="Pickup Method" :items="submittalMethods" filled
                      v-model="ahjPermit.deliveryPickupTypeId"
            ></v-select>
            <v-text-field label="Fee Amount" prepend-inner-icon="attach_money"
                          filled type="number" step="0.01" min="0.00"
                          v-model="ahjPermit.deliveryFeeAmount"
            ></v-text-field>
            <v-select label="Payment Method" :items="submittalMethods" filled
                      v-model="ahjPermit.deliveryPaymentTypeId"
            ></v-select>
            <v-card class="mb-4">
              <v-toolbar class="primaryCustom">
                <v-toolbar-title class="white--text font-weight-bold"
                                 title="Documents Required for Inspection">
                  Documents Required for Inspection
                </v-toolbar-title>
                <v-spacer></v-spacer>
                <v-btn icon color="#ddd" style="border-radius: 3px"
                       @click="addInspectionDocument()">
                  <v-icon class="white--text">add</v-icon>
                </v-btn>
              </v-toolbar>
              <v-list v-show="documents.length > 0"
                      v-for="document in documents"
                      :key="document.id">
                <v-list-item :title="document.name">
                  <v-list-item-content>
                    <v-list-item-title>
                      <a @click="downloadInspectionDocument(document.id)" class="list-link">{{document.name}}</a>
                    </v-list-item-title>
                  </v-list-item-content>
                  <v-list-item-action>
                    <v-icon small class="mr-3" @click="deleteInspectionDocument(document.id)">delete</v-icon>
                  </v-list-item-action>
                </v-list-item>
              </v-list>
              <div class="empty-list" v-show="documents.length < 1">
                No documents uploaded
              </div>
            </v-card>
            <v-textarea v-model="ahjPermit.deliveryNote"
                        label="Delivery Instructions" auto-grow filled></v-textarea>
          </v-card-text>
        </v-card>

        <!-- PERMITTING CYCLE TIMES -->
        <v-card style="overflow-x: auto">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Permitting Cycle Times
          </v-card-title>
          <v-card-text class="mt-4">
            <v-select label="Viewing Data For:" :items="timePeriods" filled
                      v-model="permittingCycleTimes.timePeriod"
                      @change="setTimePeriodDates()"
            ></v-select>
            <p style="margin: -15px 0">{{permittingCycleTimes.startDate}} to {{permittingCycleTimes.endDate}}</p>
          </v-card-text>
          <table class="pa-3" style="width: 100%">
            <thead>
              <tr>
                <th>{{ permittingCycleTimes.headers.approvedHeaders[0] }}</th>
                <th class="pr-1 centered">{{ permittingCycleTimes.headers.approvedHeaders[1] }}</th>
                <th class="centered">{{ permittingCycleTimes.headers.approvedHeaders[2] }}</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>{{ permittingCycleTimes.headers.approvedSubheaders[0] }}</td>
                <td class="centered">{{ permittingCycleTimes.data.approvedPermits.permits.avgTime }}</td>
                <td class="centered">{{ permittingCycleTimes.data.approvedPermits.asBuilts.avgTime }}</td>
              </tr>
              <tr>
                <td>{{ permittingCycleTimes.headers.approvedSubheaders[1] }}</td>
                <td class="centered">{{ permittingCycleTimes.data.approvedPermits.permits.medianTime }}</td>
                <td class="centered">{{ permittingCycleTimes.data.approvedPermits.asBuilts.medianTime }}</td>
              </tr>
              <tr>
                <td>{{ permittingCycleTimes.headers.approvedSubheaders[2] }}</td>
                <td class="centered">{{ permittingCycleTimes.data.approvedPermits.permits.approvals }}</td>
                <td class="centered">{{ permittingCycleTimes.data.approvedPermits.asBuilts.approvals }}</td>
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
        <AhjPermitLinks
          title="Submission Links"
          :typeId="4"
          :permitId="ahjPermit.id"
          :links="ahjPermit.submissionLinks"
        ></AhjPermitLinks>

        <v-card class="pb-2">
          <v-toolbar class="primaryCustom mb-2">
            <v-toolbar-title class="white--text font-weight-bold" title="Submission Contacts">
              Submission Contacts
            </v-toolbar-title>
            <v-spacer></v-spacer>
            <v-btn icon color="#ddd" style="border-radius: 3px">
              <v-icon v-show="!submissionContactAddCtrls" @click="addContact(1)" class="white--text">add</v-icon>
              <v-icon v-show="submissionContactAddCtrls"
                      @click="submissionContactAddCtrls=false" class="white--text">remove</v-icon>
            </v-btn>
          </v-toolbar>
          <v-form v-show="submissionContactAddCtrls || submissionContactEditCtrls"
                  ref="submissionContactForm" class="pa-3">
            <v-text-field v-model="editedContact.name" required label="Name" filled></v-text-field>
            <v-text-field v-model="editedContact.title" label="Title" filled></v-text-field>
            <v-text-field v-model="editedContact.phoneNumber" label="Phone" filled></v-text-field>
            <v-text-field v-model="editedContact.email" label="Email" type="email" filled></v-text-field>
            <v-text-field v-model="editedContact.hours" label="Hours" filled></v-text-field>
            <v-textarea label="Address" auto-grow filled
                        v-model="editedContact.address">
            </v-textarea>
            <v-textarea label="Notes" auto-grow filled
                        v-model="editedContact.notes">
            </v-textarea>
            <div class="link-btns">
              <a @click="resetContactCtrls(1)"
                 class="cancel-link">Cancel</a>
              <v-btn v-show="submissionContactEditCtrls" dark
                     @click="deleteContact(1)" class="error">
                Delete
              </v-btn>
              <v-btn @click="saveContact(1)" color="primaryButton" class="white--text"
                     :disabled="!editedContact.name">
                {{submissionContactEditCtrls ? 'Update' : 'Add'}}
              </v-btn>
            </div>
          </v-form>
          <div v-for="(contact, index) in ahjPermit.submissionContacts" :key="contact.id"
               v-show="ahjPermit.submissionContacts.length > 0" class="px-3 pt-1 pb-1">
            <dl class="horizontal-dl">
              <dt v-if="contact.name" class="font-weight-bold">Name</dt>
              <dd v-if="contact.name">{{contact.name}}</dd>
              <dt v-if="contact.title" class="font-weight-bold">Title</dt>
              <dd v-if="contact.title">{{contact.title}}</dd>
              <dt v-if="contact.phoneNumber" class="font-weight-bold">Phone</dt>
              <dd v-if="contact.phoneNumber">{{contact.phoneNumber}}</dd>
              <dt v-if="contact.email" class="font-weight-bold">Email</dt>
              <dd v-if="contact.email">{{contact.email}}</dd>
              <dt v-if="contact.hours" class="font-weight-bold">Hours</dt>
              <dd v-if="contact.hours">{{contact.hours}}</dd>
              <dt v-if="contact.address" class="font-weight-bold">Address</dt>
              <dd v-if="contact.address">{{contact.address}}</dd>
              <dt v-if="contact.notes"></dt>
              <dd v-if="contact.notes" class="pa-2" style="background-color: #eee">{{contact.notes}}</dd>
              <dt></dt>
              <dd>
                <v-btn small color="primaryButton"
                       @click="editContact(contact, 1)"
                       class="pa-0 mx-0 mt-2 text-capitalize white--text">Edit</v-btn>
              </dd>
            </dl>
            <v-spacer v-if="index !== ahjPermit.submissionContacts.length - 1"
                      class="mt-2" style="border-bottom: 1px solid #ccc"></v-spacer>
          </div>
          <div class="empty-list" v-show="ahjPermit.submissionContacts.length < 1">
            No contacts found
          </div>
        </v-card>
      </v-flex>

      <!-- SECOND COLUMN -->
      <v-flex xs12 md4 mb-3 class="padded-sides">
        <AhjPermitLinks
          title="Follow-up and Delivery Links"
          :typeId="5"
          :permitId="ahjPermit.id"
          :links="ahjPermit.followUpLinks"
        ></AhjPermitLinks>

        <v-card class="pb-2">
          <v-toolbar class="primaryCustom mb-2">
            <v-toolbar-title class="white--text font-weight-bold" title="Print Locations">
              Print Locations
            </v-toolbar-title>
            <v-spacer></v-spacer>
            <v-btn icon color="#ddd" style="border-radius: 3px">
              <v-icon v-show="!printLocationAddCtrls" @click="addPrintLocation()" class="white--text">add</v-icon>
              <v-icon v-show="printLocationAddCtrls"
                      @click="printLocationAddCtrls=false" class="white--text">remove</v-icon>
            </v-btn>
          </v-toolbar>
          <v-form v-show="printLocationAddCtrls || printLocationEditCtrls"
                  ref="printLocationForm" class="pa-3">
            <v-text-field v-model="editedPrintLocation.storeName" required label="Store Name" filled></v-text-field>
            <v-text-field v-model="editedPrintLocation.storeNumber" label="Store Number" filled></v-text-field>
            <v-text-field v-model="editedPrintLocation.phone" label="Phone" filled></v-text-field>
            <v-text-field v-model="editedPrintLocation.email" label="Email" type="email" filled></v-text-field>
            <v-text-field v-model="editedPrintLocation.hours" label="Hours" filled></v-text-field>
            <v-textarea label="Address" auto-grow filled
                        v-model="editedPrintLocation.address">
            </v-textarea>
            <v-textarea label="Notes" auto-grow filled
                        v-model="editedPrintLocation.notes">
            </v-textarea>
            <div class="link-btns">
              <a @click="resetPrintLocationCtrls()"
                 class="cancel-link">Cancel</a>
              <v-btn v-show="printLocationEditCtrls" dark
                     @click="deletePrintLocation()" class="error">
                Delete
              </v-btn>
              <v-btn @click="savePrintLocation()" color="primaryButton" class="white--text"
                     :disabled="!editedPrintLocation.storeName">
                {{printLocationEditCtrls ? 'Update' : 'Add'}}
              </v-btn>
            </div>
          </v-form>
          <div v-for="(location, index) in printLocations" :key="location.id"
               v-show="printLocations.length > 0" class="px-3 pt-1 pb-1">
            <dl class="horizontal-dl">
              <dt v-if="location.storeName" class="font-weight-bold">Store Name</dt>
              <dd v-if="location.storeName">{{location.storeName}}</dd>
              <dt v-if="location.storeNumber" class="font-weight-bold">Store Number</dt>
              <dd v-if="location.storeNumber">{{location.storeNumber}}</dd>
              <dt v-if="location.phone" class="font-weight-bold">Phone</dt>
              <dd v-if="location.phone">{{location.phone}}</dd>
              <dt v-if="location.email" class="font-weight-bold">Email</dt>
              <dd v-if="location.email">{{location.email}}</dd>
              <dt v-if="location.hours" class="font-weight-bold">Hours</dt>
              <dd v-if="location.hours">{{location.hours}}</dd>
              <dt v-if="location.address" class="font-weight-bold">Address</dt>
              <dd v-if="location.address">{{location.address}}</dd>
              <dt v-if="location.notes"></dt>
              <dd v-if="location.notes" class="pa-2" style="background-color: #eee">{{location.notes}}</dd>
              <dt></dt>
              <dd>
                <v-btn small color="primaryButton"
                       @click="editPrintLocation(location, 2)"
                       class="pa-0 mx-0 mt-2 text-capitalize white--text">Edit</v-btn>
              </dd>
            </dl>
            <v-spacer v-if="index !== printLocations.length - 1"
                      class="mt-2" style="border-bottom: 1px solid #ccc"></v-spacer>
          </div>
          <div class="empty-list" v-show="printLocations.length < 1">
            No locations found
          </div>
        </v-card>
      </v-flex>

      <!-- THIRD COLUMN -->
      <v-flex xs12 md4 mb-3 class="padded-sides">
        <v-card class="mb-3">
          <v-toolbar class="primaryCustom">
            <v-toolbar-title class="white--text font-weight-bold" title="Servicing FOT's">
              Servicing FOT's
            </v-toolbar-title>
          </v-toolbar>
          <v-list v-show="servicingFots.length > 0" v-for="fot in servicingFots"
                  :key="fot.officeId" class="px-2">
            <v-list-item :title="fot.office">
              <v-list-item-content class="flex-row-center">
                <v-list-item-title>
                  <a class="list-link">{{fot.office}}</a>
                </v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </v-list>
          <div class="empty-list" v-show="servicingFots.length < 1">
            No Servicing FOT's found
          </div>
        </v-card>

        <v-card class="pb-2">
          <v-toolbar class="primaryCustom mb-2">
            <v-toolbar-title class="white--text font-weight-bold" title="Follow-up and Delivery Contacts">
              Follow-up and Delivery Contacts
            </v-toolbar-title>
            <v-spacer></v-spacer>
            <v-btn icon color="#ddd" style="border-radius: 3px">
              <v-icon v-show="!followUpContactAddCtrls" @click="addContact(2)" class="white--text">add</v-icon>
              <v-icon v-show="followUpContactAddCtrls"
                      @click="followUpContactAddCtrls=false" class="white--text">remove</v-icon>
            </v-btn>
          </v-toolbar>
          <v-form v-show="followUpContactAddCtrls || followUpContactEditCtrls"
                  ref="followUpContactForm" class="pa-3">
            <v-text-field v-model="editedContact.name" required label="Name" filled></v-text-field>
            <v-text-field v-model="editedContact.title" label="Title" filled></v-text-field>
            <v-text-field v-model="editedContact.phoneNumber" label="Phone" filled></v-text-field>
            <v-text-field v-model="editedContact.email" label="Email" type="email" filled></v-text-field>
            <v-text-field v-model="editedContact.hours" label="Hours" filled></v-text-field>
            <v-textarea label="Address" auto-grow filled
                        v-model="editedContact.address">
            </v-textarea>
            <v-textarea label="Notes" auto-grow filled
                        v-model="editedContact.notes">
            </v-textarea>
            <div class="link-btns">
              <a @click="resetContactCtrls(2)"
                 class="cancel-link">Cancel</a>
              <v-btn v-show="followUpContactEditCtrls" dark
                     @click="deleteContact(2)" class="error">
                Delete
              </v-btn>
              <v-btn @click="saveContact(2)" color="primaryButton" class="white--text"
                     :disabled="!editedContact.name">
                {{followUpContactEditCtrls ? 'Update' : 'Add'}}
              </v-btn>
            </div>
          </v-form>
          <div v-for="(contact, index) in followUpContacts" :key="contact.id"
               v-show="followUpContacts.length > 0" class="px-3 pt-1 pb-1">
            <dl class="horizontal-dl">
              <dt v-if="contact.name" class="font-weight-bold">Name</dt>
              <dd v-if="contact.name">{{contact.name}}</dd>
              <dt v-if="contact.title" class="font-weight-bold">Title</dt>
              <dd v-if="contact.title">{{contact.title}}</dd>
              <dt v-if="contact.phoneNumber" class="font-weight-bold">Phone</dt>
              <dd v-if="contact.phoneNumber">{{contact.phoneNumber}}</dd>
              <dt v-if="contact.email" class="font-weight-bold">Email</dt>
              <dd v-if="contact.email">{{contact.email}}</dd>
              <dt v-if="contact.hours" class="font-weight-bold">Hours</dt>
              <dd v-if="contact.hours">{{contact.hours}}</dd>
              <dt v-if="contact.address" class="font-weight-bold">Address</dt>
              <dd v-if="contact.address">{{contact.address}}</dd>
              <dt v-if="contact.notes"></dt>
              <dd v-if="contact.notes" class="pa-2" style="background-color: #eee">{{contact.notes}}</dd>
              <dt></dt>
              <dd>
                <v-btn small color="primaryButton"
                       @click="editContact(contact, 2)"
                       class="pa-0 mx-0 mt-2 text-capitalize white--text">Edit</v-btn>
              </dd>
            </dl>
            <v-spacer v-if="index !== followUpContacts.length - 1"
                      class="mt-2" style="border-bottom: 1px solid #ccc"></v-spacer>
          </div>
          <div class="empty-list" v-show="followUpContacts.length < 1">
            No contacts found
          </div>
        </v-card>
      </v-flex>
    </v-layout>

  </v-layout>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import max from 'lodash.max'
  import moment from 'moment'
  import AhjChecklist from './components/AhjChecklist.vue'
  import AhjPermitLinks from './components/AhjPermitLinks.vue'
  import { getRequest, deleteRequest, putRequest, postRequest } from '@/helpers/helpers'

  export default {
    name: 'ahjPermit',
    components: {
      AhjChecklist,
      AhjPermitLinks
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
      ahjPermit: {
        approvalTimeline: null,
        asBuiltChecklist: [
          // {
          //   id: 1,
          //   type: 3,
          //   details: 'Do something'
          // },
          // {
          //   id: 2,
          //   type: 3,
          //   details: 'Do something else'
          // },
          // {
          //   id: 3,
          //   type: 3,
          //   details: 'Coming up with test data is hard sometimes'
          // }
        ],
        asBuiltFeeAmount: null,
        asBuiltNote: null,
        asBuiltPaymentTypeId: null,
        asBuiltPaymentTypeOther: null,
        asBuiltSubmittalTypeId: null,
        asBuiltSubmittalTypeOther: null,
        averagePermitFee: null,
        businessLicense: null,
        businessLicenseExpirationDate: null,
        contractorLicense: null,
        contractorLicenseExpirationDate: null,
        deliveryFeeAmount: null,
        deliveryNote: null,
        deliveryPaymentTypeId: null,
        deliveryPaymentTypeOther: null,
        deliveryPickupTypeId: null,
        deliveryPickupTypeOther: null,
        depositAmount: null,
        documentsAvailable: null,
        engineeringLetterRequired: null,
        followUpContacts: [],
        followUpFeeAmount: null,
        followUpLinks: [
          // {
          //   id: 1,
          //   type: 5,
          //   name: 'Outlook',
          //   url: 'https://www.outlook.com/',
          //   username: 'Username',
          //   password: 'Password',
          //   notes: 'Testing again'
          // },
          // {
          //   id: 2,
          //   type: 5,
          //   name: 'Google',
          //   url: 'https://www.google.com/',
          //   username: 'Username',
          //   password: 'Password',
          //   notes: 'Testing'
          // }
        ],
        followUpPaymentTypeId: null,
        followUpPaymentTypeOther: null,
        hoaApprovalRequiredTypeId: null,
        hoaApprovalRequiredTypeOther: null,
        id: null,
        nemApprovalRequiredTypeId: null,
        nemApprovalRequiredTypeOther: null,
        notes: [],
        otherLicense: null,
        otherLicenseExpirationDate: null,
        paymentMethod: null,
        printLocation: null,
        printLocations: [],
        revisionChecklist: [],
        revisionFeeAmount: null,
        revisionNote: null,
        revisionPaymentTypeId: null,
        revisionPaymentTypeOther: null,
        revisionSubmittalTypeId: null,
        revisionSubmittalTypeOther: null,
        servicingFots: [],
        stampedPlan: null,
        submissionChecklist: [
          // {
          //   id: 1,
          //   type: 3,
          //   details: 'Do something'
          // },
          // {
          //   id: 2,
          //   type: 3,
          //   details: 'Do something else'
          // },
          // {
          //   id: 3,
          //   type: 3,
          //   details: 'Coming up with test data is hard sometimes'
          // }
        ],
        submissionContacts: [],
        submissionLinks: [
          // {
          //   id: 1,
          //   type: 4,
          //   name: 'Google',
          //   url: 'https://www.google.com/',
          //   username: 'Username',
          //   password: 'Password',
          //   notes: 'Testing'
          // },
          // {
          //   id: 2,
          //   type: 4,
          //   name: 'Outlook',
          //   url: 'https://www.outlook.com/',
          //   username: 'Username',
          //   password: 'Password',
          //   notes: 'Testing again'
          // }
        ],
        submissionNote: null,
        submissionPaymentTypeId: null,
        submissionPaymentTypeOther: null,
        submittalTypeId: null,
        submittalTypeOther: null
      },
      documents: [
        // {
        //   id: 1,
        //   name: 'instructions.txt'
        // },
        // {
        //   id: 2,
        //   name: 'importantDocument.docx'
        // }
      ],
      servicingFots: [
        // {
        //   id: 1,
        //   firstName: 'Test',
        //   lastName: 'Guy 1',
        //   fullName: 'Test Guy 1',
        //   office: 'Test Office 1',
        //   officeId: 1
        // },
        // {
        //   id: 2,
        //   firstName: 'Test',
        //   lastName: 'Guy 2',
        //   fullName: 'Test Guy 2',
        //   office: 'Test Office 2',
        //   officeId: 2
        // },
        // {
        //   id: 3,
        //   firstName: 'Test',
        //   lastName: 'Guy 3',
        //   fullName: 'Test Guy 3',
        //   office: 'Test Office 3',
        //   officeId: 3
        // }
      ],
      submissionContactAddCtrls: false,
      submissionContactEditCtrls: false,
      followUpContactAddCtrls: false,
      followUpContactEditCtrls: false,
      contactEditedIndex: -1,
      editedContact: {
        id: '',
        type: '',
        name: '',
        title: '',
        phoneNumber: '',
        email: '',
        hours: '',
        address: '',
        notes: ''
      },
      submissionContacts: [
        // {
        //   id: 1,
        //   type: 1,
        //   name: 'Bob',
        //   title: 'Store Manager',
        //   phoneNumber: '111-111-1111',
        //   email: 'bob@test.com',
        //   hours: 'M-F 8am-4pm',
        //   address: '111 Test St, Indianapolis, IN 11111',
        //   notes: 'Testing'
        // },
        // {
        //   id: 2,
        //   type: 1,
        //   name: 'Sarah',
        //   title: 'Store Manager',
        //   phoneNumber: '222-222-2222',
        //   email: 'sarah@test.com',
        //   hours: 'M-F 9am-5pm',
        //   address: '222 Test St, Indianapolis, IN 22222',
        //   notes: 'More testing'
        // }
      ],
      followUpContacts: [
        // {
        //   id: 1,
        //   type: 2,
        //   name: 'John',
        //   title: 'FedEx Delivery Truck Driver',
        //   phoneNumber: '333-333-3333',
        //   email: 'john@test.com',
        //   hours: 'M-F 9am-5pm',
        //   address: '333 Test Ave, New York City, NY 33333',
        //   notes: 'Another test'
        // },
        // {
        //   id: 2,
        //   type: 2,
        //   name: 'Jacob',
        //   title: 'Professional Mover',
        //   phoneNumber: '444-444-4444',
        //   email: 'jacob@test.com',
        //   hours: 'M-F 8am-4pm',
        //   address: '444 Test Rd, Seattle, WA 99999',
        //   notes: 'Testing some more'
        // },
        // {
        //   id: 3,
        //   type: 2,
        //   name: 'Scott',
        //   title: 'Test Contact',
        //   phoneNumber: '555-555-5555',
        //   email: 'scott@test.com',
        //   hours: 'M-F 10am-6pm',
        //   address: '555 Test Pl, Redmond, WA 88888',
        //   notes: 'Doing more testing'
        // }
      ],
      printLocationAddCtrls: false,
      printLocationEditCtrls: false,
      printLocationEditedIndex: -1,
      editedPrintLocation: {
        id: '',
        storeName: '',
        storeNumber: '',
        phone: '',
        email: '',
        hours: '',
        address: '',
        notes: ''
      },
      printLocations: [
        // {
        //   id: 1,
        //   storeName: 'Alphagraphics',
        //   storeNumber: '111',
        //   phone: '111-111-1111',
        //   email: 'alphagraphics@test.com',
        //   hours: 'M-F 10am-7pm',
        //   address: '111 Test Ave, Seattle, WA 99999',
        //   notes: 'Testing'
        // },
        // {
        //   id: 2,
        //   storeName: 'Zippy\'s Quick Ship \'N Copy',
        //   storeNumber: '222',
        //   phone: '222-222-2222',
        //   email: 'zippys@test.com',
        //   hours: 'M-F 9am-5pm',
        //   address: '222 Test St, Indianapolis, IN 22222',
        //   notes: 'More testing'
        // }
      ]
    }),
    methods: {
      resetForm() {
        console.log("Resetting the form...")
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
      resetContactCtrls(type) {
        switch (type) {
          case 1:
            this.submissionContactAddCtrls = false
            this.submissionContactEditCtrls = false
            this.$refs.submissionContactForm.reset()
            break
          case 2:
            this.followUpContactAddCtrls = false
            this.followUpContactEditCtrls = false
            this.$refs.followUpContactForm.reset()
            break
        }
      },
      addContact(type) {
        this.submissionContactEditCtrls = false
        this.followUpContactEditCtrls = false

        switch (type) {
          case 1:
            this.submissionContactAddCtrls = true
            this.followUpContactAddCtrls = false
            this.$refs.submissionContactForm.reset()
            break
          case 2:
            this.submissionContactAddCtrls = false
            this.followUpContactAddCtrls = true
            this.$refs.followUpContactForm.reset()
        }
      },
      editContact(contact, type) {
        this.submissionContactAddCtrls = false
        this.followUpContactAddCtrls = false

        switch (type) {
          case 1:
            this.submissionContactEditCtrls = true
            this.followUpContactEditCtrls = false
            this.contactEditedIndex = this.submissionContacts.indexOf(contact)
            break
          case 2:
            this.submissionContactEditCtrls = false
            this.followUpContactEditCtrls = true
            this.contactEditedIndex = this.followUpContacts.indexOf(contact)
            break
        }
        this.editedContact = Object.assign({}, contact)
        this.editedContact.type = type
      },
      deleteContact(type) {
        switch (type) {
          case 1:
            this.submissionContacts.splice(this.contactEditedIndex, 1)
            this.submissionContactEditCtrls = false
            break
          case 2:
            this.followUpContacts.splice(this.contactEditedIndex, 1)
            this.followUpContactEditCtrls = false
            break
        }
      },
      saveContact(type) {
        switch (type) {
          case 1:
            if (this.contactEditedIndex > -1) {
              Object.assign(this.submissionContacts[this.contactEditedIndex], this.editedContact)
              this.submissionContactEditCtrls = false
            } else {
              if (this.submissionContacts.length > 0) {
                let idsArray = []
                this.submissionContacts.forEach(item => idsArray.push(item.id))
                this.editedContact.id = max(idsArray) + 1
              } else {
                this.editedContact.id = 1
              }
              this.submissionContacts.push(this.editedContact)
              this.submissionContactAddCtrls = false
            }
            break
          case 2:
            if (this.contactEditedIndex > -1) {
              Object.assign(this.followUpContacts[this.contactEditedIndex], this.editedContact)
              this.followUpContactEditCtrls = false
            } else {
              if (this.followUpContacts.length > 0) {
                let idsArray = []
                this.followUpContacts.forEach(item => idsArray.push(item.id))
                this.editedContact.id = max(idsArray) + 1
              } else {
                this.editedContact.id = 1
              }
              this.followUpContacts.push(this.editedContact)
              this.followUpContactAddCtrls = false
            }
            break
        }
      },
      resetPrintLocationCtrls() {
        this.printLocationAddCtrls = false
        this.printLocationEditCtrls = false
        this.$refs.printLocationForm.reset()
      },
      addPrintLocation() {
        this.printLocationEditCtrls = false
        this.printLocationAddCtrls = true
        this.$refs.printLocationForm.reset()
      },
      editPrintLocation(location) {
        this.printLocationAddCtrls = false
        this.printLocationEditCtrls = true
        this.printLocationEditedIndex = this.printLocations.indexOf(location)
        this.editedPrintLocation = Object.assign({}, location)
      },
      deletePrintLocation() {
        this.printLocations.splice(this.printLocationEditedIndex, 1)
        this.printLocationEditCtrls = false
      },
      savePrintLocation() {
        if (this.printLocationEditedIndex > -1) {
          Object.assign(this.printLocations[this.printLocationEditedIndex], this.editedPrintLocation)
          this.printLocationEditCtrls = false
        } else {
          if (this.printLocations.length > 0) {
            let idsArray = []
            this.printLocations.forEach(item => idsArray.push(item.id))
            this.editedPrintLocation.id = max(idsArray) + 1
          } else {
            this.editedPrintLocation.id = 1
          }
          this.printLocations.push(this.editedPrintLocation)
          this.printLocationAddCtrls = false
        }
      },
      saveAhjPermit() {
        console.log("Saving AHJ Permit...")
        console.log("AHJ Permit:", this.ahjPermit)
      }
    },
    async created () {
      let ahjId = parseInt(this.$route.params.ahjId)
      const {data} = await getRequest(`/api/v1/company/blueraven/ahj/${ahjId}/permit/`)
      this.ahjPermit = cloneDeep(data)
      console.log("AHJ Permit:", this.ahjPermit)
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
  .v-text-field,
  .v-select,
  .v-input ::v-deep label,
  .v-list-item__title,
  .list-link {
    font-size: 0.95em !important;
  }
  .cancel-link,
  .empty-list,
  .horizontal-dl,
  table {
    font-size: 0.85em !important;
  }
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
  .empty-list {
    padding: 20px;
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
  /*Definition list styles*/
  .horizontal-dl {
    display: flex;
    flex-flow: row wrap;
    justify-content: space-between;
    width: 100%;
  }
  .horizontal-dl dt {
    text-align: right;
    width: 30%;
  }
  .horizontal-dl dd {
    width: 65%;
  }
  /*End definition list styles*/
</style>