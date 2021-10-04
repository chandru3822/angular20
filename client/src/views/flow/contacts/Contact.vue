<template>
  <v-container class="pt-0" v-if="contact && contact.id">
    <v-dialog width="500" v-model="unsavedFieldsModal">
      <v-card>
        <v-card-title
          class="headline grey lighten-2"
          primary-title
        >
          Confirm
        </v-card-title>

        <v-card-text class="pt-4">
          You have unsaved {{getDirtyText()}}. <br/>
          Are you sure you want to continue without saving?
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            @click="unsavedFieldsModal = false">
            No
          </v-btn>
          <v-btn
            color="primaryCustom"
            text
            @click="[navigationOverride = true, goToPath(toPath)]">
            Yes
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-row class="contact-header elevation-0">
      <v-col cols="6" class="text-left pb-2">
        <v-breadcrumbs :items="breadcrumbs" class="pl-0 pt-0 pb-2"></v-breadcrumbs>
        <div class="contact-title">
          {{contact.fullName}}
          <v-menu
              v-if="$store.getters.userHasFeatureAccessLevel('PROJECTS', 'ADD')"
              bottom
              offset-y
              :close-on-content-click="false"
          >
            <template v-slot:activator="{ on: menu }">
              <v-tooltip top>
                <template v-slot:activator="{ on: tooltip }">
                  <div v-on="{ ...tooltip }" class="d-inline-block">
                    <v-btn v-on="{ ...menu }"
                           color="primaryCustom"
                           :disabled="(!contact.firstName && !contact.lastName) || !contact.owner || !contact.owner.userId"
                           class="white--text"
                           id="qa-create-project-button"
                           @click="getAvailableProcesses">
                      Add Project
                    </v-btn>
                  </div>
                </template>
                <span v-if="!contact.firstName && !contact.lastName">Contact Requires First or Last Name</span>
                <span v-else-if="!contact.owner || !contact.owner.userId">Requires Owner</span>
              </v-tooltip>
            </template>
            <v-card class="pa-5">
              Select a process to be used
              <v-select attach v-model="selectedProcess"
                        :items="availableProcesses"
                        label="Process"
                        id="qa-process-selector"
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
        </div>
        <div class="contact-subtitle">
          {{contact.street1}} - {{contact.city}}, {{contact.state}}
        </div>
      </v-col>
      <v-col cols="4" class="contact-owner pb-2">
        <div class="d-inline-block mr-4" v-if="contact.companyId !== this.companyId">
          <v-avatar
            :tile="false"
            :size="25"
            color="#D6D6D6"
            class="account-img mr-2"
          >
            <v-icon color="white" size="20">mdi-office-building</v-icon>
          </v-avatar>
          <span>{{contact.companyName}}</span><br/>
          <span class="project-company-subheader">Company</span>
        </div>
        <div v-if="!changeOwner || !userCanEdit" class="d-inline-block">
          <div v-if="contact.owner">
            <v-avatar
                :tile="false"
                :size="25"
                color="grey lighten-4"
                class="account-img mr-2"
            >
              <img name="accountImg" src="../../../assets/flow/user_img_placeholder.png">
            </v-avatar>
            {{contact.owner.fullName}}<br/>
            {{contact.owner.position}}
          </div>
        </div>
        <div v-if="changeOwner && userCanEdit">
          <v-autocomplete v-model="contact.owner"
                    :items="owners"
                    label="Select Owner"
                    item-text="fullName"
                    return-object
                    autocomplete="off"
                    @change="updateOwner"
                          attach
          >
          </v-autocomplete>
        </div>
        <v-btn text x-small class="change-owner-button" v-if="userCanEdit && !contactOwnerIsReadOnly()"
               @click="changeOwner = !changeOwner">
          <span v-if="changeOwner">cancel</span>
          <span v-else-if="contact.owner && contact.owner.userId">change</span>
          <span v-else style="font-size: 15px;">add owner</span>
        </v-btn>
      </v-col>
      <v-col cols="2" class="contact-owner pb-2">
        Associated Projects<br/>
        <div v-for="p in contact.projects" :key="p.id">
          <router-link v-if="$store.getters.userHasFeature('PROJECTS')" :to="`/project/${p.id}/details`">{{p.projectName}} <span v-if="contact.projects && contact.projects.length > 1">- {{p.id}}</span></router-link>
          <span v-else>{{p.projectName}}</span>
        </div>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12" md="6" class="text-left">
        <div>
          <v-toolbar color="transparent" class="elevation-0">
            <v-toolbar-title>Summary</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <v-btn text v-if="userCanEdit"
                     :disabled="fieldsSaving"
                     @click="validate(true)">Save</v-btn>
            </v-toolbar-items>
          </v-toolbar>
          <v-card class="pa-4">
            <v-form ref="addressForm">
              <v-text-field text
                            label="First Name"
                            id="qa-first-name-field"
                            placeholder=" "
                            :rules="nameRequiredRules"
                            @change="dirtySystemFields = true"
                            :readonly="!userCanEdit"
                            v-model="contact.firstName"></v-text-field>
              <v-text-field text
                            label="Last Name"
                            id="qa-last-name-field"
                            placeholder=" "
                            :rules="nameRequiredRules"
                            @change="dirtySystemFields = true"
                            :readonly="!userCanEdit"
                            v-model="contact.lastName"></v-text-field>
              <v-text-field text
                            label="Address"
                            id="qa-address-field"
                            placeholder=" "
                            :rules="addressRules"
                            :readonly="!userCanEdit"
                            @change="[addressChanged = true, dirtySystemFields = true]"
                            v-model="contact.street1"></v-text-field>
              <v-text-field text
                            label="City"
                            id="qa-city-field"
                            placeholder=" "
                            :rules="cityRules"
                            @change="[addressChanged = true, dirtySystemFields = true]"
                            :readonly="!userCanEdit"
                            v-model="contact.city"></v-text-field>
              <v-select attach v-model="contact.companyStateId"
                        :items="states"
                        label="State"
                        id="qa-state-field"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        @change="[addressChanged = true, dirtySystemFields = true]"
                        item-text="state"
                        item-value="id"
              ></v-select>
              <v-select attach v-model="contact.companyCountryId"
                        :items="countries"
                        label="Country"
                        id="qa-country-field"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        @change="[addressChanged = true, dirtySystemFields = true]"
                        item-text="country"
                        item-value="id"
              ></v-select>
              <v-text-field text
                            label="Zip"
                            type="text"
                            id="qa-zip-field"
                            placeholder=" "
                            @change="[addressChanged = true, dirtySystemFields = true]"
                            :readonly="!userCanEdit"
                            counter
                            @keypress="isNumberOrHyphen"
                            :rules="postalCodeRules"
                            maxlength="10"
                            v-model="contact.postalCode"></v-text-field>
              <v-text-field text
                            label="Phone"
                            id="qa-phone-field"
                            placeholder=" "
                            :rules="contactPhoneRule"
                            @change="dirtySystemFields = true"
                            :readonly="!userCanEdit"
                            v-model="contact.phone"></v-text-field>
              <v-text-field text
                            label="Mobile"
                            id="qa-mobile-field"
                            :readonly="!userCanEdit"
                            @change="dirtySystemFields = true"
                            :rules="contactPhoneRule"
                            placeholder=" "
                            v-model="contact.mobile"></v-text-field>
              <v-text-field text
                            label="E-Mail"
                            id="qa-email-field"
                            placeholder=" "
                            @change="dirtySystemFields = true"
                            :readonly="!userCanEdit"
                            v-model="contact.email"></v-text-field>
            </v-form>
            <DatetimePickerInput
              v-model="contact.dateCreated"
              :timezone="timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="Created Date"
              :readonly="true"
            />
            <v-dialog
              v-if="userIsAdmin"
              v-model="deleteContactConfirm"
              width="500">
              <template #activator="{ on }">
                <v-btn color="primaryCustom" dark class="mr-2 white--text" v-on="on" id="qa-delete-contact">
                  Delete Contact
                </v-btn>
              </template>
              <v-card>
                <v-card-title
                  class="headline grey lighten-2"
                  primary-title>
                  Confirm
                </v-card-title>

                <v-card-text class="pt-4">
                  <span class="bold error-text">WARNING: This cannot be undone. Are you sure you want to delete this contact?</span>
                </v-card-text>

                <v-divider></v-divider>

                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn
                    @click="deleteContactConfirm = false" id="qa-delete-contact-no">
                    No
                  </v-btn>
                  <v-btn
                    color="primaryCustom"
                    text
                    @click="deleteContact"
                    id="qa-delete-contact-yes">
                    Yes
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-card>
        </div>
        <div class="mt-4" v-for="(cfg, index) in customFieldGroups" :key="index">
          <v-toolbar color="transparent" class="elevation-0">
            <v-toolbar-title>{{cfg.groupName}}</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
