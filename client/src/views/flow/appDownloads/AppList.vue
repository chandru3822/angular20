<template>
  <v-data-table
      :headers="headers"
      :items="getFilteredApps(true)"
      :fixed-header="true"
      hide-default-footer
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
      <tr :class="{'shaded-row': index % 2}">
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
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {getRequest, deleteRequest, putRequest, postRequest, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
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
      headers: [
        {text: 'Filename', value: 'filename', show: true},
        {text: 'Version', value: 'version', show: true},
        {text: 'Created', value: 'dateCreated', show: true},
        {text: '', value: 'icons', show: true, width: 175},
      ],
    }
  },
  created () {},
  methods: {
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
      let sourceId = this.isIos ? 1 : 3
      //plist: 1 = prod, 2= uat
      //apk: 3 = prod, 4= uat
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

<style lang="scss" scoped>

</style>

