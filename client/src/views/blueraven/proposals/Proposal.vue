<template>
  <v-container
    id="proposals-container"
    :style="cssVars"
    class="pa-4"
    v-if="proposalExists"
  >
    <v-row>
      <v-col cols="12" class="py-0">
        <v-row align="center" justify="center" no-gutters>
          <v-col cols="12" sm="8" md="6" lg="4" xl="3">
            <v-alert
              class="centered"
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

        <v-card class="d-flex mb-2 pa-4">
          <div class="new-proposal-header">
            <router-link
              id="back-btn"
              v-if="proposal && proposal.projectId"
              :to="`/proposalDesigns/${proposal.projectId}`"
              class="pt-1"
            >
              <v-icon>mdi-chevron-left</v-icon>
              Back
            </router-link>
            <editable-input
              class="pl-4 ma-0 prop-title"
              :editable="!proposal.locked"
              :display-text="proposal.displayName"
              :value="defaultProposalName"
              @input="handleNameChange"
            />
          </div>
          <div v-if="proposal.locked" class="d-flex align-center">
            <v-chip small color="error" dark class="ml-2 text-uppercase">
              <v-icon small>mdi-lock</v-icon>
              Locked
            </v-chip>
          </div>
          <v-spacer />
          <div class="d-flex align-center">
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
                <a-btn
                  class="pr-3 pl-0"
                  variant="text"
                  :activation-handler="on"
                  v-bind="attrs"
                  :disabled="!userIsAdmin && !userCanManage"
                  @click="loadProposalVersions()"
                  :color="userIsAdmin && userCanManage ? 'unset' : 'grey'"
                >
                  v.{{ proposal.version }}
                  <v-icon v-if="userIsAdmin && userCanManage" class="ml-1">
                    mdi-menu-down
                  </v-icon>
                </a-btn>
              </template>
              <v-card flat color="white" class="pa-4" :elevation="0">
                <a-autocomplete
                  :items="versions"
                  item-value="id"
                  item-title="version"
                  :loading="loadingVersions"
                  hide-details
                  class="mt-0"
                  label="Select a version..."
                  v-model="proposal.proposalVersionId"
                />
                <a-btn
                  color="primary"
                  class="mt-3"
                  :disabled="
                    (!userIsAdmin && !userCanManage) ||
                    !proposal.proposalVersionId
                  "
                  @click="updateProposalVersion()"
                  text="Save"
                ></a-btn>
              </v-card>
            </v-menu>
            <next-step-menu
              v-if="proposal.id"
              :disabled="dirtyCfvs.length > 0"
              :proposal="proposal"
              @update="handleStepChange"
            />
          </div>
        </v-card>
      </v-col>
    </v-row>

    <v-form ref="proposalForm">
      <v-row>
        <v-col cols="12" sm="6" md="4" class="mt-1 configurations-column">
          <v-row cols="12" class="px-3 config-row">
            <v-card width="100%" class="rounded-0 configurations-card">
              <label class="config-label">Configurations</label>
              <v-spacer />
              <div
                class="config-buttons-group"
                v-if="canEdit && !proposal.locked"
              >
                <a-btn
                  depressed
                  variant="text"
                  color="primary"
                  :disabled="dirtyCfvs.length === 0"
                  class="text-capitalize config-buttons"
                  @click="resetToDefault"
                  text="Reset to Default"
                ></a-btn>
                <a-btn
                  v-if="canEdit && !proposal.locked"
                  color="primary"
                  depressed
                  :dark="dirtyCfvs.length !== 0"
                  :disabled="dirtyCfvs.length === 0"
                  @click="validateForm()"
                  class="text-capitalize font-weight-bold config-buttons"
                  text="Save"
                ></a-btn>
              </div>
            </v-card>
          </v-row>
          <v-card class="proposal-container prop-custom-field-groups">
            <div class="ml-4 mr-2 mt-2">
              <v-expansion-panels multiple v-model="expansionPanelsStatus">
                <v-expansion-panel
                  v-for="cfg in sortedCustomFieldGroups"
                  :key="cfg.id"
                  class="my-2 pr-4"
                >
                  <v-expansion-panel-header>
                    <v-toolbar flat dense>
                      <v-toolbar-title class="configuration-group-title ml-0">
                        {{ cfg.groupName }}
                      </v-toolbar-title>
                    </v-toolbar>
                  </v-expansion-panel-header>
                  <v-expansion-panel-content
                    v-for="field in filteredCustomFields(cfg.customFieldValues)"
                    :key="field.id"
                  >
                    <CustomValueInput
                      v-if="isFieldVisible(field)"
                      :required="field.required"
                      :callback="inputChangeCallback"
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
                      v-if="
                        field.customFieldGroupAssignmentId === 454 &&
                        isFieldVisible(field)
                      "
                      :custom-field-groups="sortedCustomFieldGroups"
                      :proposal-id="proposalId"
                    />
                    <div v-if="field.customFieldGroupAssignmentId === 1312 && field.booleanValue && auroraProjectId && auroraDesignId"
                       class="mb-4 mt-n4"
                    ><a :href="`https://v2.aurorasolar.com/projects/${auroraProjectId}/designs/${auroraDesignId}/storage`"
                        target="_blank">Aurora Storage Options</a>
                    </div>
                  </v-expansion-panel-content>
                </v-expansion-panel>
              </v-expansion-panels>
            </div>
          </v-card>
        </v-col>
        <v-col cols="12" sm="6" md="8" class="px-6 pt-4">
          <v-row class="prop-view-row" ref="proposalFullscreenViewerEl">
            <v-card
              width="100vw"
              class="rounded-0 prop-view-card"
              elevation="4"
            >
              <label class="config-label">
                Proposal <span>#{{ proposal.proposalNbr }}</span>
              </label>
              <v-spacer />
              <div class="prop-button-group" v-if="canEdit">
                <a-btn
                  v-if="canEdit && !proposal.locked"
                  variant="text"
                  class="text-capitalize primary--text"
                  @click="deleteProposal"
                >
                  <span class="delete-btn">
                    <v-icon color="">delete</v-icon>
                    <span class="d-none d-md-inline">Delete</span>
                  </span>
                </a-btn>
                <a-btn
                  v-if="canEdit && pages && pages.length"
                  variant="text"
                  class="text-capitalize primary--text"
                  :disabled="dirtyCfvs.length > 0"
                  @click="duplicate"
                >
                  <v-icon>mdi-content-copy</v-icon>
                  <span class="d-none d-md-inline">Duplicate</span>
                </a-btn>
                <a-btn
                  v-if="pages && pages.length"
                  variant="text"
                  :disabled="dirtyCfvs.length > 0"
                  class="text-capitalize primary--text"
                  @click="downloadPdf"
                >
                  <v-icon>download</v-icon>
                  <span class="d-none d-md-inline">Download</span>
                </a-btn>
              </div>
            </v-card>
            <v-card
              v-if="!hideProposalSection"
              class="pt-4 proposal-container proposal-viewer"
              :class="{ paged: isPageable }"
              ref="proposalViewerEl"
            >
              <v-alert
                class="text-center overlay-alert"
                color="warning"
                dense
                tile
                :value="dirtyCfvs.length > 0"
                transition="scale-transition"
              >
                Changes haven't been reflected on proposal
              </v-alert>
              <div
                v-if="pages && pages.length > 0"
                class="proposal-zoom-lock"
                ref="viewportEl"
              >
                <proposal-template
                  :children="pages"
                  :debug="false"
                  :editable="false"
                />
              </div>
              <div v-else>
                <v-alert
                  v-if="!templateLoading && loadingErrorMessage"
                  prominent
                  type="error"
                >
                  <v-row>
                    <v-col class="grow"> {{ loadingErrorMessage }}</v-col>
                  </v-row>
                </v-alert>
              </div>
            </v-card>
            <v-card class="rounded-0 proposal-actions">
              <div class="text-center max-width" v-if="isPageable">
                <a-select
                  attach
                  v-if="pages && pages.length"
                  v-model="currentPage"
                  prepend-icon="mdi-page-next"
                  :items="pageIndexes"
                  :item-title="(item) => `Page #${item.idx}`"
                  item-value="id"
                  @change="moveToPage"
                >
                </a-select>
              </div>
              <!--              <a-btn-->
              <!--                variant="text"-->
              <!--                class="text-capitalize primary&#45;&#45;text"-->
              <!--                @click="toggleFullscreen"-->
              <!--              >-->
              <!--                <v-icon v-if="isFullscreen">mdi-fullscreen-exit</v-icon>-->
              <!--                <span v-if="isFullscreen" class="d-none d-md-inline"-->
              <!--                  >Minimize</span-->
              <!--                >-->

              <!--                <v-icon v-if="!isFullscreen">mdi-fullscreen</v-icon>-->
              <!--                <span v-if="!isFullscreen" class="d-none d-md-inline"-->
              <!--                  >Fullscreen</span-->
              <!--                >-->
              <!--              </a-btn>-->
            </v-card>
          </v-row>
        </v-col>
      </v-row>
    </v-form>
    <confirm-dialog ref="confirmDialogRef" />
    <confirm-dialog ref="deleteConfirmDialogRef">
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
            v-slot="{ navigate }"
          >
            <a-btn
              @click="navigate"
              color="unset"
              text="Back to project"
            ></a-btn>
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
import ConfirmDialog from '@/views/blueraven/proposals/ConfirmDialog'
import NextStepMenu from '@/views/blueraven/proposals/NextStepMenu'
import EditableInput from '@/views/blueraven/proposals/EditableInput'
import CommissionDetailsMenu from '@/views/blueraven/proposals/CommissionDetailsMenu.vue'

