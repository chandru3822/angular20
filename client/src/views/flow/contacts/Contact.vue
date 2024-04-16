<template>
  <div id="contact-container">
    <!--    modal for leaving with unsaved fields -->
    <ConfirmationDialog :open-dialog="unsavedFieldsModal" @confirm="[navigationOverride = true, goToPath(toPath)]"
                        @close-dialog="unsavedFieldsModal = false">
      <template v-slot:title>Confirm</template>
      You have unsaved fields in <span class="label-large">Contact Summary</span>.<br/>
      Are you sure you want to continue without saving?
      <template v-slot:yes>Don't Save</template>
    </ConfirmationDialog>
    <!--    modal for editing contact fields -->
    <ConfirmationDialog v-if="showEditModal" :open-dialog="showEditModal" parent-close
                        @confirm="validateForm()" @close-dialog="showEditModal = false">
      <template v-slot:title><div class="title-large">Contact Overview</div></template>
      <v-form ref="contactEditForm">
        <v-card-text class="pt-4 px-0">
          <div>
            <a-text-field
                id="qa-first-name-field"
                v-model="tempContact.firstName"
                :rules="requiredRules"
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                label="Contact First Name"
                class="body-large"
            ></a-text-field>
            <a-text-field
                class="body-large"
                id="qa-last-name-field"
                v-model="tempContact.lastName"
                :rules="requiredRules"
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                label="Contact Last Name"
            ></a-text-field>
            <a-text-field
                class="body-large"
                v-model="tempContact.street1"
                label="Street"
                id="qa-address-field"
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                :maxlength="100"
                counter
                @change="tempContact.reloadCoordinates = true"
            ></a-text-field>
            <a-text-field
                id="qa-city-field"
                class="body-large"
                v-model="tempContact.city"
                label="City"
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                @change="tempContact.reloadCoordinates = true"
            ></a-text-field>
            <a-text-field
                class="body-large"
                type="text"
                v-model="tempContact.postalCode"
                counter
                id="qa-zip-field"
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                :maxlength="10"
                :rules="postalCodeRules"
                @change="tempContact.reloadCoordinates = true"
                label="Postal Code"
            ></a-text-field>
            <a-autocomplete v-model="tempContact.companyStateId"
                            class="body-large"
                            :items="states"
                            label="State"
                            id="qa-state-field"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            :loading="statesLoading"
                            item-title="state"
                            item-value="id"
                            @input="tempContact.reloadCoordinates = true"
            ></a-autocomplete>
            <a-select v-model="tempContact.companyCountryId"
                      class="body-large"
                      :items="countries"
                      label="Country"
                      :readonly="!userCanEdit"
                      id="qa-country-field"
                      :disabled="!userCanEdit"
                      :loading="countriesLoading"
                      @input="tempContact.reloadCoordinates = true"
                      item-title="country"
                      item-value="id"
            ></a-select>
            <a-text-field
                          class="body-large"
                          label="Phone"
                          placeholder=" "
                          id="qa-phone-field"
                          :rules="contactPhoneRule"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          v-model="tempContact.phone"></a-text-field>
            <a-text-field
                          class="body-large"
                          label="Mobile"
                          placeholder=" "
                          id="qa-mobile-field"
                          :rules="contactPhoneRule"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          v-model="tempContact.mobile"></a-text-field>
            <a-text-field
                          class="body-large"
                          label="E-Mail"
                          id="qa-email-field"
                          placeholder=" "
                          :rules="emailRules"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          v-model="tempContact.email"></a-text-field>
          </div>
          <a-autocomplete v-model="tempContact.owner"
                          class="body-large"
                          id="qa-owner-field"
                          :readonly="contactOwnerFieldIsReadOnly()"
                          :disabled="contactOwnerFieldIsReadOnly()"
                          :items="availableOwners"
                          :loading="ownersLoading"
                          label="Contact Owner"
                          clearable
                          item-title="fullName"
                          return-object
                          autocomplete="off">
            <template v-slot:prepend v-if="!contactOwnerFieldIsReadOnly()">
              <v-tooltip top small>
                <template v-slot:activator="{on, attrs}">
                  <v-icon @click="selectSelf" class="clickable" color="primary" v-bind="attrs" v-on="on">mdi-account-arrow-right-outline</v-icon>
                </template>
                <span class="albatross-body-3">Select Me</span>
              </v-tooltip>
            </template>
          </a-autocomplete>
        </v-card-text>
      </v-form>
      <template v-slot:no><div class="body-medium">Cancel</div></template>
      <template v-slot:yes><div class="body-medium">Save</div></template>

    </ConfirmationDialog>
    <!-- modal for deleting contact -->
    <ConfirmationDialog :open-dialog="deleteContactConfirm" @confirm="deleteContact"
                        @close-dialog="deleteContactConfirm = false">
      <span class="bold error-text">WARNING:</span> This cannot be undone. Are you sure you want to delete this contact?
    </ConfirmationDialog>
    <!--    end dialogs -->
    <ThreeColumnLayout :header-text="contact.fullName"
                       :auto-overflow-left="false" :show-right-collapse-btn="true">


      <template v-slot:back-btn>

      </template>
      <template v-slot:header-btn>
        <div class="mt-3">
          <a-btn
              id="qa-delete-contact"
              variant="text"
              color="primary"
              v-if="userCanDelete"
              :disabled="contact.projects && contact.projects.length > 0"
              class="hide-xs"
              @click="deleteContactConfirm = true"
              prepend-icon="delete"
          ></a-btn>
        </div>
      </template>
      <template v-slot:left-column>
        <div v-if="!projectStore.leftSideSplit && contact && contact.id"
             class="px-2 height-one-hunned overflow-y-auto hide-xs">
          <PageOverview page-name="Contact"
                        :show-edit-btn="contact && contact.id && userCanEdit"
                        @clickEdit="[getStatesAndCountries(), getOwners(), tempContact = cloneDeep(contact), showEditModal = true]"
                        :details="overviewDetails"
          ></PageOverview>
          <v-divider></v-divider>
          <SidePanelExpansionPanel header="Associated Projects" :sectionExpanded="sectionExpanded">
            <template v-slot:tool-btn>
              <v-menu
                  v-if="userStore.userHasFeatureAccessLevel('PROJECTS', 'ADD')"
                  bottom
                  offset-y
                  :close-on-content-click="false"
              >
                <template v-slot:activator="{ on: menu }">
                  <v-tooltip top
                             :disabled="(null != contact.firstName || null != contact.lastName) && (null != contact.owner && null != contact.owner.userId)">
                    <template v-slot:activator="{ on: tooltip }">
                      <div v-on="{ ...tooltip }" class="d-inline-block">
                        <a-btn
                            :activation-handler="{ ...menu }"
                            variant="text"
                            small
                            :disabled="(!contact.firstName && !contact.lastName) || !contact.owner || !contact.owner.userId"
                            color="primary"
                            id="qa-create-project-button"
                            class="px-0"
                            @click="getAvailableProcesses"
                            prepend-icon="add"
                        ></a-btn>
                      </div>
                    </template>
                    <span v-if="!contact.firstName && !contact.lastName">Contact Requires First or Last Name</span>
                    <span v-else-if="!contact.owner || !contact.owner.userId">Requires Owner</span>
                  </v-tooltip>
                </template>
                <v-card class="pa-5 body-large">
                  Select a process to be used
                  <a-select v-model="selectedProcess"
                            :items="availableProcesses"
                            label="Process"
                            id="qa-process-selector"
                            :loading="processesLoading"
                            placeholder="Select one..."
                            item-title="processName"
                            return-object
                            class="mt-2 qa-process-selector"
                  ></a-select>
                  <a-btn
                      variant="text"
                      color="primary"
                      class="body-medium"
                      :disabled="!selectedProcess || !selectedProcess.id"
                      @click="convertToCustomer"
                      id="qa-add-project-button"
                      text="Add Project"
                  ></a-btn>
                </v-card>
              </v-menu>
            </template>
            <template v-slot:expanded-content>
              <div>
                <v-card flat v-for="p in contact.projects"
                        class="project-button albatross-body-1"
                        :to="`/project/${p.id}/${defaultProjectPage}`">
                  <div class="body-large" >{{ p.projectName }} </div>
                  <div class="body-small" :class="getStatusClass(p.projectStatusTypeId)">{{ p.projectStatusType }}</div>
                </v-card>
                <span v-if="contact?.projects?.length === 0">No associated projects</span>
              </div>
            </template>
          </SidePanelExpansionPanel>
          <v-divider></v-divider>
        </div>
        <div v-if="!projectStore.leftSideSplit && contact && contact.id"
             class="px-2 height-one-hunned scrollable show-xs mobile-padding-menu">
          <div class=menu-option :class="{'body-large': !showMobileSummary, 'label-large': showMobileSummary}" @click="openTab('summary')">Summary</div>
          <div class=menu-option :class="{'body-large': !showMobileOverview, 'label-large': showMobileOverview}" @click="openTab('overview')">Overview</div>
          <div class=menu-option :class="{'body-large': !showMobileAssociatedProjects, 'label-large': showMobileAssociatedProjects}" @click="openTab('associatedProjects')">Associated Projects</div>
          <div class=menu-option :class="{'body-large': !showMobileNotes, 'label-large': showMobileNotes}" @click="openTab('notes')">Notes</div>
          <div class=menu-option :class="{'body-large': !showMobileDocuments, 'label-large': showMobileDocuments}" @click="openTab('documents')">Documents</div>
          <div v-if="userCanDelete && !(contact.projects && contact.projects.length > 0)" class="body-large menu-option"
               id="qa-delete-contact"
               @click="deleteContactConfirm = true" style="color: #B4221F">Delete Contact</div>
          <div v-else class="body-large menu-option" style="color: #FECDD2">Delete Contact</div>

        </div>
      </template>
      <template v-slot:main-column>
        <div v-if="contact && contact.id && (showMobileNotes || showMobileDocuments)"
             class="px-2 height-one-hunned overflow-y-auto " style="background-color: white">
          <ProjectActivity v-if="!contactLoading && contactId !== 0"
                           :contact-id="contactId"
                           :force-show-upload-btn="true"
                           :show-notes="showMobileNotes"
                           :show-sms-tab="false"></ProjectActivity>
        </div>
        <div v-if="contact && contact.id && showMobileOverview"
             class="px-2 height-one-hunned overflow-y-auto mobile-background">
          <PageOverview page-name="Contact"
                        :show-edit-btn="contact && contact.id && userCanEdit"
                        @clickEdit="[getStatesAndCountries(), getOwners(), tempContact = cloneDeep(contact), showEditModal = true]"
                        :details="overviewDetails"
          ></PageOverview>
        </div>
        <div class="show-xs mobile-background" v-if="showMobileAssociatedProjects">
          <v-toolbar class="mobile-contact-header" color="transparent" flat>
            <div class=" headline-small"><v-icon class="hide-xs mobile-hamburger-menu" @click="openMenu()">mdi-menu</v-icon>Associated Projects</div>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <v-menu
                  v-if="userStore.userHasFeatureAccessLevel('PROJECTS', 'ADD')"
                  bottom
                  offset-y
                  :close-on-content-click="false"
              >
                <template v-slot:activator="{ on: menu }">
                  <!--                  <v-tooltip top :disabled="(!contact.firstName && !contact.lastName) || !contact.owner || !contact.owner.userId">-->
                  <v-tooltip top
                             :disabled="(null != contact.firstName || null != contact.lastName) && (null != contact.owner && null != contact.owner.userId)">
                    <template v-slot:activator="{ on: tooltip }">
                      <div v-on="{ ...tooltip }" class="d-inline-block mt-4">
                        <a-btn
                            :activation-handler="{ ...menu }"
                            variant="text"
                            x-small
                            :disabled="(!contact.firstName && !contact.lastName) || !contact.owner || !contact.owner.userId"
                            color="primary"
                            id="qa-create-project-button"
                            @click="getAvailableProcesses"
                            prepend-icon="add"
                        ></a-btn>
                      </div>
                    </template>
                    <span v-if="!contact.firstName && !contact.lastName">Contact Requires First or Last Name</span>
                    <span v-else-if="!contact.owner || !contact.owner.userId">Requires Owner</span>
                  </v-tooltip>
                </template>
                <v-card class="pa-5 body-large">
                  Select a process to be used
                  <a-select v-model="selectedProcess"
                            :items="availableProcesses"
                            label="Process"
                            id="qa-process-selector"
                            :loading="processesLoading"
                            placeholder="Select one..."
                            item-title="processName"
                            return-object
                            class="mt-2 qa-process-selector"
                  ></a-select>
                  <a-btn
                      variant="text"
                      color="primary"
                      class="body-medium"
                      :disabled="!selectedProcess || !selectedProcess.id"
                      @click="convertToCustomer"
                      id="qa-add-project-button"
                      text="Add Project"
                  ></a-btn>
                </v-card>
              </v-menu>
            </v-toolbar-items>
          </v-toolbar>
          <div class="mx-2 mobile-content-padding">
            <v-card flat v-for="p in contact.projects"
                    class="project-button albatross-body-1"
                    :to="`/project/${p.id}/${defaultProjectPage}`">
              <div class="body-large" >{{ p.projectName }} </div>
              <div :class="getStatusClass(p.projectStatusTypeId)">{{ p.projectStatusType }}</div>
              <!--            <div class="ps-owner albatross-body-2" v-if="ps && ps.owner && ps.owner.fullName">{{ ps.owner.fullName }}</div>-->

            </v-card>
          </div>
        </div>
        <div class="hide-xs">
          <!-- this cannot be inside the v-if display or else the fixed toolbar doesn't work -->
          <v-toolbar flat color="secondary" class="cfg-name-header fixed-toolbar toolbar-z-index-override">
            <v-toolbar-title class="headline-small">
              Contact Summary
            </v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <a-btn
                  variant="text"
                  color="primary"
                  @click="setSplitColumnValue()"
                  class="px-0 hide-xs"
                  :prepend-icon="!projectStore.manualColumnSplit ? 'mdi-format-columns' : 'mdi-format-align-justify'"
              ></a-btn>
              <div>
                <a-btn
                    color="primary"
                    class="body-medium mt-3"
                    v-if="userCanEdit"
                    id="qa-save-fields-button"
                    :loading="fieldsLoading"
                    :disabled="fieldsSaving"
                    @click="validateFields(true)"
                    text="Save Fields"
                ></a-btn>
              </div>
            </v-toolbar-items>
          </v-toolbar>
          <div class="contact-fields-container" v-if="contact && contact.id && !fieldsLoading">
            <v-row class="px-5">
              <v-col cols="12" class="text-left py-0 px-0">
                <!--    process field groups-->
                <v-form ref="contactForm">
                  <v-col
                      class="pt-0"
                      v-for="(cfg, index) in customFieldGroups"
                      :key="index"
                  >
                    <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar body-large" dense>
                      <v-toolbar-title class="body-medium">
                        {{ cfg.groupName }}
                      </v-toolbar-title>
                      <v-spacer></v-spacer>
                      <v-toolbar-items>
                      </v-toolbar-items>
                    </v-toolbar>

                    <v-card class="px-4 square-card" v-if="cfg.customFieldValues && cfg.customFieldValues.length > 0">
                      <v-row>
                        <v-col :cols="projectStore.manualColumnSplit ? 6 : 12" class="pb-0 pt-2">
                          <CustomValueInput v-for="(cf, idx) in getCustomFieldValuesToDisplay(cfg.customFieldValues, 1)"
                                            :key="idx"
                                            :required="cf.required"
                                            :readonly="getReadOnly(cf)"
                                            :callback="populateDirtyCfvs"
                                            :field="cf"
                                            class = "body-large"
                                            :show-field-name="false"></CustomValueInput>
                        </v-col>
                        <v-col cols="6" v-if="projectStore.manualColumnSplit" class="pb-0 pt-2">
                          <CustomValueInput v-for="(cf, idx) in getCustomFieldValuesToDisplay(cfg.customFieldValues, 2)"
                                            :key="idx"
                                            :required="cf.required"
                                            :readonly="getReadOnly(cf)"
                                            :callback="populateDirtyCfvs"
                                            :field="cf"
                                            class = "body-large"
                                            :show-field-name="false"></CustomValueInput>
                        </v-col>
                      </v-row>

                    </v-card>
                  </v-col>

                </v-form>
              </v-col>
            </v-row>
          </div>
          <div v-else>
            <SpinnerInline centered :size="50" color="primary"/>
          </div>
        </div>
        <div class = "show-xs mobile-contact-header" v-if="showMobileSummary">
          <!-- this cannot be inside the v-if display or else the fixed toolbar doesn't work -->
          <v-toolbar flat class="cfg-name-header mobile-background fixed-toolbar toolbar-z-index-override">
            <v-toolbar-title class="headline-small">
              <v-icon class="mobile-hamburger-menu" @click="openMenu()">mdi-menu</v-icon>
              Summary
            </v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <a-btn
                  variant="text"
                  color="primary"
                  @click="setSplitColumnValue()"
                  class="px-0 hide-xs"
                  :prepend-icon="!projectStore.manualColumnSplit ? 'mdi-format-columns' : 'mdi-format-align-justify'"
              ></a-btn>
              <div>
                <a-btn
                    color="primary"
                    class="body-medium mt-3"
                    v-if="userCanEdit"
                    id="qa-edit-contact-save"
                    :loading="fieldsLoading"
                    :disabled="fieldsSaving"
                    @click="validateFields(true)"
                    text="Save"
                ></a-btn>
              </div>
            </v-toolbar-items>
          </v-toolbar>
          <div v-if="contact && contact.id && !fieldsLoading" style="overflow-x: hidden">
            <v-row class="px-5">
              <v-col cols="12" class="text-left py-0 px-0">
                <!--    process field groups-->
                <v-form ref="contactForm">
                  <v-col
                      class="pt-0"
                      v-for="(cfg, index) in customFieldGroups"
                      :key="index"
                  >
                    <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar body-large" dense>
                      <v-toolbar-title class="body-medium">
                        <span class="body-medium">
                        {{ cfg.groupName }}
                          </span>
                      </v-toolbar-title>
                      <v-spacer></v-spacer>
                      <v-toolbar-items>
                      </v-toolbar-items>
                    </v-toolbar>

                    <v-card class="px-4 square-card" v-if="cfg.customFieldValues && cfg.customFieldValues.length > 0">
                      <v-row>
                        <v-col :cols="projectStore.manualColumnSplit ? 6 : 12" class="pb-0 pt-2">
                          <CustomValueInput v-for="(cf, idx) in getCustomFieldValuesToDisplay(cfg.customFieldValues, 1)"
                                            :key="idx"
                                            :required="cf.required"
                                            :readonly="getReadOnly(cf)"
                                            :callback="populateDirtyCfvs"
                                            :field="cf"
                                            class = "body-large"
                                            :show-field-name="false"></CustomValueInput>
                        </v-col>
                        <v-col cols="6" v-if="projectStore.manualColumnSplit" class="pb-0 pt-2">
                          <CustomValueInput v-for="(cf, idx) in getCustomFieldValuesToDisplay(cfg.customFieldValues, 2)"
                                            :key="idx"
                                            :required="cf.required"
                                            :readonly="getReadOnly(cf)"
                                            :callback="populateDirtyCfvs"
                                            :field="cf"
                                            class = "body-large"
                                            :show-field-name="false"></CustomValueInput>
                        </v-col>
                      </v-row>

                    </v-card>
                  </v-col>

                </v-form>
              </v-col>
            </v-row>
          </div>
          <div v-else>
            <SpinnerInline centered :size="50" color="primary"/>
          </div>
        </div>

      </template>
      <template v-slot:right-column>
        <ProjectActivity v-if="!contactLoading && contactId !== 0"
                         :contact-id="contactId"
                         :force-show-upload-btn="true"
                         :show-sms-tab="false"></ProjectActivity>
      </template>
    </ThreeColumnLayout>
  </div>

