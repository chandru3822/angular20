<!--suppress CssInvalidPseudoSelector -->
<template>
  <v-row no-gutters>
    <v-col class="ahj-form-btns py-1" cols="12">
      <a v-if="dataWasChanged"
         @click="resetForm"
         class="cancel-link"
         style="margin-right: 10px"
      >Cancel</a>
      <v-btn class="white--text mr-0 save-btn" v-if="userCanEdit"
             color="primaryButton"
             @click="saveDialog = true"
      >Save</v-btn>
    </v-col>

    <!-- UPPER SECTION -->
    <v-row class="mb-4" no-gutters>
      <!-- FIRST COLUMN -->
      <v-col cols="12" md="3" class="pr-sm-0 pr-md-1 mb-3">
        <!-- SCHEDULING WITH AHJ -->
        <v-card>
          <v-card-title class="primaryCustom white--text font-weight-bold title-with-icon">
            Scheduling with AHJ
            <router-link :to="'/schedule'" title="Go to Scheduling Tool" v-if="this.$store.getters.userHasFeature('SCHEDULE')">
              <v-icon class="white--text">launch</v-icon>
            </router-link>
          </v-card-title>
          <v-card-text class="mt-4">
            <div v-for="item in getCustomFieldsForGroup(17)" :key="item.id">
              <v-select v-model="item.intValue"
                        @change="[item.valueWasChanged = true, dataWasChanged = true]"
                        :items="item.listOfValues"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
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
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            class="other-field"
              ></v-text-field>
            </div>
            <v-text-field v-model="ahjInspection.requiredInspectionTypes"
                          @change="dataWasChanged = true"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          label="Type of Inspections Required"
                          filled
            ></v-text-field>
            <v-card flat class="pa-0">
              <v-card-title class="pa-0">
                Scheduling Note
                <v-btn text x-small fab @click="editSchedulingNote = !editSchedulingNote">
                  <v-icon>edit</v-icon>
                </v-btn>
              </v-card-title>
              <v-card-text class="pa-0">
                <v-textarea v-model="ahjInspection.schedulingNote"
                            @change="dataWasChanged = true"
                            :readonly="!userCanEdit || !editSchedulingNote"
                            :disabled="!userCanEdit || !editSchedulingNote"
                            filled
                            auto-grow
                ></v-textarea>
              </v-card-text>
            </v-card>
            <AhjChecklist v-if="dataReady"
                          title="Checklist"
                          :checklistTypeId="12"
                          :itemId="ahjInspection.id"
                          :user-can-edit="userCanEdit"
                          :itemType="itemType"
                          :ahjId="ahjId"
                          :checklistItems="ahjInspection.schedulingWithAhjChecklist"
                          :isNested="true"
            ></AhjChecklist>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- SECOND COLUMN -->
      <v-col cols="12" md="3" class="px-sm-0 px-md-1 mb-3">
        <!-- SCHEDULING WITH BRS TECHNICIAN -->
        <v-card>
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Scheduling with BRS Technician
          </v-card-title>
          <v-card-text class="mt-4">
            <div v-for="item in getCustomFieldsForGroup(18)" :key="item.id">
              <v-select v-model="item.intValue"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        @change="[item.valueWasChanged = true, dataWasChanged = true]"
                        :items="item.listOfValues"
                        item-text="name"
                        item-value="id"
                        :label="item.fieldName"
                        filled
              ></v-select>
              <v-text-field v-if="showOtherField(item.intValue, item.listOfValues)"
                            v-model="item.textValue"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            @change="[item.valueWasChanged = true, dataWasChanged = true]"
                            label="Other Value"
                            filled
                            class="other-field"
              ></v-text-field>
            </div>
            <v-card flat class="pa-0">
              <v-card-title class="pa-0">
                Instructions for BRS Technician
                <v-btn text x-small fab @click="editInstructionsForBRSTech = !editInstructionsForBRSTech">
                  <v-icon>edit</v-icon>
                </v-btn>
              </v-card-title>
              <v-card-text class="pa-0">
                <v-textarea v-model="ahjInspection.technicianInstructionNote"
                            @change="dataWasChanged = true"
                            :readonly="!userCanEdit || !editInstructionsForBRSTech"
                            :disabled="!userCanEdit || !editInstructionsForBRSTech"
                            filled
                            auto-grow
                ></v-textarea>
              </v-card-text>
            </v-card>
            <v-card flat class="pa-0">
              <v-card-title class="pa-0">
                Documentation Notes
                <v-btn text x-small fab @click="editDocumentationNote = !editDocumentationNote">
                  <v-icon>edit</v-icon>
                </v-btn>
              </v-card-title>
              <v-card-text class="pa-0">
                <v-textarea v-model="ahjInspection.documentationNote"
                            @change="dataWasChanged = true"
                            :readonly="!userCanEdit || !editDocumentationNote"
                            :disabled="!userCanEdit || !editDocumentationNote"
                            filled
                            auto-grow
                ></v-textarea>
              </v-card-text>
            </v-card>
            <AhjChecklist v-if="dataReady"
                          title="Checklist"
                          :checklistTypeId="13"
                          :user-can-edit="userCanEdit"
                          :itemId="ahjInspection.id"
                          :itemType="itemType"
                          :ahjId="ahjId"
                          :checklistItems="ahjInspection.schedulingWithBrsTechnicianChecklist"
                          :isNested="true"
            ></AhjChecklist>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- THIRD COLUMN -->
      <v-col cols="12" md="3" class="px-sm-0 px-md-1 mb-3">
        <!-- SCHEDULING WITH CUSTOMER -->
        <v-card class="mb-3">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Scheduling with Customer
          </v-card-title>
          <v-card-text class="mt-4">
            <div v-for="item in getCustomFieldsForGroup(19)" :key="item.id">
              <v-select v-model="item.intValue"
                        @change="[item.valueWasChanged = true, dataWasChanged = true]"
                        :items="item.listOfValues"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        item-text="name"
                        item-value="id"
                        :label="item.fieldName"
                        filled
              ></v-select>
            </div>
            <v-text-field v-model="ahjInspection.timeWindowCallTime"
                          @change="dataWasChanged = true"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          label="Time to Call For Window"
                          filled
            ></v-text-field>
            <v-text-field v-model="ahjInspection.timeWindowPhone"
                          @change="dataWasChanged = true"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          label="Phone # for Time Window"
                          filled
            ></v-text-field>
            <v-card flat class="pa-0">
              <v-card-title class="pa-0">
                Scheduling with Customer Note
                <v-btn text x-small fab @click="editCustomerNote = !editCustomerNote">
                  <v-icon>edit</v-icon>
                </v-btn>
              </v-card-title>
              <v-card-text class="pa-0">
                <v-textarea v-model="ahjInspection.schedulingWithCustomerNote"
                            @change="dataWasChanged = true"
                            :readonly="!userCanEdit || !editCustomerNote"
                            :disabled="!userCanEdit || !editCustomerNote"
                            filled
                            auto-grow
                ></v-textarea>
              </v-card-text>
            </v-card>
            <AhjChecklist v-if="dataReady"
                          title="Scheduling Checklist"
                          :checklistTypeId="9"
                          :user-can-edit="userCanEdit"
                          :itemId="ahjInspection.id"
                          :itemType="itemType"
                          :ahjId="ahjId"
                          :checklistItems="ahjInspection.schedulingChecklist"
                          :isNested="true"
            ></AhjChecklist>
          </v-card-text>
        </v-card>

        <!-- OBTAINING RESULTS -->
        <v-card>
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Obtaining Results
          </v-card-title>
          <v-card-text class="mt-4">
            <v-text-field v-model="ahjInspection.obtainingResultsMethod"
                          @change="dataWasChanged = true"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          label="Obtaining Results Method"
                          filled
            ></v-text-field>
            <div v-for="item in getCustomFieldsForGroup(20)" :key="item.id">
              <v-select v-model="item.intValue"
                        @change="[item.valueWasChanged = true, dataWasChanged = true]"
                        :items="item.listOfValues"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        item-text="name"
                        item-value="id"
                        :label="item.fieldName"
                        filled
              ></v-select>
              <v-text-field v-if="showOtherField(item.intValue, item.listOfValues)"
                            v-model="item.textValue"
                            @change="[item.valueWasChanged = true, dataWasChanged = true]"
                            label="Other Value"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            filled
                            class="other-field"
              ></v-text-field>
            </div>
            <v-card flat class="pa-0">
              <v-card-title class="pa-0">
                Obtaining Results Notes
                <v-btn text x-small fab @click="editObtainingResultsNote = !editObtainingResultsNote">
                  <v-icon>edit</v-icon>
                </v-btn>
              </v-card-title>
              <v-card-text class="pa-0">
                <v-textarea v-model="ahjInspection.obtainingResultsNote"
                            @change="dataWasChanged = true"
                            :readonly="!userCanEdit || !editObtainingResultsNote"
                            :disabled="!userCanEdit || !editObtainingResultsNote"
                            filled
                            auto-grow
                ></v-textarea>
              </v-card-text>
            </v-card>
            <AhjChecklist v-if="dataReady"
                          title="Obtaining Results Checklist"
                          :checklistTypeId="10"
                          :user-can-edit="userCanEdit"
                          :itemId="ahjInspection.id"
                          :itemType="itemType"
                          :ahjId="ahjId"
                          :checklistItems="ahjInspection.obtainingResultsChecklist"
                          :isNested="true"
            ></AhjChecklist>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- FOURTH COLUMN -->
      <v-col cols="12" md="3" class="pl-sm-0 pl-md-1 mb-3">
        <!-- RE-INSPECTIONS -->
        <v-card class="mb-3">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Re-inspections
          </v-card-title>
          <v-card-text class="mt-4">
            <div v-for="item in getCustomFieldsForGroup(21)" :key="item.id">
              <v-select v-model="item.intValue"
                        @change="[item.valueWasChanged = true, dataWasChanged = true]"
                        :items="item.listOfValues"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        item-text="name"
                        item-value="id"
                        :label="item.fieldName"
                        filled
              ></v-select>
              <v-text-field v-if="showOtherField(item.intValue, item.listOfValues)"
                            v-model="item.textValue"
                            @change="[item.valueWasChanged = true, dataWasChanged = true]"
                            label="Other Value"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            filled
                            class="other-field"
              ></v-text-field>
            </div>
            <v-text-field v-model="ahjInspection.inspectionFee"
                          @change="dataWasChanged = true"
                          label="Re-inspection Fee Amount"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          filled
                          prepend-inner-icon="attach_money"
            ></v-text-field>
            <v-text-field v-model="ahjInspection.paymentMethod"
                          @change="dataWasChanged = true"
                          label="Payment Method"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          filled
            ></v-text-field>
            <v-card flat class="pa-0">
              <v-card-title class="pa-0">
                Re-inspection Notes
                <v-btn text x-small fab @click="editReinspectionNote = !editReinspectionNote">
                  <v-icon>edit</v-icon>
                </v-btn>
              </v-card-title>
              <v-card-text class="pa-0">
                <v-textarea v-model="ahjInspection.reinspectionNote"
                            @change="dataWasChanged = true"
                            :readonly="!userCanEdit || !editReinspectionNote"
                            :disabled="!userCanEdit || !editReinspectionNote"
                            filled
                            auto-grow
                ></v-textarea>
              </v-card-text>
            </v-card>
            <AhjChecklist v-if="dataReady"
                          title="Re-inspections Checklist"
                          :checklistTypeId="11"
                          :user-can-edit="userCanEdit"
                          :itemId="ahjInspection.id"
                          :itemType="itemType"
                          :ahjId="ahjId"
                          :checklistItems="ahjInspection.reinspectionsChecklist"
                          :isNested="true"
            ></AhjChecklist>
          </v-card-text>
        </v-card>

        <!-- NOTE TEMPLATES -->
        <AhjNoteTemplate v-if="dataReady"
                         :inspectionId="ahjInspection.id"
                         :ahjId="ahjId"
                         :user-can-edit="userCanEdit"
                         :noteTemplates="ahjInspection.noteTemplates"
        ></AhjNoteTemplate>

        <!-- IN-HOUSE MPUS -->
        <v-card class="mb-3">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            In-House MPUs
          </v-card-title>
          <v-card-text class="mt-4 pb-1">
            <div v-for="item in getCustomFieldsForGroup(22)" :key="item.id">
              <v-select v-model="item.intValue"
                        @change="[item.valueWasChanged = true, dataWasChanged = true]"
                        :items="item.listOfValues"
                        item-text="name"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        item-value="id"
                        :label="item.fieldName"
                        filled
              ></v-select>
            </div>
            <v-card flat class="pa-0">
              <v-card-title class="pa-0">
                MPU Inspection Notes
                <v-btn text x-small fab @click="editMPUNote = !editMPUNote">
                  <v-icon>edit</v-icon>
                </v-btn>
              </v-card-title>
              <v-card-text class="pa-0">
                <v-textarea v-model="ahjInspection.mpuInspectionNote"
                            @change="dataWasChanged = true"
                            :readonly="!userCanEdit || !editMPUNote"
                            :disabled="!userCanEdit || !editMPUNote"
                            filled
                            auto-grow
                ></v-textarea>
              </v-card-text>
            </v-card>
            <AhjContact v-if="dataReady"
                        title="Utility Service Department Contacts"
                        :contactTypeId="9"
                        :user-can-edit="userCanEdit"
                        :itemId="ahjInspection.id"
                        :itemType="itemType"
                        :ahjId="ahjId"
                        :contacts="ahjInspection.utilityServiceDeptContacts"
                        :isNested="true"
            ></AhjContact>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <!-- LOWER SECTION -->
    <h1 class="pb-2 mb-4 lower-section">Links and Contacts</h1>
    <!-- FIRST ROW -->
    <v-row no-gutters>
      <v-col cols="12" md="4" class="px-1">
        <AhjLink v-if="dataReady"
                 title="Scheduling Links"
                 :linkTypeId="1"
                 :user-can-edit="userCanEdit"
                 :itemId="ahjInspection.id"
                 :itemType="itemType"
                 :ahjId="ahjId"
                 :links="ahjInspection.schedulingLinks"
        ></AhjLink>
      </v-col>

      <v-col cols="12" md="4" class="px-1">
        <AhjLink v-if="dataReady"
                 title="Links for FOT"
                 :linkTypeId="2"
                 :user-can-edit="userCanEdit"
                 :itemId="ahjInspection.id"
                 :itemType="itemType"
                 :ahjId="ahjId"
                 :links="ahjInspection.fotLinks"
        ></AhjLink>
      </v-col>

      <v-col cols="12" md="4" class="px-1">
        <AhjLink v-if="dataReady"
                 title="Results Links"
                 :linkTypeId="3"
                 :user-can-edit="userCanEdit"
                 :itemId="ahjInspection.id"
                 :itemType="itemType"
                 :ahjId="ahjId"
                 :links="ahjInspection.resultsLinks"
        ></AhjLink>
      </v-col>
    </v-row>

    <!-- SECOND ROW -->
    <v-row no-gutters>
      <v-col cols="12" md="3" class="px-1">
        <AhjContact v-if="dataReady"
                    title="Scheduling Contacts"
                    :contactTypeId="2"
                    :user-can-edit="userCanEdit"
                    :itemId="ahjInspection.id"
                    :itemType="itemType"
                    :ahjId="ahjId"
                    :contacts="ahjInspection.schedulingContacts"
        ></AhjContact>
      </v-col>

      <v-col cols="12" md="3" class="px-1">
        <AhjContact v-if="dataReady"
                    title="Inspector Contacts"
                    :contactTypeId="4"
                    :user-can-edit="userCanEdit"
                    :itemId="ahjInspection.id"
                    :itemType="itemType"
                    :ahjId="ahjId"
                    :contacts="ahjInspection.feeContacts"
        ></AhjContact>
      </v-col>

      <v-col cols="12" md="3" class="px-1">
        <AhjContact v-if="dataReady"
                    title="Obtaining Results Contacts"
                    :contactTypeId="3"
                    :itemId="ahjInspection.id"
                    :user-can-edit="userCanEdit"
                    :itemType="itemType"
                    :ahjId="ahjId"
                    :contacts="ahjInspection.obtainingResultsContacts"
        ></AhjContact>
      </v-col>

      <v-col cols="12" md="3" class="px-1">
        <AhjServicingFot v-if="dataReady"
                         :servicingFots="ahjInspection.servicingFots"
        ></AhjServicingFot>
      </v-col>
    </v-row>

    <!-- THIRD ROW -->
    <v-row no-gutters class="mb-3">
      <v-col cols="12" md="12" class="px-1">
        <AhjChecklist v-if="dataReady" id="lower-checklist"
                      title="Noteworthy Reasons for Previous Inspection Failures"
                      :checklistTypeId="8"
                      :isNested="false"
                      :itemId="ahjInspection.id"
                      :user-can-edit="userCanEdit"
                      :itemType="itemType"
                      :ahjId="ahjId"
                      :checklistItems="ahjInspection.failureChecklist"
        ></AhjChecklist>
      </v-col>
    </v-row>

    <!-- FOURTH ROW -->
    <v-row no-gutters class="mb-6">
      <v-col cols="12" md="12" class="px-1">
        <AhjRequirement v-if="dataReady"
                        title="AHJ Specific Installation Requirements"
                        :transparent="false"
                        :requirementTypeId="5"
                        :itemType="itemType"
                        :itemId="ahjId"
                        :requirements="ahjInspection.installationRequirements"
        ></AhjRequirement>
      </v-col>
    </v-row>

    <v-dialog v-model="saveDialog" max-width="700">
      <v-card>
        <v-card-title>
          <span class="headline">Save Changes</span>
        </v-card-title>

        <v-divider></v-divider>

        <v-card-text class="pb-0">
          <v-radio-group v-model="ahjInspection.updateAllInState">
            <v-radio label="Save changes to this AHJ only" :value="false"></v-radio>
            <v-radio :label="`Save changes to all AHJs in ${ahjInspection.stateName}`" :value="true"></v-radio>
          </v-radio-group>
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions class="px-6">
          <v-spacer></v-spacer>
          <a @click="saveDialog = false"
             class="cancel-link mr-2"
          >Cancel</a>
          <v-btn v-if="ahjInspection.updateAllInState"
                 class="white--text mr-0 save-btn"
                 color="primaryButton"
                 @click="saveConfirmDialog = true"
          >Save</v-btn>
          <v-btn v-else
                 class="white--text mr-0 save-btn"
                 color="primaryButton"
                 @click="updateAhjInspection"
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
                 @click="updateAhjInspection"
          >Yes</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>


  </v-row>
