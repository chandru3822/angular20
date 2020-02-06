<!--suppress CssInvalidPseudoSelector -->
<template>
  <v-row dense>
    <v-col class="text-right" cols="12">
      <a @click="resetForm"
         class="cancel-link"
         style="margin-right: 10px"
      >Cancel</a>
      <v-btn id="save-btn"
             color="primaryButton"
             class="white--text mr-0"
             @click="saveAhjPermit"
      >Save</v-btn>
    </v-col>

    <v-row no-gutters>
      <!-- FIRST COLUMN -->
      <v-col cols="12" md="3" class="px-1 mb-3">
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
                        :items="item.listOfValues"
                        item-text="name"
                        item-value="id"
                        :label="item.fieldName"
                        filled
              ></v-select>
              <v-text-field v-if="showOtherField(item.intValue, item.listOfValues)"
                            v-model="item.textValue"
                            label="Other Value"
                            filled
                            class="other-field"
              ></v-text-field>
            </div>
            <v-text-field v-model="ahjPermit.depositAmount"
                          label="Deposit Amount"
                          filled
                          prepend-inner-icon="attach_money"
            ></v-text-field>
            <v-row>
              <v-col cols="6">
                <v-text-field v-model="ahjPermit.businessLicense"
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
                                  label="mm/dd/yyyy"
                                  filled
                                  append-icon="event"
                                  readonly
                                  v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="ahjPermit.businessLicenseExpirationDate"
                                 @input="businessLicenseMenu=false"
                  ></v-date-picker>
                </v-menu>
              </v-col>
            </v-row>
            <v-row>
              <v-col cols="6">
                <v-text-field v-model="ahjPermit.contractorLicense"
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
                                  label="mm/dd/yyyy"
                                  filled
                                  append-icon="event"
                                  readonly
                                  v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="ahjPermit.contractorLicenseExpirationDate"
                                 @input="contractorLicenseMenu=false"
                  ></v-date-picker>
                </v-menu>
              </v-col>
            </v-row>
            <v-row>
              <v-col cols="6">
                <v-text-field v-model="ahjPermit.otherLicense"
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
                                  label="mm/dd/yyyy"
                                  filled
                                  append-icon="event"
                                  readonly
                                  v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="ahjPermit.otherLicenseExpirationDate"
                                 @input="otherLicenseMenu=false"
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
                        :items="item.listOfValues"
                        item-text="name"
                        item-value="id"
                        :label="item.fieldName"
                        filled
              ></v-select>
              <v-text-field v-if="showOtherField(item.intValue, item.listOfValues)"
                            v-model="item.textValue"
                            label="Other Value"
                            filled
                            class="other-field"
              ></v-text-field>
            </div>
            <v-text-field v-model="ahjPermit.revisionFeeAmount"
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
                        :items="item.listOfValues"
                        item-text="name"
                        item-value="id"
                        :label="item.fieldName"
                        filled
              ></v-select>
              <v-text-field v-if="showOtherField(item.intValue, item.listOfValues)"
                            v-model="item.textValue"
                            label="Other Value"
                            filled
                            class="other-field"
              ></v-text-field>
            </div>
            <v-text-field v-model="ahjPermit.asBuiltFeeAmount"
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
                        label="As-Built Submission Instructions"
                        filled
                        auto-grow
                        style="margin-top: 30px"
            ></v-textarea>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- FOURTH COLUMN -->
      <v-col cols="12" md="3" class="px-1 mb-3">
        <!-- FOLLOW-UP / APPROVAL DETAILS -->
        <v-card class="mb-3">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Follow-up / Approval Details
          </v-card-title>
          <v-card-text class="mt-4">
            <v-text-field v-model="ahjPermit.approvalTimeline"
                          label="Approval Timeline"
                          filled
            ></v-text-field>
            <v-text-field v-model="ahjPermit.followUpFeeAmount"
                          label="Fee Amount"
                          filled
                          prepend-inner-icon="attach_money"
            ></v-text-field>
            <div v-for="item in getCustomFieldsForGroup(4)" :key="item.id">
              <v-select v-model="item.intValue"
                        :items="item.listOfValues"
                        item-text="name"
                        item-value="id"
                        :label="item.fieldName"
                        filled
              ></v-select>
              <v-text-field v-if="showOtherField(item.intValue, item.listOfValues)"
                            v-model="item.textValue"
                            label="Other Value"
                            filled
                            class="other-field"
              ></v-text-field>
            </div>
            <v-text-field v-model="ahjPermit.documentsAvailable"
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
                        :items="item.listOfValues"
                        item-text="name"
                        item-value="id"
                        :label="item.fieldName"
                        filled
              ></v-select>
              <v-text-field v-if="showOtherField(item.intValue, item.listOfValues)"
                            v-model="item.textValue"
                            label="Other Value"
                            filled
                            class="other-field"
              ></v-text-field>
            </div>
            <v-text-field v-model="ahjPermit.deliveryFeeAmount"
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
                        label="Delivery Instructions"
                        filled
                        auto-grow
            ></v-textarea>
          </v-card-text>
        </v-card>

        <!-- TODO: come back to this after the migration of custom fields has taken place -->
        <!-- PERMITTING CYCLE TIMES -->
