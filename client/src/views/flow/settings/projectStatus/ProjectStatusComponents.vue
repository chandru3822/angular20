<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <div class="px-5">
          <v-text-field v-model="status.projectStatusType"
                        label="Status Type"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
          ></v-text-field>
          <v-autocomplete
            :items="rootStatusTypes"
            v-model="status.projectStatusTypeId"
            item-value="id"
            :readonly="!userCanEdit"
            :disabled="!userCanEdit"
            label="Select a Category"
            item-text="projectStatusType"
            attach></v-autocomplete>
          <v-textarea
            label="Description"
            outlined
            hide-details
            auto-grow
            v-model="status.description"
          ></v-textarea>

          <v-checkbox label="Use as Milestone"
                      class="default-text-color"
                      v-model="status.isMilestone"
          />

          <div v-if="!status.isDefault" class="mb-3">
            <v-dialog
              v-model="status.setInitialConfirm"
              width="500">
              <template #activator="{ on }">
                <v-btn v-on="on">
                  Set as Initial
                </v-btn>
              </template>
              <v-card>
                <v-card-title
                  class="text-h5 grey lighten-2"
                  primary-title>
                  Confirm
                </v-card-title>

                <v-card-text class="pt-4">
                  Setting this Project Status Type as default will unset the other initial status. Are you sure you want
                  to continue?
                </v-card-text>

                <v-divider></v-divider>

                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn
                    @click="status.setInitialConfirm = false">
                    No
                  </v-btn>
                  <v-btn
                    color="primary"
                    text
                    @click="setAsInitial(status)">
                    Yes
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </div>

          <v-card class="fifty-cent">
            <v-text-field v-model="status.iconTag"
                          label="Material Icon Tag"
                          hide-details
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
            ></v-text-field>
            <div class="mt-3">
              Preview: <v-icon v-if="status.iconTag">{{status.iconTag}}</v-icon>
            </div>
          </v-card>

          <v-card class="fifty-cent mt-5">
            <div class="my-2" v-if="status.icon && status.icon.id != null">
              <label>Status Type Icon <br>(Obsolete, only used on mobile until Status Tracker release)</label>
              <div class="flex-display ma-2">
                <img class="status-icon" :src="status.icon.presignedUrl">
                <v-btn x-small text color="primary" @click="deleteAttachment(status)">
                  <v-icon>close</v-icon>
                </v-btn>
              </div>
            </div>
            <div class="my-2" v-else>
              <label>Status Type Icon<br>(Obsolete, only used on mobile until Status Tracker release)</label>
              <form enctype="multipart/form-data" novalidate>
                <input
                  type="file"
                  :accept="acceptedFileTypes"
                  class="file-input clickable"
                  :disabled="savingTypeLogo"
                  @change="uploadFile(status, $event.target.files, attachmentTypeId, status.id, 1048576)"
                  name="avatar"
                >
                <br/><span>* Due to render times associated with this file it cannot exceed 1MB</span>
              </form>
            </div>
          </v-card>
        </div>

        <v-btn v-if="userCanEdit"
               :disabled="!status.projectStatusType || !status.projectStatusTypeId"
               color="primary"
               class="d-inline-block mt-5"
               @click="saveType(status)">
          <v-icon class="mr-2">save</v-icon>
          Save
        </v-btn>
      </v-col>

    </v-row>
  </v-container>
</template>


<script>
import {Actions} from '@/store'
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import draggable from 'vuedraggable'

import {getCompanyProjectStatusType, getProjectStatusTypes} from '@/services/projectStatusTypeService'
import {handleHidingGlobalLoader, putRequest, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from '@/components/ConfirmationDialog.vue'
import { mapStores } from 'pinia'
import { useUserStore } from '@/stores/UserStorePinia.js'

export default {
  name: 'ProjectStatusComponents',
  mixins: [Vue2Filters.mixin],
  components: {
    ConfirmationDialog,
    draggable,
  },
  data() {
    return {
      snackbar: {},
      constants,
      colorOptions: {
        canvasHeight: 75,
        width: 200,
        mode: 'hexa',
        hideModeSwitch: true
      },
      status: {},
      rootStatusTypes: [],
      acceptedFileTypes: constants.STANDARD_IMAGES_ONLY,
      savingTypeLogo: false,
      //463 = project status type attachment
      attachmentTypeId: 463,
      statusId: this.$route.params.id
    }
  },
  computed: {
    ...mapStores(useUserStore),
    userCanEdit() {
      return this.userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
    }
  },
  methods: {
    initItemColor(item) {
      item.color = item.color ?? '#FFFFFF'
    },
    async uploadFile(item, files, attachmentTypeId, sourceId, sizeLimit) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        let file = files[0]
        await this.$store.dispatch(Actions.FILE_UPLOAD, {
          file: file,
          sizeLimit,
          attachmentTypeId,
          sourceId,
          displayName: file.name.substr(0, file.name.lastIndexOf('.')),
          callback: async (img, error) => {
            if (error?.error) {
              this.snackbar = getSnackbar('ERROR', error.errorMsg)
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
            } else {
              item.icon = img

              this.snackbar = getSnackbar('SUCCESS', 'Image Uploaded')
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
            }
          }
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteAttachment(item) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await this.$store.dispatch(Actions.FILE_DELETE, {
          id: item.icon.id,
          callback: async () => {
            item.icon = {}
            this.snackbar = getSnackbar('SUCCESS', 'Image Deleted')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting File')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getStatusInfo() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getCompanyProjectStatusType(this.statusId)
        this.status = data
        this.initItemColor(this.status)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getProjectStatusTypes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getProjectStatusTypes()
        this.rootStatusTypes = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveType(type) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await putRequest(`/projectStatus/company`, type)
        this.snackbar = getSnackbar('SUCCESS', 'Project Status Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Project Status')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async setAsInitial(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await putRequest(`/projectStatus/company/initial/${item.id}`,)
        item.isDefault = true
        this.snackbar = getSnackbar('SUCCESS', 'Status Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Status')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  },
  async created() {
    this.getStatusInfo()
    this.getProjectStatusTypes()
  }
}
</script>

<style scoped lang="scss">
.status-icon {
  margin-top: 15px;
  max-width: 50px;
  height: auto;
}

.status-icon-grid {
  margin-top: 5px;
  max-width: 40px;
  height: auto;
}

.fifty-cent {
  width: 50%;
  padding: 15px 20px;
}
</style>
