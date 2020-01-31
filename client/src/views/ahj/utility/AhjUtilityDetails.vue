<!--suppress CssInvalidPseudoSelector -->
<template>
  <v-row>
    <v-col cols="12">
      <v-row justify="space-between">
        <v-col class="text-left" cols="12">
          <v-btn id="back-btn" text class="pl-0 pr-2" :to="'/ahjUtility'">
            <v-icon>arrow_left</v-icon><span id="back-btn-text">Back to menu</span>
          </v-btn>

          <v-row justify="space-between" align="center" no-gutters>
            <div class="page-title">Utility</div>
            <div class="page-info">
              <div>{{ ahjUtility.name }}</div>
              <div>{{ ahjUtility.metroArea }}, {{ ahjUtility.state }}</div>
            </div>
          </v-row>

          <v-divider></v-divider>

          <v-tabs background-color="rgba(0,0,0,0)">
            <v-tab style="cursor: default" :ripple="false" class="text-capitalize ma-0">Details</v-tab>
          </v-tabs>

          <v-divider></v-divider>
        </v-col>
      </v-row>

      <v-row dense>
        <v-col class="text-right" cols="12">
          <a @click="resetForm"
             class="cancel-link"
             style="margin-right: 10px"
          >Cancel</a>
          <v-btn id="save-btn"
                 color="primaryButton"
                 class="white--text mr-0"
                 @click="saveAhjUtility"
          >Save</v-btn>
        </v-col>

        <v-row no-gutters>
          <!-- FIRST COLUMN -->
          <v-col cols="12" md="4" class="px-1 mb-3">
            <!-- CONTACTS -->
            <AhjContact v-if="dataReady"
                        title="Contacts"
                        :contactTypeId="8"
                        :itemId="ahjUtility.id"
                        :itemType="itemType"
                        :contacts="ahjUtility.contacts"
            ></AhjContact>

            <!-- UTILITY RATES -->
            <v-card class="mb-3">
              <v-card-title class="primaryCustom white--text font-weight-bold">
                Utility Rates
              </v-card-title>
              <v-card-text class="mt-4">
                <v-row no-gutters>
                  <v-col cols="6" class="pr-4">
                    <v-text-field v-model="ahjUtility.regulatedBy"
                                  label="Regulated By"
                                  filled
                    ></v-text-field>
                  </v-col>
                  <v-col cols="6" class="pl-4">
                    <v-text-field v-model="ahjUtility.monthlyFacilityCharge"
                                  label="Monthly Facility Charge"
                                  filled
                    ></v-text-field>
                  </v-col>
                </v-row>
                <v-row no-gutters>
                  <v-col cols="6" class="pr-4">
                    <v-text-field v-model="ahjUtility.populationOfService"
                                  label="Population of Service"
                                  filled
                    ></v-text-field>
                  </v-col>
                  <v-col cols="6" class="pl-4">
                    <div v-for="item in getCustomFieldsForGroup(7)" :key="item.id">
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
                                    style="margin-top: -20px"
                      ></v-text-field>
                    </div>
                  </v-col>
                </v-row>
                <v-row no-gutters>
                  <v-col cols="6" class="pr-4">
                    <v-text-field v-model="ahjUtility.netMeteringRate"
                                  label="Net Metering Rate"
                                  filled
                   ></v-text-field>
                  </v-col>
                  <v-col cols="6" class="pl-4">
                    <v-text-field v-model="ahjUtility.rebateRates"
                                  label="Rebate Rates"
                                  filled
                   ></v-text-field>
                  </v-col>
                </v-row>
                <AhjDocument v-if="dataReady"
                             title="Documents"
                             :documentTypeId="7"
                             :sourceId="ahjUtility.id"
                             :documents="documents"
                             :isNested="true"
                ></AhjDocument>
                <v-textarea v-model="ahjUtility.utilityRateNotes"
                            label="Notes"
                            filled
                            auto-grow
                            style="margin-top: 30px"
                ></v-textarea>
              </v-card-text>
            </v-card>

            <!-- DESIGN UTILITY REQUIREMENTS -->
            <v-card class="mb-3">
              <v-card-title class="primaryCustom white--text font-weight-bold">
                Design Utility Requirements
              </v-card-title>
              <v-card-text class="mt-4">
                <div class="flex-display flex-wrap justify-space-between">
                  <div class="flex-display custom-field"
                       v-for="item in getCustomFieldsForGroup(9)" :key="item.id">
                    <v-select v-model="item.intValue"
                              :items="item.listOfValues"
                              item-text="name"
                              item-value="id"
                              :label="item.fieldName"
                              filled
                    ></v-select>
                    <AhjDocumentsButton v-if="item.customFieldId === 22"
                                        title="Documents"
                                        :documentTypeId="20"
                                        :sourceId="ahjUtility.id"
                    ></AhjDocumentsButton>
                    <AhjDocumentsButton v-if="item.customFieldId === 23"
                                        title="Documents"
                                        :documentTypeId="21"
                                        :sourceId="ahjUtility.id"
                    ></AhjDocumentsButton>
                    <AhjDocumentsButton v-if="item.customFieldId === 30"
                                        title="Documents"
                                        :documentTypeId="22"
                                        :sourceId="ahjUtility.id"
                    ></AhjDocumentsButton>
                    <AhjDocumentsButton v-if="item.customFieldId === 24"
                                        title="Documents"
                                        :documentTypeId="22"
                                        :sourceId="ahjUtility.id"
                    ></AhjDocumentsButton>
                    <AhjDocumentsButton v-if="item.customFieldId === 25"
                                        title="Documents"
                                        :documentTypeId="23"
                                        :sourceId="ahjUtility.id"
                    ></AhjDocumentsButton>
                  </div>
                </div>
                <AhjRequirement v-if="dataReady"
                                title="Utility PV Design Notes and Additional Requirements"
                                :requirementTypeId="4"
                                :itemType="itemType"
                                :requirements="ahjUtility.utilityRequirements"
                                :transparent="true"
                                :isNested="true"
                ></AhjRequirement>
              </v-card-text>
            </v-card>

            <!-- NOTES -->
            <v-card>
              <v-card-title class="primaryCustom white--text font-weight-bold">
                Notes
              </v-card-title>
              <v-card-text class="mt-4">
                <v-textarea v-model="ahjUtility.notes"
                            label="Notes"
                            filled
                            auto-grow
                ></v-textarea>
              </v-card-text>
            </v-card>
          </v-col>

          <!-- SECOND COLUMN -->
          <v-col cols="12" md="4" class="px-1 mb-3">
            <!-- OVERVIEW -->
            <v-card class="mb-3">
              <v-card-title class="primaryCustom white--text font-weight-bold">
                Overview
              </v-card-title>
              <v-card-text class="mt-4">
                <v-textarea v-model="ahjUtility.timelinesAndStages"
                            label="Timelines / Stages"
                            filled
                            auto-grow
                ></v-textarea>
              </v-card-text>
            </v-card>

            <!-- CUSTOMER SIGNATURES -->
            <v-card>
              <v-card-title class="primaryCustom white--text font-weight-bold">
                Customer Signatures
              </v-card-title>
              <v-card-text class="mt-4">
                <div v-for="item in getCustomFieldsForGroup(8)" :key="item.id">
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
                                style="margin-top: -20px"
                  ></v-text-field>
                </div>
                <AhjLink v-if="dataReady"
                         title="Links"
                         :linkTypeId="6"
                         :itemId="ahjUtility.id"
                         :itemType="itemType"
                         :links="ahjUtility.customerSignatureLinks"
                         :isNested="true"
                ></AhjLink>
                <v-textarea v-model="ahjUtility.customerSignatureInstructions"
                            label="Instructions"
                            filled
                            auto-grow
                            style="margin-top: 30px"
                ></v-textarea>
              </v-card-text>
            </v-card>
          </v-col>

          <!-- THIRD COLUMN -->
          <v-col cols="12" md="4" class="px-1 mb-3">

          </v-col>
        </v-row>
      </v-row>
    </v-col>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-row>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import orderBy from "lodash.orderby"
  import AhjChecklist from "../components/AhjChecklist"
  import AhjContact from "../components/AhjContacts"
  import AhjDocument from "../components/AhjDocuments"
  import AhjDocumentsButton from "../components/AhjDocumentsButton"
  import AhjLink from "../components/AhjLinks"
  import AhjRequirement from "../components/AhjRequirements"
  import Snackbar from '@/components/Snackbar'
  import { AppMutations } from '@/stores/AppStore'
  import { getRequest, getRequestWithParams, putRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: 'ahjUtilityDetails',
    components: {
      AhjChecklist,
      AhjContact,
      AhjDocument,
      AhjDocumentsButton,
      AhjLink,
      AhjRequirement,
      Snackbar
    },
    data: () => ({
      ahjUtilityId: null,
      itemType: 'utility',
      snackbar: {},
      dataReady: false,
      customFieldGroupAssignments: [],
      ahjUtility: {
        customerSignatureLinks: [],
        ptoLinks: [],
        ptoFollowupLinks: [],
        submissionLinks: [],
        submissionChecklist: [],
        approvalChecklist: [],
        ptoChecklist: [],
        utilityInspectionChecklist: [],
        contacts: [],
        utilityRequirements: []
      },
      documents: []
    }),
    methods: {
      async getAhjUtility() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/ahjUtility/${this.ahjUtilityId}`, 'blueraven')
          this.ahjUtility = cloneDeep(data)
          this.ahjUtility.customerSignatureLinks = orderBy(this.ahjUtility.customerSignatureLinks, link => link.name.toLowerCase())
          this.ahjUtility.ptoLinks = orderBy(this.ahjUtility.ptoLinks, link => link.name.toLowerCase())
          this.ahjUtility.ptoFollowupLinks = orderBy(this.ahjUtility.ptoFollowupLinks, link => link.name.toLowerCase())
          this.ahjUtility.submissionLinks = orderBy(this.ahjUtility.submissionLinks, link => link.name.toLowerCase())
          this.ahjUtility.contacts = orderBy(this.ahjUtility.contacts, contact => contact.name.toLowerCase())
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving AHJ Permit')
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      async getCustomFieldGroupAssignmentsForScreen() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const params = {sourceId: this.ahjUtility.id, objectTypeId: 2}
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
      async resetForm() {
        this.dataReady = false
        this.getAhjUtility().then(() => this.dataReady = true)
      },
      async saveAhjUtility() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.ahjPermit.customFieldGroups = this.customFieldGroupAssignments
          const {data} = await putRequest('/ahjUtility', this.ahjUtility, 'blueraven')
          this.ahjPermit = cloneDeep(data)
          this.snackbar = getSnackbar('SUCCESS', 'AHJ Utility saved')
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error saving AHJ Utility')
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async created () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.ahjUtilityId = parseInt(this.$route.params.ahjUtilityId)

      this.getAhjUtility().then(() => {
        this.getCustomFieldGroupAssignmentsForScreen()
        this.dataReady = true
      })
    }
  }
</script>

<style scoped lang="scss">
  #back-btn {
    text-transform: unset;
    letter-spacing: unset;
    &:before {
      background-color: initial;
    }
    #back-btn-text:hover {
      text-decoration: underline;
    }
  }
  .page-title {
    font-size: 32px;
    font-weight: 200;
  }
  .page-info {
    font-family: 'Roboto Condensed', sans-serif;
    font-size: 20px;
    text-align: right;
  }
  #save-btn {
    margin: 0 5px 10px 0;
    text-transform: capitalize;
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
  .cancel-link {
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
  .custom-field {
    width: 48%;
  }
</style>