import { computed, onBeforeUnmount, onMounted, provide, ref, watch } from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
import { onBeforeRouteLeave, useRoute, useRouter } from 'vue-router/composables'
import { useAppStore } from '@/stores/AppStore.js'
import useProposalStore from '@/views/blueraven/settings/proposalDesigner/store.js'
import { storeToRefs } from 'pinia'
import { buildContext, exec } from '@/views/blueraven/proposals/exec.js'

const { VITE_HIDE_PROPOSAL } = import.meta.env

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const store = useProposalStore()
const {
  template,
  loadingErrorMessage,
  loading: templateLoading
} = storeToRefs(store)

const isPageable = ref(true)
const currentPage = ref(undefined)
const autoSelectFieldIds = [407, 102, 81]
const proposalExists = ref(true)
const loading = ref(false)
const hideProposalSection = ref(VITE_HIDE_PROPOSAL || false)
const proposalId = ref(parseInt(route.params.proposalId))
const versionMenu = ref(false)
const loadingVersions = ref(true)
const versions = ref([])
const proposal = ref({ customFieldGroups: [] })
const dirtyCfvs = ref([])
const filters = ref({})
const confirmDialogRef = ref(null)
const proposalForm = ref(null)
const deleteConfirmDialogRef = ref(null)
const expansionPanelsStatus = ref([0, 1, 2, 3, 4])
const proposalFullscreenViewerEl = ref(undefined)
const isFullscreen = ref(false)
const viewportEl = ref(null)
const proposalViewerEl = ref(null)
const auroraProjectId = ref(null)
const auroraDesignId = ref(null)
const gridUrlIsLoading = ref(null)

