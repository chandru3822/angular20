<template>
  <v-container id="proposals-container">
    <v-row class="ml-0 mr-0">
      <v-col cols="12">
        <router-link :to="`/proposals`">Back</router-link>
        <div class="proposal-designs-title font-weight-bold">
          {{ project.projectName }}
        </div>
        <div class="project-subtitle">
          Project ID:
          <router-link :to="`/project/${project.projectId}/${projectPath}`">{{ project.projectId }}</router-link>
          <br/>
          Address: {{ project.street1 }} - {{ project.city }}, {{ project.state }} {{ project.postalCode }}
          <br/>
          <span v-if="project.mobile">
            Phone: {{ formatPhoneNumber(project.mobile) }}
          </span>
        </div>
      </v-col>
    </v-row>
    <v-divider/>
    <v-toolbar flat color="transparent">
      <v-toolbar-title class="proposal-designs-title">Designs and Proposals</v-toolbar-title>
    </v-toolbar>
    <v-row class="mx-2" v-if="projectLoaded">
      <v-card v-for="(d, idx) in designs"
              :key="idx"
              width="355"
              :height="cardHeight"
              class="pa-4 proposal-card">

        <div class="d-flex">
          <v-text-field v-model="d.tempDesignName"
                        label="Design Name"
                        :readonly="!d.edit"
                        :disabled="!d.edit"
            ></v-text-field>
          <div class="d-flex mt-4">
            <v-btn x-small text color="primary" v-if="!d.edit" @click="d.edit = true"><v-icon>edit</v-icon></v-btn>
            <v-btn x-small text color="primary" v-if="d.edit" @click="[d.tempDesignName = d.designName, d.edit = false]"><v-icon>close</v-icon></v-btn>
            <v-btn x-small text color="primary" v-if="d.edit" @click="saveDesignField(d)"><v-icon>save</v-icon></v-btn>
          </div>
        </div>
        <div v-if="d.attachments.length > 0" style="position: relative;" class="design-image">
          <img-proxy
            name="designImg"
            class="design-image"
            :quality="80"
            :uuid="d.attachments[d.imageIndex].uuid"/>

          <div class="design-image image-selection-container"
               :style="{'justify-content': d.imageIndex === 0 ? 'end' : d.imageIndex !== 0 ? 'space-between' : ''}">
            <v-btn x-small v-if="d.imageIndex !== 0"
                   @click="d.imageIndex--"
                   color="black" fab class="image-selection-icon">
              <v-icon color="white">mdi-chevron-left</v-icon>
            </v-btn>
            <v-btn x-small v-if="d.imageIndex !== d.attachments.length - 1"
                   @click="d.imageIndex++"
                   color="black" fab class="image-selection-icon">
              <v-icon color="white">mdi-chevron-right</v-icon>
            </v-btn>
          </div>
        </div>
        <div v-else class="design-image no-image-placeholder">
          <v-icon size="50">mdi-home</v-icon>
        </div>
        <div class="mt-3 design-small-gray">
          Created: {{ d.dateCreated | formatDate('date', 'MMM D, YYYY') }} <br>
          Designed by:
          <span v-if="d.designedByAuroraAi">Aurora AI</span>
          <span v-else>Proposals Team</span>
        </div>
        <div class="design-small-gray" v-if="project.projectId">
          <router-link
            :to="{ name : 'projectProcessStep', params: {projectId: project.projectId, processStepId: d.projectProcessStepId}}"
            target="_blank">
            Open Process Step
          </router-link>
          <v-icon small class="anchor">mdi-open-in-new</v-icon>
        </div>
        <v-btn color="primary"
               dark
               class="mt-4 one-hunned text-capitalize font-weight-bold"
               v-if="canEdit"
               @click="addProposal(d)">
          Create new proposal
        </v-btn>
        <v-list v-if="d.proposals.length > 0">
          <v-list-item
            v-for="(proposal, index) in d.proposals.slice((d.offset * numberToDisplay),(numberToDisplay + (d.offset * numberToDisplay)))"
            :key="index"
            two-line
            class="proposal-container"
            @click="$router.push({name: 'proposal', params: {proposalId: proposal.id}})">
            <v-list-item-content>
              <v-list-item-title class="proposal-title d-flex justify-space-between align-center">
                <span class="d-inline-flex">
                  <span>{{ proposal.displayName }}</span>
                  <v-icon v-if="proposal.locked" class="pl-1" small>mdi-lock</v-icon>
                </span>
                <span class="design-small-gray">
                  {{ proposal.dateCreated | formatDate('date', 'MMM D, YYYY') }}
                </span>
              </v-list-item-title>
            </v-list-item-content>
          </v-list-item>
        </v-list>
        <div class="mt-6 ml-4" v-else>No Proposals Available</div>
        <div class="slice-selectors" v-if="d.proposals.length > numberToDisplay">
          <v-icon dense
                  class="pr-1 pb-3"
                  :disabled="d.offset === 0"
                  @click="d.offset--">mdi-chevron-left
          </v-icon>
          <v-icon dense
                  class="pl-1 pb-3"
                  :disabled="disableAddSlice(d.proposals.length, d.offset)"
                  @click="d.offset++">mdi-chevron-right
          </v-icon>
        </div>
      </v-card>
      <v-card
        width="355"
        v-if="!hasActiveAiDesign && (activeDesign.companyProcessStepStatusTypeId == null || activeDesign.companyProcessStepStatusTypeId !== pendingAuroraAdjustmentsStatusId)"
        :height="cardHeight"
        class="proposal-card request-new"
        :class="{'disable-new': lockNewRequests || hasActiveDesign || !requestSuccessful}">

        <div v-if="canEdit">
          <v-btn text
                 :disabled="lockNewRequests || hasActiveDesign || !requestSuccessful"
                 color="primary"
                 @click="handleNewRequest">
            <v-icon :size="60">add</v-icon>
          </v-btn>
          <div class="mt-5 primary--text"
               :class="{'grey--text text--darken-1': lockNewRequests || hasActiveDesign || !requestSuccessful}">
            Request New Design <br>
            Thru Proposals Team
          </div>
        </div>
        <div class="request-new-details grey--text text--darken-2" v-if="hasActiveDesign">
          <div>
            <router-link
              :to="{ name : 'projectProcessStep', params: {projectId: project.projectId, processStepId: activeDesign.projectProcessStepId}}"
              target="_blank">
              Open Process Step
            </router-link>
            <v-icon small class="anchor">mdi-open-in-new</v-icon>
          </div>

          Current Step: {{ activeDesign.processStepName }} <br/>
          Last Requested: {{ activeDesign.dateCreated | formatDate('date') }} <br/>
          Current Status: {{ activeDesign.companyProcessStepStatusType }}
          <div v-if="activeDesign.comments">
            Comments: {{ activeDesign.comments }}
          </div>
        </div>
      </v-card>
      <v-card
          v-if="!hasActiveDesign && (closerApptRequirementsMet || designs.length > 0)"
          color="transparent"
          width="355"
          :height="cardHeight"
          class="proposal-card request-new ai-design-request">

        <div v-if="canEdit && closerApptRequirementsMet && !activeDesign.projectId && designs.length === 0">
          <v-btn text
                 color="primary"
                 @click="handleAIRequest(false)">
            <v-icon :size="60">add</v-icon>
          </v-btn>
          <div class="mt-5 primary--text">
            Request AI Design
          </div>
        </div>
        <div v-if="canEdit && designs.length > 0 && !activeDesign.projectId">
          <v-btn text
                 color="primary"
                 @click="handleAIRequest(true)">
            <v-icon :size="60">add</v-icon>
          </v-btn>
          <div class="mt-5 primary--text">
            Create my own design in Aurora
          </div>
        </div>
        <v-card-text v-else-if="canEdit && activeDesign.companyProcessStepStatusTypeId != null && activeDesign.companyProcessStepStatusTypeId === pendingAuroraAdjustmentsStatusId">
          <div class="mb-10">
            Immediate Design Pending Aurora Adjustments
          </div>
          <v-btn outlined color="primary"
              @click="syncAuroraDesignDetails()">
            Sync Design
          </v-btn>
        </v-card-text>
      </v-card>
    </v-row>
    <v-dialog width="500" persistent v-model="showNewDesignRequestForm">
      <v-card>
        <v-card-title>Request New Design</v-card-title>
        <v-card-text class="default-text-color">
          Describe your request (Required)
          <v-textarea required
                      auto-grow
                      outlined
                      counter="250"
                      color="#808588"
                      v-model="newDesignRequest.description"/>

          <v-file-input
            dense
            class="mb-5"
            multiple
            :accept="acceptedFileTypes"
            ref="fileInput"
            hide-details
            label="Attach utility bill"
            @change="uploadUtilityBillFiles"
          />

          <v-file-input
            dense
            class="mb-3"
            multiple
            :accept="acceptedFileTypes"
            ref="fileInput"
            hide-details
            label="Attach supporting files"
            @change="uploadFiles"
          />

        </v-card-text>

        <v-card-actions>
          <v-spacer/>
          <v-btn text
                 color="primary"
                 class="text-capitalize"
                 @click="showNewDesignRequestForm = false">
            Cancel
          </v-btn>
          <v-btn
            color="primary"
            class="white--text text-capitalize font-weight-bold"
            :disabled="!newDesignRequest.description"
            @click="requestNewDesign()">
            Request
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog width="500" persistent v-model="showAIDesignRequestForm">
      <v-card>
        <v-card-title>Create New AI Design</v-card-title>
        <v-card-text class="default-text-color">
          <v-form ref="aiForm">
            <CustomValueInput v-for="(cf, idx) in aiRequestFields"
                            :key="idx"
                            :show-field-name="false"
                            :required="true"
                            custom-class="albatross-body-2"
                            :field="cf"></CustomValueInput>
          </v-form>
        </v-card-text>

        <v-card-actions>
          <v-spacer/>
          <v-btn text
                 color="primary"
                 class="text-capitalize"
                 @click="showAIDesignRequestForm = false">
            Cancel
          </v-btn>
          <v-btn
              color="primary"
              :loading="savingNewAiDesign"
              class="white--text text-capitalize font-weight-bold"
              @click="validateAIRequest()">
            Save
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog width="500" v-model="showNewPostalCodeRequestForm">
      <v-card>
        <v-card-title class="text-capitalize">
          Unapproved Zip Code
        </v-card-title>
        <v-card-subtitle>This home lies outside of approved zones. Zip code needs to be approved before requesting a new
          design.
        </v-card-subtitle>
        <v-card-text>
          Additional comments (optional)
          <v-textarea required
                      auto-grow
                      outlined
                      counter="250"
                      color="#808588"
                      v-model="newDesignRequest.description"/>
        </v-card-text>

        <v-card-actions>
          <v-spacer/>
          <v-btn text
                 class="text-capitalize"
                 @click="showNewPostalCodeRequestForm = false">
            Cancel
          </v-btn>
          <v-btn
            color="primary"
            class="white--text text-capitalize font-weight-bold"
            @click="requestPostalCodeApproval(newDesignRequest.description)">
            Request Approval
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<script>