</template>

<script>
  import moment from 'moment'
  import cloneDeep from 'lodash.clonedeep'
  import AhjChecklist from './components/AhjChecklist'
  import AhjContact from './components/AhjContacts'
  import AhjLink from './components/AhjLinks'
  import AhjNoteTemplate from './components/AhjNoteTemplates'
  import AhjRequirement from './components/AhjRequirements'
  import AhjServicingFot from './components/AhjServicingFots'

  import { AppMutations } from '@/stores/AppStore'
  import { getRequest, getRequestWithParams, putRequest, getSnackbar } from '@/helpers/helpers'
  import orderBy from "lodash.orderby";

  export default {
    name: 'ahjInspection',
    components: {
      AhjChecklist,
      AhjContact,
      AhjLink,
      AhjNoteTemplate,
      AhjRequirement,
      AhjServicingFot,
    },
    computed: {
      userCanEdit() {
        return this.$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'EDIT')
      },
    },
    data: () => ({
      ahjId: null,
      itemType: 'inspection',
      snackbar: {},
      saveDialog: false,
      saveConfirmDialog: false,
      dataWasChanged: false,
      dataReady: false,
      customFieldGroupAssignments: [],
      editSchedulingNote: false,
      editDocumentationNote: false,
      editInstructionsForBRSTech: false,
      editCustomerNote: false,
      editObtainingResultsNote: false,
      editReinspectionNote: false,
      editMPUNote: false,
      ahjInspection: {
        reinspectionFeeAmount: null,
        schedulingWithAhjChecklist: [],
        schedulingWithBrsTechnicianChecklist: [],
        schedulingChecklist: [],
        obtainingResultsChecklist: [],
        reinspectionsChecklist: [],
        noteTemplates: [],
        utilityServiceDeptContacts: [],
        schedulingLinks: [],
        fotLinks: [],
        resultsLinks: [],
        schedulingContacts: [],
        feeContacts: [],
        obtainingResultsContacts: [],
        servicingFots: [],
        failureChecklist: [],
        installationRequirements: []
      }
    }),
    methods: {
      async getAhjInspection() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/ahj/${this.ahjId}/inspection`, 'blueraven')

          if (data.servicingFots && data.servicingFots.length > 0) {
            data.servicingFots.forEach(servicingFot => {
              if (servicingFot.hierarchy && servicingFot.hierarchy.length > 0) {
                servicingFot.hierarchy = servicingFot.hierarchy[0]
              }
            })

            data.servicingFots = orderBy(data.servicingFots, fot => {
              if (fot.hierarchy && fot.hierarchy.orgName) {
                return fot.hierarchy.orgName.toLowerCase()
              }
            })
          } else {
            data.servicingFots = []
          }

          data.installationRequirements.forEach(requirement => {
            if (requirement.dateCreated && requirement.createdBy) {
              requirement.formattedDateCreated = moment(requirement.dateCreated).format('MM/DD/YY h:mm A')
            }

            if (requirement.dateModified && requirement.modifiedBy) {
              requirement.formattedDateModified = moment(requirement.dateModified).format('MM/DD/YY h:mm A')
            }
          })
          this.ahjInspection = cloneDeep(data)
          this.ahjInspection.updateAllInState = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving AHJ Inspection')
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      async getCustomFieldGroupAssignmentsForScreen() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const params = {sourceId: this.ahjInspection.id, objectTypeId: 3}
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
        this.getAhjInspection().then(() => {
          this.getCustomFieldGroupAssignmentsForScreen().then(() => this.dataReady = true)
        })
      },
      async updateAhjInspection() {
        this.saveDialog = false
        this.saveConfirmDialog = false
        let updateAllInState = this.ahjInspection.updateAllInState

        try {
          this.$store.commit(AppMutations.SET_LOADING, true)

          if (updateAllInState) {
            try {
              const {data} = await getRequest(`/ahj/${this.ahjId}/inspection/searchAhjsByState/${this.ahjInspection.stateId}`, 'blueraven')
              this.ahjInspection.ahjIds = []
              this.ahjInspection.inspectionIds = []

              data.forEach(row => {
                this.ahjInspection.ahjIds.push(row.ahjId)
                this.ahjInspection.inspectionIds.push(row.id)
              })
            } catch (e) {
              console.error('*** ERROR ***', e)
              this.snackbar = getSnackbar('ERROR', 'An error occurred when preparing to update all inspections in ' + this.ahjInspection.stateName)
            }
          }

          this.ahjInspection.customFieldGroups = this.customFieldGroupAssignments
          const {data} = await putRequest(`/ahj/${this.ahjId}/inspection/${this.ahjInspection.id}`, this.ahjInspection, 'blueraven')
          this.ahjInspection = cloneDeep(data)
          this.ahjInspection.updateAllInState = false
          this.dataWasChanged = false
          this.resetCustomFieldValueWasChangedFlags()
          let successMessage = updateAllInState ? 'All inspections in ' + this.ahjInspection.stateName + ' have been updated successfully' : 'Inspection updated successfully'
          this.snackbar = getSnackbar('SUCCESS', successMessage)
        } catch (e) {
          console.error('*** ERROR ***', e)
          let errorMessage = updateAllInState ? 'An error occurred when attempting to update all inspections in ' + this.ahjInspection.stateName : 'Failed to update inspection'
          this.snackbar = getSnackbar('ERROR', errorMessage)
        }

        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async created () {
      this.ahjId = parseInt(this.$route.params.ahjId)
      this.getAhjInspection().then(() => {
        this.getCustomFieldGroupAssignmentsForScreen().then(() => this.dataReady = true)
      })
    }
  }
</script>

<style scoped lang="scss">
  .padded-sides {
    padding: 0 5px;
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
  .empty-list {
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
  .row {
    width: 100%;
  }
  .lower-section {
    border-bottom: 1px solid #ccc;
    width: 100%;
  }
  .other-field {
    margin-top: -20px;
  }
</style>