provide('editor', undefined)

const toggle = () => {
  isFullscreen.value = !!document.fullscreenElement
}

//set up watcher to toggle icon
watch(
  proposalFullscreenViewerEl,
  (newEl, oldEl) => {
    if (newEl !== oldEl) {
      newEl.addEventListener('fullscreenchange', toggle)
    }

    if (oldEl) {
      oldEl.removeEventListener('fullscreenchange', toggle)
    }
  },
  { immediate: true }
)

const USD = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD'
})

const isFieldVisible = (field) => {
  if (field?.visibility === undefined || field?.visibility === null) {
    return true
  }

  const ctx = buildContext(proposal.value?.customFieldGroups)
  return exec(field.visibility, ctx)
}

onMounted(() => {
  getProposalDetails()
  store.fetchTemplateContext({
    proposalId: proposalId.value
  })
  window.addEventListener('beforeunload', beforeWindowUnload.value)
})

onBeforeRouteLeave(async (to, from, next) => {
  if (dirtyCfvs.value?.length > 0) {
    const { ok } = (await confirmDialogRef.value?.open()) ?? { ok: false }
    return ok ? next() : false
  }
  next()
})

onBeforeUnmount(async () => {
  window.removeEventListener('beforeunload', beforeWindowUnload.value)
})

const moveToPage = (id) => {
  const nodes = viewportEl.value.querySelectorAll(`[data-id="${id}"]`)
  const container = proposalViewerEl.value?.$el
  if (nodes.length > 0) {
    const rect = nodes[0].getBoundingClientRect()
    const top = container.scrollTop + rect.top - 250
    container.scrollTo({ top, behavior: 'instant' })
  }
}

const filteredCustomFields = (values = []) => {
  return values.filter((f) => {
    return userHasWhiteListedPosition(f, 'hidden')
  })
}

const userIsAdmin = computed(() =>
  userStore.userHasFeatureAccessLevel('PROPOSALS', 'ADMIN')
)