<!--              <v-btn text @click="saveContact">Save</v-btn>-->
            </v-toolbar-items>
          </v-toolbar>
          <v-card class="pa-4">
            <CustomValueInput v-for="(cf, idx) in cfg.customFieldValues"
                              :key="idx"
                              :readonly="getReadOnly(cf)"
                              :callback="populateDirtyCfvs"
                              :field="cf"></CustomValueInput>
          </v-card>
        </div>
      </v-col>
      <v-col cols="12" md="6" class="text-left pa-0">
        <NotesAndActivity ref="notes" :showNotes="true" :showActivity="false"
                          :notes="notes" :primaryId="parseInt(contactId)"
                          type="Contact"
        ></NotesAndActivity>

        <Attachments :object-type-id="2" :contact-id="contactId" />
      </v-col>
    </v-row>

  </v-container>
  <v-row align="center" justify="center" v-else-if="!contactLoading">
    <v-col cols="12" sm="8">
      <v-card color="secondaryMaster" class="elevation-12 pb-5">
        <v-toolbar dark color="red">
          <v-toolbar-title>Error</v-toolbar-title>
        </v-toolbar>
        <v-card-text class="login-card-text">
          This contact either doesn't exist or you don't have access to it in this context.
        </v-card-text>
        <v-card-actions class="justify-center">
          <v-btn to="/contacts">Click here to go back to Contacts</v-btn>
        </v-card-actions>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'

