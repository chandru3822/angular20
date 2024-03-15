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
          <router-link :to="`/project/${project.id}/status`">{{ project.id }}</router-link>
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
    <v-row class="mx-2">
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
            <AlbatrossButton
                size="x-small"
                variant="text"
                color="primary"
                v-if="!d.edit"
                @click="d.edit = true"
                prepend-icon="edit"
            ></AlbatrossButton>
            <AlbatrossButton
                size="x-small"
                variant="text"
                color="primary"
                v-if="d.edit"
                @click="[d.tempDesignName = d.designName, d.edit = false]"
                prepend-icon="close"
            ></AlbatrossButton>
            <AlbatrossButton
                size="x-small"
                variant="text"
                color="primary"
                v-if="d.edit"
                @click="saveDesignField(d)"
                prepend-icon="save"
            ></AlbatrossButton>
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
            <AlbatrossButton
                size="x-small"
                v-if="d.imageIndex !== 0"
                @click="d.imageIndex--"
                color="black"
                fab
                class="image-selection-icon"
                prepend-icon="mdi-chevron-left"
            ></AlbatrossButton>
            <AlbatrossButton
                size="x-small"
                v-if="d.imageIndex !== d.attachments.length - 1"
                @click="d.imageIndex++"
                color="black"
                fab
                class="image-selection-icon"
                prepend-icon="mdi-chevron-right"
            ></AlbatrossButton>
          </div>
        </div>
        <div v-else class="design-image no-image-placeholder">
          <v-icon size="50">mdi-home</v-icon>
        </div>
        <div class="mt-3 design-small-gray">
          Created: {{ d.dateCreated | formatDate('date', 'MMM D, YYYY') }}
        </div>
        <div class="design-small-gray" v-if="project.id">
          <router-link
              :to="{ name : 'projectProcessStep', params: {projectId: project.id, processStepId: d.projectProcessStepId}}"
              target="_blank">
            Open Process Step
          </router-link>
          <v-icon small class="anchor">mdi-open-in-new</v-icon>
        </div>
        <AlbatrossButton
            color="primary"
            class="mt-4 one-hunned text-capitalize font-weight-bold"
            v-if="canEdit"
            @click="addProposal(d)"
            text="Create new proposal"
        ></AlbatrossButton>
        <v-list v-if="d.proposals.length > 0">
          <v-list-item
              v-for="(proposal, index) in d.proposals.slice((d.offset * numberToDisplay),(numberToDisplay + (d.offset * numberToDisplay)))"
              :key="index"
              two-line
              class="proposal-container"
              @click="router.push({name: 'proposal', params: {proposalId: proposal.id}})">
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
          :height="cardHeight"
          class="proposal-card request-new"
          :class="{'disable-new': lockNewRequests || hasActiveDesign || !requestSuccessful}">

        <div v-if="canEdit">
          <AlbatrossButton
              variant="text"
              :disabled="lockNewRequests || hasActiveDesign || !requestSuccessful"
              color="primary"
              @click="handleNewRequest"
          >
            <template #default>
              <v-icon :size="60">add</v-icon>
            </template>
          </AlbatrossButton>
          <div class="mt-5 primary--text"
               :class="{'grey--text text--darken-1': lockNewRequests || hasActiveDesign || !requestSuccessful}">
            Request New Design
          </div>
        </div>
        <div class="request-new-details grey--text text--darken-2" v-if="hasActiveDesign">
          <div>
            <router-link
                :to="{ name : 'projectProcessStep', params: {projectId: project.id, processStepId: activeDesign.projectProcessStepId}}"
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
    </v-row>
    <v-dialog width="500" v-model="showNewDesignRequestForm">
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
          <AlbatrossButton
              variant="text"
              color="primary"
              class="text-capitalize"
              @click="showNewDesignRequestForm = false"
              text="Cancel"
          ></AlbatrossButton>
          <AlbatrossButton
              color="primary"
              class="text-capitalize font-weight-bold"
              :disabled="!newDesignRequest.description"
              @click="requestNewDesign()"
              text="Request"
          ></AlbatrossButton>
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
          <AlbatrossButton
              variant="text"
              class="text-capitalize"
              @click="showNewPostalCodeRequestForm = false"
              color="unset"
              text="Cancel"
          ></AlbatrossButton>
          <AlbatrossButton
              color="primary"
              class="text-capitalize font-weight-bold"
              @click="requestPostalCodeApproval(newDesignRequest.description)"
              text="Request Approval"
          ></AlbatrossButton>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<script setup>
import {formatPhoneNumber, getRequest, handleHidingGlobalLoader, logError, postRequest} from '@/helpers/helpers'

import moment from 'moment'
import DatetimePickerInput from '@/components/DatetimePickerInput'
import constants from '@/helpers/constants'
import ImgProxy from '@/components/ImgProxy'
import CustomValueInput from "@/views/flow/components/CustomValueInput.vue";
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar


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