</template>

<script setup>

import ProjectActivity from '@/views/flow/project/ProjectActivity'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import ThreeColumnLayout from '@/views/ThreeColumnLayout'
import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
  formatPhoneNumber,
  getRequestWithParams,
  getSnackbar, logError, postRequestWithRequestParams, getProjectPath
} from '@/helpers/helpers'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import {getCompanyStates} from '@/services/stateService'
import {getCountries} from '@/services/countryService'
import {getCustomFieldReadOnly} from '@/services/customFieldService'
import constants from '@/helpers/constants'
import cloneDeep from 'lodash.clonedeep'
import {getStatusClass} from "@/services/processStepStatusTypeService";
import SpinnerInline from '@/components/SpinnerInline'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import PageOverview from "../PageOverview";
import SidePanelExpansionPanel from "@/components/SidePanelExpansionPanel.vue";
import {saveContact} from "@/services/contactService";
import { useProjectStore } from '@/stores/ProjectStore.js'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import { onBeforeRouteLeave } from 'vue-router/composables'

const projectStore = useProjectStore()
const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store


const defaultProjectPage = ref(getProjectPath().pathSuffix)
const states = ref([])
const countries = ref([])
const showEditModal = ref(false)
const contact = ref({})
const sectionExpanded = ref(true)
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
const postalCodeRules = ref(constants.POSTAL_CODE_RULES)
const cityRules = ref(constants.CITY_RULES)
const emailRules = ref(constants.EMAIL_RULES)
const addressRules = ref(constants.ADDRESS_RULES)
const nameRules = ref(constants.NAME_RULES)
const nameRequiredRules = ref(constants.NAME_REQUIRED_RULES)
const contactPhoneRule = ref([() => ((tempContact.value.phone != null && tempContact.value.phone !== '') || (tempContact.value.mobile != null && tempContact.value.mobile !== '')) || "Phone or Mobile is required",v => (!v || (v && (v.length <= 20))) || 'Must be 20 characters or less',v => (!v || (/^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$/.test(v))) || "Please reformat the Phone field with a valid phone number",v => ((!v || (tempContact.value.phone !== tempContact.value.mobile))) || 'Phone and Mobile Cannot be the same',])
const deleteContactConfirm = ref(false)
const contactLoading = ref(true)
const customFieldGroups = ref([])
const unsavedFieldsModal = ref(false)
const toPath = ref(null)
const navigationOverride = ref(false)
const notes = ref([])
const fieldsSaving = ref(false)
const fieldsLoading = ref(true)
const hasDirtyNotes = ref(false)
const dirtyCfvs = ref([])
const dirtySystemFields = ref(false)
const availableOwners = ref([])
const ownersLoading = ref(false)
const statesLoading = ref(false)
const countriesLoading = ref(false)
const tempContact = ref({})
const contactId = ref(parseInt(route.params.contactId))
const userPositionIds = ref([])
const selectedProcess = ref(null)
const processesLoading = ref(true)
const availableProcesses = ref([])
const showMobileOverview = ref(false)
const showMobileSummary = ref(true)
const showMobileAssociatedProjects = ref(false)
const showMobileNotes = ref(false)
const showMobileDocuments = ref(false)
const addressChanged = ref(false)
const notesComponent = ref(null)
const contactEditForm = ref(null)
const contactForm = ref(null)


