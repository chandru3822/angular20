<template>
  <v-main>
    <v-toolbar flat class="app-toolbar">
      <v-toolbar-title class="app-title">{{isIos ? 'iOS' : 'Android'}}</v-toolbar-title>
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
                   :href="`itms-services://?action=download-manifest&url=https://7oaks-albatross.s3.amazonaws.com/{{item.s3Key}}`">
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
import {getRequest, deleteRequest, putRequest, postRequest, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import Vue2Filters from "vue2-filters";
import constants from '@/helpers/constants'

const { VUE_APP_ENV } = process.env

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
      console.log('randaLogger', this.headers)
      return this.headers.filter(header => header.show === true)
    },
    async deleteApp(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await deleteRequest(`/app/${item.id}`)
        item.archived = true
        this.$store.commit(AppMutations.SET_LOADING, false)
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
        await putRequest(`/app/show`, app)
        app.showConfirm = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating App')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getFilteredApps() {
      let sourceId;
      //plist: 1 = prod, 2= uat
      //apk: 3 = prod, 4= uat
      if(this.isIos) {
        sourceId = VUE_APP_ENV === 'prod' ? 1 : 2
      } else {
        sourceId = VUE_APP_ENV === 'prod' ? 3 : 4
      }
      return this.apps.filter(a => {
        return this.userCanEdit ? a.sourceId === sourceId && !a.archived : a.sourceId === sourceId && a.show && !a.archived
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

