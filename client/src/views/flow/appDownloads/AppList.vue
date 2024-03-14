<template>
  <v-main>
    <v-alert color="success lighten-1" v-model="betaUpdatedAlertSuccess" dismissible transition="scale-transition">Beta Updated Successfully!</v-alert>
    <v-alert color="error lighten-1" v-model="betaUpdatedAlertFailed" dismissible transition="scale-transition">Beta Update Failed</v-alert>
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
        <AlbatrossButton
            variant="text"
            color="primary"
            size="x-small"
            @click="editMinVersion = !editMinVersion"
            class="d-inline-block"
            :prepend-icon="!editMinVersion ? 'edit' : 'close'"
        ></AlbatrossButton>
        <AlbatrossButton
            variant="text"
            color="primary"
            size="x-small"
            v-if="editMinVersion"
            @click="saveMinVersion()"
            class="d-inline-block"
            prepend-icon="save"
        ></AlbatrossButton>
      </div>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <AlbatrossButton
            variant="text"
            color="primary"
            @click="[addNew = !addNew, newApp = {}]"
            v-if="userCanAdd"
            prepend-icon="add"
        ></AlbatrossButton>
        <AlbatrossButton
            v-if="isIos"
            variant="text"
            color="primary"
            @click="showIos = !showIos"
            prepend-icon="mdi-chevron-down"
        ></AlbatrossButton>
        <AlbatrossButton
            v-else
            variant="text"
            color="primary"
            @click="showAndroid = !showAndroid"
            prepend-icon="mdi-chevron-down"
        ></AlbatrossButton>
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

      <AlbatrossButton
          color="primary"
          :disabled="!newApp.versionNumber || !newApp.buildNumber || (!newApp.attachment || !newApp.attachment.name) || (isIos && (!newApp.secondaryAttachment || !newApp.secondaryAttachment.name))"
          @click="saveNewApp"
          text="Save"
      ></AlbatrossButton>
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
            <AlbatrossButton
                variant="text"
                color="primary"
                small
                v-if="isIos"
                :href="`itms-services://?action=download-manifest&url=https://7oaks-albatross.s3.amazonaws.com/${item.s3Key}`"
                prepend-icon="download"
            ></AlbatrossButton>
            <AlbatrossButton
                variant="text"
                color="primary"
                small
                v-else
                :href="item.presignedUrl"
                prepend-icon="download"
            ></AlbatrossButton>
          </td>
          <td class="text-left">
            {{item.buildNumber}}
          </td>
          <td class="text-left">
            {{ item.versionNumber }}
          </td>
          <td class="text-left" v-if="userCanEdit">
            {{ item.mobileBranch }}
          </td>
          <td class="text-left">
            {{item.dateCreated | formatDate('timestamp')}}
          </td>
          <td class="px-0" v-if="userCanEdit">
            <AlbatrossButton
                v-if="userCanDelete"
                variant="text"
                color="primary"
                @click="appToDelete = item"
                prepend-icon="delete"
            ></AlbatrossButton>
            <AlbatrossButton
                v-if="userCanEdit"
                size="small"
                variant="text"
                color="primary"
                @click="appToShowHide = item"
                :text="item.show ? 'hide' : 'show'"
            ></AlbatrossButton>
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

<script setup>

import {
  handleHidingGlobalLoader,
  deleteRequest,
  putRequest,
  putRequestWithRequestParams,
  getRequestWithParams,
  getRequest,

  postRequest
} from '@/helpers/helpers'
  ;
import constants from '@/helpers/constants'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const props = defineProps({
  isIos: Boolean
})
const { isIos } = toRefs(props)

const emit = defineEmits(['versionNumberLoaded'])

const showIos = ref(true)
const addNew = ref(false)
const apps = ref([])
const newApp = ref({})
const minVersion = ref(null)
const buildNumbers = ref([])
const editMinVersion = ref(false)
const showAndroid = ref(true)
const isMobile = ref(false)
const appToDelete = ref(null)
const appToShowHide = ref(null)
const appToToggleBeta = ref(null)
const betaUpdatedAlertSuccess = ref(false)
const betaUpdatedAlertFailed = ref(false)
const appTypeId = ref(isIos.value ? 1 : 3)