const is7oaksAdmin  = computed(() => {
  return userStore.isSystemAdmin
})
const userCanEdit  = computed(() => {
  return userStore.userHasFeatureAccessLevel('CONTACTS', 'EDIT')
})
const userCanDelete  = computed(() => {
  return userStore.userHasFeatureAccessLevel('CONTACTS', 'DELETE')
})
const companyId  = computed(() => {
  return userStore.details.companyId
})
const timezone  = computed(() => {
  return userStore.timezone.value
})

const addressFieldRequired = computed(() => {
  //this logic seems backwards but it is just the way rules work
  //if one address field is filled in then all of them are required
  return {
    street: [!(!contact.value.street1 && (Boolean(contact.value.city) || Boolean(contact.value.companyStateId) || Boolean(contact.value.companyCountryId) || Boolean(contact.value.postalCode))) || "Required when other address fields are populated"],
    city: [!(!contact.value.city && (Boolean(contact.value.street1) || Boolean(contact.value.companyStateId) || Boolean(contact.value.companyCountryId) || Boolean(contact.value.postalCode))) || "Required when other address fields are populated"],
    state: [!(!contact.value.companyStateId && (Boolean(contact.value.street1) || Boolean(contact.value.city) || Boolean(contact.value.companyCountryId) || Boolean(contact.value.postalCode))) || "Required when other address fields are populated"],
    country: [!(!contact.value.companyCountryId && (Boolean(contact.value.street1) || Boolean(contact.value.city) || Boolean(contact.value.companyStateId) || Boolean(contact.value.postalCode))) || "Required when other address fields are populated"],
    zip: [!(!contact.value.postalCode && (Boolean(contact.value.street1) || Boolean(contact.value.city) || Boolean(contact.value.companyStateId) || Boolean(contact.value.companyCountryId))) || "Required when other address fields are populated"]
  }
})
const overviewDetails = computed(() => {
  return [
    {
      label: 'Date Created',
      type: constants.OVERVIEW_FIELD_TYPES.DATE,
      value: contact.value.dateCreated
    },
    {
      label: 'Address',
      type: constants.OVERVIEW_FIELD_TYPES.ADDRESS,
      value: {
        street: contact.value.street1,
        city: contact.value.city,
        state: contact.value.state,
        zip: contact.value.postalCode
      }
    },
    {
      label: 'Phone number',
      type: constants.OVERVIEW_FIELD_TYPES.PHONE,
      value: contact.value.phone
    },
    {
      label: 'Mobile number',
      type: constants.OVERVIEW_FIELD_TYPES.MOBILE_PHONE,
      value: formatPhoneNumber(contact.value.mobile)
    },
    {
      label: 'Email address',
      type: constants.OVERVIEW_FIELD_TYPES.EMAIL,
      value: contact.value.email
    },
    {
      label: 'Owner',
      type: constants.OVERVIEW_FIELD_TYPES.OWNER,
      value: contact.value.owner
    }
  ]
})
onMounted(async () => {
  let requests = [getContact(), getCustomFieldGroups()]
  await Promise.all(requests).then(async () => {
    fieldsLoading.value = false
  })
  getUserPositionIds();
})

