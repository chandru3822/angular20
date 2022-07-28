<template>
  <div id="contact-container">
    <!--    modal for leaving with unsaved fields -->
    <ConfirmationDialog :open-dialog="unsavedFieldsModal" @confirm="[navigationOverride = true, goToPath(toPath)]" @close-dialog="unsavedFieldsModal = false">
      <template v-slot:title>Confirm</template>
      You have unsaved fields. <br/>
      Are you sure you want to continue without saving?
      <template v-slot:yes>Continue and Don't Save</template>
    </ConfirmationDialog>
    <!--    modal for editing contact fields -->
    <ConfirmationDialog :open-dialog="showEditModal" :disable-confirm="!contact.firstName || !contact.lastName" @confirm="validateForm()" @close-dialog="showEditModal = false">
      <template v-slot:title>Contact Overview</template>
      <v-form ref="contactEditForm">
        <v-card-text class="pt-4 px-0">
          <div>
            <v-text-field
              v-model="tempContact.firstName"
              :readonly="!userCanEdit"
              :disabled="!userCanEdit"
              label="Contact First Name"
            ></v-text-field>
            <v-text-field
              v-model="tempContact.lastName"
              :readonly="!userCanEdit"
              :disabled="!userCanEdit"
              label="Contact Last Name"
            ></v-text-field>
            <v-text-field
              v-model="tempContact.street1"
              label="Street"
              :readonly="!userCanEdit"
              :disabled="!userCanEdit"
              @change="tempContact.reloadCoordinates = true"
            ></v-text-field>
            <v-text-field
              v-model="tempContact.city"
              label="City"
              :readonly="!userCanEdit"
              :disabled="!userCanEdit"
              @change="tempContact.reloadCoordinates = true"
            ></v-text-field>
            <v-text-field
              type="text"
              v-model="tempContact.postalCode"
              counter
              :readonly="!userCanEdit"
              :disabled="!userCanEdit"
              maxlength="10"
              @keypress="isNumberOrHyphen"
              :rules="postalCodeRules"
              @change="tempContact.reloadCoordinates = true"
              label="Postal Code"
            ></v-text-field>
            <v-autocomplete v-model="tempContact.companyStateId"
                            :items="states"
                            label="State"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            :loading="statesLoading"
                            item-text="state"
                            item-value="id"
                            @input="tempContact.reloadCoordinates = true"
            ></v-autocomplete>
            <v-select v-model="tempContact.companyCountryId"
                      :items="countries"
                      label="Country"
                      :readonly="!userCanEdit"
                      :disabled="!userCanEdit"
                      :loading="countriesLoading"
                      @input="tempContact.reloadCoordinates = true"
                      item-text="country"
                      item-value="id"
            ></v-select>
            <v-text-field text
                          label="Phone"
                          placeholder=" "
                          :rules="contactPhoneRule"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          v-model="tempContact.phone"></v-text-field>
            <v-text-field text
                          label="Mobile"
                          placeholder=" "
                          :rules="contactPhoneRule"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          v-model="tempContact.mobile"></v-text-field>
            <v-text-field text
                          label="E-Mail"
                          id="qa-email-field"
                          placeholder=" "
                          :rules="emailRules"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          v-model="tempContact.email"></v-text-field>
          </div>
          <v-autocomplete v-model="tempContact.owner"
                          :readonly="contactOwnerFieldIsReadOnly()"
                          :disabled="contactOwnerFieldIsReadOnly()"
                          :items="availableOwners"
                          :loading="ownersLoading"
                          label="Contact Owner"
                          clearable
                          item-text="fullName"
                          return-object
                          autocomplete="off">
          </v-autocomplete>
        </v-card-text>
      </v-form>
      <template v-slot:yes>Save</template>
    </ConfirmationDialog>
    <!-- modal for deleting contact -->
    <ConfirmationDialog :open-dialog="deleteContactConfirm" @confirm="deleteContact" @close-dialog="deleteContactConfirm = false">
      <span class="bold error-text">WARNING:</span> This cannot be undone. Are you sure you want to delete this contact?
    </ConfirmationDialog>
    <!--    end dialogs -->
    <ThreeColumnLayout :header-text="contact.fullName"
                       :auto-overflow-left="false">
      <template v-slot:back-btn>
        <v-btn fab text small color="primary" class="mr-2" @click="goToPath('/contacts')">
          <v-icon>mdi-view-list</v-icon>
        </v-btn>
      </template>
      <template v-slot:header-btn>
        <div class="mt-3">
          <v-btn text color="primary" v-if="userCanDelete" @click="deleteContactConfirm = true"><v-icon>delete</v-icon></v-btn>
        </div>
      </template>
      <template v-slot:left-column>
        <div v-if="!$store.state.project.leftSideSplit && contact && contact.id"
             class="px-2 height-one-hunned overflow-y-auto">
            <PageOverview :page-name="Contact"
                          :show-edit-btn="contact && contact.id && (userCanEdit || !contactOwnerFieldIsReadOnly())"
                          @clickEdit="[getStatesAndCountries(), getOwners(), tempContact = cloneDeep(contact), showEditModal = true]"
                          :details="overviewDetails"
                          :owner="contact.owner"
            ></PageOverview>
          <v-divider class="mt-4"></v-divider>
          <v-toolbar color="transparent" flat>
            <v-toolbar-title class="albatross-header-3">Associated Projects</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <v-menu
                v-if="$store.getters.userHasFeatureAccessLevel('PROJECTS', 'ADD')"
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
                        <v-btn v-on="{ ...menu }"
                               text
                               x-small
                               :disabled="(!contact.firstName && !contact.lastName) || !contact.owner || !contact.owner.userId"
                               class="white--text"
                               id="qa-create-project-button"
                               @click="getAvailableProcesses">
                          <v-icon>add</v-icon>
                        </v-btn>
                      </div>
                    </template>
                    <span v-if="!contact.firstName && !contact.lastName">Contact Requires First or Last Name</span>
                    <span v-else-if="!contact.owner || !contact.owner.userId">Requires Owner</span>
                  </v-tooltip>
                </template>
                <v-card class="pa-5">
                  Select a process to be used
                  <v-select v-model="selectedProcess"
                            :items="availableProcesses"
                            label="Process"
                            id="qa-process-selector"
                            :loading="processesLoading"
                            placeholder="Select one..."
                            item-text="processName"
                            return-object
                            class="mt-2 qa-process-selector"
                  ></v-select>
                  <v-btn text :disabled="!selectedProcess" @click="convertToCustomer" id="qa-add-project-button">
                    Add Project
                  </v-btn>
                </v-card>
              </v-menu>
            </v-toolbar-items>
          </v-toolbar>
          <div class="mx-2">
            <v-card flat v-for="p in contact.projects"
                    class="project-button albatross-body-1"
                    @click="goToPath(`/project/${p.id}/details`)">
              {{ p.projectName }}
              <div :class="getStatusClass(p.projectStatusTypeId)">{{ p.projectStatusType }}</div>
              <!--            <div class="ps-owner albatross-body-2" v-if="ps && ps.owner && ps.owner.fullName">{{ ps.owner.fullName }}</div>-->
              <div class="albatross-body-3"
                   v-if="$store.getters.userHasFeatureAccessLevel('PROJECTS', 'ADMIN')">
                {{ p.id }}
              </div>
            </v-card>
          </div>
        </div>
      </template>
      <template v-slot:main-column>
        <div v-if="contact && contact.id && !fieldsLoading" style="overflow-x: hidden">
          <v-toolbar flat color="secondary" class="cfg-name-header fixed-toolbar toolbar-z-index-override">
            <v-toolbar-title class="albatross-header-3">
              Contact Summary
            </v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <v-btn text color="primary" @click="setSplitColumnValue()" class="px-0">
                <v-icon v-if="!$store.state.project.manualColumnSplit" class="px-0">mdi-format-columns</v-icon>
                <v-icon v-else class="px-0">mdi-format-align-justify</v-icon>
              </v-btn>
              <div>
                <v-btn color="primary"
                       class="white--text mt-3"
                       v-if="userCanEdit"
                       :loading="fieldsLoading"
                       :disabled="fieldsSaving"
                       @click="validateFields(true)">
                  Save Fields
                </v-btn>
              </div>
            </v-toolbar-items>
          </v-toolbar>
          <v-row class="px-5">
            <v-col cols="12" class="text-left py-0 px-0">
              <!--    process field groups-->
              <v-form ref="contactForm">
                <v-col
                  class="pt-0"
                  v-for="(cfg, index) in customFieldGroups"
                  :key="index"
                >
                  <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar" dense>
                    <v-toolbar-title>
                      {{ cfg.groupName }}
                    </v-toolbar-title>
                    <v-spacer></v-spacer>
                    <v-toolbar-items>
                    </v-toolbar-items>
                  </v-toolbar>

                  <v-card class="px-4 square-card" v-if="cfg.customFieldValues && cfg.customFieldValues.length > 0">
                    <v-row>
                      <v-col :cols="$store.state.project.manualColumnSplit ? 6 : 12" class="pb-0 pt-2">
                        <CustomValueInput v-for="(cf, idx) in getCustomFieldValuesToDisplay(cfg.customFieldValues, 1)"
                                          :key="idx"
                                          :required="cf.required"
                                          :readonly="getReadOnly(cf)"
                                          :callback="populateDirtyCfvs"
                                          :field="cf"
                                          :show-field-name="false"></CustomValueInput>
                      </v-col>
                      <v-col cols="6" v-if="$store.state.project.manualColumnSplit" class="pb-0 pt-2">
                        <CustomValueInput v-for="(cf, idx) in getCustomFieldValuesToDisplay(cfg.customFieldValues, 2)"
                                          :key="idx"
                                          :required="cf.required"
                                          :readonly="getReadOnly(cf)"
                                          :callback="populateDirtyCfvs"
                                          :field="cf"
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
      </template>
      <template v-slot:right-column>
        <ProjectActivity v-if="!contactLoading && contactId !== 0"
                         :contact-id="contactId"
                         :show-sms-tab="false"></ProjectActivity>
      </template>
    </ThreeColumnLayout>
  </div>