const userCanManage = computed(() =>
  userStore.userHasFeatureAccessLevel('PROPOSALS', 'MANAGE')
)

const canEdit = computed(() => {
  const hasAdmin = userStore.userHasFeatureAccessLevel('PROPOSALS', 'ADMIN')
  const hasEdit = userStore.userHasFeatureAccessLevel('PROPOSALS', 'EDIT')
  return hasAdmin || hasEdit
})

const defaultProposalName = computed(() => {
  if (proposal.value?.name) {
    return proposal.value.name
  }
  return 'New Proposal'
})

const pages = computed(() => {
  return template.value
    ?.filter((x) => x.parentId === undefined)
    ?.sort((a, b) => a.blockOrder - b.blockOrder)
})

//temporary until we can display the name of the block?
const pageIndexes = computed(() => {
  return (
    pages.value?.map((x, idx) => ({
      idx: idx + 1,
      id: x.id
    })) ?? []
  )
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

const toggleFullscreen = () => {
  if (document.fullscreenElement) {
    document.exitFullscreen()
    isFullscreen.value = false
  } else {
    proposalFullscreenViewerEl.value?.requestFullscreen()
    isFullscreen.value = true
  }
}

const PricePerWattCfgaId = 869
const OtherMaxDiscountCfgaId = 167

const getHint = (field) => {
  if (!field) {
    return undefined
  }

  if (field.customFieldGroupAssignmentId === PricePerWattCfgaId) {
    const minPricePerWatt = proposal.value.minPricePerWatt
    if (minPricePerWatt) {
      return `Price Per Watt must be greater than ${minPricePerWatt}`
    }
  }

  if (field.customFieldGroupAssignmentId === OtherMaxDiscountCfgaId) {
    const maxDiscountAmount = proposal.value.maxDiscountAmount
    if (maxDiscountAmount) {
      return `Max discount allowed is ${USD.format(maxDiscountAmount)}`
    }
  }
}
const cssVars = computed(() => {
  return {
    '--proposal-action-height': '50px',
    '--dirty-cfv-height': dirtyCfvs.value.length > 0 ? '56px' : '0px',
    '--padding-and-margins': '240px' // this number is toolbars, margins, and paddings above the column headings
  }
})
const userHasWhiteListedPosition = (cf, arg = 'readonly') => {
  const wlAttr =
    arg === 'readonly' ? 'whiteListedPositions' : 'hiddenWhiteListedPositions'
  const prAttr =
    arg === 'readonly'
      ? 'customFieldGroupAssignmentReadOnly '
      : 'customFieldGroupAssignmentHidden'

  //field doesn't require a white listed position
  if (!cf[prAttr]) {
    return true
  }

  //positions required for user
  const positions = cf[wlAttr]?.map((wlp) => wlp.positionId) ?? []
  return userStore.userHasAnyPosition(positions)
}

const handleNameChange = async ({ save, value }) => {
  const hasChanged = proposal.value?.name !== value
  proposal.value = { ...proposal.value, name: value }
  if (save && hasChanged) {
    try {
      const { data } = await postRequest(
        `/proposal/${proposalId.value}/name`,
        { name: value },
        'blueraven',
        {}
      )
      proposal.value = data
    } catch (e) {
      appStore.showSnack(
        'ERROR',
        e?.data?.message || 'Error updating proposal name'
      )
    }
  }
}
const getProposalDetails = async () => {
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

    const buildFilterList = fields
      ?.filter((f) =>
        conditionalOnFields.includes(f.customFieldGroupAssignmentId)
      )
      ?.map(buildFilters)

    //wait for all the filters to run initially
    await Promise.allSettled(buildFilterList)

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
          ?.filter((x) => x?.customFieldGroupAssignmentId === f.conditionalOnId)
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

    handleHidingGlobalLoader(status)
  } catch (e) {
    logError(e)
    proposalExists.value = false
    appStore.showSnack(
      'ERROR',
      `Error retrieving proposal #${proposalId.value}`
    )
  } finally {
    appStore.loading = false
  }
}

const resetToDefault = async () => {
  await getProposalDetails()
  proposalForm.value.resetValidation()
}

const validateForm = () => {
  //checks for required fields prior to opening the save dialog
  if (proposalForm.value.validate()) {
    saveCustomFieldValues()
  } else {
    appStore.showSnack('ERROR', 'Missing Required Fields')
  }
}

const loadProposalVersions = async () => {
  try {
    loadingVersions.value = true
    const { data } = await getRequest(
      `/proposal/versions?published=true&size=50&page=0`,
      'blueraven'
    )
    versions.value = data.content
  } catch (e) {
    appStore.showSnack('ERROR', 'Error loading proposal versions')
  } finally {
    appStore.loading = false
    loadingVersions.value = false
  }
}
const updateProposalVersion = async () => {
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
    appStore.showSnack('ERROR', 'Error updating proposal versions')
  } finally {
    appStore.loading = false
  }
}
const saveCustomFieldValues = async () => {
  try {
    appStore.loading = true

    const { data, status } = await postRequest(
      `/proposal/${proposalId.value}`,
      dirtyCfvs.value,
      'blueraven'
    )
    proposal.value = data
    dirtyCfvs.value = []
    appStore.showSnack('SUCCESS', 'Proposal Updated')
    await store.fetchTemplateContext({
      proposalId: proposalId.value
    })

    handleHidingGlobalLoader(status)
  } catch (e) {
    const msg = e?.data?.message || 'Error Saving Proposal'
    appStore.showSnack('ERROR', msg)
  } finally {
    appStore.loading = false
  }
}