onBeforeRouteLeave(async (to, from, next) => {
  //do stuff
  // called when the route that renders this component is about to
  // be navigated away from.
  // has access to `this` component instance.
  hasDirtyNotes.value = notesComponent.value?.hasUnsavedNotes()
  if (navigationOverride.value || (dirtyCfvs.value.length === 0 && !dirtySystemFields.value && !hasDirtyNotes.value)) {
    //navigationOverride gets set to true if they click "Yes" to continue. if you don't override then it just hits the else again before navigating
    to.params.useSavedFilters = "true"
    next()
  } else {
    toPath.value = to.path
    unsavedFieldsModal.value = true
  }
})

const openTab = (tab)=> {
  showMobileOverview.value = (tab === 'overview');
  showMobileSummary.value = (tab === 'summary');
  showMobileAssociatedProjects.value = (tab === 'associatedProjects');
  showMobileNotes.value = (tab === 'notes');
  showMobileDocuments.value = (tab === 'documents');
  projectStore.leftSideSplit = true;
}

const openMenu = ()=> {
  projectStore.leftSideSplit = false;
}
const setSplitColumnValue = () => {
  projectStore.manualColumnSplit = !projectStore.manualColumnSplit
}
const getCustomFieldValuesToDisplay = (values, columnNum) => {
  if (projectStore.manualColumnSplit) {
    return values.filter(function (element, index, values) {
      return (index % 2 === (columnNum === 1 ? 0 : 1));
    });
  } else {
    return values
  }
}
const collapseSide = (side) => {
  if (side === 'left') {
    projectStore.leftSideSplit = !projectStore.leftSideSplit
  } else {
    projectStore.rightSideSplit = !projectStore.rightSideSplit
  }
}
const getStatesAndCountries = () => {
  // only load countries and states if they try to edit the project address and they haven't already been loaded
  if (states.value.length === 0 || countries.value.length === 0) {
    getAllCompanyStates()
    getAllCountries()
  }
}
const getUserPositionIds = () => {
  userPositionIds.value = userStore.details.userPositions.map(p => p.positionId)
}
const selectSelf = () => {
  let match = availableOwners.value.find(o => o.userId === userStore.details.id) || {}
  vueInstance.$set(tempContact.value, 'owner', match)
}
const validateForm = async() => {
  if (contactEditForm.value.validate()) {
    //these could be combined - just dont have time atm
    saveContactAddressFields()

    // updateOwner()

    //set project values if they hit save
    contact.value = cloneDeep(tempContact.value)
    showEditModal.value = false
  }
}
const saveContactAddressFields = async () => {
  appStore.loading = true
  try {
    //temp contact holds all the changes in case they cancel. use those values
    tempContact.value.ownerUserPositionId = tempContact.value.owner?.userPositionId || null
    const {status} = await postRequest(`/contact`, tempContact.value)
    appStore.showSnack('SUCCESS', 'Contact Updated')

    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error Saving Fields')

    appStore.loading = false
  }
}
const contactOwnerFieldIsReadOnly = () => {
  if (is7oaksAdmin.value) {
    return false
  } else if (contact.value.ownerReadOnlyWhiteListedPositions?.length > 0) {
    return !userStore.userHasAnyPosition(contact.value.ownerReadOnlyWhiteListedPositions?.map(wlp => wlp.positionId))
  } else {
    return contact.value.ownerReadOnly
  }
}
const goToPath = (path) => {
  router.push(path)
}
const validateFields = async(saveContact) => {
  let valid = contactForm.value?.validate()
  if (valid && saveContact) {
    fieldsSaving.value = true
    await saveCustomFieldValues()
    fieldsSaving.value = false
  } else {
    appStore.showSnack('ERROR', 'Missing Required Fields')

  }
}
const contactOwnerIsReadOnly = () => {
  if (contact.value.ownerReadOnlyWhiteListedPositions?.length > 0) {
    return !userStore.userHasAnyPosition(contact.value.ownerReadOnlyWhiteListedPositions?.map(wlp => wlp.positionId))
  } else {
    return contact.value.ownerReadOnly
  }
}
const saveCustomFieldValues = async() => {
  if (dirtyCfvs.value.length > 0) {
    fieldsSaving.value = true
    appStore.loading = true
    try {
      // save dirty custom field values
      let body = {
        contact: null, //dont add the contact here. this new endpoint will save it if you do and this isn't where changes are made anymore
        cfvs: dirtyCfvs.value
      }
      const {data, status} = await saveContact(contactId.value, body)
      dirtyCfvs.value = []
      addressChanged.value = false
      customFieldGroups.value = data?.cfgs
      fieldsSaving.value = false
      appStore.showSnack('SUCCESS', 'Fields Saved')

      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Saving Contact')

    } finally {
      appStore.loading = false
      fieldsSaving.value = false
    }
  }
}
const populateDirtyCfvs = (field) => {
  let match = dirtyCfvs.value.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
  if (!match) {
    dirtyCfvs.value.push(field)
  }
}
const getCustomFieldGroups = async() => {
  try {
    const {data, status} = await getRequestWithParams(`/customFieldValues/contact/${contactId.value}`)
    customFieldGroups.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Custom Fields')

  }
}
const getContact = async() => {
  try {
    const {data, status} = await getRequest(`/contact/${contactId.value}`)
    contact.value = data
    contactLoading.value = false
    window.document.title = `Contact - ${contact.value.fullName}`
  } catch (e) {
    console.error('*** ERROR ***', e)
    contactLoading.value = false
    appStore.showSnack('ERROR', 'Error Retrieving Contact')

  }
}
const getOwners = async() => {
  try {
    let params = {
      contactId: parseInt(contactId.value)
    }
    const {data, status} = await getRequestWithParams(`/contact/owners`, {params})
    availableOwners.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Owners')

  }
}
const getAvailableProcesses = async() => {
  try {
    processesLoading.value = true
    let params = {
      contactId: parseInt(contactId.value)
    }
    const {data, status} = await getRequestWithParams(`/processes`, {params})
    availableProcesses.value = data
    if(!userStore.isSystemAdmin) { //7 Oaks admin should be able to see all processes
      availableProcesses.value = availableProcesses.value.filter(p => {
        for (let id of userPositionIds.value) {
          if (!p.denyListPositions.find(dlp => dlp.positionId === id)) {
            return p;
          }
        }
      })
    }
    selectedProcess.value = data?.length === 1 ? data[0] : {}
    processesLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Available Processes')

  }
}
const convertToCustomer = async() => {
  appStore.loading = true
  try {
    const {data, status} = await putRequest(`/contact/${contact.value.id}/convert`, selectedProcess.value)
    appStore.showSnack('SUCCESS', 'Successfully Converted')

    // router.push({name: 'projectDetails', params: {projectId: data.id}, query: { checkAddress: true }})
    // ^^ i cant figure out why but doing the routing by name, param, query doesn't load the proper modal on the project screen when needed but it work by hard-coded path
    let path = data.companyStateId ? `/project/${data.id}/${defaultProjectPage.value}` : `/project/${data.id}/${defaultProjectPage.value}?checkAddress=true`
    router.push(path)
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Converting Contact')

    appStore.loading = false
  }
}
const getAllCompanyStates = async() => {
  try {
    const {data, status} = await getCompanyStates()
    states.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving States')

  }
}
const getAllCountries = async() => {
  try {
    const {data, status} = await getCountries(parseInt(companyId.value))
    countries.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Countries')

  }
}
const getReadOnly =  (field) => {
  let fieldReadOnly = false
  if (null != field) {
    fieldReadOnly = getCustomFieldReadOnly(field)
  }
  return !userCanEdit.value || fieldReadOnly
}
const deleteContact = async() => {
  try {
    appStore.loading = true
    await deleteRequest(`/contact/${contact.value.id}`)
    appStore.showSnack('SUCCESS', 'Contact Deleted')

    router.push('/contacts')
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error deleting contact')

    appStore.loading = false
  }
}

