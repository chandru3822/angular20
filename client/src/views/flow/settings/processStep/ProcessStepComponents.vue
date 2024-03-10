<template>
  <v-container class="custom-field-group-container py-0">
    <div class="text-center">
      <v-dialog width="700"
                v-model="deleteError"
      >
        <v-card>
          <v-card-title class="text-h5 grey lighten-2 error--text">
            Error Deleting Status from Process Step
          </v-card-title>

          <v-card-text class="pt-5">
            <div v-if="cannotDeleteReasons.inUseByWqt" class="mb-5">
              * This status is in use by Work Queue Types. <br/>
              <span class="ml-5">You must delete those before you can delete this status.</span>
            </div>

            <div v-if="cannotDeleteReasons.inUseByInitialStep" class="mb-5">
              * This step is set as an Initial Step in a process and is using this status. <br/>
              <span class="ml-5">You must remove it there before you can delete this status.</span>
            </div>

            <div v-if="cannotDeleteReasons.actions && cannotDeleteReasons.actions.length > 0" class="mb-5">
              * This status is being used as the Parent Status in the following actions on this step:
              <div v-for="a in cannotDeleteReasons.actions" :key="a.id" class="ml-5">
                <strong>{{ a.actionName }}</strong>
              </div>
            </div>

            <div v-if="cannotDeleteReasons.childProcesses && cannotDeleteReasons.childProcesses.length > 0"
                 class="mb-5">
              * This status is being used when creating a Child Process Step in the following step and actions:
              <div v-for="a in cannotDeleteReasons.childProcesses" :key="a.id" class="ml-5">
                <strong>{{ a.processStepName }} - {{ a.actionName }}</strong>
              </div>
            </div>
          </v-card-text>

          <v-card-actions>
            <v-spacer></v-spacer>

            <AlbatrossButton
                color="primary"
                class=""
                @click="deleteError = false"
                text="OK"
            ></AlbatrossButton>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </div>
    <v-row>
      <v-col cols="12" class="py-0">
        <v-row>
          <v-col cols="12" class="pt-0 px-0">
            <v-toolbar flat class="wqt-header-bar">
              <v-toolbar-title class="title-large">Process Step Status Types</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <AlbatrossButton
                    variant="text"
                    color="primary"
                    @click="[addNewProcessStepStatusType = !addNewProcessStepStatusType, expanded = [], getCompanyProcessStepStatusTypes()]"
                    v-if="userCanAdd"
                    :prepend-icon="!addNewProcessStepStatusType ? 'add' : 'close'"
                    :text="$vuetify.breakpoint.smAndDown ? '' : addNewProcessStepStatusType ? 'Cancel' : 'Add Process Step Status Type'"
                ></AlbatrossButton>
                <AlbatrossButton
                    variant="text"
                    color="primary"
                    @click="expandPsst = !expandPsst"
                    :prepend-icon="!expandPsst ? 'mdi-chevron-down' : 'mdi-chevron-up'"
                ></AlbatrossButton>
              </v-toolbar-items>
            </v-toolbar>
            <div class="mb-4">
              <v-card flat class="square-card mb-3 pa-3" color="primary lighten-9" v-if="addNewProcessStepStatusType">
                <h3>Assign a Status Type</h3>
                <v-autocomplete label="Process Step Status Type"
                                :items="availableCompanyProcessStepStatusTypes"
                                v-model="newProcessStepStatusTypeId"
                                item-text="processStepStatusType"
                                item-value="id"
                                attach
                                :loading="companyStatusesLoading"
                                autocomplete="off"
                                @input="assignStatusTypeToProcessStep"
                >
                  <template slot="item" slot-scope="data">
                    <!-- HTML that describes how select should render items when the select is open -->
                    {{ data.item.processStepStatusType }} ({{ data.item.rootProcessStepStatusType }})
                  </template>
                </v-autocomplete>
              </v-card>
              <v-data-table
                v-if="expandPsst"
                :headers="processStepHeaders"
                :items="filteredAssignedProcessStepStatusTypes"
                hide-default-footer
                :items-per-page="-1"
                disable-sort
                class="elevation-1 square-card mb-2 table-striped"
              >
                <template #no-data>
                  <span class="default-text-color">No available process step status types</span>
                </template>

                <template #no-results>
                  <span class="default-text-color">No available process step status types</span>
                </template>

                    <template #item.statusType = {item} class="text-left"><a href="/settings/processStepStatuses" >{{ item.processStepStatusType }}</a></template>
                    <template #item.category="{item}" class="text-left">{{ item.rootProcessStepStatusType }}</template>
                    <template #item.allowNonAdminUse="{item}" class="text-left" v-if="nonAdminAdd">
                      <input type="checkbox" v-model="item.allowNonAdminUse"
                             @input="saveNonAdminUse($event, item)"
                             :disabled="!userCanEdit" :readonly="!userCanEdit" />
                    </template>
                    <template #item.icons="{item}" class="text-right">
                      <div class="flex-display">
                        <AlbatrossButton
                            v-if="userCanEdit"
                            size="small"
                            variant="text"
                            color="primary"
                            @click="deleteProcessStepStatusType=item"
                            prepend-icon="delete"
                        ></AlbatrossButton>
                      </div>
                    </template>
              </v-data-table>
            </div>
            <ProcessStepWorkQueueTypes v-if="!psLoading" :process-step="processStep"></ProcessStepWorkQueueTypes>
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="12" class="mt-1 pa-0">
            <v-toolbar flat class="link-header-bar">
              <v-toolbar-title class="title-large">Links</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <AlbatrossButton
                    variant="text"
                    color="primary"
                    @click="getLinksForProcessStep"
                    v-if="userCanAdd"
                    :prepend-icon="!addNewLink ? 'add' : 'close'"
                    :text="$vuetify.breakpoint.smAndDown ? '' : addNewLink ? 'Cancel' : 'Add Link'"
                ></AlbatrossButton>
                <AlbatrossButton
                    variant="text"
                    color="primary"
                    @click="expandLinks = !expandLinks"
                    :prepend-icon="!expandLinks ? 'mdi-chevron-down' : 'mdi-chevron-up'"
                ></AlbatrossButton>
              </v-toolbar-items>
            </v-toolbar>
            <v-card class="square-card pa-2" color="primary lighten-9" v-if="addNewLink">
              <v-autocomplete attach v-if="addNewLink"
                        v-model="newLink.linkId"
                        :items="availableLinks"
                        label="Select Link"
                        item-text="link"
                        item-value="id"
                        @input="assignNewLink"
              ></v-autocomplete>
            </v-card>
            <v-card flat v-if="processStep.links && processStep.links.length > 0 && expandLinks">
              <draggable v-model="processStep.links" group="links"
                         :disabled="!userCanEdit"
                         id="link-draggable"
                         @change="saveLinkOrder(processStep.links)"
                         @start="drag=true" @end="drag=false">
                <v-list class="grab" v-for="(a, index) in processStep.links?.filter(l => !l.archived)"
                        :key="index">
                  <v-list-item dense :class="{'shaded-row': index % 2}">
                    <v-list-item-action>
                      <v-icon>drag_handle</v-icon>
                    </v-list-item-action>
                    <v-list-item-content>
                      {{ a.link }}
                    </v-list-item-content>
                    <AlbatrossButton
                        v-if="userCanEdit"
                        size="small"
                        variant="text"
                        color="primary"
                        @click="deleteLink=a"
                        prepend-icon="delete"
                    ></AlbatrossButton>
                  </v-list-item>
                </v-list>
              </draggable>
            </v-card>
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="12" class="pa-0 mt-4">
            <v-toolbar flat class="access-header-bar">
              <v-toolbar-title class="title-large">Process Step Access Control</v-toolbar-title>
            </v-toolbar>
            <div v-if="positionsLoading" class="section-spinner">
              <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
            </div>
            <v-row v-else>
              <v-card flat color="rowShadeCustom" class="square-card mt-2 col-12 col-md-4">
                <v-card-text>
                  <multi-select-group
                      v-if="!positionsLoading"
                      background-color="transparent"
                      :userCanEdit="userCanEdit"
                      :returnObject="processStep"
                      :content="positions"
                      :dropdownEnabled="processStep.readonly"
                      :selectedContent="processStep.whiteListedPositions"
                      :title="'Read Only'"
                      :label="'Allowed Positions'"
                      :alternateLabel = "'Denied Positions'"
                      :allow="processStep.readonlyAllow"
                      :contentLoading="positionsLoading"
                      save-button
                      full-size
                      @selected-changed="startTimeReadOnlySelectedEventListener"
                      @allow-changed="startTimeReadOnlyAllowEventListener"
                      @checkbox-changed="startTimeReadOnlyCheckboxEventListener"
                      @save-multi-select="saveReadOnlyAndWhiteList"
                  ></multi-select-group>
                </v-card-text>
              </v-card>
              <v-card flat class="square-card mt-2 col-12 col-md-8 col-lg-6">
                <v-card-text>
                  <multi-select-group
                      v-if="!positionsLoading"
                      background-color="transparent"
                      :userCanEdit="userCanEdit"
                      :return-object="processStep"
                      :content="positions"
                      :dropdownEnabled="processStep.nonAdminAdd"
                      :selectedContent="processStep.nonAdminAddWhiteListedPositions"
                      title="Allow Non-Admin to Add to Project"
                      label="Allowed Positions"
                      alternateLabel = "Denied Positions"
                      :allow="true"
                      :contentLoading="positionsLoading"
                      save-button
                      full-size
                      @selected-changed="nonAdminWBLPositionsSelectionChange"
                      @allow-changed="toggleNonAdminAllowDenyList"
                      @checkbox-changed="toggleAllowNonAdminCheckbox"
                      @save-multi-select="saveProcessStep"
                  />
                </v-card-text>
            </v-card>
            </v-row>
          </v-col>
        </v-row>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog" @confirm="confirmDelete" @close-dialog="[deleteProcessStepStatusType = null, deleteLink = null, deleteAttachment = null]">
      Are you sure you want to delete {{deleteDialogText}}<strong>{{deleteDialogItemText}}</strong>?

    </ConfirmationDialog>
  </v-container>
