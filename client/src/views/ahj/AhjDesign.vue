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
             @click="saveAhjDesign"
      >Save</v-btn>
    </v-col>

    <v-row no-gutters>
      <!-- FIRST COLUMN -->
      <v-col cols="12" md="4" class="pr-sm-0 pr-md-1 mb-sm-0 mb-md-3">
        <!-- CODES -->
        <v-card class="mb-3">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Codes
          </v-card-title>
          <v-card-text class="mt-4">
            <div class="flex-display" v-for="item in getCustomFieldsForGroup(12)" :key="item.id">
              <v-select v-model="item.intValue"
                        :items="item.listOfValues"
                        item-text="name"
                        item-value="id"
                        :label="item.fieldName"
                        filled
              ></v-select>
              <AhjDocumentsButton v-if="item.customFieldId === 1"
                                  title="Documents"
                                  :documentTypeId="17"
                                  :sourceId="ahjDesign.id"
                                  :ahjId="ahjId"
              ></AhjDocumentsButton>
            </div>
            <v-textarea v-model="ahjDesign.referenceStandards"
                        label="Reference Standards"
                        filled
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
              <v-select v-model="item.intValue"
                        :items="item.listOfValues"
                        item-text="name"
                        item-value="id"
                        :label="item.fieldName"
                        filled
              ></v-select>
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
                <v-select v-model="item.intValue"
                          :items="item.listOfValues"
                          item-text="name"
                          item-value="id"
                          :label="item.fieldName"
                          filled
                ></v-select>
                <AhjDocumentsButton v-if="item.customFieldId === 7"
                                    title="Documents"
                                    :documentTypeId="18"
                                    :sourceId="ahjDesign.id"
                                    :ahjId="ahjId"
                ></AhjDocumentsButton>
              </div>
            </div>
            <AhjRequirement v-if="dataReady"
                            title="PV Design Notes and Additional Requirements"
                            :transparent="true"
                            :requirementTypeId="3"
                            :itemType="itemType"
                            :ahjId="ahjId"
                            :requirements="ahjDesign.designRequirements"
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
                <v-select v-model="item.intValue"
                          :items="item.listOfValues"
                          item-text="name"
                          item-value="id"
                          :label="item.fieldName"
                          filled
                ></v-select>
                <AhjDocumentsButton v-if="item.customFieldId === 10"
                                    title="Documents"
                                    :documentTypeId="19"
                                    :sourceId="ahjDesign.id"
                                    :ahjId="ahjId"
                ></AhjDocumentsButton>
              </div>
            </div>
            <AhjRequirement v-if="dataReady"
                            title="Electrical Design Notes and Additional Requirements"
                            :transparent="true"
                            :requirementTypeId="1"
                            :itemType="itemType"
                            :ahjId="ahjId"
                            :requirements="ahjDesign.electricalRequirements"
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
              <div class="flex-display custom-field mx-2" v-for="item in getCustomFieldsForGroup(16)" :key="item.id">
                <v-select v-model="item.intValue"
                          :items="item.listOfValues"
                          item-text="name"
                          item-value="id"
                          :label="item.fieldName"
                          filled
                ></v-select>
                <AhjDocumentsButton v-if="item.customFieldId === 14"
                                    title="Documents"
                                    :documentTypeId="13"
                                    :sourceId="ahjDesign.id"
                                    :ahjId="ahjId"
                ></AhjDocumentsButton>
                <AhjDocumentsButton v-if="item.customFieldId === 16"
                                    title="Documents"
                                    :documentTypeId="14"
                                    :sourceId="ahjDesign.id"
                                    :ahjId="ahjId"
                ></AhjDocumentsButton>
                <AhjDocumentsButton v-if="item.customFieldId === 17"
                                    title="Documents"
                                    :documentTypeId="15"
                                    :sourceId="ahjDesign.id"
                                    :ahjId="ahjId"
                ></AhjDocumentsButton>
                <AhjDocumentsButton v-if="item.customFieldId === 19"
                                    title="Documents"
                                    :documentTypeId="16"
                                    :sourceId="ahjDesign.id"
                                    :ahjId="ahjId"
                ></AhjDocumentsButton>
              </div>
              <v-text-field class="structural-design-text-field mx-2"
                            v-model="ahjDesign.groundSnowLoad"
                            label="Ground Snow Load"
                            filled
              ></v-text-field>
              <v-text-field class="structural-design-text-field mx-2"
                            v-model="ahjDesign.roofSnowLoad"
                            label="Roof Snow Load"
                            filled
              ></v-text-field>
              <v-text-field class="structural-design-text-field mx-2"
                            v-model="ahjDesign.windSpeed"
                            label="Wind Speed"
                            filled
              ></v-text-field>
            </div>
            <AhjRequirement v-if="dataReady"
                            title="Structural Design Notes and Additional Requirements"
                            :transparent="true"
                            :requirementTypeId="2"
                            :itemType="itemType"
                            :ahjId="ahjId"
                            :requirements="ahjDesign.structuralRequirements"
            ></AhjRequirement>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-row>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import AhjDocumentsButton from './components/AhjDocumentsButton'
  import AhjRequirement from './components/AhjRequirements'
  import Snackbar from '@/components/Snackbar'
  import { AppMutations } from '@/stores/AppStore'
  import { getRequest, getRequestWithParams, putRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: 'ahjDesign',
    components: {
      AhjDocumentsButton,
      AhjRequirement,
      Snackbar
    },
    data: () => ({
      ahjId: null,
      itemType: 'design',
      snackbar: {},
      dataReady: false,
      customFieldGroupAssignments: [],
      ahjDesign: {
        designRequirements: [],
        electricalRequirements: [],
        structuralRequirements: []
      }
    }),
    methods: {
      async getCustomFieldGroupAssignmentsForScreen() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const params = {
            sourceId: this.ahjDesign.id,
            objectTypeId: 1
          }
          const {data} = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupAssignmentsByObjectType`, {params}, 'blueraven')
          this.customFieldGroupAssignments = cloneDeep(data)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving custom fields')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getAhjDesign() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/ahj/${this.ahjId}/design`, 'blueraven')
          this.ahjDesign = cloneDeep(data)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving AHJ Design')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      getCustomFieldsForGroup(groupId) {
        let match = this.customFieldGroupAssignments.find(cfga => cfga.id === groupId)
        return match ? match.customFieldValues : []
      },
      async resetForm() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.dataReady = false
        this.getAhjDesign().then(() => {
          this.getCustomFieldGroupAssignmentsForScreen().then(() => {
            this.dataReady = true
            this.$store.commit(AppMutations.SET_LOADING, false)
          })
        })
      },
      async saveAhjDesign() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.ahjDesign.customFieldGroups = this.customFieldGroupAssignments
          const {data} = await putRequest(`/ahj/${this.ahjId}/inspection/${this.ahjInspection.id}`, this.ahjInspection, 'blueraven')
          this.ahjDesign = cloneDeep(data)
          this.snackbar = getSnackbar('SUCCESS', 'AHJ Design saved')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error saving AHJ Design')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async created () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.ahjId = parseInt(this.$route.params.ahjId)

      this.getAhjDesign().then(() => {
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
  #save-btn {
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
