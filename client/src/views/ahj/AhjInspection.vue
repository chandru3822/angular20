<!--suppress CssInvalidPseudoSelector -->
<template>
  <v-row no-gutters>
    <v-col class="text-right py-1" cols="12">
      <a @click="resetForm"
         class="cancel-link"
         style="margin-right: 10px"
      >Cancel</a>
      <v-btn id="save-btn"
             color="primaryButton"
             class="white--text mr-0"
             @click="saveAhjInspection"
      >Save</v-btn>
    </v-col>

    <!-- UPPER SECTION -->
    <v-row no-gutters>
      <!-- FIRST COLUMN -->
      <v-col cols="12" md="3" class="pr-sm-0 pr-md-1 mb-3">
        <!-- SCHEDULING WITH AHJ -->
        <v-card>
          <v-card-title class="primaryCustom white--text font-weight-bold title-with-icon">
            Scheduling with AHJ
            <router-link :to="'/schedule'" title="Go to Scheduling Tool">
              <v-icon class="white--text">launch</v-icon>
            </router-link>
          </v-card-title>
          <v-card-text class="mt-4">
            <div v-for="item in getCustomFieldsForGroup(17)" :key="item.id">
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
              ></v-text-field>
            </div>
            <v-text-field v-model="ahjInspection.requiredInspectionTypes"
                          label="Type of Inspections Required"
                          filled
            ></v-text-field>
            <v-textarea v-model="ahjInspection.schedulingNote"
                        label="Scheduling Note"
                        filled
                        auto-grow
            ></v-textarea>
            <AhjChecklist v-if="dataReady"
                          title="Checklist"
                          :checklistTypeId="12"
                          :itemId="ahjInspection.id"
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
              ></v-text-field>
            </div>
            <v-textarea v-model="ahjInspection.technicianInstructionNote"
                        label="Instructions for BRS Technician"
                        filled
                        auto-grow
            ></v-textarea>
            <v-textarea v-model="ahjInspection.documentationNote"
                        label="Documentation Notes"
                        filled
                        auto-grow
            ></v-textarea>
            <AhjChecklist v-if="dataReady"
                          title="Checklist"
                          :checklistTypeId="13"
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
                        :items="item.listOfValues"
                        item-text="name"
                        item-value="id"
                        :label="item.fieldName"
                        filled
              ></v-select>
            </div>
            <v-text-field v-model="ahjInspection.timeWindowCallTime"
                          label="Time to Call For Window"
                          filled
            ></v-text-field>
            <v-text-field v-model="ahjInspection.timeWindowPhone"
                          label="Phone # for Time Window"
                          filled
            ></v-text-field>
            <v-textarea v-model="ahjInspection.schedulingWithCustomerNote"
                        label="Scheduling with Customer Note"
                        filled
                        auto-grow
            ></v-textarea>
            <AhjChecklist v-if="dataReady"
                          title="Scheduling Checklist"
                          :checklistTypeId="9"
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
                          label="Obtaining Results Method"
                          filled
            ></v-text-field>
            <div v-for="item in getCustomFieldsForGroup(20)" :key="item.id">
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
              ></v-text-field>
            </div>
            <v-textarea v-model="ahjInspection.obtainingResultsNote"
                        label="Obtaining Results Notes"
                        filled
                        auto-grow
            ></v-textarea>
            <AhjChecklist v-if="dataReady"
                          title="Obtaining Results Checklist"
                          :checklistTypeId="10"
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
              ></v-text-field>
            </div>
            <v-text-field v-model="ahjInspection.inspectionFee"
                          label="Re-inspection Fee Amount"
                          filled
                          prepend-inner-icon="attach_money"
            ></v-text-field>
            <v-text-field v-model="ahjInspection.paymentMethod"
                          label="Payment Method"
                          filled
            ></v-text-field>
            <v-textarea v-model="ahjInspection.reinspectionNote"
                        label="Re-inspection Notes"
                        filled
                        auto-grow
            ></v-textarea>
            <AhjChecklist v-if="dataReady"
                          title="Re-inspections Checklist"
                          :checklistTypeId="11"
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
                        :items="item.listOfValues"
                        item-text="name"
                        item-value="id"
                        :label="item.fieldName"
                        filled
              ></v-select>
            </div>
            <v-textarea v-model="ahjInspection.mpuInspectionNote"
                        label="MPU Inspection Notes"
                        filled
                        auto-grow
            ></v-textarea>
            <AhjContact v-if="dataReady"
                        title="Utility Service Department Contacts"
                        :contactTypeId="9"
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
                      :itemType="itemType"
                      :ahjId="ahjId"
                      :checklistItems="ahjInspection.failureChecklist"
        ></AhjChecklist>
      </v-col>
    </v-row>

    <!-- FOURTH ROW -->
    <v-row no-gutters>
      <v-col cols="12" md="12" class="px-1">
        <AhjRequirement v-if="dataReady"
                        title="AHJ Specific Installation Requirements"
                        :transparent="false"
                        :requirementTypeId="5"
                        :itemType="itemType"
                        :ahjId="ahjId"
                        :requirements="ahjInspection.installationRequirements"
        ></AhjRequirement>
      </v-col>
    </v-row>

    <Snackbar :snackbar="snackbar"></Snackbar>
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
  import Snackbar from '@/components/Snackbar'
  import { AppMutations } from '@/stores/AppStore'
  import { getRequest, getRequestWithParams, putRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: 'ahjInspection',
    components: {
      AhjChecklist,
      AhjContact,
      AhjLink,
      AhjNoteTemplate,
      AhjRequirement,
      AhjServicingFot,
      Snackbar
    },
    data: () => ({
      ahjId: null,
      itemType: 'inspection',
      snackbar: {},
      dataReady: false,
      customFieldGroupAssignments: [],
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
      async getAhjInspection() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/ahj/${this.ahjId}/inspection`, 'blueraven')
          data.servicingFots.forEach(servicingFot => servicingFot.hierarchy = servicingFot.hierarchy[0])
          data.installationRequirements.forEach(requirement => {
            if (requirement.dateCreated && requirement.createdBy) {
              requirement.formattedDateCreated = moment(requirement.dateCreated).format('MM/DD/YY h:mm A')
            }

            if (requirement.dateModified && requirement.modifiedBy) {
              requirement.formattedDateModified = moment(requirement.dateModified).format('MM/DD/YY h:mm A')
            }
          })
          this.ahjInspection = cloneDeep(data)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving AHJ Inspection')
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
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.dataReady = false
        this.getAhjInspection().then(() => {
          this.getCustomFieldGroupAssignmentsForScreen().then(() => this.dataReady = true)
        })
      },
      async saveAhjInspection() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.ahjInspection.customFieldGroups = this.customFieldGroupAssignments
          const {data} = await putRequest(`/ahj/${this.ahjId}/inspection/${this.ahjInspection.id}`, this.ahjInspection, 'blueraven')
          this.ahjInspection = cloneDeep(data)
          this.snackbar = getSnackbar('SUCCESS', 'AHJ Inspection saved')
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error saving AHJ Inspection')
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
  .row {
    width: 100%;
  }
  .lower-section {
    border-bottom: 1px solid #ccc;
    width: 100%;
  }
</style>
