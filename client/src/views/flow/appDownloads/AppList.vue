<template>
  <v-main>
    <v-alert color="green lighten-1" v-model="betaUpdatedAlertSuccess" dismissible transition="scale-transition">Beta Updated Successfully!</v-alert>
    <v-alert color="red lighten-1" v-model="betaUpdatedAlertFailed" dismissible transition="scale-transition">Beta Update Failed</v-alert>
    <v-toolbar flat class="app-toolbar">
      <v-toolbar-title class="app-title">
        {{isIos ? 'iOS' : 'Android'}}
      </v-toolbar-title>
      <v-spacer v-if="userCanEdit"></v-spacer>
      <div v-if="userCanEdit">
        <v-autocomplete v-model="minVersion"
                        class="d-inline-block"
                        :items="buildNumbers"
                        :readonly="!editMinVersion"
                        :disabled="!editMinVersion"
                        hide-details
                        label="Min Required Build Number"
        ></v-autocomplete>
        <v-btn text color="primary" x-small @click="editMinVersion = !editMinVersion" class="d-inline-block">
          <v-icon v-if="!editMinVersion">edit</v-icon>
          <v-icon v-else>close</v-icon>
        </v-btn>
        <v-btn text color="primary" x-small v-if="editMinVersion" @click="saveMinVersion()" class="d-inline-block">
          <v-icon>save</v-icon>
        </v-btn>
      </div>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn text color="primary" @click="[addNew = !addNew, newApp = {}]" v-if="userCanAdd">
          <v-icon>add</v-icon>
        </v-btn>
        <v-btn v-if="isIos" text color="primary" @click="showIos = !showIos">
          <v-icon>mdi-chevron-down</v-icon>
        </v-btn>
        <v-btn v-else text color="primary" @click="showAndroid = !showAndroid">
          <v-icon>mdi-chevron-down</v-icon>
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <v-card flat class="square-card mt-3 pa-4" v-if="addNew">
      <v-file-input
        dense
        v-if="isIos"
        class="mb-3"
        :accept="'.ipa'"
        ref="fileInput"
        hide-details
        label="Select an .ipa File"
        @change="uploadSecondaryFile"
      />
      <v-file-input
        dense
        class="mb-3"
        :accept="isIos ? '.plist' : '.apk'"
        ref="fileInput"
        hide-details
        :label="isIos ? 'Select a .plist File' : 'Select an .apk File'"
        @change="uploadFile"
      />
      <v-text-field text
                    type="text"
                    label="Version Number"
                    v-model="newApp.versionNumber">
      </v-text-field>
      <v-text-field text
                    type="number"
                    label="Build Number"
                    v-model.number="newApp.buildNumber">
      </v-text-field>

      <v-btn color="primary"
             :disabled="!newApp.versionNumber || !newApp.buildNumber
                        || (!newApp.attachment || !newApp.attachment.name)
                        || (isIos && (!newApp.secondaryAttachment || !newApp.secondaryAttachment.name))"
             @click="saveNewApp">
        Save
      </v-btn>
    </v-card>
    <v-data-table v-if="(isIos && showIos) || (!isIos && showAndroid)"
        :headers="filterHeaders"
        :items="getFilteredApps(true)"
        :fixed-header="true"
        disable-sort
        hide-default-footer
        :mobile-breakpoint="0"
        :items-per-page="-1"
        class="elevation-1"
    >
      <template #no-data>
        <span class="default-text-color">No available apps</span>
      </template>
      <template #no-results>
        <span class="default-text-color">No available apps</span>
      </template>

      <template #item="{ item, index }">
        <tr :class="{'default-row': item.show, 'shaded-row': index % 2}">
          <td>
            <v-btn text color="primary" small
                   v-if="isIos"
                   :href="`itms-services://?action=download-manifest&url=https://7oaks-albatross.s3.amazonaws.com/${item.s3Key}`">
              <v-icon>download</v-icon>
            </v-btn>
            <v-btn text color="primary" small
                   v-else
                   :href="item.presignedUrl">
              <v-icon>download</v-icon>
            </v-btn>
          </td>
          <td class="text-left">
            {{item.filename}}
          </td>
          <td class="text-left">
            {{getVersion(item.filename)}}
          </td>
          <td class="text-left">
            {{item.dateCreated | formatDate('timestamp')}}
          </td>
          <td class="px-0" v-if="userCanEdit">
            <v-btn v-if="userCanDelete" text color="primary" @click="appToDelete = item"><v-icon>delete</v-icon></v-btn>
            <v-btn v-if="userCanEdit" small text color="primary" @click="appToShowHide = item">
              {{ item.show ? 'hide' : 'show'}}
            </v-btn>
          </td>
          <td class="text-left">
            <v-checkbox v-if="userCanEdit || userHasBeta"
                        :disabled="!userCanEdit"
                        v-model="item.beta" @click="appToToggleBeta = item; toggleBetaForApp()"></v-checkbox>
          </td>
        </tr>
      </template>
    </v-data-table>
    <ConfirmationDialog :open-dialog="!!appToDelete" @confirm="deleteApp" @close-dialog="appToDelete = null">
      Are you sure you want to delete this app <strong>{{appToDeleteName}}</strong>?
    </ConfirmationDialog>
    <ConfirmationDialog hide-title :open-dialog="!!appToShowHide" @confirm="showHideApp" @close-dialog="appToShowHide = null">
      {{hideOrShowApp ? `Are you sure you want to hide this app from everyone?` : `Are you sure you want to make this app available to everyone?`}}
      <template v-slot:yes>{{hideOrShowApp ? 'hide' : 'show'}}</template>
    </ConfirmationDialog>
  </v-main>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {
  handleHidingGlobalLoader,
  deleteRequest,
  putRequest,
  putRequestWithRequestParams,
  getRequestWithParams,
  getRequest,
  getSnackbar,
  postRequest
} from '@/helpers/helpers'
import Vue2Filters from "vue2-filters";
import constants from '@/helpers/constants'
import ConfirmationDialog from "@/components/ConfirmationDialog";