</template>

<script setup>

import AlbatrossButton from "@/components/customVuetify/AlbatrossButton"
import draggable from 'vuedraggable'
import {getAvailableForProcessStep} from '@/services/processStepStatusTypeService'
import ProcessStepCustomFieldGroups from './ProcessStepCustomFieldGroups'
import ProcessStepWorkQueueTypes from './ProcessStepWorkQueueTypes'
import orderBy from "lodash.orderby"

import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
  getSnackbar
} from '@/helpers/helpers'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import { getCurrentInstance, computed, ref, onMounted } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute} from "vue-router/composables";
import {defineProps} from 'vue'
import { useAppStore } from '@/stores/AppStorePinia.js'
const appStore = useAppStore()

const route = useRoute()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const props = defineProps({
  nonAdminAdd: Boolean
})

const {nonAdminAdd} = props;


      const nonAdminAddWhiteListedPositionsChanged = ref(false)
      const psLoading = ref(true)
      const expandPsst = ref(true)
      const expandLinks = ref(true)
      const expanded = ref([])
      const deleteError = ref(false)
      const cannotDeleteReasons = ref({})
      const addNewCustomFieldGroup = ref(false)
      const changesMade = ref(false)
      const addNewType = ref(false)
      const newType = ref({})
      const addNewLink = ref(false)
      const newLink = ref({})
      const availableLinks = ref([])
      const processStep = ref({})
      const positions = ref([])
      const positionsLoading = ref(false)
      const readOnlyPositionsChanged = ref(false)
      const companyStatusesLoading = ref(false)
      const availableCompanyProcessStepStatusTypes = ref([])
      const addNewProcessStepStatusType = ref(false)
      const newProcessStepStatusTypeId = ref(null)
      const checkedIds = ref([])
      const deleteProcessStepStatusType = ref(null)
      const deleteLink = ref(null)
      const deleteAttachment = ref(null)
      const breadcrumbs = ref([
        {
          text: 'Back',
          disabled: false,
          exact: true,
          to: `/settings/processSteps`
        },
      ])

