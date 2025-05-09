<template>
  <v-container
    id="proposals-container"
    :style="cssVars"
    class="pa-2"
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
              :value="dirtyCfvs.length > 0 || adderStateChanged"
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
        <v-col cols="12" sm="6" md="4" class="configurations-column">
          <div class="configurations-wrapper">
            <v-card class="configurations-card-container">
              <div class="configurations-scroll-area">
                <v-expansion-panels multiple class="rounded-0" v-model="expandedPanel">
                  <v-expansion-panel class="rounded-0">
                    <v-expansion-panel-header class="parent-expansion-header sticky-configuration-header configuration-header">
                      Configuration
                      <div class="config-buttons-group">
                        <a-btn
                          size="small"
                          variant="text"
                          color="primary"
                          class="text-capitalize config-buttons"
                          @click="resetToDefault"
                          v-if="!proposal.locked && (dirtyCfvs.length > 0 || adderCostField.hasChanges)"
                          text="Reset"
                        ></a-btn>
                        <a-btn
                          size="small"
                          v-if="canEdit && !proposal.locked && (dirtyCfvs.length > 0 || adderCostField.hasChanges)"
                          color="primary"
                          depressed
                          :dark="dirtyCfvs.length !== 0 || adderCostField.hasChanges"
                          :readonly="dirtyCfvs.length === 0 && !adderCostField.hasChanges"
                          @click="validateForm()"
                          class="text-capitalize config-buttons"
                          text="Save"
                        ></a-btn>
                      </div>
                    </v-expansion-panel-header>
              <v-expansion-panel-content>
                <v-expansion-panels
                  multiple
                  class="rounded-0 mb-2"
                  v-model="expansionPanelsStatus"
                >
                  <v-expansion-panel
                    v-for="cfg in sortedCustomFieldGroups"
                    :key="cfg.id"
                    class="child-expansion-panel"
                  >
                    <v-expansion-panel-header class="child-expansion-header">
                      {{ cfg.groupName }}
                    </v-expansion-panel-header>
                    <v-expansion-panel-content
                      v-for="field in filteredCustomFields(cfg.customFieldValues)"
                      :key="field.id"
                      class="child-expansion-panel"
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
                            field.customFieldGroupAssignmentId === FIELD_IDS.COMMISSION_DETAILS &&
                            isFieldVisible(field)
                          "
                        :custom-field-groups="sortedCustomFieldGroups"
                        :proposal-id="proposalId"
                      />
                      <!-- Only show the Aurora Storage options link for the Storage Type custom field and only if the selected value has "Grid-tied" in the name -->
                      <div
                        v-if="field.customFieldGroupAssignmentId === FIELD_IDS.STORAGE_TYPE &&
                            field.listOfValues.find(v => v.id === field.intValue)?.name.search(/\bgrid[-\s]+tied\b/i) >= 0 &&
                            auroraProjectId &&
                            auroraDesignId"
                        class="mb-4 mt-n4"
                      >
                        <v-tooltip bottom>
                          <template v-slot:activator="{ on, attrs }">
                            <a
                              :href="`https://v2.aurorasolar.com/projects/${auroraProjectId}/designs/${auroraDesignId}/storage`"
                              target="_blank"
                              class="pr-1"
                              v-on="on"
                              v-bind="attrs"
                            >
                              <v-icon
                                small
                                color="primary"
                                class="pr-1"
                              >
                                mdi-open-in-new
                              </v-icon>
                              Aurora Storage Options
                              <v-icon small>
                                mdi-information
                              </v-icon>
                            </a>
                          </template>
                          <span>
                            Aurora savings calculator for grid-tied batteries
                          </span>
                        </v-tooltip>
                      </div>
                    </v-expansion-panel-content>
                  </v-expansion-panel>
                  <v-expansion-panel class="child-expansion-panel">
                    <v-expansion-panel-header class="child-expansion-header">
                      Adders
                    </v-expansion-panel-header>
                    <v-expansion-panel-content class="child-expansion-panel">
                      <!-- Clickable field that opens the dialog -->
                      <v-combobox
                        label="Selected Adders"
                        multiple
                        chips
                        small-chips
                        append-icon="mdi-table-edit"
                        :value="selectedAddersDisplay"
                        class="my-4"
                        @focus="openAdderDialog"
                        @click="openAdderDialog"
                        :disabled="!canEdit || proposal.locked"
                        readonly
                      >
                        <template v-slot:selection="{ item }">
                          <v-chip
                            x-small
                            class="ma-1"
                            color="primary lighten-9"
                            text-color="black"
                          >
                            {{ item.label }}
                          </v-chip>
                        </template>
                      </v-combobox>
                      <!-- Display total cost if there are selected adders -->
                      <div v-if="selectedAddersDisplay.length > 0" class="d-flex flex-column mb-2">
                        <div class="d-flex">
                          <v-text-field
                            disabled
                            readonly
                            label="Total Adder Cost"
                            :value="`$${adderTotalCost.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2})}`"
                            dense
                            class="font-weight-medium"
                          />
                        </div>
                      </div>
                    </v-expansion-panel-content>
                  </v-expansion-panel>
                </v-expansion-panels>
                <AdderCostDialog
                  :openDialog="showAdderCostDialog"
                  :existingAdders="adderCostData"
                  :proposalId="proposalId"
                  :commissionStrategyId="commissionStrategyId"
                  :storageId="storageId"
                  :financialProductId="financialProductId"
                  @close-dialog="showAdderCostDialog = false"
                  @apply-costs="handleAppliedCosts"
                  @cancel="handleAdderDialogCancel"
                />
              </v-expansion-panel-content>
            </v-expansion-panel>
            <v-expansion-panel class="sticky-price-details" v-if="proposal.id">
              <v-expansion-panel-header class="parent-expansion-header price-details-header">
                Price Details
              </v-expansion-panel-header>
              <v-expansion-panel-content>
                <PriceDetails
                  :proposal-id="proposalId"
                  :adder-data="adderData"
                />
              </v-expansion-panel-content>
            </v-expansion-panel>
          </v-expansion-panels>
          </div>
            </v-card>
          </div>
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
                    <v-icon>delete</v-icon>
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
                :value="dirtyCfvs.length > 0 || adderStateChanged"
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
import AdderCostDialog from '@/components/AdderCostDialog.vue'
import PriceDetails from '@/components/PriceDetails.vue'
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
const expansionPanelsStatus = ref([0, 1, 2, 3, 4, 5, 6])
const expandedPanel = ref([0])
const proposalFullscreenViewerEl = ref(undefined)
const isFullscreen = ref(false)
const viewportEl = ref(null)
const proposalViewerEl = ref(null)
const auroraProjectId = ref(null)
const auroraDesignId = ref(null)

