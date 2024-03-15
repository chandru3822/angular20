<template>
  <v-container id="proposals-container" v-if="proposalExists">
    <v-row>
      <v-col cols="12" class="py-0">
        <router-link
            v-if="proposal && proposal.projectId"
            :to="`/proposalDesigns/${proposal.projectId}`"
        >Back
        </router-link>

        <v-row align="center" justify="center" no-gutters>
          <v-col md="auto">
            <v-alert
                color="warning"
                dense
                tile
                :value="dirtyCfvs.length > 0"
                transition="scale-transition"
            >
              Changes haven't been reflected on proposal
            </v-alert>
          </v-col>
        </v-row>

        <v-toolbar dense flat color="transparent">
          <v-toolbar-title class="new-proposal-header">
            <editable-input
                :editable="!proposal.locked"
                :display-text="proposal.displayName"
                :value="defaultProposalName"
                @input="handleNameChange"
            />
          </v-toolbar-title>
          <v-chip
              v-if="proposal.locked"
              small
              color="error"
              dark
              class="ml-2 text-uppercase"
          >
            <v-icon small>mdi-lock</v-icon>
            Locked
          </v-chip>
          <v-spacer />
          <v-toolbar-items>
            <v-menu
                v-model="versionMenu"
                v-if="proposal && proposal.projectId"
                transition="slide-x-transition"
                :close-on-content-click="false"
                :offset-y="true"
                :z-index="250"
                :max-width="375"
            >
              <template #activator="{ on, attrs }">
                <AlbatrossButton
                    variant="text"
                    :activation-handler="on"
                    v-bind="attrs"
                    :disabled="!userIsAdmin && !userCanManage"
                    @click="loadProposalVersions()"
                    color="unset"
                    :text="`v.${proposal.version}`"
                ></AlbatrossButton>
              </template>
              <v-card flat color="white" class="pa-4" :elevation="0">
                <v-autocomplete
                    :items="versions"
                    item-value="id"
                    item-text="version"
                    :loading="loadingVersions"
                    hide-details
                    class="mt-0"
                    label="Select a version..."
                    v-model="proposal.proposalVersionId"
                />
                <AlbatrossButton
                    color="primary"
                    class="mt-3"
                    :disabled="(!userIsAdmin && !userCanManage) || !proposal.proposalVersionId"
                    @click="updateProposalVersion()"
                    text="Save"
                ></AlbatrossButton>
              </v-card>
            </v-menu>
            <next-step-menu
                v-if="proposal.id"
                :disabled="dirtyCfvs.length > 0"
                :proposal="proposal"
                @update="handleStepChange"
            />
          </v-toolbar-items>
        </v-toolbar>
      </v-col>
    </v-row>

    <v-form ref="proposalForm">
      <v-row>
        <v-col cols="12" sm="4">
          <v-card class="proposal-container">
            <div>
              <div class="proposal-container-header">
                <div class="proposal-title">Configurations</div>
              </div>
              <div v-for="(cfg, index) in sortedCustomFieldGroups" :key="index">
                <div class="configuration-group-title">{{ cfg.groupName }}</div>
                <div
                    class="cf-container"
                    v-for="(field, idx) in cfg.customFieldValues.filter((f) => {return userHasWhiteListedPosition(f, 'hidden')})"
                    :key="idx"
                >
                  <CustomValueInput
                      :required="field.required"
                      :callback="populateDirtyCfvs"
                      :readonly="
                      !canEdit ||
                      proposal.locked ||
                      !isConditionalFieldPopulated(field) ||
                      (field.conditionalOnId && loading) ||
                      !userHasWhiteListedPosition(field, 'readonly') ||
                      field.ancillaryCustomFieldGroupAssignmentId !== null
                    "
                      :field="field"
                      :show-field-name="false"
                      :list-of-value-filter="filters[field.customFieldId]"
                      :hint="getHint(field)"
                  />
                  <CommissionDetailsMenu
                      v-if="field.customFieldGroupAssignmentId === 454"
                      :custom-field-groups="sortedCustomFieldGroups"
                      :proposal-id="proposalId"
                  />
                </div>
              </div>
            </div>
            <div
                class="configuration-save-container"
                v-if="canEdit && !proposal.locked"
            >
              <AlbatrossButton
                  depressed
                  variant="text"
                  color="primary"
                  :disabled="dirtyCfvs.length === 0"
                  class="text-capitalize"
                  @click="resetToDefault"
                  text="Reset to Default"
              ></AlbatrossButton>
              <v-spacer />
              <AlbatrossButton
                  color="primary"
                  depressed
                  :dark="dirtyCfvs.length !== 0"
                  :disabled="dirtyCfvs.length === 0"
                  @click="validateForm()"
                  class="text-capitalize font-weight-bold"
                  text="Save"
              ></AlbatrossButton>
            </div>
          </v-card>
        </v-col>
        <v-col cols="12" sm="8">
          <v-card class="proposal-container" v-if="!hideProposalSection">
            <div
                class="proposal-container-header sticky-header"
                :class="isIntersecting ? 'is-pinned' : ''"
                v-intersect="{
                handler: onStickyHeader,
                options: { threshold: [1] }
              }"
            >
              <v-alert
                  class="text-center"
                  v-if="isIntersecting"
                  color="warning"
                  dense
                  tile
                  :value="dirtyCfvs.length > 0"
                  transition="scale-transition"
              >
                Changes haven't been reflected on proposal
              </v-alert>

              <div class="d-flex align-center">
                <div class="proposal-title">
                  Proposal <span>#{{ proposal.proposalNbr }}</span>
                </div>
                <v-spacer />
                <AlbatrossButton
                    v-if="canEdit && !proposal.locked"
                    color="grey lighten-4"
                    class="proposal-container-buttons text-capitalize primary--text"
                    @click="deleteProposal"
                    text="Delete"
                ></AlbatrossButton>
                <AlbatrossButton
                    v-if="canEdit && pages && pages.length"
                    color="grey lighten-4"
                    class="proposal-container-buttons text-capitalize primary--text"
                    :disabled="dirtyCfvs.length > 0"
                    @click="duplicate"
                    text="Duplicate"
                ></AlbatrossButton>
                <AlbatrossButton
                    v-if="pages && pages.length"
                    color="grey lighten-4"
                    :disabled="dirtyCfvs.length > 0"
                    class="proposal-container-buttons text-capitalize primary--text"
                    @click="downloadPdf"
                    text="Download"
                ></AlbatrossButton>
              </div>
            </div>
            <div class="proposal-zoom-lock" v-if="pages && pages.length > 0">
              <proposal-template
                  :children="pages"
                  :debug="false"
                  :editable="false"
              />
            </div>
            <div v-else>
              <v-alert v-if="!templateLoading" prominent type="error">
                <v-row>
                  <v-col class="grow"> Error generating proposal </v-col>
                </v-row>
              </v-alert>
            </div>
          </v-card>
        </v-col>
      </v-row>
    </v-form>
    <confirm-dialog ref="confirmDialog" />
    <confirm-dialog ref="deleteConfirmDialog">
      <p>Are you sure you want to delete this proposal?</p>
    </confirm-dialog>
  </v-container>
  <v-container v-else>
    <v-alert prominent type="error">
      <v-row align="center">
        <v-col class="grow"> Proposal #{{ proposalId }} does not exist. </v-col>
        <v-col class="shrink">
          <router-link
              v-if="proposal && proposal.projectId"
              :to="`/proposalDesigns/${proposal.projectId}`"
              custom
              v-slot="{ href, route, navigate, isActive, isExactActive }"
          >
            <AlbatrossButton
                @click="navigate"
                color="unset"
                text="Back to project"
            ></AlbatrossButton>
          </router-link>
        </v-col>
      </v-row>
    </v-alert>
  </v-container>
