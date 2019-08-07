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
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Submission Details
          </v-card-title>
          <v-card-text class="mt-4">
            <v-select v-model="ahjPermit.submittalTypeId"
                      :items="submittalMethods"
                      label="Submittal Method"
                      filled
            ></v-select>
            <v-select v-model="ahjPermit.hoaApprovalRequiredTypeId"
                      :items="approvalRequiredOptions"
                      label="HOA Approval Required for Submission"
                      filled
            ></v-select>
            <v-select v-model="ahjPermit.nemApprovalRequiredTypeId"
                      :items="approvalRequiredOptions"
                      label="NEM Approval Required for Submission"
                      filled
            ></v-select>
            <v-text-field v-model="ahjPermit.depositAmount"
                          label="Deposit Amount"
                          filled
                          prepend-inner-icon="attach_money"
            ></v-text-field>
            <v-select v-model="ahjPermit.submissionPaymentTypeId"
                      :items="submittalMethods"
                      label="Payment Method"
                      filled
            ></v-select>
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
                        full-width
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
                        full-width
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
                        full-width
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
                          :permitId="ahjPermit.id"
                          :ahjId="ahjId"
                          :checklistItems="ahjPermit.submissionChecklist"
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
            <v-select v-model="ahjPermit.revisionSubmittalTypeId"
                      :items="submittalMethods"
                      label="Submittal Method"
                      filled
            ></v-select>
            <v-text-field v-model="ahjPermit.revisionFeeAmount"
                          label="Fee Amount"
                          filled
                          prepend-inner-icon="attach_money"
            ></v-text-field>
            <v-select v-model="ahjPermit.revisionPaymentTypeId"
                      :items="submittalMethods"
                      label="Payment Method"
                      filled
            ></v-select>
            <AhjChecklist v-if="dataReady"
                          title="Revision Submission Checklist"
                          :checklistTypeId="2"
                          :permitId="ahjPermit.id"
                          :ahjId="ahjId"
                          :checklist-items="ahjPermit.revisionChecklist"
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
            <v-select v-model="ahjPermit.asBuiltSubmittalTypeId"
                      :items="submittalMethods"
                      label="Submittal Method"
                      filled
            ></v-select>
            <v-text-field v-model="ahjPermit.asBuiltFeeAmount"
                          label="Fee Amount"
                          filled
                          prepend-inner-icon="attach_money"
            ></v-text-field>
            <v-select v-model="ahjPermit.asBuiltPaymentTypeId"
                      :items="submittalMethods"
                      label="Payment Method"
                      filled
            ></v-select>
            <AhjChecklist v-if="dataReady"
                          title="As-Built Submission Checklist"
                          :checklistTypeId="3"
                          :permitId="ahjPermit.id"
                          :ahjId="ahjId"
                          :checklist-items="ahjPermit.asBuiltChecklist"
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
            <v-select v-model="ahjPermit.followUpPaymentTypeId"
                      :items="submittalMethods"
                      label="Payment Method"
                      filled
            ></v-select>
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
            <v-select v-model="ahjPermit.deliveryPickupTypeId"
                      :items="submittalMethods"
                      label="Pickup Method"
                      filled
            ></v-select>
            <v-text-field v-model="ahjPermit.deliveryFeeAmount"
                          label="Fee Amount"
                          filled
                          prepend-inner-icon="attach_money"
            ></v-text-field>
            <v-select v-model="ahjPermit.deliveryPaymentTypeId"
                      :items="submittalMethods"
                      label="Payment Method"
                      filled
            ></v-select>
            <AhjDocument v-if="dataReady"
                         title="Documents Required for Inspection"
                         :documentTypeId="1"
                         :sourceId="ahjPermit.id"
                         :ahjId="ahjId"
                         :documents="documents"
            ></AhjDocument>
            <v-textarea v-model="ahjPermit.deliveryNote"
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
                      @change="setTimePeriodDates"
                      label="Viewing Data For:"
                      filled
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
      </v-col>
    </v-row>

    <h1 class="pb-2 mb-4"
        style="border-bottom: 1px solid #ccc; width: 100%;"
    >Links and Contacts</h1>
    <v-row no-gutters>
      <!-- FIRST COLUMN -->
      <v-col cols="12" md="4" class="px-1 mb-3">
        <AhjPermitLink v-if="dataReady"
                       title="Submission Links"
                       :linkTypeId="4"
                       :permitId="ahjPermit.id"
                       :ahjId="ahjId"
                       :links="ahjPermit.submissionLinks"
        ></AhjPermitLink>

        <AhjContact v-if="dataReady"
                    title="Submission Contacts"
                    :contactTypeId="1"
                    :permitId="ahjPermit.id"
                    :ahjId="ahjId"
                    :contacts="ahjPermit.submissionContacts"
        ></AhjContact>
      </v-col>

      <!-- SECOND COLUMN -->
      <v-col cols="12" md="4" class="px-1 mb-3">
        <AhjPermitLink v-if="dataReady"
                       title="Follow-up and Delivery Links"
                       :linkTypeId="5"
                       :permitId="ahjPermit.id"
                       :ahjId="ahjId"
                       :links="ahjPermit.followUpLinks"
        ></AhjPermitLink>

        <AhjContact v-if="dataReady"
                    title="Print Locations"
                    :contactTypeId="7"
                    :permitId="ahjPermit.id"
                    :ahjId="ahjId"
                    :contacts="ahjPermit.printLocations"
        ></AhjContact>
      </v-col>

      <!-- THIRD COLUMN -->
      <v-col cols="12" md="4" class="px-1 mb-3">
        <v-card class="mb-3">
          <v-toolbar class="primaryCustom">
            <v-toolbar-title class="white--text font-weight-bold"
                             title="Servicing FOT's"
            >Servicing FOT's</v-toolbar-title>
          </v-toolbar>
          <v-list v-show="ahjPermit.servicingFots.length > 0"
                  v-for="fot in ahjPermit.servicingFots"
                  :key="fot.officeId"
                  class="px-2">
            <v-list-item :title="fot.office">
              <v-list-item-content class="flex-row-center">
                <v-list-item-title>
                  <a class="list-link">{{fot.office}}</a>
                </v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </v-list>
          <div class="empty-list"
               v-show="ahjPermit.servicingFots.length < 1"
          >No FOT's found</div>
        </v-card>

        <AhjContact v-if="dataReady"
                    title="Follow-up and Delivery Contacts"
                    :contactTypeId="6"
                    :permitId="ahjPermit.id"
                    :ahjId="ahjId"
                    :contacts="ahjPermit.followUpContacts"
        ></AhjContact>
      </v-col>
    </v-row>

  </v-row>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import moment from 'moment'
  import AhjChecklist from './components/AhjChecklist.vue'
  import AhjContact from './components/AhjContacts.vue'
  import AhjDocument from './components/AhjDocuments.vue'
  import AhjPermitLink from './components/AhjPermitLinks.vue'
  import { AppMutations } from '@/stores/AppStore'
  import { getRequest, putRequest } from '@/helpers/helpers'

  export default {
    name: 'ahjPermit',
    components: {
      AhjChecklist,
      AhjContact,
      AhjDocument,
      AhjPermitLink
    },
    data: () => ({
      dataReady: false,
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
      async getAhjPermit() {
        const {data} = await getRequest(`/api/v1/company/blueraven/ahj/${this.ahjId}/permit`)
        this.ahjPermit = cloneDeep(data)
      },
      async getDocuments() {
        const params = {
          sourceId: this.ahjPermit.id,
          attachmentSourceTypeId: 1
        }
        const {data} = await getRequest('/api/v1/flow/document/getSourceAttachments', {params})
        this.documents = cloneDeep(data)
      },
      async resetForm() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.dataReady = false
        this.getAhjPermit().then(() => {
          this.getDocuments().then(() => {
            this.dataReady = true
            this.$store.commit(AppMutations.SET_LOADING, false)
          })
        })
      },
      async saveAhjPermit() {
        console.log("this.ahjPermit:", this.ahjPermit)
        // const {data} = await putRequest(`/api/v1/company/blueraven/ahj/${this.ahjId}/permit/${this.ahjPermit.id}`, this.ahjPermit)
        // this.ahjPermit = cloneDeep(data)
      }
    },
    async created() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.ahjId = parseInt(this.$route.params.ahjId)
      this.getAhjPermit().then(() => {
        this.getDocuments().then(() => {
          this.dataReady = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        })
      })
    }
  }
</script>

<style scoped lang="scss">
  .padded-sides {
    padding: 0 5px;
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
</style>