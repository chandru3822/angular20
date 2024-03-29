<template>
  <v-container>
    <confirmation-dialog :open-dialog="!!unsavedFieldsModal" @close-dialog="unsavedFieldsModal = false"
                         @confirm="[navigationOverride = true, goToPath(toPath)]">
      <template v-slot:title>Unsaved Changes</template>
      You have unsaved changes. Are you sure you want to continue without saving?
      <template v-slot:no>Cancel</template>
      <template v-slot:yes>Don't Save</template>
    </confirmation-dialog>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat elevation="0" class="app-toolbar">
          <v-toolbar-title class="title-large">Account</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <!--mobile save button-->
            <a-btn v-if="isMobile" variant="text" icon large color="primary" @click="validate" prepend-icon="mdi-content-save"/>
            <!--normal save button-->
            <a-btn v-else variant="text" color="primary" @click="validate" prepend-icon="mdi-content-save" text="SAVE CHANGES"/>
            <!--mobile admin button-->
            <a-btn
              v-if="isMobile && userIsAdmin"
              variant="text"
              icon
              large
              color="primary"
              class="pl-6"
              :to="`/settings/userProfileAdmin`"
              prepend-icon="mdi-cogs"
            />
            <!--normal admin button-->
            <a-btn variant="text" color="primary" v-else-if="userIsAdmin" :to="`/settings/userProfileAdmin`" prepend-icon="mdi-cogs" text="ADMIN"/>
          </v-toolbar-items>
        </v-toolbar>
      </v-col>
    </v-row>
    <v-row>
      <v-col>
        <a-btn v-if="!notificationsEnabled" @click="getNotificationToken" text="GET NOTIFIED"/>
        <a-btn v-else @click="removeNotificationToken" text="REMOVE NOTIFICATIONS"/>
      </v-col>
    </v-row>
    <v-form ref="userForm">
      <v-row>
        <v-col cols="12" md="6">