import {
  formatPhoneNumber,
  getRequest,
  getRequestWithParams,
  getProjectPath,
  handleHidingGlobalLoader,
  logError,
  postRequest,
  postRequestWithRequestParams
} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import moment from 'moment'
import DatetimePickerInput from '@/components/DatetimePickerInput'
import constants from '@/helpers/constants'
import ImgProxy from '@/components/ImgProxy'
import CustomValueInput from "@/views/flow/components/CustomValueInput.vue";

const dateSortFn = (prop = 'dateCreated') => {
  return (a, b) => {
    const aDate = new Date(a[prop])
    const bDate = new Date(b[prop])

    if (aDate < bDate) {
      return 1
    }
    if (aDate > bDate) {
      return -1
    }
    return 0
  }
}

export default {
  name: 'ProposalDesigns',
  components: {
    CustomValueInput,
    DatetimePickerInput,
    ImgProxy
  },
  data() {
    return {
      designs: [],
      projectLoaded: false,
      cardHeight: 600,
      minDate: moment().format('YYYY-MM-DDTHH:mm:ssZ'),
      offset: 0,
      numberToDisplay: 3,
      newDesignRequest: {},
      aiDesignRequest: {},
      aiRequestFields: [],
      useExistingDesign: false,
      acceptedFileTypes: constants.STANDARD_IMAGES_AND_DOCS,
      showNewDesignRequestForm: false,
      showAIDesignRequestForm: false,
      savingNewAiDesign: false,
      showNewPostalCodeRequestForm: false,
      lockNewRequests: false,
      project: {},
      activeDesign: {},
      pendingAuroraAdjustmentsStatusId: 1649,
      requestSuccessful: false,
      projectId: this.$route.params.projectId,
      timezone: this.$store.state.user.details.timezone?.value,
      requiredRules: constants.BASIC_REQUIRED_RULE,
      formatPhoneNumber,
      projectPath: '',
    }
  },
  async created() {
    this.getProposalProject()
    this.projectPath = getProjectPath(this).pathSuffix
    await this.pageLoadOrRefresh()
  },
  computed: {
    canEdit() {
      const hasAdmin = this.$store.getters.userHasFeatureAccessLevel('PROPOSALS', 'ADMIN')
      const hasEdit = this.$store.getters.userHasFeatureAccessLevel('PROPOSALS', 'EDIT')
      return hasAdmin || hasEdit
    },
    closerApptRequirementsMet () {
      return this.project.closerAppointmentStart != null && moment(this.project.closerAppointmentStart).isBetween(moment(), moment().add(30, 'm'))
    },
    hasActiveDesign() {
      return this.activeDesign?.projectId && (this.activeDesign.companyProcessStepStatusTypeId == null || this.activeDesign.companyProcessStepStatusTypeId !== this.pendingAuroraAdjustmentsStatusId)
    },
    hasActiveAiDesign() {
      return this.activeDesign.companyProcessStepStatusTypeId === this.pendingAuroraAdjustmentsStatusId
    },
    firstDesignId() {
      return this.designs?.find(d => d.designId != null)?.designId
    }
  },
  methods: {
    async pageLoadOrRefresh () {
      let requests = [
        this.getCompletedProposalDesigns(),
        this.getActiveDesign()
      ]
      await Promise.all(requests)
    },
    async validateAIRequest () {
      let valid = this.$refs.aiForm.validate()
      if (valid) {
        if(this.useExistingDesign) {
          await this.createAiFromExisting()
        } else {
          await this.requestAIDesign()

        }
      }
    },
    async createAiFromExisting() {
      try {
        this.savingNewAiDesign = true
        // get the aurora project id for the first design we return from our side
        const {data, status} = await getRequest(`/aurora/design/${this.firstDesignId}`, 'blueraven')

        if(data?.projectId) {
          let projectId = data.projectId
          //get all aurora designs using that aurora projectId
          const {data: designData, status} = await getRequest(`/aurora/project/${projectId}/designs`, 'blueraven')


          if(designData?.designs && designData?.designs.length > 0) {
            //duplicate the first created design in aurora (the first created is the LAST design in the returned array)
            let firstAuroraDesignId = designData?.designs.pop()?.id

            let params = {
              designName: this.aiRequestFields.find(f => f.customFieldGroupAssignmentId === 26300)?.textValue
            }
            //find the pps that is using that first aurora design and see if it was designedByAurora. use that value when creating the new pps
            let designedByAurora = this.designs?.find(d => d.designId === firstAuroraDesignId)?.designedByAuroraAi || false;
            const {data: designCopy, status} = await postRequestWithRequestParams(`/aurora/design/${firstAuroraDesignId}/duplicate`, {},
                params, 'blueraven')

            if(designCopy?.design?.id) {

              //create the new pps for this
              let designByAuroraParams = {
                designByAuroraValue: designedByAurora
              }
              await postRequestWithRequestParams(`/proposal/projects/${this.projectId}/ai/design/${designData?.designs[0].id}`, this.aiRequestFields,
                  designByAuroraParams, 'blueraven')

              //open the new design in sales mode
              let url = `https://v2.aurorasolar.com/projects/${projectId}/designs/${designCopy.design.id}/e-proposal`
              window.open(url, '_blank')

              //reload the active design
              await this.getActiveDesign()
            }
          }

        } else {
          this.$snackbar('ERROR', 'Failed to find Aurora Project')
        }
      } catch (e) {
        logError(e)
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.$snackbar('ERROR', e?.data?.message || 'There was an error requesting a new design')
      } finally {
        this.showAIDesignRequestForm = false
        this.savingNewAiDesign = false
      }
    },
    async handleAIRequest(useExisting) {
      //utility company (23802), estimated annual consumption (22573), design name (26300)
      this.useExistingDesign = useExisting
      let encodedIds = encodeURI([23802, 22573, 26300])
      let params = { cfgaIds: encodedIds}
      const { data } = await getRequestWithParams(`/customFieldGroup/getCustomFieldsByCfgaIds`, {
        params
      })
      this.aiRequestFields = data

      this.showAIDesignRequestForm = true
    },
    async handleNewRequest() {
      this.lockNewRequests = true
      const {data} = await getRequest(`/proposal/projects/${this.projectId}/postalCode`, 'blueraven')

      if (data?.approved) {
        this.showNewDesignRequestForm = true
      } else {
        this.showNewPostalCodeRequestForm = true
      }

      this.lockNewRequests = false

    },
    async requestAIDesign() {
      try {
        this.savingNewAiDesign = true
        const { data } = await postRequest(`/proposal/projects/${this.projectId}/ai`, this.aiRequestFields, 'blueraven')
        if(data?.design?.id && data?.design?.project_id) {
          let url = `https://v2.aurorasolar.com/projects/${data?.design?.project_id}/designs/${data?.design?.id}/e-proposal`
          window.open(url, '_blank')
        }
        await this.getActiveDesign()
      } catch (e) {
        logError(e)
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.$snackbar('ERROR', e?.data?.message || 'There was an error requesting a new design')
      } finally {
        this.showAIDesignRequestForm = false
        this.savingNewAiDesign = false
      }
    },
    async syncAuroraDesignDetails() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)

        const {data, status} = await postRequest(`/projectProcessStep/${this.activeDesign.projectProcessStepId}/action/10293`, {})
        if (status === 204 || status === 200) {
          //sync updates the pps status to complete and grabs assets from Aurora and uploads them to our side
          // let designId = "ba92c16d-b674-464d-a220-3dd0a0b4daf8" <--use to test a design that for sure has the right asset you need
          await postRequest(`/proposal/pps/${this.activeDesign.projectProcessStepId}/design/${this.activeDesign.designId}/sync`, {}, 'blueraven')

          //reload the required data for the screen
          await this.pageLoadOrRefresh()
          handleHidingGlobalLoader(this, status)
        } else {
          this.$snackbar('ERROR', `Aurora design incomplete. Please navigate back to Aurora and finish your design changes before syncing.`, false)
          handleHidingGlobalLoader(this, status)
        }
      } catch (e) {
        this.$snackbar('ERROR', `Aurora design incomplete. Please navigate back to Aurora and finish your design changes before syncing.`, false)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async requestNewDesign() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const formData = new FormData()
        formData.append('description', this.newDesignRequest.description)
        // formData.append('dueDate', this.newDesignRequest.dueDate)

        this.newDesignRequest?.attachments?.forEach(a => {
          formData.append('attachments', a)
        })

        this.newDesignRequest?.utilityBillAttachments?.forEach(a => {
          formData.append('utilityBillAttachments', a)
        })

        const {
          data,
          status
        } = await postRequest(`/proposal/projects/${this.projectId}/designs`, formData, 'blueraven')
        //this endpoint returns all the designs because adding a new one could possibly remove (cancel) an existing one
        this.designs = data
        await this.getActiveDesign()
        this.newDesignRequest = {}
        this.showNewDesignRequestForm = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.$snackbar('ERROR', e?.data?.message || 'There was an error requesting a new design')
      }
    },
    async requestPostalCodeApproval(comments) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)

        const {
          data,
          status
        } = await postRequest(`/proposal/projects/${this.projectId}/postalCode`, {comments}, 'blueraven')
        this.activeDesign = data
        this.newDesignRequest = {}
        this.showNewPostalCodeRequestForm = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.$snackbar('ERROR', e?.data?.message || 'There was an error requesting a new design')
      }
    },
    disableAddSlice(proposalCount, offset) {
      let pageCount = (Math.floor(proposalCount / this.numberToDisplay))
      let dividesEqually = proposalCount % this.numberToDisplay === 0
      if (dividesEqually && pageCount !== 0) {
        pageCount--
      }
      return pageCount === offset
    },
    async getProposalProject() {
      this.projectLoaded = false
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data, status} = await getRequest(`/proposal/projects/${this.projectId}`, 'blueraven')
        this.project = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } finally {
        this.projectLoaded = true
      }
    },
    async saveDesignField(design) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        let values = [
            {
              textValue: design.tempDesignName,
              customFieldGroupAssignmentId: 26300
            }
          ]
        const {data, status} = await postRequest(`/customFieldValues/project/${design.projectId}/processStep/${design.projectProcessStepId}`, values)
        design.edit = false
        design.designName = design.tempDesignName
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCompletedProposalDesigns() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data, status} = await getRequest(`/proposal/projects/${this.projectId}/designs`, 'blueraven', [])
        const designs = data
          ?.map((d) => {
            d?.proposals.sort(dateSortFn())
            return d
          })
          ?.sort(dateSortFn('dateModified'))

        designs.forEach(d => {
          d.tempDesignName = d.designName
          d.edit = false
        })

        this.designs = designs
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getActiveDesign() {
      try {
        this.requestSuccessful = false
        this.$store.commit(AppMutations.SET_LOADING, true)

        const {
          data,
          status
        } = await getRequest(`/proposal/projects/${this.projectId}/designs/active`, 'blueraven', [])
        this.activeDesign = data
        this.requestSuccessful = true
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        this.requestSuccessful = false
        logError(e)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async addProposal(design) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data, status} = await postRequest(`/proposal`, {
          projectProcessStepId: design.projectProcessStepId
        }, 'blueraven')
        this.$router.push({name: 'proposal', params: {proposalId: data.id}})
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.$snackbar('ERROR', `An error occurred while creating proposal: <strong>${e?.data?.message}</strong>`, true)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    uploadFiles: function (files) {
      this.newDesignRequest.attachments = files
    },
    //cuz i am dumb and can't figure out how to pass in "files"
    uploadUtilityBillFiles: function (files) {
      this.newDesignRequest.utilityBillAttachments = files
    }
  }
}
</script>

