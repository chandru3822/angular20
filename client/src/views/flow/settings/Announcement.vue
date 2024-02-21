<template>
  <v-container>
    <v-row class="pt-0" v-if="!dataLoading">
      <v-col cols="12" class="pt-0">
        <AlbatrossButton variant="text" round @click="cancel()"
                         custom-classes="back-button">
          <template v-slot:default>
            <v-icon x-large>mdi-chevron-left</v-icon>
          </template>
        </AlbatrossButton>
        <v-toolbar flat id="announcement-admin-header">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">
            {{ announcementId ? 'Edit Announcement' : 'Add Announcement' }}
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton variant="text" @click="validate()" prepend-icon="save"
                   v-if="userCanEdit" :loading="saving">
            </AlbatrossButton>
          </v-toolbar-items>
        </v-toolbar>
        <v-form ref="announcementForm">
          <h3>Overview</h3>
          <div class="error--text" v-if="timeError">
            {{ timeErrorMsg }}
          </div>
          <v-text-field v-model="announcement.title"
                        density="compact"
                        :disabled="!userCanEdit"
                        :readonly="!userCanEdit"
                        :rules="requiredRules"
                        label="Title"/>
          <v-text-field v-model="announcement.alertText"
                        density="compact"
                        :disabled="!userCanEdit"
                        :readonly="!userCanEdit"
                        :rules="requiredRules"
                        label="Alert Text"/>

          <h3>Platform</h3>
          <v-checkbox v-model="announcement.showOnWeb" dense
                      :disabled="!userCanEdit"
                      :readonly="!userCanEdit"
                      :rules="!announcement.showOnWeb && !announcement.showOnMobile ? onePlatformRequired : []"
                      label="Web"></v-checkbox>
          <v-checkbox v-model="announcement.showOnMobile" dense
                      :disabled="!userCanEdit"
                      :readonly="!userCanEdit"
                      :rules="!announcement.showOnWeb && !announcement.showOnMobile ? onePlatformRequired : []"
                      label="Mobile"></v-checkbox>
          <DatetimePickerInput
              v-model="announcement.startTime"
              :timezone="timezone"
              :readonly="!userCanEdit"
              :type="'timestamp'"
              :required="true"
              :format="'MMMM DD, YYYY, h:mm A'"
              label="Start Time"
          />

          <DatetimePickerInput
              v-model="announcement.endTime"
              :timezone="timezone"
              :readonly="!userCanEdit"
              :type="'timestamp'"
              :format="'MMMM DD, YYYY, h:mm A'"
              label="End Time"
          />


          <div class="d-flex flex-row flex-align-items-center">
            <v-checkbox v-model="announcement.expandable"
                        :disabled="!userCanEdit"
                        :readonly="!userCanEdit"></v-checkbox>
            <label>Expandable Announcement</label>
          </div>

          <div v-if="announcement.expandable">
            <h3>Expandable Announcement</h3>

            <v-text-field v-model="announcement.subtitle"
                          density="compact"
                          :disabled="!userCanEdit"
                          :readonly="!userCanEdit"
                          :rules="requiredRules"
                          label="Subtitle"/>

            <div class="albatross-body-1 d-flex align-baseline mb-2 description-label">
              Description
            </div>
            <quill-editor
                :options="toolbarOptions"
                :disabled="!userCanEdit"
                class="rich-text-editor albatross-body-2"
                v-model="announcement.description"
            />

            <v-text-field v-model="announcement.hyperlink"
                          class="mt-3"
                          :disabled="!userCanEdit"
                          :readonly="!userCanEdit"
                          density="compact"
                          :rules="[urlRule]"
                          label="Hyperlink"/>

            <div class="mt-3">
              <div
                  v-if="!announcementLogo.saving && !announcement.presignedUrl && !announcementLogo.image?.presignedUrl">
                <v-file-input
                    dense
                    :disabled="!userCanEdit"
                    outlined
                    hide-details
                    v-model="announcementFile"
                    label="Attach image"
                    @change="uploadFile(announcementFile, null)"
                    @click:clear="announcementFile=null"
                    style="width: 255px"
                />
                <span>* Due to render times associated with this file it cannot exceed 1MB</span>
              </div>
              <!--                  <input-->
              <!--                      type="file"-->
              <!--                      -->
              <!--                      :accept="acceptedFileTypes"-->
              <!--                      class="file-input clickable body-medium mx-6"-->
              <!--                      :disabled="announcementLogo.saving"-->
              <!--                      @change="uploadFile(, null)"-->
              <!--                      name="avatar"-->
              <!--                  >-->
              <AlbatrossButton :size="vueInstance.$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                     v-else class="mb-3"
                     :disabled="!userCanEdit"
                     text="Delete Attachment"
                     append-icon="delete"
                     @click="showDeleteDialog = true">
              </AlbatrossButton>
            </div>

            <div class="company-logo-background" v-if="announcement.presignedUrl">
              <img class="announcement-image" :src="announcement.presignedUrl">
            </div>
            <ConfirmationDialog :open-dialog="showDeleteDialog" @confirm="deleteAttachment()"
                                @close-dialog="showDeleteDialog=false">
              Are you sure you want to delete this image?
            </ConfirmationDialog>
          </div>

        </v-form>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="unsavedModal" @confirm="[goToPath(toPath, query)]"
                        @close-dialog="unsavedModal = false">
      <template v-slot:title>Unsaved Changes</template>
      You have unsaved fields. Are you sure you want to continue without saving?
      <template v-slot:yes>Don't Save</template>
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import {getCurrentInstance, computed, onMounted, ref} from 'vue'
import {onBeforeRouteLeave, onBeforeRouteUpdate} from 'vue-router/composables'
import constants from '@/helpers/constants'
import DatetimePickerInput from "@/components/DatetimePickerInput.vue";
import 'quill/dist/quill.snow.css'
import {quillEditor} from 'vue-quill-editor'
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
import moment from 'moment'
import cloneDeep from 'lodash.clonedeep'
import isEqual from 'lodash.isequal'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton"