<!--          yes, i realize this should be done better. buuuuut i just dont wanna -->
          <a-text-field v-model="user.firstName"
                        placeholder="Enter a value"
                        required
                        v-if="showOnUserProfile('First Name')"
                        :rules="requiredRules"
                        @change="setFieldsDirty"
                        label="First Name">
          </a-text-field>
          <a-text-field v-model="user.lastName"
                        placeholder="Enter a value"
                        required
                        v-if="showOnUserProfile('Last Name')"
                        :rules="requiredRules"
                        @change="setFieldsDirty"
                        label="Last Name">
          </a-text-field>
          <a-text-field v-model="user.email"
                        placeholder="Enter a value"
                        required
                        v-if="showOnUserProfile('Email')"
                        :rules="emailRules"
                        @change="setFieldsDirty"
                        label="E-mail">
          </a-text-field>
          <a-text-field v-model="user.username"
                        placeholder="Enter a value"
                        required
                        v-if="showOnUserProfile('Username')"
                        type="search"
                        :rules="usernameRules"
                        @change="setFieldsDirty"
                        label="Username">
          </a-text-field>
          <a-text-field v-model="user.phoneNumber"
                        :rules="userPhoneRule"
                        placeholder="Enter a value"
                        v-if="showOnUserProfile('Phone')"
                        required
                        @change="setFieldsDirty"
                        label="Phone">
          </a-text-field>
          <a-text-field v-model="user.newPassword"
                        v-if="!userIsMasquerading && showOnUserProfile('Password')"
                        placeholder="Enter a new password"
                        type="password"
                        autocomplete="new-password"
                        :rules="[passwordRule]"
                        @change="setFieldsDirty"
                        label="Change Password">
          </a-text-field>
          <a-text-field v-model="user.newPasswordConfirm"
                        v-if="!userIsMasquerading && showOnUserProfile('Password')"
                        placeholder="Verify password"
                        :required="user.newPassword?.length > 0"
                        type="password"
                        autocomplete="new-password"
                        :rules="[passwordRule]"
                        @change="setFieldsDirty"
                        label="Confirm Password">
          </a-text-field>
        </v-col>
      </v-row>
    </v-form>
    <v-divider class="mt-3 mb-3" v-if="smsTeams && smsTeams.length > 0"></v-divider>
    <v-row v-if="smsTeams && smsTeams.length > 0">
      <v-col cols="12" md="6">
        <h3 class="title-medium">Preferences</h3>
        <v-card flat color="transparent">
          <v-autocomplete v-if="!userIsAlbatross && showOnUserProfile('Default Home Page')"
                          v-model="user.homePageCompanyFeatureId"
                          :items="homePages"
                          label="Default Home Page"
                          clearable
                          item-text="featureName"
                          item-value="id"
                          autocomplete="off"
                          type="search"
                          @change="setFieldsDirty"
                          attach
          ></v-autocomplete>
          <v-autocomplete v-if="!userIsAlbatross && showOnUserProfile('Default Project Page')"
                          v-model="user.defaultProjectPage"
                          :items="projectPages"
                          label="Default Project Page"
                          clearable
                          item-text="tabName"
                          item-value="uniqueIdentifier"
                          autocomplete="off"
                          type="search"
                          @change="setFieldsDirty"
                          attach
          ></v-autocomplete>
          <v-select attach
                    v-model="user.notificationTypeId"
                    :items="userNotificationTypes"
                    label="Notification"
                    v-if="showOnUserProfile('Notification')"
                    item-text="userNotificationType"
                    item-value="id"
                    @change="setFieldsDirty"
                    autocomplete="off">
          </v-select>
          <div v-for="item in smsTeams" class="unassigned-notif-div d-flex">
            <span class="mt-4">{{ item.teamName }} SMS Team:</span>
            <v-checkbox class="pl-4 py-0" @change="checkForDeselect(item)" v-model="item.receiveUnassignedNotifications" label="Receive notifications for team's unassigned messages"></v-checkbox>
          </div>
        </v-card>
      </v-col>
    </v-row>
    <v-divider class="mt-3 mb-3" v-if="userProfileCustomFields && userProfileCustomFields.length > 0"></v-divider>
    <v-row v-if="userProfileCustomFields && userProfileCustomFields.length > 0">
      <v-col cols="12" md="6">
        <h3 class="title-medium pb-2">Miscellaneous</h3>
        <SpinnerInline v-if="loadingUserProfileCustomFields" :text="'Checking For Additional Fields...'" :size="20" color="primary"/>
        <CustomValueInput v-for="(cf, idx) in userProfileCustomFields"
                          :key="idx"
                          :callback="populateDirtyCfvs"
                          :required="cf.required"
                          :field="cf"
                          :showFieldName="false">
        </CustomValueInput>
      </v-col>
    </v-row>
    <v-divider class="mt-3 mb-3"></v-divider>
    <v-row v-if="showOnUserProfile('Profile Image')">
      <v-col cols="12">
        <v-toolbar color="white" flat>
          <v-toolbar-title class="title-large">Profile Image</v-toolbar-title>
          <v-spacer></v-spacer>
          <a-btn variant="text" v-if="!savingUserImage && !profileImage.presignedUrl"  @click="addImage = !addImage"
            :prepend-icon="addImage ? 'remove' : 'add'"
          />
          <a-btn v-else variant="text" icon :large="isMobile" color="primary" class="mr-2" @click="deleteAttachment(profileImage.id)" prepend-icon="delete"/>
        </v-toolbar>
        <div class="text-center">
          <div class="mt-4" v-if="addImage">
            <form enctype="multipart/form-data" novalidate>
              <input
                  type="file"
                  :accept="acceptedFileTypes"
                  class="file-input clickable"
                  :disabled="savingUserImage"
                  @change="uploadFile($event.target.files, attachmentTypeId, userId, 2097152)"
                  name="avatar"
              >
              <br/><span>* Due to render times associated with this file it cannot exceed 2MB</span>
            </form>
          </div>
          <img class="user-profile-image" v-else-if="profileImage.presignedUrl" :src="profileImage.presignedUrl">
          <div class="mt-4" v-else>
            No image uploaded
          </div>
        </div>
      </v-col>
    </v-row>
    <ConfirmationDialog
      :open-dialog="notificationToRemove"
      @confirm="[notificationToRemove.receiveUnassignedNotifications = true, notificationToRemove = null]"
      @close-dialog="[notificationToRemove=null]">
      <span class="error--text">WARNING:</span>
      If you uncheck this box, you will no longer be notified about
      unassigned customer messages. If you are the only person monitoring
      these messages on your team, we recommend keeping this box checked.<br/><br/>
      Are you sure you do not want to get notified about <strong>{{ teamNameToRemoveNotif }}'s unassigned team messages</strong>?
      <template v-slot:title>Confirm</template>
      <template v-slot:no>Do not notify</template>
      <template v-slot:yes>I want to receive notifications</template>
    </ConfirmationDialog>
  </v-container>