<style scoped lang="scss">
.proposal-designs-title {
  font-size: 18px;
  color: var(--v-blackText-base);
  font-weight: bold;
}

.project-subtitle {
  font-size: 14px;
  color: var(--v-blackText-base);
}

.proposal-card {
  display: inline-block;
  margin-left: 10px;
  margin-right: 10px;
  position: relative;
  margin-bottom: 20px;
}

.design-image {
  height: 170px;
  width: 323px;
  border-radius: 0 !important;
}

.image-selection-icon {
  opacity: .6;
}

.image-selection-container {
  position: absolute;
  top: 0;
  left: 0;
  padding: 5px;
  display: flex;
  align-items: center;
}

.no-image-placeholder {
  text-align: center;
  display: flex;
  background-color: #dddddd;
  justify-content: center;
}

.design-small-gray {
  color: var(--v-grey-darken1);
  font-size: 12px;
}

.proposal-title {
  font-size: 14px;
  color: var(--v-blackText-base);
}

.subtitle-container {
  padding: 0;
}

//.proposal-container {
//  height: 71px;
//}

.slice-selectors {
  position: absolute;
  bottom: 0;
  width: calc(100% - 40px);
  text-align: center;
}

.request-new {
  text-align: center;
  width: 100%;
  height: 100%;
  font-size: 18px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.ai-design-request {
  border: solid 4px var(--v-anchor-base) !important;
}

.request-new-details {
  margin-top: 16px;
  font-size: 12px;
}

.disable-new {
  color: var(--v-grey-darken1);
}
</style>