const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('APP_DOWNLOADS', 'ADD')
})
const userCanViewAll = computed(() => {
  return userStore.userHasFeatureAccessLevel('APP_DOWNLOADS', 'VIEW_ALL')
})
const userCanView = computed(() => {
  return userStore.userHasFeatureAccessLevel('APP_DOWNLOADS', 'VIEW')
})
const userHasBeta = computed(() => {
  return userStore.userHasFeatureAccessLevel('APP_DOWNLOADS', 'VIEW_CUSTOM')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('APP_DOWNLOADS', 'EDIT')
})
const userCanDelete = computed(() => {
  return userStore.userHasFeatureAccessLevel('APP_DOWNLOADS', 'DELETE')
})
const headers = computed(() => {
  return [
    {text: '', value: 'dlIcon', show: true, width: 40},
    {text: 'Build', value: 'buildNumber', show: true},
    {text: 'Version', value: 'version', show: true},
    {
      text: 'Branch',
      value: 'mobileBranch',
      show: userStore.userHasFeatureAccessLevel('APP_DOWNLOADS', 'EDIT')
    },
    {text: 'Created', value: 'dateCreated', show: true},
    {text: '', value: 'icons', width: 175, show: userStore.userHasFeatureAccessLevel('APP_DOWNLOADS', 'EDIT')},
    {
      text: 'Beta',
      value: 'beta',
      show: userStore.userHasFeatureAccessLevel('APP_DOWNLOADS', 'VIEW_CUSTOM') || userStore.userHasFeatureAccessLevel('APP_DOWNLOADS', 'EDIT')
    }
  ]
})
const filterHeaders = computed(() => {
  return headers.value.filter(header => header.show === true)
})
const appToDeleteName = computed(() => {
  return appToDelete.value ? appToDelete.value.filename : ''
})
const hideOrShowApp = computed(() => {
  return appToShowHide.value ? appToShowHide.value.show : false
})

onMounted(() => {
  getApps()
  getMinVersion()
  getAvailableBuildNumbers()
  let userAgent = window.navigator.userAgent
  if(userAgent && userAgent.includes('Android')){
    showIos.value = false
    isMobile.value = true
  } else if (userAgent && (userAgent.includes('iPhone') || userAgent.includes('iPad'))) {
    showAndroid.value = false
    isMobile.value = true
  }
})
const saveNewApp = async() => {
  appStore.loading = true
  const formData = new FormData()
  formData.append('versionNumber', newApp.value.versionNumber);
  formData.append('buildNumber', newApp.value.buildNumber);
  formData.append('attachment', newApp.value.attachment);
  formData.append('secondaryAttachment', newApp.value.secondaryAttachment);

  let url = isIos.value ? '/app/ios' : '/app/android'
  await postRequest(url, formData)
  newApp.value = {}
  addNew.value = false
  //reload it all cuz i'm lazy
  await getApps()
}
const uploadFile = (file) => {
  newApp.value.attachment = file
}
const uploadSecondaryFile = (file) => {
  newApp.value.secondaryAttachment = file
}
const getApps = async() => {
  appStore.loading = true
  try {
    let url = isIos.value ? '/app/ios' : '/app/android'
    const {data, status} = await getRequest(url)
    apps.value = data
    let versionNumber = apps.value[0].versionNumber
    emit('versionNumberLoaded', versionNumber)
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Apps')

    appStore.loading = false
  }
}
const saveMinVersion = async () => {
  appStore.loading = true
  try {
    const {status} = await putRequestWithRequestParams(`/app/${appTypeId.value}/minVersion`, null, { minVersion: minVersion.value})
    editMinVersion.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Min Build Number')

    appStore.loading = false
  }
}
const getAvailableBuildNumbers = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequestWithParams(`/app/${appTypeId.value}/buildNumbers`)
    buildNumbers.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Build Numbers')

    appStore.loading = false
  }
}
const getMinVersion = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequestWithParams(`/app/${appTypeId.value}/minVersion`)
    minVersion.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Min Build Number')

    appStore.loading = false
  }
}
const deleteApp = async() => {
  const item = appToDelete.value
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/app/${item.id}`)
    item.archived = true
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Apps')

    appStore.loading = false
  }
}
const showHideApp = async() => {
  const app = appToShowHide.value
  appStore.loading = true
  try {
    app.show = !app.show
    const {status} = await putRequest(`/app/show`, app)
    app.showConfirm = false
    appToShowHide.value = null
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Updating App')

    appStore.loading = false
  }
}
const toggleBetaForApp = async() => {
  const app = appToToggleBeta.value
  appStore.loading = true
  try {
    const {status} = await putRequest(`/app/beta`, app)
    app.showConfirm = false
    appToToggleBeta.value = null
    handleHidingGlobalLoader( status)
    betaUpdatedAlertSuccess.value = true
    betaUpdatedAlertFailed.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Updating App')

    appStore.loading = false
    betaUpdatedAlertSuccess.value = false
    betaUpdatedAlertFailed.value = true
  }
}
const getFilteredApps = () => {
  //filter archived
  return apps.value.filter(a => {
    //user can view all or can edit then return all unarchived
    return userCanEdit.value || userCanViewAll.value ? !a.archived :
        //if they have beta AND view access then just show them all the shown apps regardless of beta status
        userHasBeta.value && userCanView.value ? !a.archived && a.show :
            //if they ONLY have beta then only show them shown beta apps
            userHasBeta.value ? !a.archived && a.show && a.beta :
                //otherwise they should only have view acces and only show them shown non-beta apps
                a.show && !a.archived && !a.beta
  })
}

</script>

<style lang="scss">
.default-row {
  background-color: #c3fad2 !important;
}
</style>