</template>


<script setup>
import SpinnerInline from '@/components/SpinnerInline'
import ConfirmationDialog from '@/components/ConfirmationDialog'

import moment from 'moment'
import {getUserProfileDefaultFields} from '@/services/userService'

import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import {handleHidingGlobalLoader, getRequest, putRequest, postRequest} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import { useFirebase } from '@/firebase/firebase.js'

import { onBeforeRouteLeave } from 'vue-router/composables'
import {getCurrentInstance, onMounted, ref, computed} from "vue";

import { useUserStore } from '@/stores/UserStorePinia.js'
import { useFileStore } from '@/stores/FileStore.js'
import {useRouter} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStorePinia.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify
const store = vueInstance.$store
const userStore = useUserStore()
const fileStore = useFileStore()
const router = useRouter()

const { registered, getNotificationToken, removeNotificationToken } = useFirebase()

const loadComplete = ref(false)
const addImage = ref(false)
const userPhoneRule = ref([
  v => (!v || (v && (v.length <= 20))) || 'Must be 20 characters or less',
  v => (!v || (/^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$/.test(v))) || "Please reformat the Phone field with a valid phone number"
])
const loadingUserProfileCustomFields = ref(false)
const userProfileCustomFields = ref([])
const userProfileDefaultFields = ref([])
const dirtyCfvs = ref([])
// timeValue: '2014-06-01T12:00:00Z',
// timeValue: moment.utc().format('YYYY-MM-DD HH:mm Z'),
const timeValue = ref(moment.utc().format('YYYY-MM-DDTHH:mm:ssZ'))
const user = ref({})
const homePages = ref([])
const projectPages = ref([])
const userIsAlbatross = ref(false)
const userIsMasquerading = ref(userStore.details?.masqueradingUserId != null)
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
const emailRules = ref(constants.EMAIL_RULES)
const usernameRules = ref(constants.USERNAME_RULES)
const acceptedFileTypes = ref(constants.STANDARD_IMAGES_ONLY)
const savingUserImage = ref(false)
const attachmentTypeId = ref(9)
const userId = ref(userStore.details.id)
const profileImage = ref({})
const userNotificationTypes = ref([
  {
    id: 1,
    userNotificationType: 'Email'
  },
  {
    id: 2,
    userNotificationType: 'SMS'
  }
])
const smsTeams = ref([])
const notificationToRemove = ref(null)
const unsavedFieldsModal = ref(false)
const navigationOverride = ref(false)
const toPath = ref(null)
const dirtyFields = ref(false)

const userIsAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('USERS', 'ADMIN')
})
const notificationsEnabled = computed(() => {
  return registered.value
})
const teamNameToRemoveNotif = computed(() => {
  return notificationToRemove.value ? notificationToRemove.value.teamName : ''
})
const isMobile = computed(()=> {
  return vuetify.breakpoint.smAndDown
})
onMounted(async () => {
  if(userStore.isSystemAdmin) {
    //this was all super dumb because we can't load albatross users the same way as regular users
    userIsAlbatross.value = true
    await getUser(userIsAlbatross.value)
  } else {
    await getAllUserProfileDefaultFields()
    await getUserProfileCustomFields()
    await getHomePages()
    await getProjectPages()
    await getUser(false)
    await getSmsTeams()
  }
  await loadProfileImage()
})
onBeforeRouteLeave(async (to, from, next) => {
  // called when the route that renders this component is about to
  // be navigated away from.
  // has access to `this` component instance.
  if (navigationOverride.value || !dirtyFields.value) {
    //navigationOverride gets set to true if they click "Yes" to continue. if you don't override then it just hits the else again before navigating
    next()
  } else {
    toPath.value = to.path
    unsavedFieldsModal.value = true
  }
})
const validate = () => {
  if (vueInstance.$refs.userForm.validate()) {
    saveUser()
  }
}
const passwordRule = (value) => {
  if (value && value.length < 8) {
    return 'Password must be at least 8 characters'
  } else if ((user.value.newPassword && !user.value.newPasswordConfirm) || (user.value.newPasswordConfirm && !user.value.newPassword)) {
    return 'Both Password Fields Are Required'
  } else if (value && user.value.newPasswordConfirm && user.value.newPassword !== user.value.newPasswordConfirm) {
    return 'Password Fields Must Match'
  } else {
    return true
  }
}
const showOnUserProfile = (fieldName) => {
  return userProfileDefaultFields.value.filter(df => df.fieldName === fieldName).length > 0
}
const getUserProfileCustomFields = async () => {
  loadingUserProfileCustomFields.value = true
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/customFieldValues/getUserProfileFields`)
    userProfileCustomFields.value = data
    loadingUserProfileCustomFields.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Custom Fields')
    loadingUserProfileCustomFields.value = false

    appStore.loading = false
  }
}
const getAllUserProfileDefaultFields = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getUserProfileDefaultFields()
    userProfileDefaultFields.value = data.filter(d => d.showOnUserProfile)
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Default Fields')
    loadingUserProfileCustomFields.value = false
    appStore.loading = false
  }
}
const getHomePages = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/feature/homePages`, null, [])
    homePages.value = data.filter(d => {
      return userStore.userHasFeature(d.featureCode)
    })
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Home Pages')
    appStore.loading = false
  }
}
const getProjectPages = async () => {
  try {
    const {data, status} = await getRequest(`/objectTypeTab/project`, null, [])
    data.unshift({
      archived: false,
      companyObjectTypeId: 1,
      displayOrder: data.length,
      id: -5,
      tabName: "All Events",
      uniqueIdentifier: "tab_events"
    })
    data.unshift({
      archived: false,
      companyObjectTypeId: 1,
      displayOrder: data.length,
      id: -4,
      tabName: "All Process Steps",
      uniqueIdentifier: "tab_processSteps"
    })
    data.unshift({
      archived: false,
      companyObjectTypeId: 1,
      displayOrder: data.length,
      id: -3,
      tabName: "Status",
      uniqueIdentifier: "tab_status"
    })
    data.push({
      archived: false,
      companyObjectTypeId: 1,
      displayOrder: data.length,
      id: -1,
      tabName: 'Uploaded and Linked Documents',
      uniqueIdentifier: 'tab_documents'
    })
    data.push({
      archived: false,
      companyObjectTypeId: 1,
      displayOrder: data.length + 1,
      id: -2,
      tabName: 'Current Work Queues',
      uniqueIdentifier: 'tab_work_queues'
    })

    projectPages.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Project Pages')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getUser = async (userIsAlbatross) => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/user/${userId.value}?userIsAlbatross=${userIsAlbatross}`)
    user.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving User')
    appStore.loading = false
  }
}
const saveUser = async () => {
  appStore.loading = true
  userStore.details.defaultProjectPage = user.value.defaultProjectPage
  try {
    const {data, status} = await putRequest(`/user?userIsAlbatross=${userIsAlbatross.value}`, user.value)
    if(data && data.id && dirtyCfvs.value?.length > 0) {
      await postRequest(`/customFieldValues/user/${data.id}`, dirtyCfvs.value)
    }
    if (smsTeams.value?.length > 0) {
      const {data, status} = await putRequest(`/user/${userId.value}/saveSmsTeamNotifications`, smsTeams.value)
    }
    user.value.newPassword = null
    user.value.newPasswordConfirm = null
    snackbar('SUCCESS', 'Saved Changes')
    dirtyFields.value = false;
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    let errorMsg = e?.message ? 'Error Saving User: ' + e.message : e?.data?.message ? 'Error Saving User: ' + e.data.message :'Error Saving User'
    snackbar('ERROR', errorMsg)
    appStore.loading = false
  }
}
const deleteAttachment = async (id) => {
  try {
    appStore.loading = true
    await fileStore.deleteFile({
      id,
      callback: async () => {
        profileImage.value = {}
        userStore.userImage = {}
        snackbar('SUCCESS', 'Image Deleted')
        appStore.loading = false
      }
    })
  } catch(e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting File')
    appStore.loading = false
  }
}
const uploadFile = async (files, attachmentTypeId, sourceId, sizeLimit) => {
  try {
    appStore.loading = true
    let file = files[0]
    await fileStore.uploadFile({
      file: file,
      attachmentTypeId,
      sizeLimit,
      sourceId,
      displayName: file.name.substr(0, file.name.lastIndexOf('.')),
      callback: async (img, error) => {
        if(error?.error) {
          snackbar('ERROR', error.errorMsg)

          appStore.loading = false
        } else {
          profileImage.value = img
          userStore.userImage = img
          addImage.value = false
          snackbar('SUCCESS', 'Image Uploaded')
          appStore.loading = false
        }
      }
    })
  } catch(e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Uploading File')
    appStore.loading = false
  }
}
const loadProfileImage = async () =>{
  try {
    appStore.loading = true
    await fileStore.getOne({
      attachmentTypeId: attachmentTypeId.value,
      sourceId: userId.value,
      callback: async (img) => {
        profileImage.value = img
        appStore.loading = false
      }
    })
  } catch(e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Image')
    appStore.loading = false
  }
}
const populateDirtyCfvs = (field) => {
  dirtyFields.value = true;
  let match = dirtyCfvs.value.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
  if (!match) {
    dirtyCfvs.value.push(field)
  }
}
const setFieldsDirty = () => {
  dirtyFields.value = true;
}
const getSmsTeams = async () =>{
  appStore.loading = true
  try {
    const { data, status } = await getRequest(`/user/getTeamsForUser/${userId.value}`)
    smsTeams.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving User')
    appStore.loading = false
  }
}
const checkForDeselect = (item) => {
  dirtyFields.value = true;
  if (!item.receiveUnassignedNotifications) {
    notificationToRemove.value = item;
  }
}
const goToPath = (path, targetBlank) => {
  if (targetBlank) {
    let routerData = router.resolve({path})
    window.open(routerData.href, '_blank')
  } else {
    router.push(path)
  }
}
</script>

<style scoped lang="scss">
.user-profile-image {
  margin-top: 15px;
  max-width: 200px;
  height: auto;
  border-radius: 50%;
}

.app-toolbar {
  width: 100vw;
}

.unassigned-notif-div {
  width: 700px;
  height: 40px;
  max-width: calc(100vw - 28px);
}
</style>
