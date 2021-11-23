<template>
  <v-main>
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
        <v-btn text x-small @click="editMinVersion = !editMinVersion" class="d-inline-block">
          <v-icon v-if="!editMinVersion">edit</v-icon>
          <v-icon v-else>close</v-icon>
        </v-btn>
        <v-btn text x-small v-if="editMinVersion" @click="saveMinVersion()" class="d-inline-block">
          <v-icon>save</v-icon>
        </v-btn>
      </div>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn v-if="isIos" text @click="showIos = !showIos">
          <v-icon>mdi-chevron-down</v-icon>
        </v-btn>
        <v-btn v-else text @click="showAndroid = !showAndroid">
          <v-icon>mdi-chevron-down</v-icon>
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <v-data-table v-if="(isIos && showIos) || (!isIos && showAndroid)"
        :headers="filterHeaders()"
        :items="getFilteredApps(true)"
        :fixed-header="true"
        disable-sort
        hide-default-footer
        :mobile-breakpoint="0"
        :items-per-page="-1"
        class="elevation-1"
    >
      <template #no-data>
        No available apps
      </template>
      <template #no-results>
        No available apps
      </template>

      <template #item="{ item, index }">
        <tr :class="{'default-row': item.show, 'shaded-row': index % 2}">
          <td>
            <v-btn text color="primaryCustom" small
                   v-if="isIos"
                   :href="`itms-services://?action=download-manifest&url=https://7oaks-albatross.s3.amazonaws.com/${item.s3Key}`">
              <v-icon>download</v-icon>
            </v-btn>
            <v-btn text color="primaryCustom" small
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
          <td class="px-0">
            <v-dialog
                v-if="userCanEdit"
                v-model="item.deleteConfirm"
                width="500">
              <template #activator="{ on }">
                <v-btn small text color="primaryCustom"
                       v-on="on">
                  <v-icon>delete</v-icon>
                </v-btn>
              </template>
              <v-card>
                <v-card-title class="headline grey lighten-2" primary-title>
                  Confirm
                </v-card-title>

                <v-card-text class="pt-4">
                  Are you sure you want to delete this app <strong>{{item.filename}}</strong>?
                </v-card-text>
                <v-divider></v-divider>
                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn @click="item.deleteConfirm = false">
                    No
                  </v-btn>
                  <v-btn
                      color="primaryCustom"
                      text
                      @click="deleteApp(item)">
                    Yes
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
            <v-dialog
                v-if="userCanEdit"
                v-model="item.showConfirm"
                width="500">
              <template #activator="{ on }">
                <v-btn small text color="primaryCustom"
                       v-on="on">
                  {{ item.show ? 'hide' : 'show'}}
                </v-btn>
              </template>
              <v-card>
                <v-card-title class="headline grey lighten-2" primary-title>
                  Confirm
                </v-card-title>

                <v-card-text class="pt-4">
                  {{item.show ? `Are you sure you want to hide this app from everyone?` : `Are you sure you want to make this app available to everyone?`}}
                </v-card-text>
                <v-divider></v-divider>
                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn @click="item.showConfirm = false">
                    No
                  </v-btn>
                  <v-btn
                      color="primaryCustom"
                      text
                      @click="showHideApp(item)">
                    Yes
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </td>
        </tr>
      </template>
    </v-data-table>
  </v-main>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import { handleHidingGlobalLoader, deleteRequest, putRequest, putRequestWithRequestParams, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import Vue2Filters from "vue2-filters";
import constants from '@/helpers/constants'

export default {
  name: 'AppDownloads',
  mixins: [Vue2Filters.mixin],
  components: {},
  props: {
    isIos: Boolean,
    userCanEdit: Boolean,
    apps: Array
  },
  data () {
    return {
      snackbar: {},
      constants,
      showIos: true,
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
        {text: '', value: 'icons', show: true, width: 175},
      ],
    }
  },
  created () {
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
    filterHeaders () {
      return this.headers.filter(header => header.show === true)
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
    async deleteApp(item) {
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
    async showHideApp(app) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        app.show = !app.show
        const {status} = await putRequest(`/app/show`, app)
        app.showConfirm = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating App')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getFilteredApps() {
      let appTypeId = this.isIos ? 1 : 3
      //1 = ios
      //3 = android
      return this.apps.filter(a => {
        return this.userCanEdit ? a.appTypeId === appTypeId && !a.archived : a.appTypeId === appTypeId && a.show && !a.archived
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