</template>

<script setup>
import {
  apiRequest,
  deleteRequest,
  getRequest,
  getRequestWithParams,
  handleHidingGlobalLoader,
  logError,
  postRequest,
  putRequest
} from '@/helpers/helpers'

import CustomValueInput from '@/views/flow/components/CustomValueInput'
import ProposalTemplate from '@/views/blueraven/settings/proposalDesigner/ProposalTemplate'
import { ProposalActions } from '@/views/blueraven/settings/proposalDesigner/store'
import ConfirmDialog from '@/views/blueraven/proposals/ConfirmDialog'
import NextStepMenu from '@/views/blueraven/proposals/NextStepMenu'
import EditableInput from '@/views/blueraven/proposals/EditableInput'
import { mapState } from 'vuex'
import Vue2Filters from 'vue2-filters'
import CommissionDetailsMenu from "@/views/blueraven/proposals/CommissionDetailsMenu.vue";
import ResidualDetailModal from "@/views/blueraven/commissionManagement/ResidualDetailModal.vue";
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"
import {getCurrentInstance, toRefs, computed, ref, onMounted, watch, onBeforeUnmount, provide} from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter, onBeforeRouteLeave} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar


const { VITE_HIDE_PROPOSAL } = import.meta.env

const autoSelectFieldIds = [407, 102, 81]