// Adder costs via dialog
const adderData = ref([]);
const showAdderCostDialog = ref(false)
const selectedAdders = ref([])
// Create a virtual adderCostField that isn't tied to customFieldGroups
const adderCostField = ref({
  customFieldId: 'adderCosts',
  stringValue: ''
})
const adderTotalCost = ref(0)
const adderCostData = ref({})
const commissionStrategyId = ref(null) // Pricing Strategy (customFieldAssignmentId=581)
const storageId = ref(null) // Storage Type (customFieldAssignmentId=200)
const financialProductId = ref(null) // Financial Product (customFieldAssignmentId=155)

// Helper function to find a custom field by assignment ID
const findCustomFieldByAssignmentId = (assignmentId) => {
  return proposal.value?.customFieldGroups
    ?.flatMap(cfg => cfg.customFieldValues)
    ?.find(f => f.customFieldGroupAssignmentId === assignmentId);
}

// Constants for field IDs to make code more maintainable
const FIELD_IDS = {
  PRICING_STRATEGY: 581, // Pricing Strategy (customFieldAssignmentId)
  STORAGE_TYPE: 200,     // Storage Type (customFieldAssignmentId)
  COMMISSION_DETAILS: 454, // Field that shows commission details menu
  FINANCIAL_PRODUCT: 155 // Financial Product (customFieldAssignmentId)
};

// Helper function to update pricing strategy and storage type refs
const updateConfigurationRefs = () => {
  const pricingStrategyField = findCustomFieldByAssignmentId(FIELD_IDS.PRICING_STRATEGY);
  if (pricingStrategyField && pricingStrategyField.intValue) {
    commissionStrategyId.value = pricingStrategyField.intValue;
  }

  const storageTypeField = findCustomFieldByAssignmentId(FIELD_IDS.STORAGE_TYPE);
  if (storageTypeField && storageTypeField.intValue) {
    storageId.value = storageTypeField.intValue;
  }

  const financialProductField = findCustomFieldByAssignmentId(FIELD_IDS.FINANCIAL_PRODUCT);
  if (financialProductField && financialProductField.intValue) {
    financialProductId.value = financialProductField.intValue;
  }
}

const loadExistingAdders = () => {
  // Update pricing strategy and storage type refs
  updateConfigurationRefs();

  // Reset the virtual adderCostField's stringValue
  adderCostField.value.stringValue = '';

  // Initialize adderCostData for the dialog
  adderCostData.value = {
    items: {},
    total: 0
  };

  // Don't look for adders in customFieldGroups - rely on API data
  if (adderData.value && adderData.value.length > 0) {
    // Mark auto-applied adders as selected, but only if they have a valid amount
    adderData.value.forEach(adder => {
      if (adder.adderType === 'auto_applied_adder') {
        const amount = adder.autoAppliedProposalAdderAmount || adder.autoAppliedAdderAmount;
        // Only mark as selected if amount exists and is greater than 0
        adder.selectedProposalAdder = !!(amount && amount > 0);
      }

      // Make sure selectedProposalAdder is set for custom adders with an amount
      if (adder.adderType === 'custom_adders' && adder.customProposalAdderAmount > 0) {
        adder.selectedProposalAdder = true;
      }

      // Make sure selected adders are properly marked
      if (adder.adderType === 'selected_adders' && adder.selectedAdderAmount > 0 && adder.applied) {
        adder.selectedProposalAdder = true;
      }
    });

    // Process the selected adders from API data
    updateAdderSelections();
  }
}