</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import ProjectActivity from '@/views/flow/project/ProjectActivity'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import ThreeColumnLayout from '@/views/ThreeColumnLayout'
import {ProjectMutations} from "@/stores/ProjectStore";
import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  isNumberOrHyphen,
  putRequest,
  postRequest,
  formatPhoneNumber,
  getRequestWithParams,
  getSnackbar, logError
} from '@/helpers/helpers'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import {getCompanyStates} from '@/services/stateService'
import {getCountries} from '@/services/countryService'
import {getCustomFieldReadOnly} from '@/services/customFieldService'
import constants from '@/helpers/constants'
import cloneDeep from 'lodash.clonedeep'
import {getStatusClass} from "@/services/processStepStatusTypeService";
import SpinnerInline from '@/components/SpinnerInline'
import ConfirmationDialog from "../../../ConfirmationDialog";
import PageOverview from "../PageOverview";

export default {
  name: 'Contact',
  components: {
    PageOverview,
    ConfirmationDialog,
    CustomValueInput,
    DatetimePickerInput,
    ThreeColumnLayout,
    ProjectActivity,
    SpinnerInline
  },
  watch: {},
  data() {
    return {
      snackbar: {},
      states: [],
      countries: [],
      showEditModal: false,
      contact: {},
      getStatusClass,
      formatPhoneNumber,
      postalCodeRules: constants.POSTAL_CODE_RULES,
      cityRules: constants.CITY_RULES,
      emailRules: constants.EMAIL_RULES,
      addressRules: constants.ADDRESS_RULES,
      nameRules: constants.NAME_RULES,
      nameRequiredRules: constants.NAME_REQUIRED_RULES,
      contactPhoneRule: [
        () => ((this.contact.phone != null && this.contact.phone !== '') || (this.contact.mobile != null && this.contact.mobile !== '')) || "Phone or Mobile is required",
        v => (!v || (v && (v.length <= 20))) || 'Must be 20 characters or less',
        v => (!v || (/^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$/.test(v))) || "Please reformat the Phone field with a valid phone number",
        v => ((!v || (this.contact.phone !== this.contact.mobile))) || 'Phone and Mobile Cannot be the same',
      ],
      deleteContactConfirm: false,
      isNumberOrHyphen,
      contactLoading: true,
      customFieldGroups: [],
      unsavedFieldsModal: false,
      toPath: null,
      navigationOverride: false,
      notes: [],
      cloneDeep,
      fieldsSaving: false,
      fieldsLoading: true,
      hasDirtyNotes: false,
      dirtyCfvs: [],
      dirtySystemFields: false,
      // owners: [],
      availableOwners: [],
      ownersLoading: false,
      statesLoading: false,
      countriesLoading: false,
      tempContact: {},
      contactId: parseInt(this.$route.params.contactId),
      is7oaksAdmin: this.$store.getters.isFullAdmin,
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('CONTACTS', 'EDIT'),
      userCanDelete: this.$store.getters.userHasFeatureAccessLevel('CONTACTS', 'DELETE'),
      companyId: this.$store.state.user.details.companyId,
      timezone: this.$store.state.user.details.timezone?.value,
      selectedProcess: null,
      processesLoading: true,
      availableProcesses: [],
    }
  },
  computed: {
    addressFieldRequired() {
      //this logic seems backwards but it is just the way rules work
      //if one address field is filled in then all of them are required
      return {
        street: [!(!this.contact.street1 && (Boolean(this.contact.city) || Boolean(this.contact.companyStateId) || Boolean(this.contact.companyCountryId) || Boolean(this.contact.postalCode))) || "Required when other address fields are populated"],
        city: [!(!this.contact.city && (Boolean(this.contact.street1) || Boolean(this.contact.companyStateId) || Boolean(this.contact.companyCountryId) || Boolean(this.contact.postalCode))) || "Required when other address fields are populated"],
        state: [!(!this.contact.companyStateId && (Boolean(this.contact.street1) || Boolean(this.contact.city) || Boolean(this.contact.companyCountryId) || Boolean(this.contact.postalCode))) || "Required when other address fields are populated"],
        country: [!(!this.contact.companyCountryId && (Boolean(this.contact.street1) || Boolean(this.contact.city) || Boolean(this.contact.companyStateId) || Boolean(this.contact.postalCode))) || "Required when other address fields are populated"],
        zip: [!(!this.contact.postalCode && (Boolean(this.contact.street1) || Boolean(this.contact.city) || Boolean(this.contact.companyStateId) || Boolean(this.contact.companyCountryId))) || "Required when other address fields are populated"]
      }
    },
    overviewDetails (){
      return [
        {
          label: 'Date Created',
          value: this.$filters.formatDate(this.contact.dateCreated, 'date')
        },
        {
          label: 'Address',
          value: `${this.contact.street1} \n ${this.contact.city}, ${this.contact.state} ${this.contact.postalCode}`
        },
        {
          label: 'Phone',
          value: formatPhoneNumber(this.contact.phone)
        },
        {
          label: 'Mobile',
          value: formatPhoneNumber(this.contact.mobile)
        },
        {
          label: 'Email',
          value: this.contact.email
        }
      ]
    }
  },
  async created() {
    console.log('routed param',this.$route.params.contactId)
    let requests = [this.getContact(), this.getCustomFieldGroups()]
    await Promise.all(requests).then(async () => {
      this.fieldsLoading = false
    })
  },
  beforeRouteLeave(to, from, next) {
    // called when the route that renders this component is about to
    // be navigated away from.
    // has access to `this` component instance.
    this.hasDirtyNotes = this.$refs.notes?.hasUnsavedNotes()
    if (this.navigationOverride || (this.dirtyCfvs.length === 0 && !this.dirtySystemFields && !this.hasDirtyNotes)) {
      //navigationOverride gets set to true if they click "Yes" to continue. if you don't override then it just hits the else again before navigating
      next()
    } else {
      this.toPath = to.path
      this.unsavedFieldsModal = true
    }
  },
  methods: {
    setSplitColumnValue() {
      //flip the flag
      this.$store.commit(ProjectMutations.FLIP_MANUAL_COLUMN_SPLIT)
    },
    getCustomFieldValuesToDisplay(values, columnNum) {
      if (this.$store.state.project.manualColumnSplit) {
        return values.filter(function (element, index, values) {
          return (index % 2 === (columnNum === 1 ? 0 : 1));
        });
      } else {
        return values
      }
    },
    collapseSide(side) {
      if (side === 'left') {
        this.$store.commit(ProjectMutations.LEFT_SIDE_COLLAPSE)
      } else {
        this.$store.commit(ProjectMutations.RIGHT_SIDE_COLLAPSE)
      }
    },
    getStatesAndCountries: function () {
      // only load countries and states if they try to edit the project address and they haven't already been loaded
      if (this.states.length === 0 || this.countries.length === 0) {
        this.getCompanyStates()
        this.getCountries()
      }
    },
    async validateForm() {
      if (this.$refs.contactEditForm.validate()) {
        //these could be combined - just dont have time atm
        this.saveContactAddressFields()
        this.updateOwner()

        //set project values if they hit save
        this.contact = cloneDeep(this.tempContact)
        this.showEditModal = false
      }
    },
    saveContactAddressFields: async function () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //temp contact holds all the changes in case they cancel. use those values
        const {status} = await postRequest(`/contact`, this.tempContact)
        this.snackbar = getSnackbar('SUCCESS', 'Contact Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    contactOwnerFieldIsReadOnly() {
      if (this.is7oaksAdmin) {
        return false
      } else if (this.contact.ownerReadOnlyWhiteListedPositions?.length > 0) {
        return !this.$store.getters.userHasAnyPosition(this.contact.ownerReadOnlyWhiteListedPositions?.map(wlp => wlp.positionId))
      } else {
        return this.contact.ownerReadOnly
      }
    },
    goToPath(path) {
      this.$router.push(path)
    },
    async validateFields(saveContact) {
      let valid = this.$refs.contactForm?.validate()
      if (valid && saveContact) {
        this.fieldsSaving = true
        await this.saveContact()
        this.fieldsSaving = false
      } else {
        this.snackbar = getSnackbar('ERROR', 'Missing Required Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    contactOwnerIsReadOnly() {
      if (this.contact.ownerReadOnlyWhiteListedPositions?.length > 0) {
        return !this.$store.getters.userHasAnyPosition(this.contact.ownerReadOnlyWhiteListedPositions?.map(wlp => wlp.positionId))
      } else {
        return this.contact.ownerReadOnly
      }
    },
    async saveContact() {
      if (this.dirtyCfvs.length > 0) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          //we no longer save the contact system fields here
          await this.saveCustomFieldValues()

          try {
            // Save BlueRaven Solar Contacts to Genesys
            if (this.companyId === 3) {
              await putRequest(`/genesys/contact/${this.contact.id}`, this.dirtyCfvs, 'blueraven')
            }
          } catch (e) {
            console.error('*** ERROR ***', e)
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Contact')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.fieldsSaving = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async saveCustomFieldValues() {
      try {
        // save dirty custom field values
        const {data, status} = await postRequest(`/customFieldValues/contact/${this.contact.id}`, this.dirtyCfvs)
        this.dirtyCfvs = []
        this.addressChanged = false
        this.customFieldGroups = data
        this.fieldsSaving = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Contact')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.fieldsSaving = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    populateDirtyCfvs(field) {
      let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
      if (!match) {
        this.dirtyCfvs.push(field)
      }
    },
    async getCustomFieldGroups() {
      try {
        const {data, status} = await getRequestWithParams(`/customFieldValues/contact/${this.contactId}`)
        this.customFieldGroups = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getContact() {
      try {
        const {data, status} = await getRequest(`/contact/${this.contactId}`)
        this.contact = data
        this.contactLoading = false
        window.document.title = `Contact - ${this.contact.fullName}`
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.contactLoading = false
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Contact')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getOwners() {
      try {
        let params = {
          contactId: parseInt(this.contactId)
        }
        const {data, status} = await getRequestWithParams(`/contact/owners`, {params})
        this.availableOwners = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Owners')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async updateOwner() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //we use tempContact to save values in case they cancel then it repopulates at the end
        const {status} = await putRequest(`/contact/${this.contactId}/updateOwner`, this.tempContact.owner || {userPositionId: null})
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        this.contact.owner = {}
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Owner')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getAvailableProcesses() {
      try {
        this.processesLoading = true
        let params = {
          contactId: parseInt(this.contactId)
        }
        const {data, status} = await getRequestWithParams(`/processes`, {params})
        this.availableProcesses = data
        this.selectedProcess = data?.length === 1 ? data[0] : {}
        this.processesLoading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Available Processes')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async convertToCustomer() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await putRequest(`/contact/${this.contact.id}/convert`, this.selectedProcess)
        this.snackbar = getSnackbar('SUCCESS', 'Successfully Converted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$router.push({name: 'projectDetails', params: {projectId: data.id}})
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Converting Contact')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCompanyStates() {
      try {
        const {data, status} = await getCompanyStates()
        this.states = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getCountries() {
      try {
        const {data, status} = await getCountries(parseInt(this.companyId))
        this.countries = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Countries')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    getReadOnly: function (field) {
      let fieldReadOnly = false
      if (null != field) {
        fieldReadOnly = getCustomFieldReadOnly(this.$store, field)
      }
      return !this.userCanEdit || fieldReadOnly
    },
    async deleteContact() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await deleteRequest(`/contact/${this.contact.id}`)
        this.snackbar = getSnackbar('SUCCESS', 'Contact Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$router.push('/contacts')
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error deleting contact')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
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

.contact-split-container {
  height: calc(100% - 50px);
  max-width: 100%;
  width: 100%;
  margin-right: 0 !important;
  margin-left: 0 !important;
}

.detail-label {
  font-size: 12px;
  color: var(--v-grey-darken2);
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

</style>

