<template>
  <v-container id="proposals-container">
    <v-row class="ml-0 mr-0">
      <v-col cols="12" md="6">
        <router-link :to="`/proposals`">Back</router-link>
        <div class="proposal-designs-title font-weight-bold">
          {{ project.projectName }}
        </div>
        <div class="project-subtitle">
          Project ID:
          <router-link
            :to="`/project/${project.projectId}/${defaultProjectPage}`"
          >
            {{ project.projectId }}
          </router-link>
          <br />
          Address: {{ project.street1 }} - {{ project.city }},
          {{ project.state }} {{ project.postalCode }}
          <br />
          <span v-if="project.mobile">
            Phone: {{ formatPhoneNumber(project.mobile) }}
          </span>
        </div>
      </v-col>
    </v-row>
    <v-divider />
    <v-toolbar flat color="transparent">
      <v-toolbar-title class="proposal-designs-title">
        Designs and Proposals
      </v-toolbar-title>
    </v-toolbar>
    <v-row class="mb-4" v-if="projectLoaded">
      <v-col v-if="allowedModules?.length > 0 && !showingMore" class="mx-4">
        <span class="label-medium">{{allowedModules[0].fieldName}}: </span>
        <span class="body-medium ml-1">{{allowedModules[0].textValue}}</span>
        <a-btn @click="showingMore = true" variant="text" class="clickable body-medium anchor text-decoration-underline ml-1">Show more modules</a-btn></v-col>
      <v-col v-else-if="allowedModules?.length > 0" class="mx-4 body-medium">
        <div v-for="(module, index) in allowedModules" >
          <span class="label-medium">{{module.fieldName}}: </span>
          <span class="body-medium ml-1">{{module.textValue}}</span>
          <a-btn v-if="index === allowedModules.length - 1" variant="text" @click="showingMore = false" class="clickable anchor text-decoration-underline ml-1">Show less</a-btn>
        </div>
      </v-col>
    </v-row>
    <v-row class="mx-2" v-if="projectLoaded">
      <v-card
        v-for="(d, idx) in designs"
        :key="idx"
        width="355"
        :height="cardHeight"
        class="pa-4 proposal-card"
      >
        <div class="d-flex">
          <a-text-field
            v-model="d.tempDesignName"
            label="Design Name"
            :readonly="!d.edit"
            :disabled="!d.edit"
          ></a-text-field>
          <div class="d-flex mt-4">
            <a-btn
              size="x-small"
              variant="text"
              color="primary"
              v-if="!d.edit"
              @click="d.edit = true"
              prepend-icon="edit"
            ></a-btn>
            <a-btn
              size="x-small"
              variant="text"
              color="primary"
              v-if="d.edit"
              @click=";[(d.tempDesignName = d.designName), (d.edit = false)]"
              prepend-icon="close"
            ></a-btn>
            <a-btn
              size="x-small"
              variant="text"
              color="primary"
              v-if="d.edit"
              @click="saveDesignField(d)"
              prepend-icon="save"
            ></a-btn>
          </div>
        </div>
        <div
          v-if="d.attachments.length > 0"
          style="position: relative"
          class="design-image"
        >
          <img-proxy
            name="designImg"
            class="design-image"
            :quality="80"
            :uuid="d.attachments[d.imageIndex].uuid"
          />

          <div
            class="design-image image-selection-container"
            :style="{
              'justify-content':
                d.imageIndex === 0
                  ? 'end'
                  : d.imageIndex !== 0
                  ? 'space-between'
                  : ''
            }"
          >
            <a-btn
              size="small"
              v-if="d.imageIndex !== 0"
              @click="d.imageIndex--"
              color="white"
              icon
              class="image-selection-icon"
              prepend-icon="mdi-chevron-left"
            ></a-btn>
            <a-btn
              size="small"
              v-if="d.imageIndex !== d.attachments.length - 1"
              @click="d.imageIndex++"
              color="white"
              icon
              class="image-selection-icon"
              prepend-icon="mdi-chevron-right"
            ></a-btn>
          </div>
        </div>
        <div v-else class="design-image no-image-placeholder">
          <v-icon size="50">mdi-home</v-icon>
        </div>
        <div class="mt-3 design-small-gray">
          Created: {{ d.dateCreated | formatDate('timestamp', 'MMM D, YYYY') }}
          <br />
          Designed by:
          <span v-if="d.designedByAuroraAi">Aurora AI</span>
          <span v-else>Proposals Team</span>
        </div>
        <div class="design-small-gray" v-if="project.projectId">
          <router-link
            :to="{
              name: 'projectProcessStep',
              params: {
                projectId: project.projectId,
                processStepId: d.projectProcessStepId
              }
            }"
            target="_blank"
          >
            Open Process Step
          </router-link>
          <v-icon small class="anchor">mdi-open-in-new</v-icon>
        </div>
        <a-btn
          color="primary"
          class="mt-4 one-hunned text-capitalize font-weight-bold"
          v-if="canEdit"
          @click="addProposal(d)"
          text="Create new proposal"
        ></a-btn>
        <v-list v-if="d.proposals.length > 0">
          <v-list-item
            v-for="(proposal, index) in d.proposals.slice(
              d.offset * numberToDisplay,
              numberToDisplay + d.offset * numberToDisplay
            )"
            :key="index"
            two-line
            class="proposal-container"
          >
            <v-list-item-content>
              <v-list-item-title
                class="proposal-title d-flex justify-space-between align-center"
              >
                <span class="d-inline-flex">
                  <span>
                    <router-link
                      :to="`/proposal/${proposal.id}`"
                      class="router-link-td elevation-0 square-card"
                    >
                      {{ proposal.displayName }}
                    </router-link>
                  </span>
                  <router-link
                    :to="`/proposal/${proposal.id}`"
                    class="router-link-td elevation-0 square-card"
                  >
                    <v-icon v-if="proposal.locked" class="pl-1" small
                      >mdi-lock</v-icon
                    >
                  </router-link>
                </span>
                <span class="design-small-gray">
                  <router-link
                    :to="`/proposal/${proposal.id}`"
                    class="router-link-td elevation-0 square-card"
                  >
                    {{
                      proposal.dateCreated | formatDate('date', 'MMM D, YYYY')
                    }}
                  </router-link>
                </span>
              </v-list-item-title>
            </v-list-item-content>
          </v-list-item>
        </v-list>
        <div class="mt-6 ml-4" v-else>No Proposals Available</div>
        <div
          class="slice-selectors"
          v-if="d.proposals.length > numberToDisplay"
        >
          <v-icon
            dense
            class="pr-1 pb-3"
            :disabled="d.offset === 0"
            @click="d.offset--"
          >
            mdi-chevron-left
          </v-icon>
          <v-icon
            dense
            class="pl-1 pb-3"
            :disabled="disableAddSlice(d.proposals.length, d.offset)"
            @click="d.offset++"
          >
            mdi-chevron-right
          </v-icon>
        </div>
      </v-card>
      <v-card
        width="355"
        v-if="
          !hasActiveAiDesign &&
          (activeDesign.companyProcessStepStatusTypeId == null ||
            activeDesign.companyProcessStepStatusTypeId !==
              pendingAuroraAdjustmentsStatusId)
        "
        :height="cardHeight"
        class="proposal-card request-new"
        :class="{
          'disable-new':
            lockNewRequests || hasActiveDesign || !requestSuccessful
        }"
      >
        <div v-if="canEdit">
          <a-btn
            variant="text"
            :disabled="lockNewRequests || hasActiveDesign || !requestSuccessful"
            color="primary"
            @click="handleNewRequest"
          >
            <template #default>
              <v-icon :size="60">add</v-icon>
            </template>
          </a-btn>
          <div
            class="mt-5 primary--text"
            :class="{
              'grey--text text--darken-1':
                lockNewRequests || hasActiveDesign || !requestSuccessful
            }"
          >
            Request New Design <br />
            Thru Proposals Team
          </div>
        </div>
        <div
          class="request-new-details grey--text text--darken-2"
          v-if="hasActiveDesign"
        >
          <div>
            <router-link
              :to="{
                name: 'projectProcessStep',
                params: {
                  projectId: project.projectId,
                  processStepId: activeDesign.projectProcessStepId
                }
              }"
              target="_blank"
            >
              Open Process Step
            </router-link>
            <v-icon small class="anchor">mdi-open-in-new</v-icon>
          </div>

          Current Step: {{ activeDesign.processStepName }} <br />
          Last Requested: {{ activeDesign.dateCreated | formatDate('date') }}
          <br />
          Current Status: {{ activeDesign.companyProcessStepStatusType }}
          <div v-if="activeDesign.comments">
            Comments: {{ activeDesign.comments }}
          </div>
        </div>
      </v-card>
      <v-card
        v-if="
          !hasActiveDesign &&
          canAuroraAI &&
          (closerApptRequirementsMet || designs.length > 0 || hasActiveAiDesign)
        "
        color="transparent"
        width="355"
        :height="cardHeight"
        class="proposal-card request-new ai-design-request"
      >
        <div
          v-if="
            canEdit &&
            closerApptRequirementsMet &&
            !activeDesign.projectId &&
            designs.length === 0
          "
        >
          <a-btn variant="text" color="primary" @click="handleNewRequest(true,false)">
            <v-icon :size="60">add</v-icon>
          </a-btn>
          <div class="mt-5 primary--text">Request AI Design</div>
        </div>
        <div v-if="canEdit && designs.length > 0 && !activeDesign.projectId">
          <a-btn variant="text" color="primary" @click="handleNewRequest(true, true)">
            <v-icon :size="60">add</v-icon>
          </a-btn>
          <div class="mt-5 primary--text">Create my own design in Aurora</div>
        </div>
        <v-card-text
          v-else-if="
            canEdit &&
            activeDesign.companyProcessStepStatusTypeId != null &&
            activeDesign.companyProcessStepStatusTypeId ===
              pendingAuroraAdjustmentsStatusId
          "
        >
          <div class="mb-3">Immediate Design Pending Aurora Adjustments</div>
          <a
            v-if="activeDesign.auroraProjectId && activeDesign.designId"
            @click="openSalesMode()"
          >
            Open in Sales Mode
          </a>
          <br />
          <a-btn
            variant="solo"
            class="mt-8"
            color="primary"
            @click="syncAuroraDesignDetails()"
          >
            Sync Design
          </a-btn>
          <br />
          <a-btn
            variant="outlined"
            class="mt-4"
            @click="cancelPendingAuroraDesign()"
          >
            Cancel Aurora Design Request
          </a-btn>
        </v-card-text>
      </v-card>
      <v-card
        v-if="canEdit && designs.length > 0 && !activeDesign.projectId"
        color="transparent"
        width="355"
        :height="cardHeight"
        class="proposal-card request-new solargraf-design-card solargraf-design-request"
      >
        <div>
          <a-btn variant="text" color="primary" @click="handleCreateSolargrafDesign">
            <v-icon :size="60">add</v-icon>
          </a-btn>
          <div class="mt-5 primary--text">Create my own design in Solargraf</div>
        </div>
      </v-card>
    </v-row>
    <v-dialog width="500" persistent v-model="showNewDesignRequestForm">
      <v-card>
        <v-card-title>Request New Design</v-card-title>
        <v-card-text class="default-text-color">
          Describe your request (Required)
          <a-textarea
            required
            auto-grow
            variant="outlined"
            counter
            :maxlength="250"
            color="#808588"
            v-model="newDesignRequest.description"
          />

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
          <v-spacer />
          <a-btn
            variant="text"
            color="primary"
            class="text-capitalize"
            @click="showNewDesignRequestForm = false"
            text="Cancel"
          ></a-btn>
          <a-btn
            color="primary"
            class="text-capitalize font-weight-bold"
            :disabled="!newDesignRequest.description"
            @click="requestNewDesign()"
            text="Request"
          ></a-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

