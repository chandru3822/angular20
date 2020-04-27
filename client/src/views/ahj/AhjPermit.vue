<!--suppress CssInvalidPseudoSelector -->
<template>
  <v-row no-gutters>
    <v-col class="ahj-form-btns py-1" cols="12">
      <a v-if="dataWasChanged"
         @click="resetForm"
         class="cancel-link"
         style="margin-right: 10px"
      >Cancel</a>
      <v-btn class="white--text mr-0 save-btn"
             color="primaryButton"
             @click="saveDialog = true"
      >Save</v-btn>
    </v-col>

    <v-row no-gutters>
      <!-- FIRST COLUMN -->
      <v-col cols="12" md="3" class="pr-sm-0 pr-md-1 mb-sm-0 mb-md-3">
        <!-- SUBMISSION DETAILS -->
        <v-card>
          <v-card-title class="primaryCustom white--text font-weight-bold title-with-icon">
            Submission Details
            <router-link :to="'/schedule'" title="Go to Scheduling Tool">
              <v-icon class="white--text">launch</v-icon>
            </router-link>
          </v-card-title>
          <v-card-text class="mt-4">
            <div v-for="item in getCustomFieldsForGroup(1)" :key="item.id">
              <v-select v-model="item.intValue"
                        @change="[item.valueWasChanged = true, dataWasChanged = true]"
                        :items="item.listOfValues"
                        item-text="name"
                        item-value="id"
                        :label="item.fieldName"
                        filled
              ></v-select>
              <v-text-field v-if="showOtherField(item.intValue, item.listOfValues)"
                            v-model="item.textValue"
                            @change="[item.valueWasChanged = true, dataWasChanged = true]"
                            label="Other Value"
                            filled
                            class="other-field"
              ></v-text-field>
            </div>
            <v-text-field v-model="ahjPermit.depositAmount"
                          @change="dataWasChanged = true"
                          label="Deposit Amount"
                          filled
                          prepend-inner-icon="attach_money"
            ></v-text-field>
            <v-row>
              <v-col cols="6">
                <v-text-field v-model="ahjPermit.businessLicense"
                              @change="dataWasChanged = true"
                              label="Business License"
                              filled
                ></v-text-field>
              </v-col>
              <v-col cols="6">
                <v-menu v-model="businessLicenseMenu"
                        :close-on-content-click="false"
                        :nudge-right="40"
                        transition="scale-transition"
                        offset-y
                        min-width="290px">
                  <template v-slot:activator="{ on }">
                    <v-text-field v-model="ahjPermit.businessLicenseExpirationDate"
                                  @change="dataWasChanged = true"
                                  label="mm/dd/yyyy"
                                  filled
                                  append-icon="event"
                                  readonly
                                  v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="ahjPermit.businessLicenseExpirationDate"
                                 @change="dataWasChanged = true"
                                 @input="businessLicenseMenu = false"
                  ></v-date-picker>
                </v-menu>
              </v-col>
            </v-row>
            <v-row>
              <v-col cols="6">
                <v-text-field v-model="ahjPermit.contractorLicense"
                              @change="dataWasChanged = true"
                              label="Contractor License"
                              filled
                ></v-text-field>
              </v-col>
              <v-col cols="6">
                <v-menu v-model="contractorLicenseMenu"
                        :close-on-content-click="false"
                        :nudge-right="40"
                        transition="scale-transition"
                        offset-y
                        min-width="290px">
                  <template v-slot:activator="{ on }">
                    <v-text-field v-model="ahjPermit.contractorLicenseExpirationDate"
                                  @change="dataWasChanged = true"
                                  label="mm/dd/yyyy"
                                  filled
                                  append-icon="event"
                                  readonly
                                  v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="ahjPermit.contractorLicenseExpirationDate"
                                 @change="dataWasChanged = true"
                                 @input="contractorLicenseMenu = false"
                  ></v-date-picker>
                </v-menu>
              </v-col>
            </v-row>
            <v-row>
              <v-col cols="6">
                <v-text-field v-model="ahjPermit.otherLicense"
                              @change="dataWasChanged = true"
                              label="Other License"
                              filled
                ></v-text-field>
              </v-col>
              <v-col cols="6">
                <v-menu v-model="otherLicenseMenu"
                        :close-on-content-click="false"
                        :nudge-right="40"
                        transition="scale-transition"
                        offset-y
                        min-width="290px">
                  <template v-slot:activator="{ on }">
                    <v-text-field v-model="ahjPermit.otherLicenseExpirationDate"
                                  @change="dataWasChanged = true"
                                  label="mm/dd/yyyy"
                                  filled
                                  append-icon="event"
                                  readonly
                                  v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="ahjPermit.otherLicenseExpirationDate"
                                 @change="dataWasChanged = true"
                                 @input="otherLicenseMenu = false"
                  ></v-date-picker>
                </v-menu>
              </v-col>
            </v-row>
            <AhjChecklist v-if="dataReady"
                          title="Submission Checklist"
                          :checklistTypeId="1"
                          :itemId="ahjPermit.id"
                          :itemType="itemType"
                          :ahjId="ahjId"
                          :checklistItems="ahjPermit.submissionChecklist"
                          :isNested="true"
            ></AhjChecklist>
            <v-textarea v-model="ahjPermit.submissionNote"
                        @change="dataWasChanged = true"
                        label="Submission Instructions"
                        filled
                        auto-grow
                        style="margin-top: 30px"
            ></v-textarea>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- SECOND COLUMN -->
      <v-col cols="12" md="3" class="px-1 mb-3">
        <!-- REVISION SUBMISSION DETAILS -->
        <v-card>
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Revision Submission Details
          </v-card-title>
          <v-card-text class="mt-4">
            <div v-for="item in getCustomFieldsForGroup(2)" :key="item.id">
              <v-select v-model="item.intValue"
                        @change="[item.valueWasChanged = true, dataWasChanged = true]"
                        :items="item.listOfValues"
                        item-text="name"
                        item-value="id"
                        :label="item.fieldName"
                        filled
              ></v-select>
              <v-text-field v-if="showOtherField(item.intValue, item.listOfValues)"
                            v-model="item.textValue"
                            @change="[item.valueWasChanged = true, dataWasChanged = true]"
                            label="Other Value"
                            filled
                            class="other-field"
              ></v-text-field>
            </div>
            <v-text-field v-model="ahjPermit.revisionFeeAmount"
                          @change="dataWasChanged = true"
                          label="Fee Amount"
                          filled
                          prepend-inner-icon="attach_money"
            ></v-text-field>
            <AhjChecklist v-if="dataReady"
                          title="Revision Submission Checklist"
                          :checklistTypeId="2"
                          :itemId="ahjPermit.id"
                          :itemType="itemType"
                          :ahjId="ahjId"
                          :checklist-items="ahjPermit.revisionChecklist"
                          :isNested="true"
            ></AhjChecklist>
            <v-textarea v-model="ahjPermit.revisionNote"
                        @change="dataWasChanged = true"
                        label="Revision Submission Instructions"
                        filled
                        auto-grow
                        style="margin-top: 30px"
            ></v-textarea>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- THIRD COLUMN -->
      <v-col cols="12" md="3" class="px-1 mb-3">
        <!-- AS-BUILT SUBMISSION DETAILS -->
        <v-card>
          <v-card-title class="primaryCustom white--text font-weight-bold">
            As-Built Submission Details
          </v-card-title>
          <v-card-text class="mt-4">
            <div v-for="item in getCustomFieldsForGroup(3)" :key="item.id">
              <v-select v-model="item.intValue"
                        @change="[item.valueWasChanged = true, dataWasChanged = true]"
                        :items="item.listOfValues"
                        item-text="name"
                        item-value="id"
                        :label="item.fieldName"
                        filled
              ></v-select>
              <v-text-field v-if="showOtherField(item.intValue, item.listOfValues)"
                            v-model="item.textValue"
                            @change="[item.valueWasChanged = true, dataWasChanged = true]"
                            label="Other Value"
                            filled
                            class="other-field"
              ></v-text-field>
            </div>
            <v-text-field v-model="ahjPermit.asBuiltFeeAmount"
                          @change="dataWasChanged = true"
                          label="Fee Amount"
                          filled
                          prepend-inner-icon="attach_money"
            ></v-text-field>
            <AhjChecklist v-if="dataReady"
                          title="As-Built Submission Checklist"
                          :checklistTypeId="3"
                          :itemId="ahjPermit.id"
                          :itemType="itemType"
                          :ahjId="ahjId"
                          :checklist-items="ahjPermit.asBuiltChecklist"
                          :isNested="true"
            ></AhjChecklist>
            <v-textarea v-model="ahjPermit.asBuiltNote"
                        @change="dataWasChanged = true"
                        label="As-Built Submission Instructions"
                        filled
                        auto-grow
                        style="margin-top: 30px"
            ></v-textarea>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- FOURTH COLUMN -->
      <v-col cols="12" md="3" class="pl-sm-0 pl-md-1 mb-3">
        <!-- FOLLOW-UP / APPROVAL DETAILS -->
        <v-card class="mb-3">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Follow-up / Approval Details
          </v-card-title>
          <v-card-text class="mt-4">
            <v-text-field v-model="ahjPermit.approvalTimeline"
                          @change="dataWasChanged = true"
                          label="Approval Timeline"
                          filled
            ></v-text-field>
            <v-text-field v-model="ahjPermit.followUpFeeAmount"
                          @change="dataWasChanged = true"
                          label="Fee Amount"
                          filled
                          prepend-inner-icon="attach_money"
            ></v-text-field>
            <div v-for="item in getCustomFieldsForGroup(4)" :key="item.id">
              <v-select v-model="item.intValue"
                        @change="[item.valueWasChanged = true, dataWasChanged = true]"
                        :items="item.listOfValues"
                        item-text="name"
                        item-value="id"
                        :label="item.fieldName"
                        filled
              ></v-select>
              <v-text-field v-if="showOtherField(item.intValue, item.listOfValues)"
                            v-model="item.textValue"
                            @change="[item.valueWasChanged = true, dataWasChanged = true]"
                            label="Other Value"
                            filled
                            class="other-field"
              ></v-text-field>
            </div>
            <v-text-field v-model="ahjPermit.documentsAvailable"
                          @change="dataWasChanged = true"
                          label="When are documents available?"
                          filled
            ></v-text-field>
          </v-card-text>
        </v-card>

        <!-- DELIVERY DETAILS -->
        <v-card class="mb-3">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Delivery Details
          </v-card-title>
          <v-card-text class="mt-4">
            <div v-for="item in getCustomFieldsForGroup(5)" :key="item.id">
              <v-select v-model="item.intValue"
                        @change="[item.valueWasChanged = true, dataWasChanged = true]"
                        :items="item.listOfValues"
                        item-text="name"
                        item-value="id"
                        :label="item.fieldName"
                        filled
              ></v-select>
              <v-text-field v-if="showOtherField(item.intValue, item.listOfValues)"
                            v-model="item.textValue"
                            @change="[item.valueWasChanged = true, dataWasChanged = true]"
                            label="Other Value"
                            filled
                            class="other-field"
              ></v-text-field>
            </div>
            <v-text-field v-model="ahjPermit.deliveryFeeAmount"
                          @change="dataWasChanged = true"
                          label="Fee Amount"
                          filled
                          prepend-inner-icon="attach_money"
            ></v-text-field>
            <AhjDocument v-if="dataReady"
                         title="Documents Required for Inspection"
                         :documentTypeId="1"
                         :sourceId="ahjPermit.id"
                         :ahjId="ahjId"
                         :documents="documents"
                         :isNested="true"
            ></AhjDocument>
            <v-textarea v-model="ahjPermit.deliveryNote"
                        @change="dataWasChanged = true"
                        label="Delivery Instructions"
                        filled
                        auto-grow
            ></v-textarea>
          </v-card-text>
        </v-card>

        <!-- PERMITTING CYCLE TIMES -->
        <v-card style="overflow-x: auto">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Permitting Cycle Times
          </v-card-title>
          <v-card-text class="mt-4">
            <v-select v-model="permittingCycleTimes.timePeriod"
                      :items="timePeriods"
                      @change="getPermitCycleTimes"
                      label="Viewing Data For:"
                      filled
            ></v-select>
            <p style="margin: -15px 0">{{ permittingCycleTimes.startDate }} to {{ permittingCycleTimes.endDate }}</p>
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
      </v-col>
    </v-row>

    <h1 class="pb-2 mb-4"
        style="border-bottom: 1px solid #ccc; width: 100%;"
    >Links and Contacts</h1>
    <v-row no-gutters>
      <!-- FIRST COLUMN -->
      <v-col cols="12" md="4" class="px-1 mb-3">
        <AhjLink v-if="dataReady"
                       title="Submission Links"
                       :linkTypeId="4"
                       :itemId="ahjPermit.id"
                       :itemType="itemType"
                       :ahjId="ahjId"
                       :links="ahjPermit.submissionLinks"
        ></AhjLink>

        <AhjContact v-if="dataReady"
                    title="Submission Contacts"
                    :contactTypeId="1"
                    :itemId="ahjPermit.id"
                    :itemType="itemType"
                    :ahjId="ahjId"
                    :contacts="ahjPermit.submissionContacts"
        ></AhjContact>
      </v-col>

      <!-- SECOND COLUMN -->
      <v-col cols="12" md="4" class="px-1 mb-3">
        <AhjLink v-if="dataReady"
                       title="Follow-up and Delivery Links"
                       :linkTypeId="5"
                       :itemId="ahjPermit.id"
                       :itemType="itemType"
                       :ahjId="ahjId"
                       :links="ahjPermit.followUpLinks"
        ></AhjLink>

        <AhjContact v-if="dataReady"
                    title="Print Locations"
                    :contactTypeId="7"
                    :itemId="ahjPermit.id"
                    :itemType="itemType"
                    :ahjId="ahjId"
                    :contacts="ahjPermit.printLocations"
        ></AhjContact>
      </v-col>

      <!-- THIRD COLUMN -->
      <v-col cols="12" md="4" class="px-1 mb-3">
        <AhjServicingFot v-if="dataReady"
                         :servicingFots="ahjPermit.servicingFots"
        ></AhjServicingFot>

        <AhjContact v-if="dataReady"
                    title="Follow-up and Delivery Contacts"
                    :contactTypeId="6"
                    :itemId="ahjPermit.id"
                    :itemType="itemType"
                    :ahjId="ahjId"
                    :contacts="ahjPermit.followUpContacts"
        ></AhjContact>
      </v-col>
    </v-row>

    <v-dialog v-model="saveDialog" max-width="700">
      <v-card>
        <v-card-title>
          <span class="headline">Save Changes</span>
        </v-card-title>

        <v-divider></v-divider>

        <v-card-text class="pb-0">
          <v-radio-group v-model="ahjPermit.updateAllInState">
            <v-radio label="Save changes to this AHJ only" :value="false"></v-radio>
            <v-radio :label="`Save changes to all AHJs in ${ahjPermit.stateName}`" :value="true"></v-radio>
          </v-radio-group>
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions class="px-6">
          <v-spacer></v-spacer>
          <a @click="saveDialog = false"
             class="cancel-link mr-2"
          >Cancel</a>
          <v-btn v-if="ahjPermit.updateAllInState"
                 class="white--text mr-0 save-btn"
                 color="primaryButton"
                 @click="saveConfirmDialog = true"
          >Save</v-btn>
          <v-btn v-else
                 class="white--text mr-0 save-btn"
                 color="primaryButton"
                 @click="updateAhjPermit"
          >Save</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="saveConfirmDialog" max-width="500">
      <v-card>
        <v-card-title>
          <span class="headline">Confirm</span>
        </v-card-title>

        <v-card-text class="pb-0 py-2">
          Are you sure you want to update <strong>ALL</strong>? This action cannot be undone.
        </v-card-text>

        <v-card-actions class="px-6">
          <v-spacer></v-spacer>
          <a @click="saveConfirmDialog = false"
             class="cancel-link mr-2"
          >Cancel</a>
          <v-btn class="white--text mr-0 save-btn"
                 color="primaryButton"
                 @click="updateAhjPermit"
          >Yes</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-row>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import orderBy from 'lodash.orderby'
  import moment from 'moment'
  import AhjChecklist from './components/AhjChecklist'
  import AhjContact from './components/AhjContacts'
  import AhjDocument from './components/AhjDocuments'
  import AhjLink from './components/AhjLinks'
  import AhjServicingFot from './components/AhjServicingFots'
  import Snackbar from '@/components/Snackbar'
  import { AppMutations } from '@/stores/AppStore'
  import { getRequest, getRequestWithParams, putRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: 'ahjPermit',
    components: {
      AhjChecklist,
      AhjContact,
      AhjDocument,
      AhjLink,
      AhjServicingFot,
      Snackbar
    },
    data: () => ({
      ahjId: null,
      itemType: 'permit',
      snackbar: {},
      saveDialog: false,
      saveConfirmDialog: false,
      dataWasChanged: false,
      dataReady: false,
      customFieldGroupAssignments: [],
      approvalRequiredOptions: [{ id: null, name: '' }],
      submittalMethods: [{ id: null, name: '' }],
      weeksInPeriod: 4,
      periodsInYear: 13,
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
        submissionChecklist: [],
        revisionChecklist: [],
        asBuiltChecklist: [],
        submissionLinks: [],
        followUpLinks: [],
        submissionContacts: [],
        printLocations: [],
        followUpContacts: [],
        servicingFots: []
      },
      documents: []
    }),
    computed: {
      currentPeriodNum() {
        return Math.ceil(moment().isoWeek() / this.weeksInPeriod) - 1
      }
    },
    methods: {
      startOfPeriod(periodNum) {
        periodNum = periodNum % this.periodsInYear
        return moment().startOf('isoWeek').isoWeek(periodNum * this.weeksInPeriod + 1)
      },
      endOfPeriod(periodNum) {
        periodNum = periodNum % this.periodsInYear
        return this.startOfPeriod(periodNum).endOf('isoWeek').add(this.weeksInPeriod - 1, 'weeks')
      },
      setTimePeriodDates() {
        let dateFormat = 'MM/DD/YYYY'

        switch (this.permittingCycleTimes.timePeriod) {
          case 'This Week':
            this.permittingCycleTimes.startDate = moment().startOf('w').format(dateFormat)
            this.permittingCycleTimes.endDate = moment().format(dateFormat)
            break
          case 'This Period':
            this.permittingCycleTimes.startDate = this.startOfPeriod(this.currentPeriodNum).format(dateFormat)
            this.permittingCycleTimes.endDate = this.endOfPeriod(this.currentPeriodNum).format(dateFormat)
            break
          case 'This Year':
            this.permittingCycleTimes.startDate = moment().startOf('y').format(dateFormat)
            this.permittingCycleTimes.endDate = moment().format(dateFormat)
            break
          case 'Last Week':
            this.permittingCycleTimes.startDate = moment().startOf('w').subtract(1, 'w').format(dateFormat)
            this.permittingCycleTimes.endDate = moment().endOf('W').subtract(1, 'w').format(dateFormat)
            break
          case 'Last Period':
            this.permittingCycleTimes.startDate = this.startOfPeriod(this.currentPeriodNum - 1).format(dateFormat)
            this.permittingCycleTimes.endDate = this.endOfPeriod(this.currentPeriodNum - 1).format(dateFormat)
            break
          case 'Last Year':
            this.permittingCycleTimes.startDate = moment().startOf('y').subtract(1, 'y').format(dateFormat)
            this.permittingCycleTimes.endDate = moment().startOf('y').format(dateFormat)
            break
          case 'Last Six Weeks':
            this.permittingCycleTimes.startDate = moment().subtract(6, 'w').format(dateFormat)
            this.permittingCycleTimes.endDate = moment().format(dateFormat)
            break
          default:
            this.permittingCycleTimes.startDate = moment().subtract(6, 'w').format(dateFormat)
            this.permittingCycleTimes.endDate = moment().format(dateFormat)
        }
      },
      async getPermitCycleTimes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.setTimePeriodDates()

        try {
          let params = { start: this.permittingCycleTimes.startDate, end: this.permittingCycleTimes.endDate }
          const {data} = await getRequestWithParams(`/ahj/${this.ahjId}/permitCycleTimes`, {params}, 'blueraven')

          if (data) {
            this.permittingCycleTimes.data = cloneDeep(data)
            console.log("this.permittingCycleTimes:", this.permittingCycleTimes)
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving permit cycle times')
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      reformatDates() {
        // Reformat dates to remove timestamps
        this.ahjPermit.businessLicenseExpirationDate = this.ahjPermit.businessLicenseExpirationDate ? moment(this.ahjPermit.businessLicenseExpirationDate).format('YYYY-MM-DD') : null
        this.ahjPermit.contractorLicenseExpirationDate = this.ahjPermit.contractorLicenseExpirationDate ? moment(this.ahjPermit.contractorLicenseExpirationDate).format('YYYY-MM-DD') : null
        this.ahjPermit.otherLicenseExpirationDate = this.ahjPermit.otherLicenseExpirationDate ? moment(this.ahjPermit.otherLicenseExpirationDate).format('YYYY-MM-DD') : null
      },
      async getAhjPermit() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/ahj/${this.ahjId}/permit`, 'blueraven')
          data.servicingFots.forEach(servicingFot => servicingFot.hierarchy = servicingFot.hierarchy[0])
          this.ahjPermit = cloneDeep(data)
          this.ahjPermit.submissionLinks = orderBy(this.ahjPermit.submissionLinks, link => link.name.toLowerCase())
          this.ahjPermit.submissionContacts = orderBy(this.ahjPermit.submissionContacts, contact => contact.name.toLowerCase())
          this.ahjPermit.followUpLinks = orderBy(this.ahjPermit.followUpLinks, link => link.name.toLowerCase())
          this.ahjPermit.printLocations = orderBy(this.ahjPermit.printLocations, location => location.name.toLowerCase())
          this.ahjPermit.servicingFots = orderBy(this.ahjPermit.servicingFots, fot => fot.hierarchy.orgName.toLowerCase())
          this.ahjPermit.followUpContacts = orderBy(this.ahjPermit.followUpContacts, contact => contact.name.toLowerCase())
          this.ahjPermit.updateAllInState = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving AHJ Permit')
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      async getCustomFieldGroupAssignmentsForScreen() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const params = {sourceId: this.ahjPermit.id, objectTypeId: 4}
          const {data} = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupAssignmentsByObjectType`, {params}, 'blueraven')
          this.customFieldGroupAssignments = cloneDeep(data)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving custom fields')
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      getCustomFieldsForGroup(groupId) {
        let match = this.customFieldGroupAssignments.find(cfga => cfga.id === groupId)
        return match ? match.customFieldValues : []
      },
      showOtherField(int, list) {
        let match = list.find(l => l.id === int)
        return match ? match.showOther : false
      },
      resetCustomFieldValueWasChangedFlags() {
        this.customFieldGroupAssignments.forEach(group => {
          group.customFieldValues.forEach(cfv => cfv.valueWasChanged = false)
        })
      },
      async resetForm() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.dataWasChanged = false
        this.dataReady = false
        this.getAhjPermit().then(() => {
          this.getCustomFieldGroupAssignmentsForScreen()
          this.reformatDates()
          this.dataReady = true
        })
      },
      async getDocuments() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const params = {sourceId: this.ahjPermit.id, attachmentTypeId: 1}
          const {data} = await getRequestWithParams('/attachment', {params})
          this.documents = cloneDeep(data)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving documents')
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      async updateAhjPermit() {
        this.saveDialog = false
        this.saveConfirmDialog = false
        let updateAllInState = this.ahjPermit.updateAllInState

        try {
          this.$store.commit(AppMutations.SET_LOADING, true)

          if (updateAllInState) {
            try {
              const {data} = await getRequest(`/ahj/${this.ahjId}/permit/searchAhjsByState/${this.ahjPermit.stateId}`, 'blueraven')
              this.ahjPermit.ahjIds = []
              this.ahjPermit.permitIds = []

              data.forEach(row => {
                this.ahjPermit.ahjIds.push(row.ahjId)
                this.ahjPermit.permitIds.push(row.id)
              })
            } catch (e) {
              console.error('*** ERROR ***', e)
              this.snackbar = getSnackbar('ERROR', 'An error occurred when preparing to update all permits in ' + this.ahjPermit.stateName)
            }
          }

          this.ahjPermit.customFieldGroups = this.customFieldGroupAssignments
          const {data} = await putRequest(`/ahj/${this.ahjId}/permit/${this.ahjPermit.id}`, this.ahjPermit, 'blueraven')
          this.ahjPermit = cloneDeep(data)
          this.ahjPermit.updateAllInState = false
          this.dataWasChanged = false
          this.resetCustomFieldValueWasChangedFlags()
          this.reformatDates()
          let successMessage = updateAllInState ? 'All permits in ' + this.ahjPermit.stateName + ' have been updated successfully' : 'Permit updated successfully'
          this.snackbar = getSnackbar('SUCCESS', successMessage)
        } catch (e) {
          console.error('*** ERROR ***', e)
          let errorMessage = updateAllInState ? 'An error occurred when attempting to update all permits in ' + this.ahjPermit.stateName : 'Failed to update permit'
          this.snackbar = getSnackbar('ERROR', errorMessage)
        }

        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async created() {
      this.ahjId = parseInt(this.$route.params.ahjId)
      this.getAhjPermit().then(() => {
        this.reformatDates()
        this.getPermitCycleTimes()
        this.getCustomFieldGroupAssignmentsForScreen()
        this.getDocuments()
        this.dataReady = true
      })
    }
  }
</script>

<style scoped lang="scss">
  .padded-sides {
    padding: 0 5px;
  }
  .row {
    width: 100%;
  }
  .ahj-form-btns {
    display: flex;
    flex-flow: row nowrap;
    justify-content: flex-end;
    align-items: center;
  }
  .title-with-icon {
    display: flex;
    justify-content: space-between;
    .v-icon {
      cursor: pointer;
    }
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
  .save-btn {
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
  .other-field {
    margin-top: -20px;
  }
</style>
