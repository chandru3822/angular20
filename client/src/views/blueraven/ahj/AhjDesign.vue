<template>
  <v-row no-gutters>
    <v-col class="ahj-form-btns py-1" cols="12">
      <a v-if="dataWasChanged"
         @click="resetForm"
         class="cancel-link"
         style="margin-right: 10px"
      >Cancel</a>
      <v-btn class="white--text mr-0 save-btn"
             v-if="userCanEdit"
             color="primaryButton"
             @click="saveDialog = true"
      >Save</v-btn>
    </v-col>

    <v-row no-gutters class="mb-3">
      <!-- FIRST COLUMN -->
      <v-col cols="12" md="4" class="pr-sm-0 pr-md-1 mb-sm-0 mb-md-3">
        <!-- CODES -->
        <v-card class="mb-3">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Codes
          </v-card-title>
          <v-card-text class="mt-4">
            <div class="flex-display" v-for="item in getCustomFieldsForGroup(12)" :key="item.id">
              <CustomValueInput
                :callback="(item) => updateDirtyValue(item)"
                :readonly="false"
                :showFieldName="false"
                :field="item"
                :filled-style="true"
              />
              <AhjDocumentsButton v-if="item.customFieldId === 1"
                                  title="Documents"
                                  :user-can-edit="userCanEdit"
                                  :documentTypeId="17"
                                  :sourceId="ahjDesign.id"
                                  :itemId="ahjId"
              ></AhjDocumentsButton>
            </div>
            <v-textarea v-model="ahjDesign.referenceStandards"
                        @change="dataWasChanged = true"
                        label="Reference Standards"
                        filled
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        auto-grow
            ></v-textarea>
          </v-card-text>
        </v-card>

        <!-- ENGINEERING -->
        <v-card class="mb-3">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Engineering
          </v-card-title>
          <v-card-text class="mt-4">
            <div v-for="item in getCustomFieldsForGroup(13)" :key="item.id">
              <CustomValueInput
                :callback="(item) => updateDirtyValue(item)"
                :readonly="false"
                :showFieldName="false"
                :field="item"
                :filled-style="true"
              />
            </div>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- SECOND COLUMN -->
      <v-col cols="12" md="8" class="pl-sm-0 pl-md-1 mb-sm-2 mb-md-3">
        <!-- DESIGN REQUIREMENTS -->
        <v-card class="mb-3 pb-10">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Design Requirements
          </v-card-title>
          <v-card-text class="mt-2">
            <v-card-subtitle class="font-weight-bold px-4 pb-3 mb-5">
              PV Design Basics
            </v-card-subtitle>
            <div class="flex-display flex-wrap justify-space-between px-2">
              <div class="flex-display custom-field mx-2" v-for="item in getCustomFieldsForGroup(14)" :key="item.id">
                <CustomValueInput
                  :callback="(item) => updateDirtyValue(item)"
                  :readonly="false"
                  :showFieldName="false"
                  :field="item"
                  :filled-style="true"
                />
                <AhjDocumentsButton v-if="item.customFieldId === 7"
                                    title="Documents"
                                    :user-can-edit="userCanEdit"
                                    :documentTypeId="18"
                                    :sourceId="ahjDesign.id"
                                    :itemId="ahjId"
                ></AhjDocumentsButton>
              </div>
            </div>
            <AhjRequirement v-if="dataReady"
                            title="PV Design Notes and Additional Requirements"
                            :requirementTypeId="3"
                            :itemType="itemType"
                            :user-can-edit="userCanEdit"
                            :itemId="ahjId"
                            :requirements="ahjDesign.designRequirements"
                            :transparent="true"
                            :isNested="true"
            ></AhjRequirement>
          </v-card-text>
        </v-card>

        <!-- ELECTRICAL REQUIREMENTS -->
        <v-card class="mb-3 pb-10">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Electrical Requirements
          </v-card-title>
          <v-card-text class="mt-2">
            <v-card-subtitle class="font-weight-bold px-4 pb-3 mb-5">
              Electrical Design Basics
            </v-card-subtitle>
            <div class="flex-display flex-wrap justify-space-between px-2">
              <div class="flex-display custom-field mx-2" v-for="item in getCustomFieldsForGroup(15)" :key="item.id">
                <CustomValueInput
                  :callback="(item) => updateDirtyValue(item)"
                  :readonly="false"
                  :showFieldName="false"
                  :field="item"
                  :filled-style="true"
                />
                <AhjDocumentsButton v-if="item.customFieldId === 10"
                                    title="Documents"
                                    :user-can-edit="userCanEdit"
                                    :documentTypeId="19"
                                    :sourceId="ahjDesign.id"
                                    :itemId="ahjId"
                ></AhjDocumentsButton>
              </div>
            </div>
            <AhjRequirement v-if="dataReady"
                            title="Electrical Design Notes and Additional Requirements"
                            :requirementTypeId="1"
                            :user-can-edit="userCanEdit"
                            :itemType="itemType"
                            :itemId="ahjId"
                            :requirements="ahjDesign.electricalRequirements"
                            :transparent="true"
                            :isNested="true"
            ></AhjRequirement>
          </v-card-text>
        </v-card>

        <!-- STRUCTURAL REQUIREMENTS -->
        <v-card class="pb-10">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Structural Requirements
          </v-card-title>
          <v-card-text class="mt-2">
            <v-card-subtitle class="font-weight-bold px-4 pb-3 mb-5">
              Structural Design Loads
            </v-card-subtitle>
            <div class="flex-display flex-wrap justify-space-between px-2">
              <div class="flex-display custom-field mx-2"
                   v-for="item in getCustomFieldsForGroup(16)" :key="item.id">
                <CustomValueInput
                  :callback="(item) => updateDirtyValue(item)"
                  :readonly="false"
                  :showFieldName="false"
                  :field="item"
                  :filled-style="true"
                />
                <AhjDocumentsButton v-if="item.customFieldId === 14"
                                    title="Documents"
                                    :user-can-edit="userCanEdit"
                                    :documentTypeId="13"
                                    :sourceId="ahjDesign.id"
                                    :itemId="ahjId"
                ></AhjDocumentsButton>
                <AhjDocumentsButton v-if="item.customFieldId === 16"
                                    title="Documents"
                                    :user-can-edit="userCanEdit"
                                    :documentTypeId="14"
                                    :sourceId="ahjDesign.id"
                                    :itemId="ahjId"
                ></AhjDocumentsButton>
                <AhjDocumentsButton v-if="item.customFieldId === 17"
                                    title="Documents"
                                    :user-can-edit="userCanEdit"
                                    :documentTypeId="15"
                                    :sourceId="ahjDesign.id"
                                    :itemId="ahjId"
                ></AhjDocumentsButton>
                <AhjDocumentsButton v-if="item.customFieldId === 19"
                                    title="Documents"
                                    :user-can-edit="userCanEdit"
                                    :documentTypeId="16"
                                    :sourceId="ahjDesign.id"
                                    :itemId="ahjId"
                ></AhjDocumentsButton>
              </div>
              <v-text-field class="structural-design-text-field mx-2"
                            v-model="ahjDesign.groundSnowLoad"
                            @change="dataWasChanged = true"
                            label="Ground Snow Load"
                            filled
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
              ></v-text-field>
              <v-text-field class="structural-design-text-field mx-2"
                            v-model="ahjDesign.roofSnowLoad"
                            @change="dataWasChanged = true"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            label="Roof Snow Load"
                            filled
              ></v-text-field>
              <v-text-field class="structural-design-text-field mx-2"
                            v-model="ahjDesign.windSpeed"
                            @change="dataWasChanged = true"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            label="Wind Speed"
                            filled
              ></v-text-field>
            </div>
            <AhjRequirement v-if="dataReady"
                            title="Structural Design Notes and Additional Requirements"
                            :requirementTypeId="2"
                            :itemType="itemType"
                            :user-can-edit="userCanEdit"
                            :itemId="ahjId"
                            :requirements="ahjDesign.structuralRequirements"
                            :transparent="true"
                            :isNested="true"
            ></AhjRequirement>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <v-dialog v-model="saveDialog" max-width="700">
      <v-card>
        <v-card-title>
          <span class="headline">Save Changes</span>
        </v-card-title>

        <v-divider></v-divider>

        <v-card-text class="pb-0">
          <v-radio-group v-model="ahjDesign.updateAllInState">
            <v-radio label="Save changes to this AHJ only" :value="false"></v-radio>
            <v-radio :label="`Save changes to all AHJs in ${ahjDesign.stateName}`" :value="true"></v-radio>
          </v-radio-group>
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions class="px-6">
          <v-spacer></v-spacer>
          <a @click="saveDialog = false"
             class="cancel-link mr-2"
          >Cancel</a>
          <v-btn v-if="ahjDesign.updateAllInState"
                 class="white--text mr-0 save-btn"
                 color="primaryButton"
                 @click="saveConfirmDialog = true"
          >Save</v-btn>
          <v-btn v-else
                 class="white--text mr-0 save-btn"
                 color="primaryButton"
                 @click="updateAhjDesign"
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
                 @click="updateAhjDesign"
          >Yes</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>


  </v-row>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import AhjDocumentsButton from './components/AhjDocumentsButton'
  import AhjRequirement from './components/AhjRequirements'
  import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
  import { AppMutations } from '@/stores/AppStore'
  import { getRequest, getRequestWithParams, putRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: 'ahjDesign',
    components: {
      AhjDocumentsButton,
      AhjRequirement,
      CustomValueInput
    },
    computed: {
      userCanEdit() {
        return this.$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'EDIT')
      },
    },
    data: () => ({
      ahjId: null,
      itemType: 'design',
      snackbar: {},
      saveDialog: false,
      saveConfirmDialog: false,
      dataWasChanged: false,
      dataReady: false,
      customFieldGroupAssignments: [],
      ahjDesign: {
        designRequirements: [],
        electricalRequirements: [],
        structuralRequirements: [],
        contacts: []
      }
    }),
    methods: {
      updateDirtyValue(item) {
        item.valueWasChanged = true
        this.dataWasChanged = true
      },
      async getAhjDesign() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/ahj/${this.ahjId}/design`, 'blueraven')
          window.document.title = `AHJ - ${data.ahjName}`
          this.ahjDesign = cloneDeep(data)
          this.ahjDesign.updateAllInState = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving AHJ Design')
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      async getCustomFieldGroupAssignmentsForScreen() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          if (this.ahjDesign.id) {
            const params = {sourceId: this.ahjDesign.id, objectTypeId: 1}
            const {data} = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupAssignmentsByObjectType`, {params}, 'blueraven')
            this.customFieldGroupAssignments = cloneDeep(data)
          } else {
            console.error('*** ERROR ***', 'Missing parameter "sourceId"')
            this.snackbar = getSnackbar('ERROR', 'Error retrieving custom fields')
          }
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
      resetCustomFieldValueWasChangedFlags() {
        this.customFieldGroupAssignments.forEach(group => {
          group.customFieldValues.forEach(cfv => cfv.valueWasChanged = false)
        })
      },
      async resetForm() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.dataWasChanged = false
        this.dataReady = false
        this.getAhjDesign().then(() => {
          this.getCustomFieldGroupAssignmentsForScreen().then(() => this.dataReady = true)
        })
      },
      async updateAhjDesign() {
        this.saveDialog = false
        this.saveConfirmDialog = false
        let updateAllInState = this.ahjDesign.updateAllInState

        try {
          this.$store.commit(AppMutations.SET_LOADING, true)

          if (updateAllInState) {
            try {
              const {data} = await getRequest(`/ahj/${this.ahjId}/design/searchAhjsByState/${this.ahjDesign.stateId}`, 'blueraven')
              this.ahjDesign.ahjIds = []
              this.ahjDesign.designIds = []

              data.forEach(row => {
                this.ahjDesign.ahjIds.push(row.ahjId)
                this.ahjDesign.designIds.push(row.id)
              })
            } catch (e) {
              console.error('*** ERROR ***', e)
              this.snackbar = getSnackbar('ERROR', 'An error occurred when preparing to update all designs in ' + this.ahjDesign.stateName)
            }
          }

          this.ahjDesign.customFieldGroups = this.customFieldGroupAssignments
          const {data} = await putRequest(`/ahj/${this.ahjId}/design/${this.ahjDesign.id}`, this.ahjDesign, 'blueraven')
          this.ahjDesign = cloneDeep(data)
          this.ahjDesign.updateAllInState = false
          this.dataWasChanged = false
          this.resetCustomFieldValueWasChangedFlags()
          let successMessage = updateAllInState ? 'All designs in ' + this.ahjDesign.stateName + ' have been updated successfully' : 'Design updated successfully'
          this.snackbar = getSnackbar('SUCCESS', successMessage)
        } catch (e) {
          console.error('*** ERROR ***', e)
          let errorMessage = updateAllInState ? 'An error occurred when attempting to update all designs in ' + this.ahjDesign.stateName : 'Failed to update design'
          this.snackbar = getSnackbar('ERROR', errorMessage)
        }

        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async created () {
      this.ahjId = parseInt(this.$route.params.ahjId)
      this.getAhjDesign().then(() => {
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
  .v-text-field,
  .v-select,
  .v-input ::v-deep label,
  .v-list-item__title {
    font-size: 0.95em !important;
  }
  .cancel-link {
    font-size: 0.85em !important;
  }
  .cancel-link:hover {
    text-decoration: underline;
  }
  .save-btn {
    margin: 10px 5px 10px 0;
    text-transform: capitalize;
  }
  .v-card__title,
  .v-toolbar__title {
    font-size: 1em !important;
  }
  .v-card__subtitle {
    color: var(--v-primaryText-base) !important;
    border-bottom: 1px solid var(--v-primaryText-base) !important;
  }

  .custom-field,
  .structural-design-text-field {
    width: 100%;
  }
  @media (min-width: 960px) {
    .custom-field,
    .structural-design-text-field {
      max-width: 46%;
    }
  }
</style>