// Helper function to update adder selections from the current adderData
const updateAdderSelections = () => {
  // Reset selections
  selectedAdders.value = [];
  adderTotalCost.value = 0;

  // Reset adderCostData to ensure clean state
  adderCostData.value = {
    items: {},
    total: 0
  };

  // Process each adder from the adderData
  adderData.value.forEach(adder => {
    // For standard adders and auto-applied adders, only include if selected
    if (adder.adderType === 'selected_adders' && adder.selectedProposalAdder) {
      // Handle standard adders
      const amount = adder.selectedAdderAmount || 0;
      selectedAdders.value.push({
        id: adder.id,
        label: adder.fieldName,
        price: amount,
        isCustom: false
      });
      adderTotalCost.value += amount;

      // Update items for dialog
      adderCostData.value.items[adder.id] = true;
    }
    // For custom adders, ALWAYS include them, regardless of selection state
    else if (adder.adderType === 'custom_adders') {
      // Handle custom adders - include ALL of them even with 0 values
      console.log("Processing custom adder in updateAdderSelections:", adder);
      const amount = adder.customProposalAdderAmount === 0 ? 0 : (adder.customProposalAdderAmount || 0);

      // Only include in visual selection and total if amount > 0
      if (amount > 0) {
        adderTotalCost.value += amount;
      }

      // Always include in the selectedAdders array for API processing
      selectedAdders.value.push({
        id: adder.id,
        label: adder.fieldName,
        price: amount,
        isCustom: true,
        forceInclude: true, // Mark for guaranteed inclusion in API
        customAdderDataType: adder.customAdderDataType
      });

      // Update items for dialog - store the exact amount
      adderCostData.value.items[adder.id] = amount;
    }
    // Handle auto-applied adders
    else if (adder.adderType === 'auto_applied_adder' && adder.selectedProposalAdder) {
      // Only include auto-applied adders if they have a valid amount
      const amount = adder.autoAppliedProposalAdderAmount || adder.autoAppliedAdderAmount || 0;

      // Only include if amount is greater than 0
        if (amount > 0) {
          selectedAdders.value.push({
            id: adder.id,
            label: adder.fieldName,
            price: amount,
            isCustom: false,
            isAutoApplied: true
          });
          adderTotalCost.value += amount;

          // Update items for dialog
          adderCostData.value.items[adder.id] = true;
        }
      }
    });


  // Update the total in adderCostData
  adderCostData.value.total = adderTotalCost.value;

  // First collect ALL custom adders regardless of selection state
  const allCustomAdders = adderData.value
    .filter(adder => adder.adderType === 'custom_adders')
    .map(adder => ({
      id: adder.id,
      fieldName: adder.fieldName,
      amount: adder.customProposalAdderAmount, // Include amount even if 0
      applied: adder.selectedProposalAdder,
      customAdderDataType: adder.customAdderDataType || 4
    }));

  adderCostField.value.stringValue = JSON.stringify({
    totalCost: adderTotalCost.value,
    selectedAdderIds: selectedAdders.value
      .filter(adder => !adder.isCustom && !adder.isAutoApplied)
      .map(adder => adder.id),
    customAdders: allCustomAdders.concat(
    // Add any custom adders that might be in selectedAdders but not in allCustomAdders
    selectedAdders.value
      .filter(adder => adder.isCustom && adder.forceInclude && !allCustomAdders.some(a => a.id === adder.id))
      .map(adder => ({
        id: adder.id,
        fieldName: adder.label,
        amount: adder.price,
        applied: adder.price > 0,
        customAdderDataType: adder.customAdderDataType || 4
      }))
  ),
    selectedAdders: selectedAdders.value,
    allAdderStates: adderData.value.map(adder => ({
      id: adder.id,
      selectedProposalAdder: adder.selectedProposalAdder,
      customProposalAdderAmount: adder.adderType === 'custom_adders' ? adder.customProposalAdderAmount : null,
      autoAppliedProposalAdderAmount: adder.adderType === 'auto_applied_adder' ? adder.autoAppliedProposalAdderAmount : null,
      customAdderDataType: adder.adderType === 'custom_adders' ? adder.customAdderDataType : null
    }))
  });
}

