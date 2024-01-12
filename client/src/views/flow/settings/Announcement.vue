<template>
  <v-container>
    <v-row  class="pt-0">
      <v-col cols="12"  class="pt-0">
        <v-btn text color="primary" @click="cancel()">
          <v-icon x-large>mdi-chevron-left</v-icon>
        </v-btn>
        <v-toolbar flat>
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">
            {{ announcementId ? 'Edit Announcement' : 'Add Announcement'}}
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn color="primary" text @click="validate()" :loading="saving">
              <v-icon>save</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-form ref="announcementForm">
          <h3>Overview</h3>
          <v-text-field v-model="announcement.title"
                        density="compact"
                        :rules="requiredRules"
                        label="Title"/>
          <v-text-field v-model="announcement.alertText"
                        density="compact"
                        :rules="requiredRules"
                        label="Alert Text"/>

          <h3>Platform</h3>
            <v-checkbox v-model="announcement.showOnWeb" dense
                        :rules="!announcement.showOnWeb && !announcement.showOnMobile ? onePlatformRequired : []"
                        label="Web"></v-checkbox>
            <v-checkbox v-model="announcement.showOnMobile" dense
                        :rules="!announcement.showOnWeb && !announcement.showOnMobile ? onePlatformRequired : []"
                        label="Mobile"></v-checkbox>

          <DatetimePickerInput
              v-model="announcement.startTime"
              :timezone="timezone"
              :type="'timestamp'"
              :required="true"
              :format="'MMMM DD, YYYY, h:mm A'"
              label="Start Time"
          />

          <DatetimePickerInput
              v-model="announcement.endTime"
              :timezone="timezone"
              :type="'timestamp'"
              :format="'MMMM DD, YYYY, h:mm A'"
              label="End Time"
          />


          <div class="d-flex flex-row flex-align-items-center">
            <v-checkbox v-model="announcement.expandable"></v-checkbox>
            <label>Expandable Announcement</label>
          </div>

          <div v-if="announcement.expandable">
            <h3>Expandable Announcement</h3>

            <v-text-field v-model="announcement.subtitle"
                          density="compact"
                          :rules="requiredRules"
                          label="Subtitle"/>

            <div class="albatross-body-1 d-flex align-baseline mb-2 description-label">
              Description
            </div>
              <quill-editor
                  :options="toolbarOptions"
                  class="rich-text-editor albatross-body-2"
                  v-model="announcement.description"
              />

            <v-text-field v-model="announcement.hyperlink"
                          class="mt-3"
                          density="compact"
                          :rules="[urlRule]"
                          label="Hyperlink"/>

            <div v-if="userCanEdit">
              <v-btn icon :large="$vuetify.breakpoint.smAndDown" color="primary"
                     v-if="!announcementLogo.saving && !announcement.presignedUrl && !announcementLogo.image?.presignedUrl" @click="announcementLogo.add = !announcementLogo.add">
                <v-icon v-if="announcementLogo.add">remove</v-icon>
                <v-icon v-else>add</v-icon>
              </v-btn>
              <v-btn icon :large="$vuetify.breakpoint.smAndDown" color="primary" v-else
                     @click="showDeleteDialog = true">
                <v-icon>delete</v-icon>
              </v-btn>
              <div class="mt-4" v-if="announcementLogo.add">
                <form enctype="multipart/form-data" novalidate>
                  <input
                      type="file"
                      :accept="acceptedFileTypes"
                      class="file-input clickable body-medium mx-6"
                      :disabled="announcementLogo.saving"
                      @change="uploadFile($event.target.files, null)"
                      name="avatar"
                  >
                  <br/><span>* Due to render times associated with this file it cannot exceed 1MB</span>
                </form>
              </div>
              <div class="company-logo-background" v-else-if="announcement.presignedUrl">
                <img class="announcement-image" :src="announcement.presignedUrl">
              </div>
              <ConfirmationDialog :open-dialog="showDeleteDialog" @confirm="deleteAttachment()"
                                  @close-dialog="showDeleteDialog=false">
                Are you sure you want to delete this image?
              </ConfirmationDialog>
            </div>

          </div>
        </v-form>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
import constants from '@/helpers/constants'
import DatetimePickerInput from "@/components/DatetimePickerInput.vue";
import 'quill/dist/quill.snow.css'
import { quillEditor } from 'vue-quill-editor'