const processStepId = computed(() => {
  return route.params.id
})
const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})
const companyId = computed(() => {
  return userStore.details.companyId
})


const processStepHeaders = computed(() => {
  let headers = [
    {text: 'Status Type', value: 'statusType', show: true},
    {text: 'Category', value: 'category', show: true},
    {text: 'Allow Non-Admin Use', value: 'allowNonAdminUse', show: nonAdminAdd || false},
    {text: '', value: 'icons', show: true, width: '100px'},
  ]
  return headers.filter(h => h.show)
})
const showDeleteDialog = computed(() => {
  return Boolean(deleteProcessStepStatusType.value || deleteAttachment.value || deleteLink.value)
})
const deleteDialogText = computed(() => {
  if(deleteLink.value){
    return `this link: `
  }
  if(deleteAttachment.value){
    return `this attachment: `
  }
  return ''
})
const deleteDialogItemText = computed(() => {
  if(deleteProcessStepStatusType.value){
    return deleteProcessStepStatusType.value.processStepStatusType
  }
  if(deleteLink.value){
    return deleteLink.value.link
  }
  if(deleteAttachment.value){
    return deleteAttachment.value.attachmentType
  }
  return ''
})
const filteredAssignedProcessStepStatusTypes = computed(() => {
  return orderBy(processStep.value?.companyProcessStepStatusTypes?.filter(u => {
    return !u.archived
  }), [f => f.processStepStatusType])
})