const handleAppliedCosts = async (costs) => {
  // Format selections for display in the combobox
  if (costs) {
    // Close the dialog after processing the data
    showAdderCostDialog.value = false;

    // Clear any previous state first - all adders unselected by default
    adderData.value.forEach(adder => {
      // Auto-applied adders are always selected
      if (adder.adderType !== 'auto_applied_adder') {
        adder.selectedProposalAdder = false;
      }

      // Don't reset custom adder amounts - we want to preserve zeros for sending to API
      // Only reset the visual selected state
      // if (adder.adderType === 'custom_adders') {
      //   adder.customProposalAdderAmount = 0;
      // }
    });

    // STEP 1: Get comprehensive state from allItems - this is the most complete view
    if (costs.allItems && Array.isArray(costs.allItems)) {
      costs.allItems.forEach(resultItem => {
        const adder = adderData.value.find(a => a.id === resultItem.id);
        if (adder) {
          // Update the selected state based on what was in the dialog
          adder.selectedProposalAdder = resultItem.applied;

          // Update custom adder amounts if this is a custom adder
          if (adder.adderType === 'custom_adders' && resultItem.customFields?.amount?.value !== undefined) {
            adder.customProposalAdderAmount = parseFloat(resultItem.customFields.amount.value);
          } else if (adder.adderType === 'custom_adders' && resultItem.rawAmount !== undefined) {
            // Fallback to rawAmount if customFields are not available
            adder.customProposalAdderAmount = resultItem.rawAmount;
          }
        }
      });
    }

    // STEP 2: Process selected standard adders (extra safety)
    if (costs.selectedAdderIds && Array.isArray(costs.selectedAdderIds)) {
      costs.selectedAdderIds.forEach(id => {
        const adder = adderData.value.find(a => a.id === id);
        if (adder && adder.adderType === 'selected_adders') {
          adder.selectedProposalAdder = true;
        }
      });
    }

    // STEP 3: Process explicitly unselected adders (extra safety)
    if (costs.unselectedAdderIds && Array.isArray(costs.unselectedAdderIds)) {
      costs.unselectedAdderIds.forEach(id => {
        const adder = adderData.value.find(a => a.id === id);
        if (adder && adder.adderType !== 'auto_applied_adder') {
          adder.selectedProposalAdder = false;
        }
      });
    }

    // STEP 4: Process custom adders (extra safety)
    if (costs.customAdders && Array.isArray(costs.customAdders)) {
      costs.customAdders.forEach(customAdderInfo => {
        const amount = customAdderInfo.amount !== undefined ? customAdderInfo.amount : 0;
        const adder = adderData.value.find(a => a.id === customAdderInfo.id);

        if (adder && adder.adderType === 'custom_adders') {
          // Store amount regardless of value, but only mark as selected if positive
          adder.customProposalAdderAmount = amount;

          // Only mark as visually selected if there's a positive amount
          if (amount > 0) {
            adder.selectedProposalAdder = true;
          } else {
            adder.selectedProposalAdder = false;
          }

          // Store the data type if available
          if (customAdderInfo.customAdderDataType) {
            adder.customAdderDataType = customAdderInfo.customAdderDataType;
          }
        }
      });
    }

    // STEP 5: Ensure auto-applied adders are always selected (final safety check)
    // But only if they have a valid amount (not null or zero)
    adderData.value.forEach(adder => {
      if (adder.adderType === 'auto_applied_adder') {
        // Check if amount exists and is greater than 0
        if (adder.autoAppliedAdderAmount && adder.autoAppliedAdderAmount > 0) {
          adder.selectedProposalAdder = true;
        } else {
          // If amount is null, 0, or undefined, mark as unselected
          adder.selectedProposalAdder = false;
        }
      }
    });

    // Use our helper function to update selections based on the updated adderData
    updateAdderSelections();

    // Mark the adderCostField as having changes to show Save button
    adderCostField.value.hasChanges = true;

    // Set flag that adder state has changed but don't refresh on next open
    adderStateChanged.value = true;

    proposalForm.value.validate();
  }
}


const getProposalAdders = async () => {
  try {
    appStore.loading = true;

    // Update pricing strategy and storage type refs
    updateConfigurationRefs();

    const params = {
      proposalId: proposalId.value,
      commissionStrategyId: commissionStrategyId.value ?? 123,
      storageId: storageId.value ?? 123,
      financialProductId: financialProductId.value ?? 123
    }

    const { data, status } = await postRequest(
      `/proposal/${proposalId.value}/adders`,
      params,
      'blueraven'
    )

    // Store the raw adder data for the AdderCostDialog
    adderData.value = [...data];

    // Process all adder types to ensure they're properly marked as selected
    adderData.value.forEach(adder => {
      // For auto-applied adders, mark as selected only if they have a valid amount
      if (adder.adderType === 'auto_applied_adder') {
        const amount = adder.autoAppliedProposalAdderAmount || adder.autoAppliedAdderAmount;
        adder.selectedProposalAdder = !!(amount && amount > 0);
      }

      // For custom adders, mark as selected if they have a positive amount
      else if (adder.adderType === 'custom_adders') {
        adder.selectedProposalAdder = adder.selectedProposalAdder || (adder.customProposalAdderAmount > 0);
      }

      // For selected adders, preserve their selected state
      else if (adder.adderType === 'selected_adders') {
        // Ensure selectedProjectAdder is properly handled
        // If it's not defined in the response, default to false
        if (adder.selectedProjectAdder === undefined) {
          adder.selectedProjectAdder = false;
        }
      }
    });

    // Load and process adder selections from API data
    loadExistingAdders();

    handleHidingGlobalLoader(status)
  } catch (e) {
    appStore.showSnack('ERROR', 'Error retrieving proposal adders')
    console.error('Error retrieving proposal adders', e);
  } finally {
    appStore.loading = false;
  }
}