<AuroraProposalDialog :show="showAIDesignRequestForm" :ai-request-fields="aiRequestFields" :saving-new-ai-design="savingNewAiDesign" @save="requestAIDesign" @close="showAIDesignRequestForm = false"/>
    <v-dialog width="500" v-model="showNewPostalCodeRequestForm">
      <v-card>
        <v-card-title class="text-capitalize">
          Unapproved Zip Code
        </v-card-title>
        <v-card-subtitle
          >This home lies outside of approved zones. Zip code needs to be
          approved before requesting a new design.
        </v-card-subtitle>
        <v-card-text>
          Additional comments (optional)
          <a-textarea
            required
            auto-grow
            variant="outlined"
            counter
            :maxlength="250"
            color="#808588"
            v-model="newDesignRequest.description"
          />
        </v-card-text>

        <v-card-actions>
          <v-spacer />
          <a-btn
            variant="text"
            class="text-capitalize"
            @click="showNewPostalCodeRequestForm = false"
            color="unset"
            text="Cancel"
          ></a-btn>
          <a-btn
            color="primary"
            class="text-capitalize font-weight-bold"
            @click="requestPostalCodeApproval(newDesignRequest.description)"
            text="Request Approval"
          ></a-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<script setup>
import {
  formatPhoneNumber,
  getRequest,
  getRequestWithParams,
  getProjectPath,
  handleHidingGlobalLoader,
  logError,
  postRequest, postRequestWithRequestParams
} from '@/helpers/helpers'