</script>

<style lang="scss">
.cfg-name-toolbar .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.cfg-name-toolbar .v-toolbar__title {
  font-size: 14px;
}

.cfg-detail-header .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.cfg-detail-header .v-toolbar__title {
  font-size: 16px;
}

</style>

<style lang="scss" scoped>
.cfg-detail-header {
  background-color: var(--v-secondary-base) !important;
  margin-left: -10px;
  margin-right: -10px;
  padding-left: 10px;
  padding-right: 10px;
}

.contact-header {
  border-bottom: solid 1px #EAEAF4
}

.contact-title {
  font-size: 20px;
}

.contact-subtitle {
  font-size: 15px;
}

.contact-status {
  font-size: 15px;
  display: flex;
  align-items: flex-end;
  text-align: left;
}

.contact-owner {
  font-size: 15px;
  /*display: flex;*/
  /*align-items: flex-end;*/
  text-align: right;
}

.change-owner-button {
  text-decoration: underline;
  text-transform: lowercase;
}

.contact-header {
  height: 64px;
}

#contact-container {
  width: 100%;
  height: 100%;
  max-height: 100% !important;
  padding: 0 !important;
  overflow: hidden;
}

#three-column-container {
  div.contact-fields-container {
    overflow: auto ;
    overflow-x: hidden;
    height: calc(100vh - 200px);
    padding-bottom: 0;
  }

  .contact-split-container {
    height: calc(100% - 50px);
    max-width: 100%;
    width: 100%;
    margin-right: 0 !important;
    margin-left: 0 !important;
  }

  .detail-label {
    font-size: 12px;
    color: var(--v-grey-darken1);
  }

  .detail-item {
    font-size: 0.875rem;
    margin-left: 5px;
    overflow-wrap: break-word;
  }

  .project-button {
    border: solid 1px #C4C4C4;
    padding: 10px;
    margin-bottom: 10px;
  }

  .menu-option{
    padding-top: 12px;
    padding-bottom: 12px;
  }

  .scrollable {
    overflow-y: scroll !important;
  }

  .mobile-padding-menu{
    padding-left: 24px !important;
    padding-bottom: 16px !important;
  }

  @media (max-width: 960px) {

    .mobile-contact-header{
      padding-top: 12px;
      padding-right: 24px;
    }

    .mobile-content-padding{
      padding-top: 16px;
      padding-left: 16px;
      padding-right: 16px;
    }

  }
}

</style>