const inputChangeCallback = async(field, remove=false) => {
  populateDirtyCfvs(field, remove)
  if(field.customFieldGroupAssignmentId === 1312){
    loadAuroraProjectId()
  }
}

const populateDirtyCfvs = async (field, remove = false) => {
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
      ?.filter((f) => f.conditionalOnId === field.customFieldGroupAssignmentId)
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

const deleteProposal = async () => {
  try {
    const { ok } = await deleteConfirmDialogRef.value.open()
    if (!ok) {
      return
    }

    const { status } = await deleteRequest(
      `/proposal/${proposalId.value}`,
      'blueraven'
    )
    proposalExists.value = false
    appStore.showSnack(
      'SUCCESS',
      `Deleted proposal #${proposal.value?.proposalNbr}`
    )
    handleHidingGlobalLoader(status)
    await router.push({
      name: 'proposalDesigns',
      params: { projectId: proposal.value?.projectId }
    })
  } catch (e) {
    appStore.showSnack('ERROR', e?.data?.message || 'Error deleting proposal')
  } finally {
    appStore.loading = false
  }
}
const duplicate = async () => {
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
      appStore.showSnack(
        'SUCCESS',
        `Duplicate proposal #${data?.proposalNbr} created in new tab. <br/> <a href="${href}">Click to open again</a>`,
        true
      )
      window.open(href, '_blank')
    }
    handleHidingGlobalLoader(status)
  } catch (e) {
    appStore.showSnack('ERROR', e?.data?.message || 'Error creating duplicate')
  } finally {
    appStore.loading = false
  }
}
const downloadPdf = async () => {
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

      appStore.showSnack('SUCCESS', 'Proposal Downloaded')
    }
  } finally {
    appStore.loading = false
  }
}
const buildFilters = async (field) => {
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
        (cfv) => !existingFieldIds.includes(cfv.customFieldId) || cfv.id != null
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
    appStore.showSnack('ERROR', e?.data?.message)
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
  const isPrepopulated = cfg?.intValue !== undefined && cfg?.intValue !== null

  //has it been changed in this session
  const dirtyCfv = dirtyCfvs.value.find(
    (cfv) => cfv.customFieldGroupAssignmentId === conditionalOnId
  )
  if (dirtyCfv !== undefined) {
    return dirtyCfv.intValue !== null
  }
  return isPrepopulated
}
const loadAuroraProjectId = async() => {
  try{
    const { data } = await getRequest( `/proposal/projects/${proposal.value.projectId}/auroraProjectId`,
        'blueraven'
    )
    auroraProjectId.value = data?.projectId
    auroraDesignId.value = data?.designId
  }catch (e) {
    console.error('*** ERROR ***', e)
  }
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
#back-btn {
  display: flex;
  flex-wrap: nowrap;
  word-break: normal;
  text-decoration: none;
  font-size: 14px;
  font-weight: 500;
}

.proposal-viewer {
  padding-left: 16px;
  height: calc(
    100vh - var(--padding-and-margins) - var(--dirty-cfv-height) - var(
        --proposal-action-height
      )
  );
}