const USD = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD'
})

const proposalExists = ref(false)
const isIntersecting = ref(false)
const loading = ref(false)
const hideProposalSection = ref(VITE_HIDE_PROPOSAL || false)
const proposalId = ref(parseInt(route.params.proposalId))
const versionMenu = ref(false)
const loadingVersions = ref(true)
const versions = ref([])
const proposal = ref({customFieldGroups: []})
const dirtyCfvs = ref([])
const filters = ref({})
const confirmDialog = ref(null)
const proposalForm = ref(null)
const deleteConfirmDialog = ref(null)

//todo: kaleb?
provide('editor', undefined)

onMounted(() => {
  getProposalDetails()
  store.dispatch(ProposalActions.FETCH_TEMPLATE_CONTEXT, {
    proposalId: proposalId.value
  })
  window.addEventListener('beforeunload', beforeWindowUnload.value)
})

onBeforeRouteLeave(async (to, from, next) => {
  if (dirtyCfvs.value?.length > 0) {
    const { ok } = await confirmDialog.value.open()
    return ok ? next() : false
  }
  next()
})
onBeforeUnmount(async () => {
  window.removeEventListener('beforeunload', beforeWindowUnload.value)
})


const userIsAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROPOSALS', 'ADMIN')
})
const userCanManage = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROPOSALS', 'MANAGE')
})
const canEdit = computed(() => {
  const hasAdmin = userStore.userHasFeatureAccessLevel('PROPOSALS', 'ADMIN')
  const hasEdit = userStore.userHasFeatureAccessLevel('PROPOSALS', 'EDIT')
  return (hasAdmin || hasEdit)
})
const defaultProposalName = computed(() => {
  if (proposal.value?.name) {
    return proposal.value.name
  }
  return 'New Proposal'
})
const pages = computed(() => {
  return template.value?.filter((x) => x.parentId === undefined)
})
const sortedCustomFieldGroups = computed(() => {
  const customFieldGroups = [...(proposal.value?.customFieldGroups ?? [])]
  return customFieldGroups.sort((cfg1, cfg2) => {
    if (cfg1.groupOrder < cfg2.groupOrder) {
      return -1
    }
    if (cfg1.groupOrder > cfg2.groupOrder) {
      return 1
    }
    return 0
  })
})

//@kaleb??
const { template, templateLoading } = mapState({
  template: (state) => state.proposal.template,
  templateLoading: (state) => state.proposal.loading
})