onMounted(async () => {
    await getProcessStepDetails()
    getPositions()

})


    const getPositions = async () => {
      if(positions.value?.length === 0) {
        try {
          positionsLoading.value = true
          const {data, status} = await getRequest(`/position/withParent`)
          positions.value = data
          positionsLoading.value = false
          handleHidingGlobalLoader(status)
        } catch (e) {
          positionsLoading.value = false
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Retrieving Positions')
          appStore.loading = false
        }
      }
    }
    const saveReadOnlyAndWhiteList = async  () => {
      appStore.loading = true
      try {
        const {status} = await putRequest(`/processStep/saveReadOnlyAndWhiteList?savePositions=${readOnlyPositionsChanged.value ?? false}`, processStep.value)
        readOnlyPositionsChanged.value = false
        if(!processStep.value.readonly) {
          processStep.value.whiteListedPositions = []
        }
        snackbar('SUCCESS', 'Saved Successfully')
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.loading = false
      }
    }
    const nonAdminWBLPositionsSelectionChange = (e) => {
      processStep.value.nonAdminAddWhiteListedPositions = e
      nonAdminAddWhiteListedPositionsChanged.value = true
    }
    const toggleNonAdminAllowDenyList = (e) => {
      processStep.value.nonAdminAddAllow = (e === 0)
    }
    const toggleAllowNonAdminCheckbox = (e) => {
      processStep.value.nonAdminAdd = e
    }
    const saveProcessStep = async () => {
      appStore.loading = true
      try {
        const {status} = await putRequest(`/processStep?savePositions=${nonAdminAddWhiteListedPositionsChanged.value ?? false}`, processStep.value)
        snackbar('SUCCESS', 'Process Step Updated')
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Updating Process Step')
        appStore.loading = false
      }
    }
    const getCompanyProcessStepStatusTypes = async () => {
      if (addNewProcessStepStatusType.value) {
        companyStatusesLoading.value = true
        try {
          const {data} = await getAvailableForProcessStep(processStepId.value)
          availableCompanyProcessStepStatusTypes.value = data
          companyStatusesLoading.value = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Retrieving Process Step Status Types')
          companyStatusesLoading.value = false
        }
      }
    }
    const deleteStatusTypeFromStep = async (item) => {
      appStore.loading = true
      try {
        //have to close the work queue editor to for the component to refresh available values
        addNewWorkQueueType.value = false
        expanded.value = []
        const {status} = await putRequest(`/processStep/status/removeStatus/${item.id}/fromStep/${processStepId.value}`)
        item.archived = true
        snackbar('SUCCESS', 'Status Type Deleted')
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)

        if (e.status === 400) {
          item.deleteConfirm = false
          deleteError.value = true
          cannotDeleteReasons.value = e.data
        }
        snackbar('ERROR', 'Error Deleting Status Type')
        appStore.loading = false
      }
    }
    const saveNonAdminUse = async (e, item) => {
      appStore.loading = true
      try {
        let body = {
          allowNonAdminUse: e.target.checked || false
        }
        const {data, status} = await putRequest(`/processStep/status/${item.id}/updateAllowNonAdminUse`, body)
        snackbar('SUCCESS', 'Changes Saved')
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Saving')
        appStore.loading = false
      }
    }
    const assignStatusTypeToProcessStep = async () => {
      appStore.loading = true
      try {
        newType.value.processStepId = processStepId
        const {data, status} = await postRequest(`/processStep/status/assignCompanyStatus/${newProcessStepStatusTypeId.value}/toProcessStep/${processStepId.value}`)
        processStep.value.companyProcessStepStatusTypes.push(data)
        // reset fields
        addNewProcessStepStatusType.value = false
        newProcessStepStatusTypeId.value = null
        snackbar('SUCCESS', 'Status Type Added')
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Adding Status Type')
        appStore.loading = false
      }
    }
    const getProcessStepDetails = async () => {
      psLoading.value = true
      appStore.loading = true
      try {
        appStore.loading = true
        const {data, status} = await getRequest(`/processStep/${processStepId.value}`)
        processStep.value = data
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Retrieving Data')
        appStore.loading = false
      } finally {
        psLoading.value = false
      }
    }
    const getLinksForProcessStep = async () => {
      try {
        addNewLink.value = !addNewLink.value
        if (addNewLink.value) {
          appStore.loading = true
          const {data, status} = await getRequest(`/links/processStep/${processStepId.value}/available`)
          availableLinks.value = data
          handleHidingGlobalLoader(status)
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Retrieving Data')
        appStore.loading = false
      }
    }
    const assignNewLink = async () => {
      appStore.loading = true
      try {
        newLink.value.processStepId = processStepId.value
        const {data, status} = await postRequest(`/links/processStep`, newLink.value)
        processStep.value.links.push(data)
        // reset fields
        addNewLink.value = false
        newLink.value = {}
        snackbar('SUCCESS', 'Link Added')
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Adding Link')
        appStore.loading = false
      }
    }
    const deleteLinkFromStep = async (id) => {
      appStore.loading = true
      try {
        addNewLink.value = false
        const {status} = await deleteRequest(`/links/processStep/${id}`)
        snackbar('SUCCESS', 'Link Deleted')
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Deleting Link')
        appStore.loading = false
      }
    }

    const saveLinkOrder = async (links) => {
      try {
        // if the fieldOrder of any item does not match idx + 1, it means it was changed and needs to be saved
        // pull those needing to be saved out of list
        let linksToSave = []
        links.forEach((f, idx) => {
          let order = idx + 1
          if (f.displayOrder !== order) {
            f.displayOrder = order
            linksToSave.push(f)
          }
        })
        // save them here
        if (linksToSave.length > 0) {
          appStore.loading = true
          const {status} = await putRequest(`/links/updateOrderInProcessStep`, linksToSave)
          handleHidingGlobalLoader(status)
        }
        snackbar('SUCCESS', 'Links Updated')
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Updating Links')
        appStore.loading = false
      }
    }
    const confirmDelete = () => {
      if(deleteProcessStepStatusType.value){
        deleteStatusTypeFromStep(deleteProcessStepStatusType.value)
        deleteProcessStepStatusType.value = null
      }else if(deleteLink.value){
        deleteLink.value.archived = true
        deleteLinkFromStep(deleteLink.value.id)
        deleteLink.value = null
      }else if(deleteAttachment.value){
        deleteAttachment.value.archived = true
        //this function doesn't exist. i dont know what it was supposed to do
        // deleteTypeFromStep(deleteAttachment.value.id)
        deleteAttachment.value = null
      }
    }
    const startTimeReadOnlySelectedEventListener = (e) => {
      processStep.value.whiteListedPositions = e;
      readOnlyPositionsChanged.value = true;
    }
    const startTimeReadOnlyAllowEventListener = (e) => {
      processStep.value.readonlyAllow = (e === 0);
    }
    const startTimeReadOnlyCheckboxEventListener = (e) => {
      processStep.value.readonly = e;
    }
</script>

<style scoped lang="scss">
.name-container {
  background-color: var(--v-primary-lighten9) !important;
  border-radius: 5px;
}

.link-header-bar,
.access-header-bar {
  border-top: 1px solid #E6E6E6;
  border-bottom: 1px solid #E6E6E6;
}
</style>