const designs = ref([])
const cardHeight = ref(575)
const minDate = ref(moment().format('YYYY-MM-DDTHH:mm:ssZ'))
const offset = ref(0)
const numberToDisplay = ref(3)
const newDesignRequest = ref({})
const acceptedFileTypes = ref(constants.STANDARD_IMAGES_AND_DOCS)
const showNewDesignRequestForm = ref(false)
const showNewPostalCodeRequestForm = ref(false)
const lockNewRequests = ref(false)
const project = ref({})
const activeDesign = ref({})
const requestSuccessful = ref(false)

onMounted(async() => {
  getProposalProject()
  getCompletedProposalDesigns()
  await getActiveDesign()
})


const projectId = computed(() => {
  return route.params.projectId
})
const canEdit = computed(() => {
  const hasAdmin = userStore.userHasFeatureAccessLevel('PROPOSALS', 'ADMIN')
  const hasEdit = userStore.userHasFeatureAccessLevel('PROPOSALS', 'EDIT')
  return hasAdmin || hasEdit
})
const hasActiveDesign = computed(() => {
  return !!activeDesign.value?.projectId
})

const handleNewRequest = async() => {
  lockNewRequests.value = true
  const {data} = await getRequest(`/proposal/projects/${projectId.value}/postalCode`, 'blueraven')

  if (data?.approved) {
    showNewDesignRequestForm.value = true
  } else {
    showNewPostalCodeRequestForm.value = true
  }

  lockNewRequests.value = false
}
const requestNewDesign = async() => {
  try {
    appStore.loading = true
    const formData = new FormData()
    formData.append('description', newDesignRequest.value.description)
    // formData.append('dueDate', newDesignRequest.value.dueDate)

    newDesignRequest.value?.attachments?.forEach(a => {
      formData.append('attachments', a)
    })

    newDesignRequest.value?.utilityBillAttachments?.forEach(a => {
      formData.append('utilityBillAttachments', a)
    })

    const {
      data,
      status
    } = await postRequest(`/proposal/projects/${projectId.value}/designs`, formData, 'blueraven')
    //this endpoint returns all the designs because adding a new one could possibly remove (cancel) an existing one
    designs.value = data
    await getActiveDesign()
    newDesignRequest.value = {}
    showNewDesignRequestForm.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    appStore.loading = false
    snackbar('ERROR', e?.data?.message || 'There was an error requesting a new design')
  }
}
const requestPostalCodeApproval = async(comments) => {
  try {
    appStore.loading = true

    const {
      data,
      status
    } = await postRequest(`/proposal/projects/${projectId.value}/postalCode`, {comments}, 'blueraven')
    activeDesign.value = data
    newDesignRequest.value = {}
    showNewPostalCodeRequestForm.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    appStore.loading = false
    snackbar('ERROR', e?.data?.message || 'There was an error requesting a new design')
  }
}
const disableAddSlice = (proposalCount, offset) => {
  let pageCount = (Math.floor(proposalCount / numberToDisplay.value))
  let dividesEqually = proposalCount % numberToDisplay.value === 0
  if (dividesEqually && pageCount !== 0) {
    pageCount--
  }
  return pageCount === offset
}
const getProposalProject = async() => {
  try {
    appStore.loading = true
    const {data, status} = await getRequest(`/project/${projectId.value}`)
    project.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    appStore.loading = false
  }
}
const saveDesignField = async(design) => {
  try {
    appStore.loading = true
    let values = [
      {
        textValue: design.tempDesignName,
        customFieldGroupAssignmentId: 26300
      }
    ]
    const {data, status} = await postRequest(`/customFieldValues/project/${design.projectId}/processStep/${design.projectProcessStepId}`, values)
    design.edit = false
    design.designName = design.tempDesignName
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    appStore.loading = false
  }
}
const getCompletedProposalDesigns = async() => {
  try {
    appStore.loading = true
    const {data, status} = await getRequest(`/proposal/projects/${projectId.value}/designs`, 'blueraven', [])
    const temppDesigns = data
        ?.map((d) => {
          d?.proposals.sort(dateSortFn())
          return d
        })
        ?.sort(dateSortFn('dateModified'))

    temppDesigns.forEach(d => {
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
const getActiveDesign = async() => {
  try {
    requestSuccessful.value = false
    appStore.loading = true

    const {
      data,
      status
    } = await getRequest(`/proposal/projects/${projectId.value}/designs/active`, 'blueraven', [])
    activeDesign.value = data
    requestSuccessful.value = true
    handleHidingGlobalLoader( status)
  } catch (e) {
    requestSuccessful.value = false
    logError(e)
    appStore.loading = false
  }
}
const addProposal = async(design) => {
  try {
    appStore.loading = true
    const {data, status} = await postRequest(`/proposal`, {
      projectProcessStepId: design.projectProcessStepId
    }, 'blueraven')
    router.push({name: 'proposal', params: {proposalId: data.id}})
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    snackbar('ERROR', `An error occurred while creating proposal: <strong>${e?.data?.message}</strong>`, true)
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

.request-new-details {
  margin-top: 16px;
  font-size: 12px;
}

.disable-new {
  color: var(--v-grey-darken1);
}
</style>