const getHint = (field) => {
  if (!field) {
    return undefined
  }

  if (field.customFieldGroupAssignmentId === 167) {
    const maxDiscountAmount = proposal.value.maxDiscountAmount
    if (maxDiscountAmount) {
      return `Max discount allowed is ${USD.format(
          proposal.value.maxDiscountAmount
      )}`
    }
  }
}
const userHasWhiteListedPosition = (cf, arg = 'readonly') => {
  const wlAttr =
      arg === 'readonly'
          ? 'whiteListedPositions'
          : 'hiddenWhiteListedPositions'
  const prAttr =
      arg === 'readonly'
          ? 'customFieldGroupAssignmentReadOnly'
          : 'customFieldGroupAssignmentHidden'

  //field doesn't require a white listed position
  if (!cf[prAttr]) {
    return true
  }

  //positions required for user
  const positions = cf[wlAttr]?.map(wlp => wlp.positionId) ?? []
  return userStore.userHasAnyPosition(positions)
}
const onStickyHeader = (entries) => {
  const ratio = entries[0].intersectionRatio
  isIntersecting.value = ratio < 1
}
const handleNameChange = async({ save, value }) => {
  const hasChanged = proposal.value?.name !== value
  proposal.value = { ...proposal.value, name: value }
  if (save && hasChanged) {
    try {
      const { data: proposal } = await postRequest(
          `/proposal/${proposalId.value}/name`,
          { name: value },
          'blueraven',
          {}
      )
      proposal.value = proposal
    } catch (e) {
      snackbar(
          'ERROR',
          e?.data?.message || 'Error updating proposal name'
      )
    }
  }
}
const getProposalDetails = async() => {
  appStore.loading = true

  try {
    //assume the proposal exists
    proposalExists.value = true

    //reset cfvs
    dirtyCfvs.value = []

    const { data, status } = await getRequest(
        `/proposal/${proposalId.value}`,
        'blueraven'
    )
    proposal.value = data

    // build filters on load for any field with a conditional property
    const fields = proposal.value?.customFieldGroups
        ?.map((cfg) => cfg.customFieldValues)
        ?.flat()

    const conditionalOnFields = fields
        ?.filter((f) => f.conditionalOnId !== null)
        ?.map((f) => f.conditionalOnId)

    const filters = fields
        ?.filter((f) =>
            conditionalOnFields.includes(f.customFieldGroupAssignmentId)
        )
        ?.map(buildFilters.value)

    //wait for all the filters to run initially
    await Promise.allSettled(filters)

    //preselect certain fields _after_ we've built the filters
    //todo order might matter at some point
    fields
        .filter((f) => autoSelectFieldIds.includes(f.customFieldId))
        .filter((f) => f.listOfValues?.length > 0)
        .filter((f) => f.intValue === null || f.intValue === undefined)
        .filter((f) => {
          //if we don't have a conditional field don't filter it out
          if (!f.conditionalOnId) {
            return true
          }
          //if we do we need to have a value set
          return fields
              ?.filter(
                  (x) => x?.customFieldGroupAssignmentId === f.conditionalOnId
              )
              ?.every((x) => x.intValue !== null)
        })
        .forEach((field) => {
          const filter = filters.value[field.customFieldId]
          const listOfValues = filter
              ? field.listOfValues.filter(filter)
              : field.listOfValues
          const initialValue = listOfValues[0]

          //only pre-select if we have one option available
          if (listOfValues.length === 1 && initialValue) {
            field.intValue = initialValue.id
            populateDirtyCfvs(field)
          }
        })

    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    proposalExists.value = false
    snackbar('ERROR', `Error retrieving proposal #${proposalId.value}`)
  } finally {
    appStore.loading = false
  }
}
const resetToDefault = async() => {
  await getProposalDetails()
  proposalForm.value.resetValidation()
}
const validateForm = () => {
  //checks for required fields prior to opening the save dialog
  if (proposalForm.value.validate()) {
    saveCustomFieldValues()
  } else {
    snackbar('ERROR', 'Missing Required Fields')
  }
}
const loadProposalVersions = async() => {
  try {
    loadingVersions.value = true
    const { data } = await getRequest(
        `/proposal/versions?published=true&size=50&page=0`,
        'blueraven'
    )
    versions.value = data.content
  } catch (e) {
    snackbar('ERROR', 'Error loading proposal versions')
  } finally {
    appStore.loading = false
    loadingVersions.value = false
  }
}
const updateProposalVersion = async() => {
  appStore.loading = true
  try {
    await putRequest(
        `/proposal/${proposalId.value}/version/${proposal.value.proposalVersionId}`,
        {},
        'blueraven'
    )
    //fully reload page due to implications of changing a proposals version
    //todo: probably should put in a v-dialog warning thing when they try to save
    window.location.reload()
  } catch (e) {
    snackbar('ERROR', 'Error updating proposal versions')
  } finally {
    appStore.loading = false
  }
}
const saveCustomFieldValues = async() => {
  try {
    appStore.loading = true

    const { data, status } = await postRequest(
        `/proposal/${proposalId.value}`,
        dirtyCfvs.value,
        'blueraven'
    )
    proposal.value = data
    dirtyCfvs.value = []
    snackbar('SUCCESS', 'Proposal Updated')
    await store.dispatch(ProposalActions.FETCH_TEMPLATE_CONTEXT, {
      proposalId: proposalId.value
    })

    handleHidingGlobalLoader( status)
  } catch (e) {
    const msg = e?.data?.message || 'Error Saving Proposal'
    snackbar('ERROR', msg)
  } finally {
    appStore.loading = false
  }
}
const populateDirtyCfvs = async(field, remove = false) => {
  //some fields are for unique behavior and they dont need to be saved. this check should filter them out
  let match = dirtyCfvs.value.find(
      (f) =>
          (null !== f.id && f.id === field.id) ||
          f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId
  )

  if (match && remove) {
    //remove any from the array where the selected field is a marked as conditional field
    const removeIds = proposal.value?.customFieldGroups
        ?.flatMap((cfg) => cfg.customFieldValues)
        ?.filter(
            (f) => f.conditionalOnId === field.customFieldGroupAssignmentId
        )
        ?.map((f) => f.customFieldGroupAssignmentId)

    removeIds.push(match.customFieldGroupAssignmentId)
    dirtyCfvs.value = dirtyCfvs.value.filter(
        (x) => !removeIds.includes(x.customFieldGroupAssignmentId)
    )
  }

  if (!match) {
    dirtyCfvs.value.push(field)
  }
  await buildFilters(field)
}