const vueInstance = getCurrentInstance().proxy
const router = vueInstance.$router
const snackbar = vueInstance.$snackbar

const store = vueInstance.$store
const saving = ref(false);
const override = ref(false);
const unsavedModal = ref(false);
const dataLoading = ref(true);
const toPath = ref(null);
const timeError = ref(false);
const timeErrorMsg = ref('');
const query = ref({});
const announcement = ref({});
const announcementCopy = ref({}); // used for seeing if changes were made

const toolbarOptions = ref({
  modules: {
    toolbar: [
      ['bold', 'italic', 'underline', 'blockquote'],
      [
        {
          'color': [
            '#000000', '#e60000', '#ff9900', '#ffff00', '#008a00', '#0066cc', '#9933ff', '#ffffff',
            '#facccc', '#ffebcc', '#ffffcc', '#cce8cc', '#cce0f5', '#ebd6ff', '#bbbbbb', '#f06666',
            '#ffc266', '#ffff66', '#66b966', '#66a3e0', '#c285ff', '#888888', '#a10000', '#b26b00',
            '#b2b200', '#006100', '#0047b2', '#6b24b2', '#444444', '#5c0000', '#663d00', '#666600',
            '#003700', '#002966', '#3d1466'
          ]
        },
        {'background': []}
      ],
      [{'size': ['small', false, 'large', 'huge']}],
      [{'list': 'ordered'}, {'list': 'bullet'}],
      ['clean']
    ]
  }
});

const acceptedFileTypes = ref(constants.STANDARD_IMAGES_ONLY);
const timezone = ref(store.state.user.details.timezone?.value);
const requiredRules = ref(constants.BASIC_REQUIRED_RULE);

const onePlatformRequired = [
  v => (!!v || v === 0) || 'At least one platform is required'
];

const announcementId = ref(parseInt(vueInstance.$route.params?.id));
const showDeleteDialog = ref(false);
const announcementFile = ref(null);
const announcementForm = ref(null);

const announcementLogo = ref({
  add: false,
  saving: false,
  image: {}
});
const isCurrent = computed(() => {
  return !announcement.value?.id || (announcement.value.id && (announcementCopy.value.endTime == null || moment().isBefore(moment(announcementCopy.value.endTime))))
})
const pathUrl = computed(() => {
  return isCurrent.value ? `/settings/announcements/current` : `/settings/announcements/past`
})
const userCanEdit = computed(() => {
  //we use the end time copy here so that if they are adding an end time in the past it will still let them save
  return store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT') &&
      (!announcement.value.id ||
          isCurrent.value)
})