import moment from 'moment'
import constants from '@/helpers/constants'
import ImgProxy from '@/components/ImgProxy'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'

import { getCurrentInstance, computed, ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
import { useRoute, useRouter } from 'vue-router/composables'
import { useAppStore } from '@/stores/AppStore.js'
import AuroraProposalDialog from "@/views/blueraven/proposals/AuroraProposalDialog.vue";
import {ProposalCFGAIDs} from "@/views/blueraven/proposals/ProposalCFGAIDEnum.js";
import { activitiesData } from '@/helpers//activitiesData.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy

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
const defaultProjectPage = ref(getProjectPath().pathSuffix)
const designs = ref([])
const cardHeight = ref(600)
const numberToDisplay = ref(3)
const newDesignRequest = ref({})
const acceptedFileTypes = ref(constants.STANDARD_IMAGES_AND_DOCS)
const showNewDesignRequestForm = ref(false)
const showNewPostalCodeRequestForm = ref(false)
const lockNewRequests = ref(false)
const project = ref({})
const activeDesign = ref({})
const requestSuccessful = ref(false)
const projectLoaded = ref(false)
const aiDesignRequest = ref({})
const aiRequestFields = ref([])
const useExistingDesign = ref(false)
const showAIDesignRequestForm = ref(false)
const savingNewAiDesign = ref(false)
const pendingAuroraAdjustmentsStatusId = ref(1649)
const allowedModules = ref(null)
const showingMore = ref(false)


onMounted(async () => {
  defaultProjectPage.value = getProjectPath(vueInstance).pathSuffix
  await getProposalProject()
  await pageLoadOrRefresh()
})

const projectId = computed(() => {
  return route.params.projectId
})
const closerApptRequirementsMet = computed(() => {
  // 2024-12-20: Removing closer appointment requirement for dealers, per Jacob
  // return (
  //   //all time constraints were removed beside checking if we are before the end time
  //   project.value.closerAppointmentEnd != null &&
  //   moment().isBefore(moment(project.value.closerAppointmentEnd))
  // )
  return true
})
const canAuroraAI = computed(() => {
  return userStore.userHasFeatureAccessLevel('AURORA_AI', 'ADD')
})
const canEdit = computed(() => {
  const hasAdmin = userStore.userHasFeatureAccessLevel('PROPOSALS', 'ADMIN')
  const hasEdit = userStore.userHasFeatureAccessLevel('PROPOSALS', 'EDIT')
  return hasAdmin || hasEdit
})
const hasActiveDesign = computed(() => {
  return (
    activeDesign.value?.projectId &&
    (activeDesign.value?.companyProcessStepStatusTypeId == null ||
      activeDesign.value?.companyProcessStepStatusTypeId !==
        pendingAuroraAdjustmentsStatusId.value)
  )
})
const hasActiveAiDesign = computed(() => {
  return (
    activeDesign.value?.companyProcessStepStatusTypeId ===
    pendingAuroraAdjustmentsStatusId.value
  )
})
const firstDesignId = computed(() => {
  return designs.value?.find((d) => d.designId != null)?.designId
})





const pageLoadOrRefresh = async () => {
  const requests = [getCompletedProposalDesigns(), getActiveDesign()]
  await Promise.all(requests)
}
const validateAIRequest = async (aiForm) => {
  const valid = aiForm.validate()
  if (valid) {
    //all checks for how to create the design are handled by backend now
    await requestAIDesign()
  }
}

const handleAIRequest = async (useExisting) => {
  //utility company (23802), how was yearly consumption calculated (23803), estimated annual consumption (22573), design name (26300)
  useExistingDesign.value = useExisting
  const encodedIds = encodeURI([ProposalCFGAIDs.UTILITY_CO, ProposalCFGAIDs.HOW_WAS_YEARLY_CONSUMPTION_CALC, ProposalCFGAIDs.SQUARE_FOOTAGE, ProposalCFGAIDs.ESTIMATED_ANNUAL_CONSUMPTION, ProposalCFGAIDs.DESIGN_NAME])
  const params = { cfgaIds: encodedIds }
  const { data } = await getRequestWithParams(
    `/customFieldGroup/getCustomFieldsByCfgaIds`,
    {
      params
    }
  )
  aiRequestFields.value = data
  showAIDesignRequestForm.value = true
}

const handleNewRequest = async (ai, useExisting) => {
  lockNewRequests.value = true
  const { data } = await getRequest(
    `/proposal/projects/${projectId.value}/postalCode`,
    'blueraven'
  )

  //per lowry dont show unapproved zip message if it is a New Home project
  if (data?.approved || project.value.objectCategoryId === 6) {
    if(ai) {
      handleAIRequest(useExisting)
    } else {
      showNewDesignRequestForm.value = true
    }
  } else {
    showNewPostalCodeRequestForm.value = true
  }

  lockNewRequests.value = false
}

const requestAIDesign = async (monthlyInputs) => {
  try {
    savingNewAiDesign.value = true
    const { data } = await postRequest(
        `/proposal/projects/${projectId.value}/ai`,
        {customFieldValuesList: aiRequestFields.value, monthlyInputs: monthlyInputs},
        'blueraven'
    )
    if (data?.design?.id && data?.design?.project_id) {
      const url = `https://v2.aurorasolar.com/projects/${data?.design?.project_id}/designs/${data?.design?.id}/e-proposal`
      window.open(url, '_blank')
    }
    await getActiveDesign()
    appStore.showSnack('SUCCESS', 'A new design has been requested')
  } catch (e) {
    logError(e)
    appStore.loading = false
    appStore.showSnack(
      'ERROR',
      e?.data?.message ||
        e?.data?.detail ||
        'There was an error requesting a new design'
    )
  } finally {
    showAIDesignRequestForm.value = false
    savingNewAiDesign.value = false
  }
}

const cancelPendingAuroraDesign = async () => {
  appStore.loading = true
  try {
    let params = {
      processStepStatusTypeId: 3, //this is the root status
      id: 1654, //this is the company status
      cancelledCompanyProcessStepStatusTypeId: 1654 //this is the cancelled status which in our case we just set to the same..it wont actually get used
    }
    await postRequest(
      `/projectProcessStep/${activeDesign.value.projectProcessStepId}/status`,
      params
    )
    activeDesign.value = {}
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error Canceling Process Step')
  } finally {
    appStore.loading = false
  }
}

const openSalesMode = async () => {
  const url = `https://v2.aurorasolar.com/projects/${activeDesign.value.auroraProjectId}/designs/${activeDesign.value.designId}/e-proposal`
  window.open(url, '_blank')
}

const syncAuroraDesignDetails = async () => {
  try {
    appStore.loading = true

    const { data, status } = await postRequest(
      `/projectProcessStep/${activeDesign.value.projectProcessStepId}/action/10293`,
      {}
    )

     activitiesData.triggerFlag= !activitiesData.triggerFlag;
    if (status === 204 || status === 200) {
      //sync updates the pps status to complete and grabs assets from Aurora and uploads them to our side
      // let designId = "ba92c16d-b674-464d-a220-3dd0a0b4daf8" <--use to test a design that for sure has the right asset you need
      await postRequest(
        `/proposal/pps/${activeDesign.value.projectProcessStepId}/design/${activeDesign.value?.designId}/${activeDesign.value.auroraProjectId}/sync`,
        {},
        'blueraven'
      )

      //reload the required data for the screen
      await pageLoadOrRefresh()
      handleHidingGlobalLoader(status)
    } else {
      appStore.showSnack(
        'ERROR',
        `Aurora design incomplete. Please navigate back to Aurora and finish your design changes before syncing.`
      )
      handleHidingGlobalLoader(status)
    }
  } catch (e) {
    appStore.loading = false
    appStore.showSnack(
      'ERROR',
      `Aurora design incomplete. Please navigate back to Aurora and finish your design changes before syncing.`
    )
  }
}

const requestNewDesign = async () => {
  try {
    appStore.loading = true
    const formData = new FormData()
    formData.append('description', newDesignRequest.value.description)
    // formData.append('dueDate', newDesignRequest.value.dueDate)

    newDesignRequest.value?.attachments?.forEach((a) => {
      formData.append('attachments', a)
    })

    newDesignRequest.value?.utilityBillAttachments?.forEach((a) => {
      formData.append('utilityBillAttachments', a)
    })

    const { data, status } = await postRequest(
      `/proposal/projects/${projectId.value}/designs`,
      formData,
      'blueraven'
    )
    //this endpoint returns all the designs because adding a new one could possibly remove (cancel) an existing one
    designs.value = data
    await getActiveDesign()
    newDesignRequest.value = {}
    showNewDesignRequestForm.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    logError(e)
    appStore.loading = false
    appStore.showSnack(
      'ERROR',
      e?.data?.message || 'There was an error requesting a new design'
    )
  }
}

const requestPostalCodeApproval = async (comments) => {
  try {
    appStore.loading = true

    const { data, status } = await postRequest(
      `/proposal/projects/${projectId.value}/postalCode`,
      { comments },
      'blueraven'
    )
    activeDesign.value = data
    newDesignRequest.value = {}
    showNewPostalCodeRequestForm.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    appStore.loading = false
    appStore.showSnack(
      'ERROR',
      e?.data?.message || 'There was an error requesting a new design'
    )
  }
}
const disableAddSlice = (proposalCount, offset) => {
  let pageCount = Math.floor(proposalCount / numberToDisplay.value)
  let dividesEqually = proposalCount % numberToDisplay.value === 0
  if (dividesEqually && pageCount !== 0) {
    pageCount--
  }
  return pageCount === offset
}
const getProposalProject = async () => {
  projectLoaded.value = false
  try {
    appStore.loading = true
    const { data, status } = await getRequest(
      `/proposal/projects/${projectId.value}`,
      'blueraven'
    )
    project.value = data
    allowedModules.value = project.value.availableModules
    if(!allowedModules.value?.length > 0 && !project.value.ahjId && !!project.value.metroAreaId){
      //if the project doesn't have an assigned ahj, go get the allowed modules based on the metroAreaId
      const {data} = await getRequest(`/metro/getAllowedModules/${project.value.metroAreaId}`, 'blueraven')
     allowedModules.value = data
    }
    handleHidingGlobalLoader(status)
  } catch (e) {
    logError(e)
    appStore.loading = false
  } finally {
    projectLoaded.value = true
  }
}
const saveDesignField = async (design) => {
  try {
    appStore.loading = true
    const values = [
      {
        textValue: design.tempDesignName,
        customFieldGroupAssignmentId: 26300
      }
    ]
    const { data, status } = await postRequest(
      `/customFieldValues/project/${design.projectId}/processStep/${design.projectProcessStepId}`,
      values
    )
    design.edit = false
    design.designName = design.tempDesignName
     activitiesData.triggerFlag= !activitiesData.triggerFlag;
    handleHidingGlobalLoader(status)
  } catch (e) {
    logError(e)
    appStore.loading = false
  }
}
const getCompletedProposalDesigns = async () => {
  try {
    appStore.loading = true
    const { data, status } = await getRequest(
      `/proposal/projects/${projectId.value}/designs`,
      'blueraven',
      []
    )
    const temppDesigns = data
      ?.map((d) => {
        d?.proposals.sort(dateSortFn())
        return d
      })
      ?.sort(dateSortFn('dateModified'))

    temppDesigns.forEach((d) => {
      d.tempDesignName = d.designName
      d.edit = false
    })

    designs.value = temppDesigns
    handleHidingGlobalLoader(status)
  } catch (e) {
    logError(e)
    appStore.loading = false
  }
}
const getActiveDesign = async () => {
  try {
    requestSuccessful.value = false
    appStore.loading = true

    const { data, status } = await getRequest(
      `/proposal/projects/${projectId.value}/designs/active`,
      'blueraven',
      []
    )
    activeDesign.value = data
    requestSuccessful.value = true
    handleHidingGlobalLoader(status)
  } catch (e) {
    requestSuccessful.value = false
    logError(e)
    appStore.loading = false
  }
}
const addProposal = async (design) => {
  try {
    appStore.loading = true
    const { data, status } = await postRequest(
      `/proposal`,
      {
        projectProcessStepId: design.projectProcessStepId
      },
      'blueraven'
    )
    router.push({ name: 'proposal', params: { proposalId: data.id } })
    handleHidingGlobalLoader(status)
  } catch (e) {
    logError(e)
    appStore.showSnack(
      'ERROR',
      `An error occurred while creating proposal: <strong>${e?.data?.message}</strong>`,
      true
    )
    appStore.loading = false
  }
}
const uploadFiles = (files) => {
  newDesignRequest.value.attachments = files
}
//cuz i am dumb and can't figure out how to pass in "files"
const uploadUtilityBillFiles = (files) => {
  newDesignRequest.value.utilityBillAttachments = files
}

const handleCreateSolargrafDesign = async () => {
  try {
    // Log all designs and their proposals for debugging
    console.log('All Designs:', designs.value);
    designs.value.forEach((d, idx) => {
      console.log(`Design #${idx + 1}:`, d);
      if (d.proposals && d.proposals.length > 0) {
        d.proposals.forEach((p, pIdx) => {
          console.log(`  Proposal #${pIdx + 1}:`, p);
        });
      } else {
        console.log('  No proposals for this design.');
      }
    });

    // Ensure designs is an array
    const designsArray = Array.isArray(designs.value) ? designs.value : [];

    // Flatten all proposals from all designs, keeping reference to parent design
    const allProposals = designsArray.flatMap(design =>
      (Array.isArray(design.proposals) ? design.proposals : []).map(proposal => ({
        proposal,
        design
      }))
    );

    // Find the proposal with the earliest dateCreated
    const earliestProposalObj = allProposals.reduce((earliest, current) => {
      if (!earliest) return current;
      const earliestDate = new Date(earliest.proposal.dateCreated);
      const currentDate = new Date(current.proposal.dateCreated);
      return currentDate < earliestDate ? current : earliest;
    }, null);

    if (!earliestProposalObj) {
      appStore.showSnack('ERROR', 'No proposals found to use.');
      return;
    }

    const { design, proposal } = earliestProposalObj;

    // Prepare new project data using the parent design and proposal
    const newProjectData = {
      name: design.designName || project.value.projectName,
      projectId: projectId.value,
      address: {
        street: project.value.street1,
        city: project.value.city,
        state: project.value.state,
        postalCode: project.value.postalCode
      }
    };

    console.log('New Project Data:', newProjectData);
    console.log(proposal.id);

    // Use postRequest helper to call backend with the correct proposal ID
    const response = await postRequest(
      `/solargraf/proposals/clone/${proposal.id}`,
      newProjectData
    );
    if (response && response.success && response.projectUrl) {
      // Open Solargraf preview in new tab
      const url = `https://app.solargraf.com/preview/${response.projectUrl.split('/').pop()}?view=demo`;
      window.open(url, '_blank');

      // Update Solargraf Design ID field (ID: 31560)
      await saveCustomFieldValue(31560, response.projectUrl.split('/').pop());
      appStore.showSnack('SUCCESS', 'Solargraf design created and opened successfully.');
    } else {
      appStore.showSnack('ERROR', response?.message || 'Failed to create Solargraf design.');
    }
  } catch (error) {
    appStore.showSnack('ERROR', 'Error creating Solargraf design.');
    logError(error);
  }
};

// Helper to update custom field value (ID: 31560)
async function saveCustomFieldValue(fieldId, value) {
  try {
    await postRequest(`/custom-field-value/${project.projectId}/${fieldId}`, { value });
  } catch (e) {
    logError(e);
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
  opacity: 0.6;
  background-color: #000000;
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

.solargraf-design-request {
  border: solid 4px var(--v-anchor-base) !important;
}
</style>