const deleteProposal = async() => {
  try {
    const { ok } = await deleteConfirmDialog.value.open()
    if (!ok) {
      return
    }

    const { status } = await deleteRequest(
        `/proposal/${proposalId.value}`,
        'blueraven'
    )
    proposalExists.value = false
    snackbar(
        'SUCCESS',
        `Deleted proposal #${proposal.value?.proposalNbr}`
    )
    handleHidingGlobalLoader( status)
    await router.push({
      name: 'proposalDesigns',
      params: { projectId: proposal.value?.projectId }
    })
  } catch (e) {
    snackbar('ERROR', e?.data?.message || 'Error deleting proposal')
  } finally {
    appStore.loading = false
  }
}
const duplicate = async() => {
  if (dirtyCfvs.value.length > 0) {
    return
  }

  try {
    const { data, status } = await postRequest(
        `/proposal/${proposalId.value}/duplicate`,
        {},
        'blueraven'
    )
    if (data?.id) {
      const { href } = router.resolve({
        name: 'proposal',
        params: { proposalId: data.id }
      })
      snackbar(
          'SUCCESS',
          `Duplicate proposal #${data?.proposalNbr} created in new tab. <br/> <a href="${href}">Click to open again</a>`,
          true
      )
      window.open(href, '_blank')
    }
    handleHidingGlobalLoader( status)
  } catch (e) {
    snackbar('ERROR', e?.data?.message || 'Error creating duplicate')
  } finally {
    appStore.loading = false
  }
}
const downloadPdf = async() => {
  try {
    appStore.loading = true

    const { data, headers } = await apiRequest('blueraven', {
      method: 'get',
      url: `/proposal/${proposalId.value}/pdf`,
      responseType: 'blob'
    })
    const contentDisposition = headers['content-disposition']
    const filename = contentDisposition
        .substring(contentDisposition.indexOf('filename=') + 9)
        .replace(/['"]+/g, '')

    if (data) {
      const pdfFile = URL.createObjectURL(
          new Blob([data], { type: 'application/pdf' })
      )
      const docUrl = document.createElement('a')
      docUrl.href = pdfFile
      docUrl.setAttribute('download', filename)
      document.body.appendChild(docUrl)
      docUrl.click()
      setTimeout(() => {
        docUrl.remove()
        URL.revokeObjectURL(pdfFile)
      }, 100)

      snackbar('SUCCESS', 'Proposal Downloaded')
    }
  } finally {
    appStore.loading = false
  }
}
const buildFilters = async(field) => {
  if (!field.hasListValues) {
    return
  }

  try {
    const fields = proposal.value?.customFieldGroups?.flatMap(
        (cfg) => cfg.customFieldValues
    )

    //value is either going to come from a local change
    const dirtyCfvValue = dirtyCfvs.value.find(
        (cfv) => cfv.customFieldId === field.customFieldId
    )?.intValue

    //or it's coming from the server
    const prePopulatedValue = fields.find(
        (f) => f.customFieldId === field.customFieldId
    )?.intValue

    //local changes take precedence over server
    const selectedFieldValue = dirtyCfvValue || prePopulatedValue || null

    const conditionalOn = fields?.filter(
        (f) => f?.conditionalOnId === field.customFieldGroupAssignmentId
    )

    if (conditionalOn.length > 0) {
      //clear out any already selected fields when data changes for conditional fields
      //unless there was already a saved value then we still need to clear it out
      const existingFieldIds = conditionalOn.map((c) => c.customFieldId)
      dirtyCfvs.value = dirtyCfvs.value.filter(
          (cfv) =>
              !existingFieldIds.includes(cfv.customFieldId) || cfv.id != null
      )

      loading.value = true
      const allFilters = conditionalOn.map(
          ({ customFieldId, flowCustomFieldId }) => {
            //reset filter for customFieldId
            filters.value[customFieldId] = undefined

            if (selectedFieldValue != null) {
              const params = {
                targetFieldId: customFieldId,
                //used when the custom field ids don't match but are tied to the same backing flow custom field
                targetFlowCustomFieldId: flowCustomFieldId,
                parentFieldId: field.customFieldId,
                parentFieldValue: selectedFieldValue
              }

              return getRequestWithParams(
                  `/proposal/${proposalId.value}/filter`,
                  { params },
                  'blueraven'
              ).then(({ data }) => {
                const { ids: filterValues } = data
                filters.value[customFieldId] = (val) =>
                    filterValues?.indexOf(val?.id) > -1

                conditionalOn.forEach((c) => {
                  if (
                      c.customFieldId === customFieldId &&
                      c.intValue != null &&
                      !filterValues.includes(c.intValue)
                  ) {
                    //if one of the conditional fields has a selected value that is now an unavailable value, unset it and add to dirty fields
                    c.intValue = null
                    const match = dirtyCfvs.value.find(
                        (f) =>
                            null !== f.customFieldId &&
                            f.customFieldId === customFieldId
                    )
                    if (!match) {
                      dirtyCfvs.value.push(c)
                    }
                  }
                })
              })
            }

            return Promise.resolve()
          }
      )

      await Promise.allSettled(allFilters)
    }
  } catch (e) {
    logError(e)
    snackbar('ERROR', e?.data?.message)
  } finally {
    loading.value = false
  }
}
const isConditionalFieldPopulated = ({ conditionalOnId }) => {
  if (conditionalOnId === null || conditionalOnId === undefined) {
    return true
  }

  const cfg = proposal.value?.customFieldGroups
      ?.map((cfg) => cfg.customFieldValues)
      ?.flat()
      ?.find((f) => f.customFieldGroupAssignmentId === conditionalOnId)

  //does it come back from the server prepopulated
  const isPrepopulated =
      cfg?.intValue !== undefined && cfg?.intValue !== null

  //has it been changed in this session
  const dirtyCfv = dirtyCfvs.value.find(
      (cfv) => cfv.customFieldGroupAssignmentId === conditionalOnId
  )
  if (dirtyCfv !== undefined) {
    return dirtyCfv.intValue !== null
  }
  return isPrepopulated
}
const handleStepChange = (updated) => {
  proposal.value = { ...updated }
}
const beforeWindowUnload = (e) => {
  if (dirtyCfvs.value?.length > 0) {
    e.preventDefault()
    // Chrome requires returnValue to be set to anything -- it doesn't display it
    e.returnValue = ''
    return false
  }
}
</script>

<style scoped lang="scss">
.new-proposal-header {
  font-size: 18px;
  font-weight: 700;
  display: flex;
  align-items: center;
}

.proposal-container {
  padding: 24px;
  border-radius: 0;
}

//this is to make the button on the desired commission field align properly without screwing everything else up
.cf-container {
  display: flex;
  align-items: center;
}

.cf-container div {
  width: 100%;
}

.proposal-title {
  font-size: 14px;
  font-weight: 700;
  color: var(--v-blackText-base);
}

.configuration-group-title {
  font-size: 14px;
  font-weight: 700;
  color: #808588;
  margin-bottom: 16px;
}

.configuration-save-container {
  display: flex;
}

.proposal-container-header {
  padding: 10px 0;
  margin-bottom: 24px;

  &.sticky-header {
    position: sticky;
    top: -1px;
    background-color: white;
    padding: 10px;
    z-index: 200;

    &.is-pinned {
      border-bottom: 1px solid #ccc;
      box-shadow: 0 3px 2px 0 rgb(0 0 0 / 10%);
    }
  }
}

.proposal-container-buttons {
  margin-left: 36px;
}

//TODO: need to fix this
.proposal-zoom-lock {
  --scale: 0.75;
  transform: scale(var(--scale));
  transform-origin: top left;

  @media (min-width: 1500px) {
    transform-origin: top center;
  }
}
</style>
