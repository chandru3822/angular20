<template>
  <v-container class="pt-0" v-if="contact && contact.id">
    <v-row class="contact-header elevation-0">
      <v-col cols="6" class="text-left pb-2">
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
              <v-select v-model="selectedProcess"
                        :items="availableProcesses"
                        label="Process"
                        placeholder="Select one..."
                        item-text="processName"
                        return-object
                        class="mt-2"
              ></v-select>
              <v-btn text :disabled="!selectedProcess" @click="convertToCustomer">
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
        <div v-if="!changeOwner || !userCanEdit">
          <div v-if="contact.owner">
            <v-avatar
                :tile="false"
                :size="25"
                color="grey lighten-4"
                class="account-img mr-2"
            >
              <img name="accountImg" src="../../../assets/user_img_placeholder.png">
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
          >
          </v-autocomplete>
        </div>
        <v-btn text x-small class="change-owner-button" v-if="userCanEdit" @click="changeOwner = !changeOwner">
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
                     @click="saveContact">Save</v-btn>
            </v-toolbar-items>
          </v-toolbar>
          <v-card class="pa-4">
            <v-form ref="address">
              <v-text-field text
                            label="First Name"
                            placeholder=" "
                            :readonly="!userCanEdit"
                            v-model="contact.firstName"></v-text-field>
              <v-text-field text
                            label="Last Name"
                            placeholder=" "
                            :readonly="!userCanEdit"
                            v-model="contact.lastName"></v-text-field>
              <v-text-field text
                            label="Address"
                            placeholder=" "
                            :readonly="!userCanEdit"
                            @change="addressChanged = true"
                            v-model="contact.street1"></v-text-field>
              <v-text-field text
                            label="City"
                            placeholder=" "
                            @change="addressChanged = true"
                            :readonly="!userCanEdit"
                            v-model="contact.city"></v-text-field>
              <v-select v-model="contact.companyStateId"
                        :items="states"
                        label="State"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        @change="addressChanged = true"
                        item-text="state"
                        item-value="id"
              ></v-select>
              <v-text-field text
                            label="Zip"
                            placeholder=" "
                            @change="addressChanged = true"
                            :readonly="!userCanEdit"
                            v-model="contact.postalCode"></v-text-field>
            </v-form>
            <v-text-field text
                          label="Phone"
                          placeholder=" "
                          :readonly="!userCanEdit"
                          v-model="contact.phone"></v-text-field>
            <v-text-field text
                          label="Mobile"
                          :readonly="!userCanEdit"
                          placeholder=" "
                          v-model="contact.mobile"></v-text-field>
            <v-text-field text
                          label="E-Mail"
                          placeholder=" "
                          :readonly="!userCanEdit"
                          v-model="contact.email"></v-text-field>
            <DatetimePickerInput
              v-model="contact.dateCreated"
              :timezone="timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="Created Date"
              :readonly="true"
            />

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
      <v-col cols="12" md="6" class="text-left">
        <NotesAndActivity :showNotes="true" :showActivity="false"
                          :notes="notes" :primaryId="parseInt(contactId)"
                          type="Contact"
        ></NotesAndActivity>
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
import {getRequest, deleteRequest, putRequest, postRequest, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import {getCompanyStates} from '@/services/stateService'
import {getCustomFieldReadOnly} from '@/services/customFieldService'

export default {
  name: 'Contact',
  components: {

    CustomValueInput,
    NotesAndActivity,
    DatetimePickerInput
  },
  data () {
    return {
      snackbar: {},
      states: [],
      contact: {},
      addressChanged: false,
      contactLoading: true,
      customFieldGroups: [],
      notes: [],
      dirtyCfvs: [],
      owners: [],
      contactId: this.$route.params.id,
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('CONTACTS', 'EDIT'),
      companyId: this.$store.state.user.details.companyId,
      timezone: this.$store.state.user.details.timezone?.value,
      changeOwner: false,
      selectedProcess: null,
      availableProcesses: []
    }
  },
  created () {
    this.getContact()
    this.getCompanyStates()
    this.getOwners()
    this.getCustomFieldGroups()
    this.getNotes()
  },
  methods: {
    async saveContact() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
      // save contact
        const {data} = await postRequest(`/contact`, this.contact)
        this.contact.projects = data.projects
      // save dirty custom field values
        await postRequest(`/customFieldValues/contact/${this.contact.id}`, this.dirtyCfvs)
        this.dirtyCfvs = []
        this.addressChanged = false
        //this line reloads the contact so we dont have to reset the cfgs
        this.$router.push({name: 'contact', params: {id: data.id}})
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Contact')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
    getReadOnly: function (field) {
      return !this.userCanEdit || getCustomFieldReadOnly(this.$store, field)
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