<!--        <v-card style="overflow-x: auto">-->
<!--          <v-card-title class="primaryCustom white&#45;&#45;text font-weight-bold">-->
<!--            Permitting Cycle Times-->
<!--          </v-card-title>-->
<!--          <v-card-text class="mt-4">-->
<!--            <v-select v-model="permittingCycleTimes.timePeriod"-->
<!--                      :items="timePeriods"-->
<!--                      @change="setTimePeriodDates"-->
<!--                      label="Viewing Data For:"-->
<!--                      filled-->
<!--            ></v-select>-->
<!--            <p style="margin: -15px 0">{{permittingCycleTimes.startDate}} to {{permittingCycleTimes.endDate}}</p>-->
<!--          </v-card-text>-->
<!--          <table class="pa-3" style="width: 100%">-->
<!--            <thead>-->
<!--              <tr>-->
<!--                <th>{{ permittingCycleTimes.headers.approvedHeaders[0] }}</th>-->
<!--                <th class="pr-1 centered">{{ permittingCycleTimes.headers.approvedHeaders[1] }}</th>-->
<!--                <th class="centered">{{ permittingCycleTimes.headers.approvedHeaders[2] }}</th>-->
<!--              </tr>-->
<!--            </thead>-->
<!--            <tbody>-->
<!--              <tr>-->
<!--                <td>{{ permittingCycleTimes.headers.approvedSubheaders[0] }}</td>-->
<!--                <td class="centered">{{ permittingCycleTimes.data.approvedPermits.permits.avgTime }}</td>-->
<!--                <td class="centered">{{ permittingCycleTimes.data.approvedPermits.asBuilts.avgTime }}</td>-->
<!--              </tr>-->
<!--              <tr>-->
<!--                <td>{{ permittingCycleTimes.headers.approvedSubheaders[1] }}</td>-->
<!--                <td class="centered">{{ permittingCycleTimes.data.approvedPermits.permits.medianTime }}</td>-->
<!--                <td class="centered">{{ permittingCycleTimes.data.approvedPermits.asBuilts.medianTime }}</td>-->
<!--              </tr>-->
<!--              <tr>-->
<!--                <td>{{ permittingCycleTimes.headers.approvedSubheaders[2] }}</td>-->
<!--                <td class="centered">{{ permittingCycleTimes.data.approvedPermits.permits.approvals }}</td>-->
<!--                <td class="centered">{{ permittingCycleTimes.data.approvedPermits.asBuilts.approvals }}</td>-->
<!--              </tr>-->
<!--            </tbody>-->
<!--            <thead>-->
<!--              <tr>-->
<!--                <th>{{ permittingCycleTimes.headers.pendingHeaders[0] }}</th>-->
<!--              </tr>-->
<!--            </thead>-->
<!--            <tbody>-->
<!--              <tr>-->
<!--                <td>{{ permittingCycleTimes.headers.pendingSubheaders[0] }}</td>-->
<!--                <td style="text-align: center">{{ permittingCycleTimes.data.pendingPermits.permits.avgAge }}</td>-->
<!--                <td style="text-align: center">{{ permittingCycleTimes.data.pendingPermits.asBuilts.avgAge }}</td>-->
<!--              </tr>-->
<!--              <tr>-->
<!--                <td>{{ permittingCycleTimes.headers.pendingSubheaders[1] }}</td>-->
<!--                <td style="text-align: center">{{ permittingCycleTimes.data.pendingPermits.permits.medianAge }}</td>-->
<!--                <td style="text-align: center">{{ permittingCycleTimes.data.pendingPermits.asBuilts.medianAge }}</td>-->
<!--              </tr>-->
<!--              <tr>-->
<!--                <td>{{ permittingCycleTimes.headers.pendingSubheaders[2] }}</td>-->
<!--                <td style="text-align: center">{{ permittingCycleTimes.data.pendingPermits.permits.maxAge }}</td>-->
<!--                <td style="text-align: center">{{ permittingCycleTimes.data.pendingPermits.asBuilts.maxAge }}</td>-->
<!--              </tr>-->
<!--            </tbody>-->
<!--          </table>-->
<!--        </v-card>-->
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
      dataReady: false,
      customFieldGroupAssignments: [],
      approvalRequiredOptions: [{ id: null, name: '' }],
      submittalMethods: [{ id: null, name: '' }],
      // timePeriods: [
      //   'This Week',
      //   'This Period',
      //   'This Year',
      //   'Last Week',
      //   'Last Period',
      //   'Last Year',
      //   'Last Six Weeks'
      // ],
      // permittingCycleTimes: {
      //   timePeriod: 'Last Six Weeks',
      //   startDate: moment().subtract(6, 'w').format('MM/DD/YYYY'),
      //   endDate: moment().format('MM/DD/YYYY'),
      //   headers: {
      //     approvedHeaders: ['Approved Permits', 'Permits', 'As-Builts'],
      //     approvedSubheaders: ['Average Cycle Time', 'Median Cycle Time', '# of Approvals'],
      //     pendingHeaders: ['Permits Pending Approval'],
      //     pendingSubheaders: ['Average Age', 'Median Age', 'Max Age']
      //   },
      //   data: {
      //     approvedPermits: {
      //       permits: {
      //         avgTime: 0,
      //         medianTime: 0,
      //         approvals: 0
      //       },
      //       asBuilts: {
      //         avgTime: 0,
      //         medianTime: 0,
      //         approvals: 0
      //       }
      //     },
      //     pendingPermits: {
      //       permits: {
      //         avgAge: 0,
      //         medianAge: 0,
      //         maxAge: 0
      //       },
      //       asBuilts: {
      //         avgAge: 0,
      //         medianAge: 0,
      //         maxAge: 0
      //       }
      //     }
      //   }
      // },
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
    methods: {
      // setTimePeriodDates() {
      //   switch (this.permittingCycleTimes.timePeriod) {
      //     case 'This Week':
      //       this.permittingCycleTimes.startDate = moment().startOf('w').format('MM/DD/YYYY')
      //       this.permittingCycleTimes.endDate = moment().format('MM/DD/YYYY')
      //       break
      //     case 'This Period':
      //       this.permittingCycleTimes.startDate = moment().startOf('W').format('MM/DD/YYYY')
      //       this.permittingCycleTimes.endDate = moment().startOf('w').add(4, 'w').format('MM/DD/YYYY')
      //       break
      //     case 'This Year':
      //       this.permittingCycleTimes.startDate = moment().startOf('y').format('MM/DD/YYYY')
      //       this.permittingCycleTimes.endDate = moment().format('MM/DD/YYYY')
      //       break
      //     case 'Last Week':
      //       this.permittingCycleTimes.startDate = moment().startOf('w').subtract(1, 'w').format('MM/DD/YYYY')
      //       this.permittingCycleTimes.endDate = moment().endOf('W').subtract(1, 'w').format('MM/DD/YYYY')
      //       break
      //     case 'Last Period':
      //       this.permittingCycleTimes.startDate = moment().startOf('W').subtract(4, 'w').format('MM/DD/YYYY')
      //       this.permittingCycleTimes.endDate = moment().startOf('w').format('MM/DD/YYYY')
      //       break
      //     case 'Last Year':
      //       this.permittingCycleTimes.startDate = moment().startOf('y').subtract(1, 'y').format('MM/DD/YYYY')
      //       this.permittingCycleTimes.endDate = moment().endOf('y').subtract(1, 'y').format('MM/DD/YYYY')
      //       break
      //     case 'Last Six Weeks':
      //       this.permittingCycleTimes.startDate = moment().subtract(6, 'w').format('MM/DD/YYYY')
      //       this.permittingCycleTimes.endDate = moment().format('MM/DD/YYYY')
      //       break
      //     default:
      //       this.permittingCycleTimes.startDate = moment().subtract(6, 'w').format('MM/DD/YYYY')
      //       this.permittingCycleTimes.endDate = moment().format('MM/DD/YYYY')
      //       break
      //   }
      // },
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
      async getDocuments() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const params = {sourceId: this.ahjPermit.id, attachmentSourceTypeId: 1}
          const {data} = await getRequestWithParams('/document/getSourceAttachments', {params})
          this.documents = cloneDeep(data)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving documents')
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      async resetForm() {
        this.dataReady = false
        this.getAhjPermit().then(() => {
          this.reformatDates()
          this.dataReady = true
        })
      },
      async saveAhjPermit() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.ahjPermit.customFieldGroups = this.customFieldGroupAssignments
          const {data} = await putRequest(`/ahj/${this.ahjId}/permit/${this.ahjPermit.id}`, this.ahjPermit, 'blueraven')
          this.ahjPermit = cloneDeep(data)
          this.reformatDates()
          this.snackbar = getSnackbar('SUCCESS', 'AHJ Permit saved')
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error saving AHJ Permit')
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async created() {
      this.ahjId = parseInt(this.$route.params.ahjId)
      this.getAhjPermit().then(() => {
        this.reformatDates()
        this.getCustomFieldGroupAssignmentsForScreen()
        this.dataReady = true
        // turned off for now.
        // this.getDocuments().then(() => this.dataReady = true)
      })
    }
  }
</script>

<style scoped lang="scss">
  .padded-sides {
    padding: 0 5px;
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
  .other-field {
    margin-top: -20px;
  }
</style>