import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import NotesAndActivity from '@/views/flow/components/NotesAndActivity.vue'
import {getRequest, deleteRequest, isNumberOrHyphen, putRequest, postRequest, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import {getCompanyStates} from '@/services/stateService'
import {getCountries} from '@/services/countryService'
import {getCustomFieldReadOnly} from '@/services/customFieldService'
import constants from '@/helpers/constants'
import Attachments from '@/views/flow/components/Attachments'

export default {
  name: 'Contact',
  components: {
    CustomValueInput,
    NotesAndActivity,
    DatetimePickerInput,
    Attachments
  },
  watch: {
    contact: {
      // This will let Vue know to look inside the array
      deep: true,

      // We have to move our method to a handler field
      handler() {
        this.validate(false)
      }
    }
  },
  data () {
    return {
      snackbar: {},
      states: [],
      countries: [],
      contact: {},
      postalCodeRules: constants.POSTAL_CODE_RULES,
      cityRules: constants.CITY_RULES,
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
      addressChanged: false,
      isNumberOrHyphen,
      contactLoading: true,
      customFieldGroups: [],
      unsavedFieldsModal: false,
      toPath: null,
      navigationOverride: false,
      notes: [],
      fieldsSaving: false,
      hasDirtyNotes: false,
      dirtyCfvs: [],
      dirtySystemFields: false,
      owners: [],
      contactId: parseInt(this.$route.params.id),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('CONTACTS', 'EDIT'),
      userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('CONTACTS', 'ADMIN'),
      companyId: this.$store.state.user.details.companyId,
      timezone: this.$store.state.user.details.timezone?.value,
      changeOwner: false,
      selectedProcess: null,
      availableProcesses: [],
      breadcrumbs: [
        {
          text: 'Back to Contacts',
          disabled: false,
          exact: true,
          to: `/contacts`
        },
      ]
    }
  },
  created () {
    this.getContact()
    this.getCompanyStates()
    this.getCountries()
    this.getOwners()
    this.getCustomFieldGroups()
    this.getNotes()
  },
  beforeRouteLeave (to, from, next) {
    // called when the route that renders this component is about to
    // be navigated away from.
    // has access to `this` component instance.
    this.hasDirtyNotes = this.$refs.notes.hasUnsavedNotes()
    if (this.navigationOverride || (this.dirtyCfvs.length === 0 && !this.dirtySystemFields && !this.hasDirtyNotes)) {
      //navigationOverride gets set to true if they click "Yes" to continue. if you don't override then it just hits the else again before navigating
      next()
    } else {
      this.toPath = to.path
      this.unsavedFieldsModal = true
    }
  },
  methods: {
    getDirtyText() {
      return this.hasDirtyNotes && (this.dirtyCfvs.length > 0 || this.dirtySystemFields) ?
        'fields and notes' : this.hasDirtyNotes ? 'notes' : 'fields'
    },
    goToPath(path) {
      this.$router.push(path)
    },
    async validate (saveContact) {
      let valid = this.$refs.addressForm?.validate()
      if (valid && saveContact) {
        this.fieldsSaving = false;
        await this.saveContact()
        this.fieldsSaving = false;
      }
    },
    contactOwnerIsReadOnly() {
      if(this.contact.ownerReadOnlyWhiteListedPositions?.length > 0) {
        return !this.$store.getters.userHasAnyPosition(this.contact.ownerReadOnlyWhiteListedPositions?.map(wlp => wlp.positionId))
      } else {
        return this.contact.ownerReadOnly
      }
    },
    async saveContact() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
        // save contact - tell server if address changed or not so we know whether to reload lat/long
          this.contact.reloadCoordinates = this.addressChanged
          const {data} = await postRequest(`/contact`, this.contact)
          this.addressChanged = false
          this.contact.reloadCoordinates = false
          this.contact.projects = data.projects
          this.dirtySystemFields = false
          await this.saveCustomFieldValues()

          try {
            // Save BlueRaven Solar Contacts to Genesys
            if (this.companyId === 3) {
              await putRequest(`/genesys/contact/${data.id}`, this.dirtyCfvs, 'blueraven')
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
    },
    async saveCustomFieldValues () {
      try {
        // save dirty custom field values
        const {data} = await postRequest(`/customFieldValues/contact/${this.contact.id}`, this.dirtyCfvs)
        this.dirtyCfvs = []
        this.addressChanged = false
        this.customFieldGroups = data
        this.fieldsSaving = false
        this.$store.commit(AppMutations.SET_LOADING, false)
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
      if(!match) {
        this.dirtyCfvs.push(field)
      }
    },
    async getCustomFieldGroups() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequestWithParams(`/customFieldValues/contact/${this.contactId}`)
        this.customFieldGroups = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getContact () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/contact/${this.contactId}`)
        this.contact = data
        this.contactLoading = false
        window.document.title = `Contact - ${this.contact.fullName}`
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.contactLoading = false
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Contact')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getOwners () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {
          contactId: parseInt(this.contactId)
        }
        const {data} = await getRequestWithParams(`/contact/owners`, { params })
        this.owners = data

        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Owners')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getNotes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequestWithParams(`/note/getContactNotes`, { params: {
            primaryId: this.contactId
          }})
        this.notes = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Notes')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateOwner() {
      this.changeOwner = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await putRequest(`/contact/${this.contact.id}/updateOwner`, this.contact.owner)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        this.contact.owner = {}
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Owner')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getAvailableProcesses () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {
          contactId: parseInt(this.contactId)
        }
        const {data} = await getRequestWithParams(`/processes`, {params})
        this.availableProcesses = data
        this.selectedProcess = data?.length === 1 ? data[0] : {}

        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Available Processes')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async convertToCustomer() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await putRequest(`/contact/${this.contact.id}/convert`, this.selectedProcess)
        this.snackbar = getSnackbar('SUCCESS', 'Successfully Converted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$router.push({name: 'projectDetails', params: {projectId: data.id}})
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Converting Contact')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCompanyStates () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getCompanyStates()
        this.states = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCountries () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getCountries(parseInt(this.companyId))
        this.countries = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Countries')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getReadOnly: function (field) {
      return !this.userCanEdit || getCustomFieldReadOnly(this.$store, field)
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
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
}
</script>

<style lang="scss" scoped>
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
</style>

