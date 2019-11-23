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
             @click="saveAhjInspection"
      >Save</v-btn>
    </v-col>

    <v-row no-gutters>
      <!-- FIRST COLUMN -->
      <v-col cols="12" md="3" class="px-1 mb-3">
        <!-- SCHEDULING WITH AHJ -->
        <v-card>
          <v-card-title class="primaryCustom white--text font-weight-bold title-with-icon">
            Scheduling with AHJ
            <router-link :to="'/schedule'" title="Go to Scheduling Tool">
              <v-icon class="white--text">launch</v-icon>
            </router-link>
          </v-card-title>
          <v-card-text class="mt-4">
            <div>
              <v-select label="Primary Scheduling Method"
                        filled
              ></v-select>
              <v-text-field v-show="false"
                            label="Other Value"
                            filled
              ></v-text-field>
            </div>
            <v-select label="Information to have Handy"
                      filled
            ></v-select>
            <v-select label="Scheduling Lead Time (Days)"
                      filled
            ></v-select>
            <v-select label="Inspection Capacity per Day"
                      filled
            ></v-select>
            <v-select label="Site Access Required"
                      filled
            ></v-select>
            <v-select label="Mid-Point / Rough Inspection Required"
                      filled
            ></v-select>
            <v-select label="Mid-Point Inspection Scheduling Lead Time (Days)"
                      filled
            ></v-select>
            <v-select label="SolaDeck Access Required"
                      filled
            ></v-select>
            <v-select label="Placard Required"
                      filled
            ></v-select>
            <v-text-field label="Type of Inspections Required"
                          filled
            ></v-text-field>
            <v-textarea label="Scheduling Note"
                        filled
                        auto-grow
            ></v-textarea>
            <AhjChecklist v-if="dataReady"
                          title="Checklist"
                          :checklistTypeId="12"
                          :inspectionId="ahjInspection.id"
                          :ahjId="ahjId"
                          :checklistItems="ahjInspection.schedulingWithAhjChecklist"
            ></AhjChecklist>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- SECOND COLUMN -->
      <v-col cols="12" md="3" class="px-1 mb-3">
        <!-- SCHEDULING WITH BRS TECHNICIAN -->
        <v-card>
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Scheduling with BRS Technician
          </v-card-title>
          <v-card-text class="mt-4">
            <v-select label="Representative Required On-Site"
                      filled
            ></v-select>
            <v-select label="Fall Protection for Inspector Required"
                      filled
            ></v-select>
            <v-select label="Special Equipment Needed"
                      filled
            ></v-select>
            <v-textarea label="Instructions for BRS Technician"
                        filled
                        auto-grow
            ></v-textarea>
            <v-select label="Plans Required On-Site"
                      filled
            ></v-select>
            <v-select label="Special Documents Required"
                      filled
            ></v-select>
            <v-textarea label="Documentation Notes"
                        filled
                        auto-grow
            ></v-textarea>
            <AhjChecklist v-if="dataReady"
                          title="Checklist"
                          :checklistTypeId="13"
                          :inspectionId="ahjInspection.id"
                          :ahjId="ahjId"
                          :checklistItems="ahjInspection.schedulingWithBrsTechChecklist"
            ></AhjChecklist>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- THIRD COLUMN -->
      <v-col cols="12" md="3" class="px-1 mb-3">
        <!-- SCHEDULING WITH CUSTOMER -->
        <v-card class="mb-3">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Scheduling with Customer
          </v-card-title>
          <v-card-text class="mt-4">
            <v-select label="Homeowner Required to be On-Site"
                      filled
            ></v-select>
            <v-select label="Call For Time Window"
                      filled
            ></v-select>
            <v-text-field label="Time to Call For Window"
                          filled
            ></v-text-field>
            <v-text-field label="Phone # for Time Window"
                          filled
            ></v-text-field>
            <v-textarea label="Scheduling with Customer Note"
                        filled
                        auto-grow
            ></v-textarea>
            <AhjChecklist v-if="dataReady"
                          title="Scheduling Checklist"
                          :checklistTypeId="9"
                          :inspectionId="ahjInspection.id"
                          :ahjId="ahjId"
                          :checklistItems="ahjInspection.schedulingChecklist"
            ></AhjChecklist>
          </v-card-text>
        </v-card>

        <!-- OBTAINING RESULTS -->
        <v-card>
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Obtaining Results
          </v-card-title>
          <v-card-text class="mt-4">
            <v-text-field label="Obtaining Results Method"
                          filled
            ></v-text-field>
            <v-select label="Results Documentation"
                      filled
            ></v-select>
            <v-textarea label="Obtaining Results Notes"
                        filled
                        auto-grow
            ></v-textarea>
            <AhjChecklist v-if="dataReady"
                          title="Obtaining Results Checklist"
                          :checklistTypeId="10"
                          :inspectionId="ahjInspection.id"
                          :ahjId="ahjId"
                          :checklistItems="ahjInspection.obtainingResultsChecklist"
            ></AhjChecklist>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- FOURTH COLUMN -->
      <v-col cols="12" md="3" class="px-1 mb-3">
        <!-- RE-INSPECTIONS -->
        <v-card class="mb-3">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Re-inspections
          </v-card-title>
          <v-card-text class="mt-4">
            <v-select label="Re-inspection Fee Required"
                      filled
            ></v-select>
            <v-text-field v-model="ahjInspection.reinspectionFeeAmount"
                          label="Re-inspection Fee Amount"
                          filled
                          prepend-inner-icon="attach_money"
            ></v-text-field>
            <v-text-field label="Payment Method"
                          filled
            ></v-text-field>
            <v-textarea label="Re-inspection Notes"
                        filled
                        auto-grow
            ></v-textarea>
            <AhjChecklist v-if="dataReady"
                          title="Re-inspections Checklist"
                          :checklistTypeId="11"
                          :inspectionId="ahjInspection.id"
                          :ahjId="ahjId"
                          :checklistItems="ahjInspection.reinspectionsChecklist"
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
          <v-card-text class="mt-4">
            <v-select label="Homeowner Required for Inspection"
                      filled
            ></v-select>
            <v-select label="BRS Tech Required for Inspection"
                      filled
            ></v-select>
            <v-textarea label="MPU Inspection Notes"
                        filled
                        auto-grow
            ></v-textarea>
            <AhjContact v-if="dataReady"
                        title="Utility Service Department Contacts"
                        :contactTypeId="9"
                        :inspectionId="ahjInspection.id"
                        :ahjId="ahjId"
                        :contacts="ahjInspection.utilityServiceDeptContacts"
            ></AhjContact>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-row>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import AhjChecklist from './components/AhjChecklist.vue'
  import AhjContact from './components/AhjContacts.vue'
  import AhjNoteTemplate from './components/AhjNoteTemplates.vue'
  import Snackbar from '@/components/Snackbar.vue'
  import { AppMutations } from '@/stores/AppStore'
  import { getRequest, getRequestWithParams, putRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: 'ahjInspection',
    components: {
      AhjChecklist,
      AhjContact,
      AhjNoteTemplate,
      Snackbar
    },
    data: () => ({
      ahjId: null,
      snackbar: {},
      dataReady: false,
      customFieldGroupAssignments: [],
      ahjInspection: {
        reinspectionFeeAmount: null,
        schedulingWithAhjChecklist: [],
        schedulingWithBrsTechChecklist: [],
        schedulingChecklist: [],
        obtainingResultsChecklist: [],
        reinspectionsChecklist: [],
        noteTemplates: [
          {
            id: 13,
            title: 'AHJ INSPECTION MASTER NOTE',
            note: 'AHJ INSPECTION MASTER NOTE, AURORA, (1 solar PV permit) Homeowner not required as long as all equipment is accessible (see install sheet/install photos). FOT required with ladder tall enough to reach roof, Schedule FOT 2 first. Schedule Electrical Final inspection online far in advance. FOT must bring Post install Engineering Letter, it takes the place of the Framing Final inspection.  - As-built or MPU permit?  - Locked gates or pets?  - Homeowner required this inspection?  - Plans on site?  - Tall ladder needed?  - Correct FOT scheduled? - Documents added to FOT calendar?  - Engineering Letter sent to UPS?  - Scheduled with AHJ?'
          },
          {
            id: 14,
            title: 'Unhappy CEO',
            note: 'Scott is sad cuz his favorite restaurant is closed'
          }
        ],
        utilityServiceDeptContacts: []
      }
    }),
    methods: {
      async getCustomFieldGroupAssignmentsForScreen() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const params = {
            sourceId: this.ahjInspection.id,
            objectTypeId: 4
          }
          const {data} = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupAssignmentsByObjectType`, {params}, 'blueraven')
          this.customFieldGroupAssignments = cloneDeep(data)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getAhjInspection() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/ahj/${this.ahjId}/inspection`, 'blueraven')
          this.ahjInspection = cloneDeep(data)
          this.$store.commit(AppMutations.SET_LOADING, false)
          console.log("AHJ Inspection:", this.ahjInspection)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving AHJ Inspection')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
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
          this.dataReady = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        })
      },
      async saveAhjInspection() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.ahjInspection.customFieldGroups = this.customFieldGroupAssignments
          const {data} = await putRequest(`/ahj/${this.ahjId}/inspection/${this.ahjInspection.id}`, this.ahjInspection, 'blueraven')
          this.ahjInspection = cloneDeep(data)
          this.snackbar = getSnackbar('SUCCESS', 'AHJ Inspection Saved')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Inspection')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async created () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.ahjId = parseInt(this.$route.params.ahjId)

      this.getAhjInspection().then(() => {
        this.getCustomFieldGroupAssignmentsForScreen()
        this.dataReady = true
        this.$store.commit(AppMutations.SET_LOADING, false)
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
</style>