.proposal-actions {
  height: var(--proposal-action-height);
  border: solid 1px var(--v-grey-lighten3);
  background-color: var(--v-grey-lighten4);
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* WRAPS THE BUTTONS UNDERNEATH HEADER TITLES BASED ON SCREEN SIZE */
@media (min-width: 1232px) {
  .configurations-card {
    flex-wrap: nowrap;
    flex-direction: row;
  }
  .config-row {
    height: 64px;
  }
  .prop-custom-field-groups {
    height: calc(100vh - var(--padding-and-margins) - var(--dirty-cfv-height));
  }
}

@media (max-width: 1232px) and (min-width: 960px) {
  .configurations-card {
    flex-wrap: nowrap;
    flex-direction: column;
    height: 96px;
  }
  .config-row,
  .prop-view-row {
    height: 96px;
  }
  .prop-custom-field-groups {
    height: calc(
      100vh - var(--padding-and-margins) - var(--dirty-cfv-height) - 32px
    );
  }
}

@media (max-width: 960px) and (min-width: 827px) {
  .configurations-card {
    flex-wrap: wrap;
    flex-direction: row;
  }
  .config-row,
  .prop-view-row {
    height: 56px;
  }
  .prop-custom-field-groups {
    height: calc(
      100vh - var(--padding-and-margins) - var(--dirty-cfv-height) + 8px
    );
  }
}

@media (max-width: 827px) and (min-width: 600px) {
  .configurations-card,
  .prop-view-card {
    flex-wrap: nowrap;
    flex-direction: column;
    height: 96px;
  }
  .config-row,
  .prop-view-row {
    height: 96px;
  }

  .prop-custom-field-groups {
    height: calc(
      100vh - var(--padding-and-margins) - var(--dirty-cfv-height) - 32px
    );
  }

  .proposal-viewer {
    height: calc(
      100vh - var(--padding-and-margins) - var(--dirty-cfv-height) - var(
          --proposal-action-height
        ) - 32px
    );
  }
}

@media (max-width: 600px) and (min-width: 440px) {
  .configurations-card {
    flex-wrap: wrap;
    flex-direction: row;
    justify-content: flex-start;
    height: 56px;
  }
  .config-row,
  .prop-view-row {
    height: 56px;
    position: sticky;
    top: 0;
    z-index: 1000;
  }
}

@media (max-width: 440px) and (min-width: 1px) {
  .configurations-card,
  .prop-view-card {
    flex-wrap: nowrap;
    flex-direction: column;
    height: 96px;
  }
  .config-row,
  .prop-view-row {
    height: 96px;
    position: sticky;
    top: 0;
    z-index: 1000;
  }
}

.configurations-card,
.prop-view-card {
  display: flex;
  padding: 14px 18px;
  font-size: 20px;
  align-content: center;
}

.config-label {
  font-size: 20px;
}

.config-buttons-group,
.prop-button-group {
  display: flex;
  justify-content: flex-end;
}

.config-buttons {
  white-space: nowrap;
}

.configurations-column {
  margin-top: 4px;
  padding-left: 12px;
  padding-right: 4px;
  @media (max-width: 600px) {
    padding-right: 12px;
  }
}

.delete-btn {
  color: rgba(180, 34, 31, 1);
}

.new-proposal-header {
  font-size: 20px;
  font-weight: 700;
  display: flex;
  flex: 1 1 auto;
  align-items: center;
  word-break: break-word;
}

.prop-view-row {
  .proposal-viewer {
    --scale: 0.75;
    width: 100vw;
  }

  &:fullscreen {
    .proposal-viewer {
      --scale: 1;
      display: flex;
      justify-content: center;
      height: calc(100vh - var(--proposal-action-height) - 60px);

      &.paged {
        align-items: center;
      }
    }
  }
}

.prop-custom-field-groups,
.proposal-viewer {
  border-radius: 0;
  overflow-y: scroll;
  background-color: var(--v-grey-lighten4);
}

/* EXPANSION PANEL STYLING */
.v-expansion-panel-header {
  padding: 0;
}

::v-deep .v-expansion-panel-content__wrap {
  padding: 0 0 0 16px;
  margin-right: 0;
}

.configuration-group-title {
  &.v-toolbar__title {
    font-size: 14px;
  }
}

/* PROPOSAL VIEWER ZOOM STYLING */
.proposal-zoom-lock {
  transform: scale(var(--scale));
  transform-origin: top left;
  margin-bottom: calc((var(--scale) - 1) * 100%);

  @media (min-width: 1548px) {
    transform-origin: top center;
  }

  @media (max-width: 600px) {
    --scale: 0.45;
  }
}
</style>