onBeforeRouteUpdate(async (to, from, next) => {
  if (!override.value && !isEqual(announcement.value, announcementCopy.value)) {
    toPath.value = to.path
    query.value = to.query
    unsavedModal.value = true
  } else {
    next()
  }
})

onBeforeRouteLeave(async (to, from, next) => {
  if (!override.value && !isEqual(announcement.value, announcementCopy.value)) {
    toPath.value = to.path
    query.value = to.query
    unsavedModal.value = true
  } else {
    next()
  }
})


onMounted(async () => {
  if (announcementId.value) {
    await getAnnouncement()
  } else {
    dataLoading.value = false
  }
  // for testing
  // announcement.value = {
  //   title: 'asdf',
  //   alertText: 'asdf',
  //   showOnWeb: true,
  //   startTime: '2024-02-04T19:55:00.000Z',
  //   endTime: '2024-02-25T19:55:00.000Z',
  //   expandable: true,
  //   subtitle: 'blah'
  // }
})

const goToPath = (path, query) => {
  override.value = true
  router.push({path, query})
}
const urlRule = (url) => {
  if (url && !(/^(?:(?:(?:https?|ftp):)?\/\/)(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:[/?#]\S*)?$/i.test(announcement.hyperlink))) {
    return 'Valid URL is required'
  } else {
    return true
  }
}
const cancel = () => {
  router.push(pathUrl.value)
}
const validate = async () => {
  console.log('json',[JSON.stringify({
    ...announcement.value
  })])
  timeError.value = false
  if (announcement.value?.endTime != null && announcement.value.startTime > announcement.value.endTime) {
    timeError.value = true
    timeErrorMsg.value = 'End Time cannot be before Start Time'
  } else if (announcementForm.value?.validate()) {
    saving.value = true
    try {
      const formData = new FormData()

      formData.append('announcement', new Blob([JSON.stringify({
        ...announcement.value
      })], {
        type: "application/json"
      }))

      if (announcementLogo.value.image !== {}) {
        formData.append('uploadFile', announcementLogo.value.image)
      }

      const {data, status} = await postRequest(`/announcements`, formData)
      announcement.value = data
      snackbar('SUCCESS', 'Announcement Saved')
      override.value = true
      await router.push(pathUrl.value)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Saving Announcement')
    } finally {
      saving.value = false
    }
  }
}
const getAnnouncement = async () => {
  try {
    store.commit(AppMutations.SET_LOADING, true)
    const {data, status} = await getRequest(`/announcements/${announcementId.value}`)
    announcement.value = data
    announcementCopy.value = cloneDeep(data)
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
  } finally {
    store.commit(AppMutations.SET_LOADING, false)
    dataLoading.value = false
  }
}
const deleteAttachment = async () => {
  try {
    store.commit(AppMutations.SET_LOADING, true)
    await store.dispatch(Actions.FILE_DELETE, {
      id: announcement.value.attachmentId,
      callback: async () => {
        announcementLogo.value = {
          add: false,
          saving: false,
          image: {}
        }
        announcement.value.presignedUrl = null
        announcement.value.attachmentId = null
        snackbar('SUCCESS', 'Image Deleted')
        store.commit(AppMutations.SET_LOADING, false)
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting File')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const uploadFile = async (uploadedFile, existingFile) => {
  let file = existingFile ? existingFile : uploadedFile
  if (!announcement.value?.id) {
    announcementLogo.value.image = file
  } else if (file && file.name) {
    try {
      store.commit(AppMutations.SET_LOADING, true)
      await store.dispatch(Actions.FILE_UPLOAD, {
        file: file,
        sizeLimit: 1048576,
        attachmentTypeId: 990,
        sourceId: announcement.value.id,
        displayName: file.name.substr(0, file.name.lastIndexOf('.')),
        callback: async (img, error) => {
          if (error?.error) {
            snackbar('ERROR', error.errorMsg)
            store.commit(AppMutations.SET_LOADING, false)
          } else {
            announcement.value.presignedUrl = img.presignedUrl
            announcementLogo.value.image = img
            announcementLogo.value.add = false
            announcementLogo.value.saving = false
            snackbar('SUCCESS', 'Image Uploaded')
            store.commit(AppMutations.SET_LOADING, false)
          }
        }
      })
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Uploading File')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}
</script>

<style lang="scss">
.ql-editor ul {
  padding-left: 0 !important;
}

#announcement-admin-header .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
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

.back-button {
  margin-left: -10px;
}

</style>
