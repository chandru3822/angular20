<!--suppress CssInvalidPseudoSelector -->
<template>
  <v-row>
    <v-col cols="12" class="pt-0">
      <v-row justify="space-between">
        <v-col class="text-left pa-0" cols="12">
          <v-btn id="back-btn" text class="pl-1 pr-2 mb-2" :to="'/ahjUtility'">
            <v-icon>arrow_left</v-icon><span id="back-btn-text">Back to menu</span>
          </v-btn>

          <div class="flex-display justify-space-between align-center px-3 mb-4" style="width: 100%">
            <div class="page-title">Utility</div>
            <div class="page-info">
              <div>{{ ahjUtility.name }}</div>
              <div>{{ ahjUtility.metroArea }}, {{ ahjUtility.state }}</div>
            </div>
          </div>

          <v-tabs id="utility-tab-bar" class="mb-6" background-color="var(--v-secondary-base)">
            <v-tab style="cursor: default" :ripple="false" class="text-capitalize my-0 ml-3 mr-0">Details</v-tab>
          </v-tabs>
        </v-col>
      </v-row>

      <v-row dense>
        <v-col class="ahj-form-btns" cols="12">
          <a v-if="dataWasChanged"
             @click="resetForm"
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
                                  @change="dataWasChanged = true"
                                  label="Regulated By"
                                  filled
                    ></v-text-field>
                  </v-col>
                  <v-col cols="6" class="pl-4">
                    <v-text-field v-model="ahjUtility.monthlyFacilityCharge"
                                  @change="dataWasChanged = true"
                                  label="Monthly Facility Charge"
                                  filled
                    ></v-text-field>
                  </v-col>
                </v-row>
                <v-row no-gutters>
                  <v-col cols="6" class="pr-4">
                    <v-text-field v-model="ahjUtility.populationOfService"
                                  @change="dataWasChanged = true"
                                  label="Population of Service"
                                  filled
                    ></v-text-field>
                  </v-col>
                  <v-col cols="6" class="pl-4">
                    <div v-for="item in getCustomFieldsForGroup(7)" :key="item.id">
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
                  </v-col>
                </v-row>
                <v-row no-gutters>
                  <v-col cols="6" class="pr-4">
                    <v-text-field v-model="ahjUtility.netMeteringRate"
                                  @change="dataWasChanged = true"
                                  label="Net Metering Rate"
                                  filled
                   ></v-text-field>
                  </v-col>
                  <v-col cols="6" class="pl-4">
                    <v-text-field v-model="ahjUtility.rebateRates"
                                  @change="dataWasChanged = true"
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
                            @change="dataWasChanged = true"
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
                              @change="[item.valueWasChanged = true, dataWasChanged = true]"
                              :items="item.listOfValues"
                              item-text="name"
                              item-value="id"
                              :label="item.fieldName"
                              filled
                    ></v-select>
                    <AhjDocumentsButton v-if="item.customFieldId === 22"
                                        title="Documents"
                                        :documentTypeId="20"
                                        :sourceId="ahjUtilityId"
                    ></AhjDocumentsButton>
                    <AhjDocumentsButton v-if="item.customFieldId === 23"
                                        title="Documents"
                                        :documentTypeId="21"
                                        :sourceId="ahjUtilityId"
                    ></AhjDocumentsButton>
                    <AhjDocumentsButton v-if="item.customFieldId === 30"
                                        title="Documents"
                                        :documentTypeId="22"
                                        :sourceId="ahjUtilityId"
                    ></AhjDocumentsButton>
                    <AhjDocumentsButton v-if="item.customFieldId === 24"
                                        title="Documents"
                                        :documentTypeId="22"
                                        :sourceId="ahjUtilityId"
                    ></AhjDocumentsButton>
                    <AhjDocumentsButton v-if="item.customFieldId === 25"
                                        title="Documents"
                                        :documentTypeId="23"
                                        :sourceId="ahjUtilityId"
                    ></AhjDocumentsButton>
                  </div>
                </div>
                <AhjRequirement v-if="dataReady"
                                title="Utility PV Design Notes and Additional Requirements"
                                :requirementTypeId="4"
                                :itemType="itemType"
                                :itemId="ahjUtilityId"
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
                            @change="dataWasChanged = true"
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
                            @change="dataWasChanged = true"
                            label="Timelines / Stages"
                            filled
                            auto-grow
                ></v-textarea>
              </v-card-text>
            </v-card>

            <!-- CUSTOMER SIGNATURES -->
            <v-card class="mb-3">
              <v-card-title class="primaryCustom white--text font-weight-bold">
                Customer Signatures
              </v-card-title>
              <v-card-text class="mt-4">
                <div v-for="item in getCustomFieldsForGroup(8)" :key="item.id">
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
                <AhjLink v-if="dataReady"
                         title="Links"
                         :linkTypeId="6"
                         :itemId="ahjUtility.id"
                         :itemType="itemType"
                         :links="ahjUtility.customerSignatureLinks"
                         :isNested="true"
                ></AhjLink>
                <v-textarea v-model="ahjUtility.customerSignatureInstructions"
                            @change="dataWasChanged = true"
                            label="Instructions"
                            filled
                            auto-grow
                            style="margin-top: 30px"
                ></v-textarea>
              </v-card-text>
            </v-card>

            <!-- SUBMISSION DETAILS -->
            <v-card class="mb-sm-3">
              <v-card-title class="primaryCustom white--text font-weight-bold">
                Submission Details
              </v-card-title>
              <v-card-text class="mt-4">
                <v-textarea v-model="ahjUtility.overviewOfSubmissionProcess"
                            @change="dataWasChanged = true"
                            label="Overview of Submission Process"
                            filled
                            auto-grow
                ></v-textarea>
                <div v-for="item in getCustomFieldsForGroup(10)" :key="item.id">
                  <v-select v-if="item.customFieldId === 56"
                            v-model="item.intValue"
                            @change="[item.valueWasChanged = true, dataWasChanged = true]"
                            :items="item.listOfValues"
                            item-text="name"
                            item-value="id"
                            :label="item.fieldName"
                            filled
                  ></v-select>
                  <v-text-field v-if="showOtherField(item.intValue, item.listOfValues) && item.customFieldId === 56"
                                v-model="item.textValue"
                                @change="[item.valueWasChanged = true, dataWasChanged = true]"
                                label="Other Value"
                                filled
                                class="other-field"
                  ></v-text-field>
                </div>
                <AhjChecklist v-if="dataReady"
                              title="Checklist"
                              :checklistTypeId="4"
                              :itemId="ahjUtility.id"
                              :itemType="itemType"
                              :checklistItems="ahjUtility.submissionChecklist"
                              :isNested="true"
                              class="mb-4"
                ></AhjChecklist>
                <AhjDocument v-if="dataReady"
                             title="Documents"
                             :documentTypeId="6"
                             :sourceId="ahjUtility.id"
                             :documents="documents"
                             :isNested="true"
                ></AhjDocument>
                <AhjLink v-if="dataReady"
                         title="Links"
                         :linkTypeId="9"
                         :itemId="ahjUtility.id"
                         :itemType="itemType"
                         :links="ahjUtility.submissionLinks"
                         :isNested="true"
                         class="mb-8"
                ></AhjLink>
                <div class="flex-display justify-space-between flex-nowrap">
                  <div v-for="item in getCustomFieldsForGroup(10)" :key="item.id"
                       :class="[{'mr-4': item.customFieldId === 55}, {'ml-4': item.customFieldId === 61}]">
                    <v-select v-if="[55,61].indexOf(item.customFieldId) !== -1"
                              v-model="item.intValue"
                              @change="[item.valueWasChanged = true, dataWasChanged = true]"
                              :items="item.listOfValues"
                              item-text="name"
                              item-value="id"
                              :label="item.fieldName"
                              filled
                    ></v-select>
                    <v-text-field v-if="showOtherField(item.intValue, item.listOfValues) && [55,61].indexOf(item.customFieldId) !== -1"
                                  v-model="item.textValue"
                                  @change="[item.valueWasChanged = true, dataWasChanged = true]"
                                  label="Other Value"
                                  filled
                                  class="other-field"
                    ></v-text-field>
                  </div>
                </div>
                <v-textarea v-model="ahjUtility.submissionInstructions"
                            @change="dataWasChanged = true"
                            label="Instructions"
                            filled
                            auto-grow
                ></v-textarea>
              </v-card-text>
            </v-card>
          </v-col>

          <!-- THIRD COLUMN -->
          <v-col cols="12" md="4" class="px-1 mb-3">
            <!-- APPROVAL DETAILS -->
            <v-card class="mb-3">
              <v-card-title class="primaryCustom white--text font-weight-bold">
                Approval Details
              </v-card-title>
              <v-card-text class="mt-4">
                <v-text-field v-model="ahjUtility.expectedApprovalTimeline"
                              @change="dataWasChanged = true"
                              label="Expected Timeline for Approval"
                              filled
                ></v-text-field>
                <AhjChecklist v-if="dataReady"
                              title="Checklist"
                              :checklistTypeId="5"
                              :itemId="ahjUtility.id"
                              :itemType="itemType"
                              :checklistItems="ahjUtility.approvalChecklist"
                              :isNested="true"
                              class="mb-4"
                ></AhjChecklist>
                <AhjDocument v-if="dataReady"
                             title="Documents"
                             :documentTypeId="25"
                             :sourceId="ahjUtility.id"
                             :documents="documents"
                             :isNested="true"
                ></AhjDocument>
                <v-card>
                  <v-card-title class="primaryCustom white--text font-weight-bold">
                    Rejections
                  </v-card-title>
                  <v-card-text>
                    <div v-for="item in getCustomFieldsForGroup(23)" :key="item.id" class="mt-4">
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
                    <v-textarea v-model="ahjUtility.rejectionInstructions"
                                @change="dataWasChanged = true"
                                label="Instructions"
                                filled
                                auto-grow
                    ></v-textarea>
                  </v-card-text>
                </v-card>
              </v-card-text>
            </v-card>

            <!-- PTO DETAILS -->
            <v-card class="mb-3">
              <v-card-title class="primaryCustom white--text font-weight-bold">
                PTO Details
              </v-card-title>
              <v-card-text class="mt-4">
                <div class="flex-display flex-row-reverse flex-nowrap justify-space-between">
                  <div v-for="item in getCustomFieldsForGroup(11)" :key="item.id"
                       :class="[{'mr-4': item.customFieldId === 54}, {'ml-4': item.customFieldId === 53}]">
                    <v-select v-if="[54,53].indexOf(item.customFieldId) !== -1"
                              v-model="item.intValue"
                              @change="[item.valueWasChanged = true, dataWasChanged = true]"
                              :items="item.listOfValues"
                              item-text="name"
                              item-value="id"
                              :label="item.fieldName"
                              filled
                    ></v-select>
                    <v-text-field v-if="showOtherField(item.intValue, item.listOfValues) && [54,53].indexOf(item.customFieldId) !== -1"
                                  v-model="item.textValue"
                                  @change="[item.valueWasChanged = true, dataWasChanged = true]"
                                  label="Other Value"
                                  filled
                                  class="other-field"
                    ></v-text-field>
                  </div>
                </div>
                <AhjChecklist v-if="dataReady"
                              title="Checklist for Submission"
                              :checklistTypeId="6"
                              :itemId="ahjUtility.id"
                              :itemType="itemType"
                              :checklistItems="ahjUtility.ptoChecklist"
                              :isNested="true"
                              class="mb-4"
                ></AhjChecklist>
                <AhjLink v-if="dataReady"
                         title="Links"
                         :linkTypeId="7"
                         :itemId="ahjUtility.id"
                         :itemType="itemType"
                         :links="ahjUtility.ptoLinks"
                         :isNested="true"
                         class="mb-8"
                ></AhjLink>
                <div v-for="item in getCustomFieldsForGroup(11)" :key="item.id">
                  <v-select v-if="item.customFieldId === 60"
                            v-model="item.intValue"
                            @change="[item.valueWasChanged = true, dataWasChanged = true]"
                            :items="item.listOfValues"
                            item-text="name"
                            item-value="id"
                            :label="item.fieldName"
                            filled
                  ></v-select>
                  <v-text-field v-if="showOtherField(item.intValue, item.listOfValues) && item.customFieldId === 60"
                                v-model="item.textValue"
                                @change="[item.valueWasChanged = true, dataWasChanged = true]"
                                label="Other Value"
                                filled
                                class="other-field"
                  ></v-text-field>
                </div>
                <AhjChecklist v-if="dataReady"
                              title="Checklist for Utility Inspection"
                              :checklistTypeId="7"
                              :itemId="ahjUtility.id"
                              :itemType="itemType"
                              :checklistItems="ahjUtility.utilityInspectionChecklist"
                              :isNested="true"
                              class="mb-4"
                ></AhjChecklist>
                <v-card class="mb-4">
                  <v-card-title class="primaryCustom white--text font-weight-bold">
                    Pending PTO Followup
                  </v-card-title>
                  <v-card-text class="mt-4">
                    <div v-for="item in getCustomFieldsForGroup(11)" :key="item.id">
                      <v-select v-if="item.customFieldId === 40"
                                v-model="item.intValue"
                                @change="[item.valueWasChanged = true, dataWasChanged = true]"
                                :items="item.listOfValues"
                                item-text="name"
                                item-value="id"
                                :label="item.fieldName"
                                filled
                      ></v-select>
                      <v-text-field v-if="showOtherField(item.intValue, item.listOfValues) && item.customFieldId === 40"
                                    v-model="item.textValue"
                                    @change="[item.valueWasChanged = true, dataWasChanged = true]"
                                    label="Other Value"
                                    filled
                                    class="other-field"
                      ></v-text-field>
                    </div>
                    <v-text-field v-model="ahjUtility.timelines"
                                  @change="dataWasChanged = true"
                                  label="Timelines"
                                  filled
                    ></v-text-field>
                    <AhjLink v-if="dataReady"
                             title="Links"
                             :linkTypeId="8"
                             :itemId="ahjUtility.id"
                             :itemType="itemType"
                             :links="ahjUtility.ptoFollowupLinks"
                             :isNested="true"
                             class="mb-8"
                    ></AhjLink>
                    <v-textarea v-model="ahjUtility.ptoFollowupInstructions"
                                @change="dataWasChanged = true"
                                label="Instructions"
                                filled
                                auto-grow
                    ></v-textarea>
                  </v-card-text>
                </v-card>
                <v-card class="mb-sm-3">
                  <v-card-title class="primaryCustom white--text font-weight-bold">
                    Final Completion Submission
                  </v-card-title>
                  <v-card-text class="mt-4">
                    <v-select v-model="selectedFinancier"
                              @change="dataWasChanged = true"
                              :items="financiers"
                              item-text="name"
                              item-value="id"
                              label="Financier"
                              filled
                              return-object
                    ></v-select>
                    <v-text-field label="Submission Method"
                                  v-model="selectedFinancier.submissionMethod"
                                  @change="dataWasChanged = true"
                                  :disabled="!selectedFinancier.id"
                                  filled
                    ></v-text-field>
                    <v-textarea v-model="ahjUtility.finalCompletionInstructions"
                                @change="dataWasChanged = true"
                                label="Instructions"
                                filled
                                auto-grow
                    ></v-textarea>
                  </v-card-text>
                </v-card>
              </v-card-text>
            </v-card>
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
      dataWasChanged: false,
      dataReady: false,
      customFieldGroupAssignments: [],
      selectedFinancier: {submissionMethod: null},
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
      documents: [],
      financiers: []
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
          this.snackbar = getSnackbar('ERROR', 'Error retrieving AHJ Utility')
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      async getFinancierList() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest('/financier/active', 'blueraven')
          this.financiers = cloneDeep(data)
          this.selectedFinancier = this.ahjUtility.financierId ? this.financiers.filter(financier => financier.id === this.ahjUtility.financierId)[0] : {submissionMethod: null}
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving list of financiers')
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
      resetCustomFieldValueWasChangedFlags() {
        this.customFieldGroupAssignments.forEach(group => {
          group.customFieldValues.forEach(cfv => cfv.valueWasChanged = false)
        })
      },
      async resetForm() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.ahjUtility.financierId = (this.selectedFinancier && this.selectedFinancier.id) ? this.selectedFinancier.id : null
        this.dataWasChanged = false
        this.dataReady = false
        this.getAhjUtility().then(() => {
          this.getFinancierList()
          this.getCustomFieldGroupAssignmentsForScreen().then(() => this.dataReady = true)
        })
      },
      async saveAhjUtility() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.ahjUtility.financierId = (this.selectedFinancier && this.selectedFinancier.id) ? this.selectedFinancier.id : null

        try {
          this.ahjUtility.customFieldGroups = this.customFieldGroupAssignments
          const {data} = await putRequest('/ahjUtility', this.ahjUtility, 'blueraven')
          this.ahjUtility = cloneDeep(data)
          this.dataWasChanged = false
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
        this.getFinancierList().then(() => {
          this.getCustomFieldGroupAssignmentsForScreen().then(() => {
            this.dataReady = true
          })
        })
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
  #utility-tab-bar {
    border-top: 1px solid #E6E6E6;
    border-bottom: 1px solid #E6E6E6;
    .v-tab:hover {
      color: var(--v-primaryCustom-base);
    }
  }
  .ahj-form-btns {
    display: flex;
    flex-flow: row nowrap;
    justify-content: flex-end;
    align-items: center;
    margin-bottom: 10px;
  }
  #save-btn {
    margin: 0 5px 0 0;
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
  .cancel-link:hover {
    text-decoration: underline;
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
  .other-field {
    margin-top: -20px;
  }
  .v-input--is-disabled ::v-deep .v-input__slot,
  .v-input--is-disabled ::v-deep input {
    cursor: not-allowed;
    pointer-events: all;
  }
  .v-input--is-disabled ::v-deep label {
    color: rgba(0, 0, 0, 0.38) !important;
  }
</style>