// Function to update selectedAdders from API data
const updateSelectedAddersFromApi = (adderApiData) => {
  if (!adderApiData || !Array.isArray(adderApiData)) return;

  // Reset the arrays
  selectedAdders.value = [];
  adderTotalCost.value = 0;

  // Process each adder from the API
  adderApiData.forEach(adder => {
    if (adder.selectedProposalAdder) {
      if (adder.adderType === 'selected_adders') {
        // Handle regular adders
        selectedAdders.value.push({
          id: adder.id,
          label: adder.fieldName,
          price: adder.selectedAdderAmount || 0,
          isCustom: false
        });
        adderTotalCost.value += adder.selectedAdderAmount || 0;
      } else if (adder.adderType === 'custom_adders' && adder.customProposalAdderAmount > 0) {
        // Handle custom adders
        selectedAdders.value.push({
          id: adder.id,
          label: adder.fieldName,
          price: adder.customProposalAdderAmount || 0,
          isCustom: true
        });
        adderTotalCost.value += adder.customProposalAdderAmount || 0;
      } else if (adder.adderType === 'auto_applied_adder') {
        // Handle auto-applied adders
        selectedAdders.value.push({
          id: adder.id,
          label: adder.fieldName,
          price: adder.autoAppliedProposalAdderAmount || adder.autoAppliedAdderAmount || 0,
          isCustom: false,
          isAutoApplied: true
        });
        adderTotalCost.value += adder.autoAppliedProposalAdderAmount || adder.autoAppliedAdderAmount || 0;
      }
    }
  });

  // Update adderCostData to reflect the current state
  adderCostData.value = {
    items: {},
    total: adderTotalCost.value
  };

  adderApiData.forEach(adder => {
    if (adder.adderType === 'selected_adders') {
      adderCostData.value.items[adder.id] = adder.selectedProposalAdder || false;
    } else if (adder.adderType === 'custom_adders') {
      adderCostData.value.items[adder.id] = adder.customProposalAdderAmount || 0;
    } else if (adder.adderType === 'auto_applied_adder') {
      adderCostData.value.items[adder.id] = adder.selectedProposalAdder || false;
    }
  });
};

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

// Watch for changes to commissionStrategyId and storageId to refresh adders
watch([commissionStrategyId, storageId], async ([newCommissionStrategy, newStorageId], [oldCommissionStrategy, oldStorageId]) => {
  // Only refresh if values have changed and they're not null
  if ((newCommissionStrategy !== oldCommissionStrategy || newStorageId !== oldStorageId) &&
      (newCommissionStrategy !== null || newStorageId !== null)) {
    await getProposalAdders();
  }
}, { deep: true });

// Watch expandedPanel to ensure only one panel is open at a time
watch(expandedPanel, (newValue) => {
  // If multiple panels are opened, keep only the last opened panel
  if (newValue && newValue.length > 1) {
    expandedPanel.value = [newValue[newValue.length - 1]];
  }
});