import {
  getSnackbar,
  getRequest,
  handleHidingGlobalLoader,
  postRequest,
  postRequestWithRequestParams
} from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
import {Actions} from "@/store";

  export default {
    name: 'Announcement',
    components: {ConfirmationDialog, DatetimePickerInput, quillEditor},
    computed: {
    },
    data() {
      return {
        constants,
        saving: false,
        announcement: {},
        toolbarOptions: {
          modules: {
            toolbar: [
              ['bold', 'italic', 'underline', 'blockquote'], //toggled buttons
              //without the color array then black = false which just un-sets color. in our case our default is navy blue, so unsetting the color goes back to navy blue and not to black.  by setting the black value to #000000 it fixes this issue.  when our default color changes to black then we could just remove the colors in this array to use the defaults from quill
              [{ 'color': ['#000000', '#e60000', '#ff9900', '#ffff00', '#008a00', '#0066cc', '#9933ff', '#ffffff', '#facccc', '#ffebcc', '#ffffcc', '#cce8cc', '#cce0f5', '#ebd6ff', '#bbbbbb', '#f06666', '#ffc266', '#ffff66', '#66b966', '#66a3e0', '#c285ff', '#888888', '#a10000', '#b26b00', '#b2b200', '#006100', '#0047b2', '#6b24b2', '#444444', '#5c0000', '#663d00', '#666600', '#003700', '#002966', '#3d1466'] },
                { 'background': [] }],          // dropdown with defaults from theme
              [{ 'size': ['small', false, 'large', 'huge'] }],  // custom dropdown
              [{ 'list': 'ordered'}, { 'list': 'bullet' }],
              ['clean']                                         // remove all formatting button
            ]
          }
        },
        acceptedFileTypes: constants.STANDARD_IMAGES_ONLY,
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
        timezone: this.$store.state.user.details.timezone?.value,
        requiredRules: constants.BASIC_REQUIRED_RULE,
        onePlatformRequired: [
          v => (!!v || v === 0) || 'At lease one platform is required'
        ],
        announcementId: this.$route.params?.id,
        showDeleteDialog: false,
        announcementLogo: {
          add: false,
          saving: false,
          image: {}
        }

      }
    },
    created() {
      if(this.announcementId) {
        this.getAnnouncement(parseInt(this.announcementId))
      }
    },
    methods: {
      urlRule(url) {
        if (url && !(/^(?:(?:(?:https?|ftp):)?\/\/)(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:[/?#]\S*)?$/i.test(this.announcement.hyperlink))) {
          return 'Valid URL is required'
        } else {
          return true
        }
      },
      cancel() {
        this.$router.push(`/settings/announcements`)
      },
      async validate() {
        if (this.$refs.announcementForm.validate()) {
          this.saving = true
          try {
            const {data, status} = await postRequest(`/announcements`,  this.announcement)
            this.announcement = data
            if(this.announcementLogo.image !== {}) {
              await this.uploadFile(null, this.announcementLogo.image)
              this.snackbar = getSnackbar('SUCCESS', 'Announcement Saved')
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$router.push(`/settings/announcements`)
            } else {
              this.snackbar = getSnackbar('SUCCESS', 'Announcement Saved')
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$router.push(`/settings/announcements`)
            }
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Saving Announcement')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          } finally {
            this.saving = false
          }
        }
      },
      async getAnnouncement(id) {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {data, status} = await getRequest(`/announcements/${id}`)
          this.announcement = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } finally {
          this.$store.commit(AppMutations.SET_LOADING, false)
          this.saving = false
        }
      },
      async deleteAttachment() {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          await this.$store.dispatch(Actions.FILE_DELETE, {
            id: this.announcement.attachmentId,
            callback: async () => {
              this.announcementLogo = {
                add: false,
                saving: false,
                image: {}
              }
              this.announcement.presignedUrl = null
              this.announcement.attachmentId = null
              // this.$store.commit(UserMutations.SET_USER_IMAGE, {})
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
      async uploadFile(files, existingFile) {
        let file = existingFile ? existingFile : files[0]
        if(!this.announcement.id) {
          this.announcementLogo.image = file
        } else if(file && file.name) {
          try {
            this.$store.commit(AppMutations.SET_LOADING, true)
            await this.$store.dispatch(Actions.FILE_UPLOAD, {
              file: file,
              sizeLimit: 1048576,
              attachmentTypeId: 990,
              sourceId: this.announcement.id,
              displayName: file.name.substr(0, file.name.lastIndexOf('.')),
              callback: async (img, error) => {
                if (error?.error) {
                  this.snackbar = getSnackbar('ERROR', error.errorMsg)
                  this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
                  this.$store.commit(AppMutations.SET_LOADING, false)
                } else {
                  this.announcement.presignedUrl = img.presignedUrl
                  this.announcementLogo.image = img
                  this.announcementLogo.add = false
                  this.announcementLogo.saving = false
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
        }
      },
    }
  }
</script>
<style lang="scss">
.ql-editor ul {
  padding-left: 0 !important;
}
</style>

<style lang="scss" scoped>
.description-label {
  color: #666666;
  font-size: 12px;

}

.announcement-image {
  max-width: 100%;
  height: auto;
}

</style>