export default {
  name: 'AppDownloads',
  mixins: [Vue2Filters.mixin],
  components: {ConfirmationDialog},
  props: {
    isIos: Boolean
  },
  data () {
    return {
      snackbar: {},
      constants,
      showIos: true,
      addNew: false,
      apps: [],
      newApp: {},
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('APP_DOWNLOADS', 'ADD'),
      userCanViewAll: this.$store.getters.userHasFeatureAccessLevel('APP_DOWNLOADS', 'VIEW_ALL'),
      userCanView: this.$store.getters.userHasFeatureAccessLevel('APP_DOWNLOADS', 'VIEW'),
      userHasBeta: this.$store.getters.userHasFeatureAccessLevel('APP_DOWNLOADS', 'VIEW_CUSTOM'),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('APP_DOWNLOADS', 'EDIT'),
      userCanDelete: this.$store.getters.userHasFeatureAccessLevel('APP_DOWNLOADS', 'DELETE'),
      minVersion: null,
      buildNumbers: [],
      editMinVersion: false,
      appTypeId: this.isIos ? 1 : 3,
      showAndroid: true,
      isMobile: false,
      headers: [
        {text: '', value: 'dlIcon', show: true, width: 40},
        {text: 'Filename', value: 'filename', show: true},
        {text: 'Version', value: 'version', show: true},
        {text: 'Created', value: 'dateCreated', show: true},
        {text: '', value: 'icons', width: 175, show: this.$store.getters.userHasFeatureAccessLevel('APP_DOWNLOADS', 'EDIT')},
        {text: 'Beta', value: 'beta', show: this.$store.getters.userHasFeatureAccessLevel('APP_DOWNLOADS', 'VIEW_CUSTOM') || this.$store.getters.userHasFeatureAccessLevel('APP_DOWNLOADS', 'EDIT')}
      ],
      appToDelete: null,
      appToShowHide: null,
      appToToggleBeta: null,
      betaUpdatedAlertSuccess: false,
      betaUpdatedAlertFailed: false
    }
  },
  computed:{
    filterHeaders () {
      return this.headers.filter(header => header.show === true)
    },
    appToDeleteName(){
      return this.appToDelete ? this.appToDelete.filename : ''
    },
    hideOrShowApp(){
      return this.appToShowHide ? this.appToShowHide.show : false
    }
  },
  created () {
    this.getApps()
    this.getMinVersion()
    this.getAvailableBuildNumbers()
    let userAgent = window.navigator.userAgent
    if(userAgent && userAgent.includes('Android')){
      this.showIos = false
      this.isMobile = true
    } else if (userAgent && (userAgent.includes('iPhone') || userAgent.includes('iPad'))) {
      this.showAndroid = false
      this.isMobile = true
    }
  },
  methods: {
    async saveNewApp() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      const formData = new FormData()
      formData.append('versionNumber', this.newApp.versionNumber);
      formData.append('buildNumber', this.newApp.buildNumber);
      formData.append('attachment', this.newApp.attachment);
      formData.append('secondaryAttachment', this.newApp.secondaryAttachment);

      let url = this.isIos ? '/app/ios' : '/app/android'
      await postRequest(url, formData)
      this.newApp = {}
      this.addNew = false
      //reload it all cuz i'm lazy
      await this.getApps()
    },
    uploadFile: function (file) {
      this.newApp.attachment = file
    },
    uploadSecondaryFile: function (file) {
      this.newApp.secondaryAttachment = file
    },
    async getApps() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let url = this.isIos ? '/app/ios' : '/app/android'
        const {data, status} = await getRequest(url)
        this.apps = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Apps')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveMinVersion () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await putRequestWithRequestParams(`/app/${this.appTypeId}/minVersion`, null, { minVersion: this.minVersion})
        this.editMinVersion = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Min Build Number')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getAvailableBuildNumbers () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequestWithParams(`/app/${this.appTypeId}/buildNumbers`)
        this.buildNumbers = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Build Numbers')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getMinVersion () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequestWithParams(`/app/${this.appTypeId}/minVersion`)
        this.minVersion = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Min Build Number')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteApp() {
      const item = this.appToDelete
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await deleteRequest(`/app/${item.id}`)
        item.archived = true
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Apps')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async showHideApp() {
      const app = this.appToShowHide
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        app.show = !app.show
        const {status} = await putRequest(`/app/show`, app)
        app.showConfirm = false
        this.appToShowHide = null
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating App')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async toggleBetaForApp() {
      const app = this.appToToggleBeta
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await putRequest(`/app/beta`, app)
        app.showConfirm = false
        this.appToToggleBeta = null
        handleHidingGlobalLoader(this, status)
        this.betaUpdatedAlertSuccess = true
        this.betaUpdatedAlertFailed = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating App')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.betaUpdatedAlertSuccess = false
        this.betaUpdatedAlertFailed = true
      }
    },
    getFilteredApps() {
      //filter archived
      return this.apps.filter(a => {
        //user can view all or can edit then return all unarchived
        return this.userCanEdit || this.userCanViewAll ? !a.archived :
          //if they have beta AND view access then just show them all the shown apps regardless of beta status
          this.userHasBeta && this.userCanView ? !a.archived && a.show :
          //if they ONLY have beta then only show them shown beta apps
          this.userHasBeta ? !a.archived && a.show && a.beta :
          //otherwise they should only have view acces and only show them shown non-beta apps
          a.show && !a.archived && !a.beta
      })
    },
    getVersion (filename) {
      let match = filename.match(/\b-(\d*.\d*.\d*)-(\d*)/)
      let version = null
      if(match && this.userCanEdit) {
        version = match[1] + ' (' + match[2] + ')'
      } else if (match) {
        version = match[1]
      }
      return match ? version : 'N/A'
    }
  }
}
</script>

<style lang="scss">
.default-row {
  background-color: #c3fad2 !important;
}
</style>