onMounted(async() => {
  await getProposalDetails()
  await getProposalAdders()
  await loadAuroraProjectId()
  await store.fetchTemplateContext({
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

// Display value with auto-applied adders
const selectedAddersDisplay = computed(() => {
  // Start with the existing selected adders
  let adders = [...selectedAdders.value];

  // Add any auto-applied adders that aren't already in the list
  if (adderData.value && adderData.value.length > 0) {
    adderData.value
      .filter(adder =>
        // Include auto-applied adders that have a valid amount greater than 0
        adder.adderType === 'auto_applied_adder' &&
        ((adder.autoAppliedProposalAdderAmount && adder.autoAppliedProposalAdderAmount > 0) ||
         (adder.autoAppliedAdderAmount && adder.autoAppliedAdderAmount > 0)) &&
        !adders.some(sa => sa.id === adder.id)
      )
      .forEach(adder => {
        adders.push({
          id: adder.id,
          label: adder.fieldName,
          price: adder.autoAppliedProposalAdderAmount || adder.autoAppliedAdderAmount || 0,
          isCustom: false,
          isAutoApplied: true
        });
      });

    // Make sure any selected standard adders are also included
    adderData.value
      .filter(adder =>
        adder.adderType === 'selected_adders' &&
        adder.selectedProposalAdder &&
        adder.selectedAdderAmount > 0 &&
        !adders.some(sa => sa.id === adder.id)
      )
      .forEach(adder => {
        adders.push({
          id: adder.id,
          label: adder.fieldName,
          price: adder.selectedAdderAmount || 0,
          isCustom: false
        });
      });

    // Make sure any custom adders with amounts > 0 are included
    adderData.value
      .filter(adder =>
        adder.adderType === 'custom_adders' &&
        adder.customProposalAdderAmount &&
        adder.customProposalAdderAmount > 0 &&  // Explicitly check for > 0, not just truthiness
        !adders.some(sa => sa.id === adder.id)
      )
      .forEach(adder => {
        adders.push({
          id: adder.id,
          label: adder.fieldName,
          price: adder.customProposalAdderAmount || 0,
          isCustom: true
        });
      });
  }

  // Final filter to ensure we only display adders with valid values
  return adders.filter(adder => {
    // Find original adder in adderData to check selectedProposalAdder flag
    const originalAdder = adderData.value?.find(a => a.id === adder.id);

    // Include if explicitly selected on proposal regardless of other conditions
    if (originalAdder && originalAdder.selectedProposalAdder) {
      return true;
    }

    // For auto-applied adders, check if they have a positive amount
    if (adder.isAutoApplied && adder.price > 0) {
      return true;
    }

    // For other adders, ensure they have a price > 0
    return adder.price > 0;
  });
});

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

// Compute pages from template
const pages = computed(() => {
  // If template has no value, return empty array
  if (!template.value || !Array.isArray(template.value)) {
    return [];
  }

  // Get all blocks that are pages (typically those without parents)
  return template.value.filter(block => !block.parentId);
});

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
      ? 'customFieldGroupAssignmentReadOnly'
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
  await getProposalAdders()
  proposalForm.value.resetValidation()
  expandedPanel.value = [0]
  adderCostField.value.hasChanges = false;
  adderStateChanged.value = false;

}

const validateForm = () => {
  //checks for required fields prior to opening the save dialog
  if (proposalForm.value.validate()) {
    // Always ensure adderCostField has updated stringValue from selectedAdders
    if (adderCostField.value) {
      // Make sure we have the latest adder selections in the stringValue
      adderCostField.value.stringValue = JSON.stringify({
        totalCost: adderTotalCost.value,
        selectedAdderIds: selectedAdders.value
          .filter(adder => !adder.isCustom && !adder.isAutoApplied)
          .map(adder => adder.id),
        customAdders: selectedAdders.value
          .filter(adder => adder.isCustom)
          .map(adder => ({
            id: adder.id,
            fieldName: adder.label,
            amount: adder.price,
            customAdderDataType: adder.customAdderDataType
          })),
        selectedAdders: selectedAdders.value,
        allAdderStates: adderData.value.map(adder => ({
          id: adder.id,
          selectedProposalAdder: adder.selectedProposalAdder,
          customProposalAdderAmount: adder.adderType === 'custom_adders' ? adder.customProposalAdderAmount : null,
          autoAppliedProposalAdderAmount: adder.adderType === 'auto_applied_adder' ? adder.autoAppliedProposalAdderAmount : null,
          customAdderDataType: adder.adderType === 'custom_adders' ? adder.customAdderDataType : null
        }))
      });

      // Mark proposal as having changes but do NOT add to dirtyCfvs
      adderCostField.value.hasChanges = true
    }
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

    const customAddersToUpdate = []
    if (adderCostField.value && adderCostField.value.stringValue) {
      try {
        const adderData = JSON.parse(adderCostField.value.stringValue)

        // Process custom adders for direct API update
        // Always include all custom adders, with special handling for 0 values
        if (adderData.customAdders && Array.isArray(adderData.customAdders)) {
          // Process all custom adders, including those with 0 value

          adderData.customAdders.forEach(adder => {
            if (adder.id) {
              // Special handling for exact 0 values
              let amount = 0;
              if (adder.amount === 0) {
                amount = 0;
              } else {
                amount = adder.amount !== undefined ? adder.amount : 0;
              }

              customAddersToUpdate.push({
                id: adder.id,
                customAdderAmount: amount,
                adderType: 'custom_adders',
                fieldName: adder.fieldName,
                // For UI display only - all values still sent to API
                applied: amount > 0,
                customAdderDataType: adder.customAdderDataType ?? 4
              })
            }
          })
        }

        // Add selected adders
        if (adderData.selectedAdderIds && Array.isArray(adderData.selectedAdderIds)) {
          adderData.selectedAdderIds.forEach(id => {
            // Find the adder in the selectedAdders array
            const adder = adderData.selectedAdders ?
              adderData.selectedAdders.find(a => a.id === id && !a.isCustom && !a.isAutoApplied) :
              null;

            if (adder) {
              customAddersToUpdate.push({
                id: id,
                adderType: 'selected_adders',
                fieldName: adder.label || 'Selected Adder',
                applied: true
              })
            }
          })
        }

        // Also handle unselected adders
        if (adderData.unselectedAdderIds && Array.isArray(adderData.unselectedAdderIds)) {
          adderData.unselectedAdderIds.forEach(id => {
            if (!customAddersToUpdate.some(a => a.id === id)) {
              // Get name from the original adder data if available
              const originalAdderName = adderData?.selectedAdders?.find(a => a.id === id)?.label || 'Unselected Adder';
              customAddersToUpdate.push({
                id: id,
                adderType: 'selected_adders',
                fieldName: originalAdderName,
                applied: false
              })
            }
          })
        }

        // Add auto-applied adders if any exist
        if (adderData.selectedAdders && Array.isArray(adderData.selectedAdders)) {
          adderData.selectedAdders
            .filter(adder => adder.isAutoApplied)
            .forEach(adder => {
              customAddersToUpdate.push({
                id: adder.id,
                adderType: 'auto_applied_adder',
                fieldName: adder.label || 'Auto-Applied Adder',
                applied: true
              })
            }
          )
        }
      } catch (e) {
        console.error('Error parsing adder data for save:', e)
      }
    }

    // Check if we need to ensure all custom adders from adderData are included
    // This is a safety measure to catch any custom adders that might not have been captured
    if (adderData.value && adderData.value.length > 0) {
      adderData.value
        .filter(adder => adder.adderType === 'custom_adders')
        .forEach(adder => {
          // Check if this adder is already in customAddersToUpdate
          const alreadyIncluded = customAddersToUpdate.some(a => a.id === adder.id);

          if (!alreadyIncluded) {

            // Add this custom adder to the update list
            customAddersToUpdate.push({
              id: adder.id,
              customAdderAmount: adder.customProposalAdderAmount === 0 ? 0 : (adder.customProposalAdderAmount || 0),
              adderType: 'custom_adders',
              fieldName: adder.fieldName,
              applied: adder.customProposalAdderAmount > 0,
              customAdderDataType: adder.customAdderDataType || 4
            });
          }
        });
    }

    // Only make the API call if we have selected_adders or custom_adders to update
    // Filter out auto_applied_adder types, we don't need to send those to the backend
    const relevantAdders = customAddersToUpdate.filter(adder =>
      adder.adderType === 'selected_adders' || adder.adderType === 'custom_adders'
    );

    // Only hit the API if we have relevant adders to update
    if (relevantAdders.length > 0) {
      try {
        // Ensure custom adders with amount of 0 are included and properly tagged
        relevantAdders.forEach(adder => {
          if (adder.adderType === 'custom_adders') {
            // Make sure amount is exactly the value we want to send
            adder.customAdderAmount = adder.customAdderAmount === 0 ? 0 : (adder.customAdderAmount || 0);

            // The applied flag only controls UI display, but all values are sent to API
            // For custom adders with amount 0, still include them but mark as not visually applied
            if (adder.customAdderAmount === 0) {
              adder.applied = false;
            }
          }
        });


        await postRequest(
          `/proposal/${proposalId.value}/adders/update`,
          { adderItems: relevantAdders }, // Send all relevant adders, including those with 0 values
          'blueraven'
        )
      } catch (e) {
        console.error('Error updating adders:', e)
      }
    }

    // Filter out our virtual adderCostField if it somehow got into dirtyCfvs
    const fieldsToSave = dirtyCfvs.value.filter(field =>
      field.customFieldId !== 'adderCosts'
    );

    // Only send update if we have regular fields to save
    let responseData, status;
    if (fieldsToSave.length > 0) {
      const response = await postRequest(
        `/proposal/${proposalId.value}`,
        fieldsToSave,
        'blueraven'
      );
      responseData = response.data;
      status = response.status;
    } else {
      // If we only had adder changes, we still need to refresh the data
      const response = await getRequest(
        `/proposal/${proposalId.value}`,
        'blueraven'
      );
      responseData = response.data;
      status = response.status;
    }

    // Reset the hasChanges flag on adderCostField since we saved it
    adderCostField.value.hasChanges = false;

    // Also reset the adderStateChanged flag since we've saved the state
    adderStateChanged.value = false;

    // Update the proposal data
    proposal.value = responseData
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
    expandedPanel.value = [0]
  }
}

const inputChangeCallback = async(field, remove=false) => {
  await populateDirtyCfvs(field, remove)

  // Update configuration refs if any relevant field changes
  if (field.customFieldGroupAssignmentId === FIELD_IDS.PRICING_STRATEGY ||
      field.customFieldGroupAssignmentId === FIELD_IDS.STORAGE_TYPE ||
      field.customFieldGroupAssignmentId === FIELD_IDS.FINANCIAL_PRODUCT) {
    updateConfigurationRefs();
  }

  if(field.customFieldGroupAssignmentId === 1312 && (!auroraDesignId.value || !auroraProjectId.value)){
    await loadAuroraProjectId()
  }
}

const populateDirtyCfvs = async (field, remove = false) => {
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
    const { data } = await getRequest( `/proposal/projects/${proposal.value?.projectId}/${proposal.value?.projectProcessStepId}/auroraProjectId`,
      'blueraven'
    )
    auroraProjectId.value = data?.projectId
    auroraDesignId.value = data?.designId
  }catch (e) {
    console.error('*** ERROR ***', e)
  }
}


// Handle cancel button in adder dialog - simply close without making changes
const handleAdderDialogCancel = () => {
  showAdderCostDialog.value = false;
  // No need to reload data or change state - the existing state is preserved
};

// Track if adders state has changed and dialog needs refresh
const adderStateChanged = ref(false);

const openAdderDialog = () => {
  // Update refs for configuration fields
  updateConfigurationRefs();

  // Check if Pricing Strategy field exists
  const pricingStrategyField = findCustomFieldByAssignmentId(FIELD_IDS.PRICING_STRATEGY);

  // Allow dialog to open if no field is found for Admin users
  if (!pricingStrategyField) {
    // Always preserve any existing adder selections and only update if empty
    if (adderCostData.value.items && Object.keys(adderCostData.value.items).length === 0) {
      updateAdderSelections();
    }
    showAdderCostDialog.value = true;
    return;
  }

  // If field exists and has a value
  if (pricingStrategyField.intValue) {
    commissionStrategyId.value = pricingStrategyField.intValue;

    // Always preserve any existing adder selections and only update if empty
    if (adderCostData.value.items && Object.keys(adderCostData.value.items).length === 0) {
      updateAdderSelections();
    }
    showAdderCostDialog.value = true;
  } else {
    // Pricing Strategy field exists but has no value, show alert
    appStore.showSnack('ERROR', 'Pricing Strategy must be selected before applying adders.');
    pricingStrategyField.required = true;

    // Force validation to highlight the required field
    if (proposalForm.value) {
      proposalForm.value.validate();
    }
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
/* Add styles for sticky headers */
.sticky-configuration-header {
  position: sticky !important;
  top: 0 !important;
  z-index: 20 !important;  /* Increased z-index to ensure it stays on top */
  background-color: white !important;
  border-bottom: 1px solid rgba(0, 0, 0, 0.12) !important;
  box-shadow: 0 2px 4px -1px rgba(0, 0, 0, 0.06) !important; /* Added subtle shadow for visual separation */
}

.configuration-header {
  position: sticky !important;
  top: 0 !important;
  z-index: 20 !important;
  background-color: white !important;
}

.price-details-header {
  position: sticky !important;
  top: 0 !important;
  z-index: 10 !important;
  background-color: white !important;
}

.sticky-price-details:not(.v-expansion-panel--active) {
  position: sticky !important;
  bottom: 0 !important;
  z-index: 10 !important;
  background-color: white !important;
}

// Style overrides to remove rounded corners and add dividers
:deep(.v-expansion-panel) {
  border-radius: 0 !important;
}

:deep(.v-expansion-panel-header) {
  padding: 12px 16px;
}

:deep(.v-expansion-panel-content__wrap) {
  padding: 0 16px 16px;
}

:deep(.v-expansion-panel--active) {
  border-radius: 0 !important;
  margin: 0;
}

/* Add divider between expansion panel header and content */
:deep(.v-expansion-panel--active > .v-expansion-panel-header) {
  border-bottom: 1px solid rgba(0, 0, 0, 0.12);
}

:deep(.v-expansion-panel:not(:first-child)::after) {
  border-top: 1px solid rgba(0, 0, 0, 0.12);
  width: 100%;
}

:deep(.parent-expansion-header) {
  margin: 0 !important;
  border-radius: 0 !important;
}

:deep(.v-expansion-panels--accordion .v-expansion-panel) {
  margin-bottom: 8px;
}

/* Set consistent padding and margin for panels */
:deep(.child-expansion-panel) {
  margin: 0 0 8px 0 !important;
  padding: 0 !important;
  &:first-child {
    margin-top: 8px !important;
  }
}

:deep(.child-expansion-panel) {
  margin: 0 0 8px 0 !important;
  padding: 0 !important;
}

/* Base layout and containers */
.configurations-wrapper {
  height: calc(100vh - (var(--padding-and-margins) - var(--dirty-cfv-height)) + var(--proposal-action-height) + 14px);
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.configurations-card-container {
  background-color: white;
  border-radius: 0;
  height: 100%;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.configurations-scroll-area {
  flex: 1;
  overflow-y: auto;
  padding: 0;
  height: 100%; /* Ensures the scroll area takes full height */
  display: flex;
  flex-direction: column;
}

.configurations-column {
  margin-top: 4px;
  padding-left: 12px;
  padding-right: 4px;

  @media (max-width: 600px) {
    padding-right: 12px;
  }
}

/* Card styling */
.configurations-card,
.prop-view-card {
  display: flex;
  padding: 14px 18px;
  font-size: 20px;
  align-content: center;
}

/* Headers and buttons */
.config-label {
  font-size: 20px;
}

.config-buttons-group,
.prop-button-group {
  display: flex;
  justify-content: flex-end;
  color: var(--primary-color);
  margin-right: 4px;
}

.config-buttons {
  white-space: nowrap;
}

.new-proposal-header {
  font-size: 20px;
  font-weight: 700;
  display: flex;
  flex: 1 1 auto;
  align-items: center;
  word-break: break-word;
}

#back-btn {
  display: flex;
  flex-wrap: nowrap;
  word-break: normal;
  text-decoration: none;
  font-size: 14px;
  font-weight: 500;
}

.delete-btn {
  color: rgba(180, 34, 31, 1);
}

/* Proposal viewer and actions */
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

.prop-custom-field-groups,
.proposal-viewer {
  border-radius: 0;
  overflow-y: auto;
  background-color: var(--v-grey-lighten4);
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

/* Expansion panel styling */
.v-expansion-panels {
  width: 100%;
  border-radius: 0;
}

.parent-expansion-header {
  font-size: 20px;
}

.child-expansion-header {
  font-size: 16px;
}

.child-expansion-panel {
  margin: 0 16px 8px 0;
  &:first-child {
    margin-top: 8px;
  }
}

//::v-deep .v-expansion-panel-content__wrap {
//  padding: 0 0 8px 16px;
//  margin-right: 0;
//}

.configuration-group-title {
  &.v-toolbar__title {
    font-size: 14px;
  }
}

.v-text-field.v-text-field--enclosed .v-input__slot {
  cursor: pointer;
}

$expansion-panel-active-margin: 0 0 0 0;
$expansion-panel-inactive-margin: 0 0 0 0;
/* Zoom styling */
.proposal-zoom-lock {
  transform: scale(var(--scale, 0.75));
  transform-origin: top left;
  margin-bottom: calc((var(--scale, 0.75) - 1) * 100%);

  @media (min-width: 1548px) {
    transform-origin: top center;
  }

  @media (max-width: 600px) {
    --scale: 0.45;
  }
}

/* Responsive layouts */
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
    height: calc(100vh - var(--padding-and-margins) - var(--dirty-cfv-height) - 32px);
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
    height: calc(100vh - var(--padding-and-margins) - var(--dirty-cfv-height) + 8px);
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
    height: calc(100vh - var(--padding-and-margins) - var(--dirty-cfv-height) - 32px);
  }

  .proposal-viewer {
    height: calc(100vh - var(--padding-and-margins) - var(--dirty-cfv-height) - var(--proposal-action-height) - 32px);
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

@media (max-width: 440px) {
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
</style>
