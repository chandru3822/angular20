<template>
  <ThreeColumnLayout :header-text="contact.fullName" :show-header-btn="false">
    <template v-slot:left-column>
      <div>
        contact edit fields will go here
      </div>
    </template>
    <template v-slot:main-column>
      custom fields will go here
    </template>
    <slot  name="right-column">
      <ProjectActivity v-if="!contactLoading && contactId !== 0"
                       @openRight="$store.state.project.rightSideSplit = false"></ProjectActivity>
    </slot>
  </ThreeColumnLayout>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import ProjectActivity from '@/views/flow/project/ProjectActivity'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import ThreeColumnLayout from '@/views/ThreeColumnLayout'
// import NotesAndActivityContent from '@/views/flow/components/NotesAndActivityContent.vue'
import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  isNumberOrHyphen,
  putRequest,
  postRequest,
  getRequestWithParams,
  getSnackbar
} from '@/helpers/helpers'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import {getCompanyStates} from '@/services/stateService'
import {getCountries} from '@/services/countryService'
import {getCustomFieldReadOnly} from '@/services/customFieldService'
import constants from '@/helpers/constants'
import cloneDeep from 'lodash.clonedeep'
// import Attachments from '@/views/flow/components/Attachments'

export default {
  name: 'Contact',
  components: {
    CustomValueInput,
    // NotesAndActivityContent,
    DatetimePickerInput,
    ThreeColumnLayout,
    ProjectActivity
    // Attachments
  },
  watch: {},
  data() {
    return {
      snackbar: {},
      states: [],
      countries: [],
      contact: {},
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
      addressChanged: false,
      isNumberOrHyphen,
      contactLoading: true,
      customFieldGroups: [],
      unsavedFieldsModal: false,
      toPath: null,
      navigationOverride: false,
      notes: [],
      fieldsSaving: false,
      fieldsLoading: true,
      hasDirtyNotes: false,
      dirtyCfvs: [],
      dirtySystemFields: false,
      owners: [],
      availableOwners: [],
      ownersLoading: false,
      statesLoading: false,
      countriesLoading: false,
      tempContact: {},
      showEditContactModal: false,
      contactId: parseInt(this.$route.params.contactId),
      is7oaksAdmin: this.$store.getters.isFullAdmin,
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('CONTACTS', 'EDIT'),
      userCanDelete: this.$store.getters.userHasFeatureAccessLevel('CONTACTS', 'DELETE'),
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
    }
  },
  async created() {
    let requests = [this.getContact(), this.getCompanyStates(), this.getCountries(), this.getOwners(), this.getCustomFieldGroups(), this.getNotes()]
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
    async validateForm() {
      if (this.$refs.contactEditForm.validate()) {
        //these could be combined - just dont have time atm
        // this.saveProjectAddressFields()
        // this.updateOwner()
        //have to wait for this one to complete or it doesn't have the right values to display fresh ones
        // await this.updateStatus()
        //set project values if they hit save
        this.contact = cloneDeep(this.tempContact)
        this.showEditProjectModal = false
      }
    },
    contactOwnerFieldIsReadOnly() {
      if(this.is7oaksAdmin) {
        return false
      } else if (this.contact.ownerReadOnlyWhiteListedPositions?.length > 0) {
        return !this.$store.getters.userHasAnyPosition(this.contact.ownerReadOnlyWhiteListedPositions?.map(wlp => wlp.positionId))
      } else {
        return this.contact.ownerReadOnly
      }
    },
    getDirtyText() {
      return this.hasDirtyNotes && (this.dirtyCfvs.length > 0 || this.dirtySystemFields) ?
        'fields and notes' : this.hasDirtyNotes ? 'notes' : 'fields'
    },
    goToPath(path) {
      this.$router.push(path)
    },
    async validate(saveContact) {
      let valid = this.$refs.contactForm?.validate()
      if (valid && saveContact) {
        this.fieldsSaving = true
        await this.saveContact()
        this.fieldsSaving = false
      }  else {
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
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequestWithParams(`/customFieldValues/contact/${this.contactId}`)
        this.customFieldGroups = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getContact() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/contact/${this.contactId}`)
        this.contact = data
        this.contactLoading = false
        window.document.title = `Contact - ${this.contact.fullName}`
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.contactLoading = false
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Contact')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getOwners() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {
          contactId: parseInt(this.contactId)
        }
        const {data, status} = await getRequestWithParams(`/contact/owners`, {params})
        this.owners = data

        handleHidingGlobalLoader(this, status)
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
        const {data, status} = await getRequestWithParams(`/note/getContactNotes`, {
          params: {
            primaryId: this.contactId
          }
        }, null, [])
        this.notes = data
        handleHidingGlobalLoader(this, status)
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
        const {status} = await putRequest(`/contact/${this.contact.id}/updateOwner`, this.contact.owner)
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
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {
          contactId: parseInt(this.contactId)
        }
        const {data, status} = await getRequestWithParams(`/processes`, {params})
        this.availableProcesses = data
        this.selectedProcess = data?.length === 1 ? data[0] : {}

        handleHidingGlobalLoader(this, status)
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
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getCompanyStates()
        this.states = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCountries() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getCountries(parseInt(this.companyId))
        this.countries = data
        handleHidingGlobalLoader(this, status)
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

</style>

