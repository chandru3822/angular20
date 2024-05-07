<template>
  <v-container class="pt-0">
    <v-dialog width="500" v-model="unsavedFieldsModal">
      <v-card>
        <v-card-title
            class="text-h5 grey lighten-2"
            primary-title
        >
          Confirm
        </v-card-title>

        <v-card-text class="pt-4">
          You have unsaved {{getDirtyText()}}. <br/>
          Are you sure you want to continue without saving?
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions>
          <v-spacer></v-spacer>
          <a-btn
              @click="unsavedFieldsModal = false"
              color="unset"
              text="No"
          ></a-btn>
          <a-btn
              color="primary"
              variant="text"
              @click="[navigationOverride = true, goToPath(toPath)]"
              text="Yes"
          ></a-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-row>
      <v-col cols="12" style="padding-bottom: 0; padding-top: 0;" class="text-left user-header-breadcrumbs">
        <a-btn
            size="small"
            variant="text"
            color="primary"
            :to="`/users`"
            prepend-icon="mdi-chevron-left"
            text="Back to users"
        ></a-btn>
      </v-col>
    </v-row>
    <v-row class="user-header">
      <v-col cols="12" class="py-0">
        <v-toolbar flat color="transparent" class="app-toolbar">
          <v-tooltip bottom max-width="300px" content-class="user-img-tooltip">
            <template v-slot:activator="{ on:tooltip }">
              <v-avatar :tile="false"
                        v-on="{ ...tooltip }"
                        :size="50"
                        color="grey lighten-4"
                        @click="doChangePhoto()"
                        class="clickable account-img mr-3"
              >
                <v-img name="userImg" alt="user-image" v-if="loadComplete && userImage && userImage.presignedUrl && !imageFailed" v-on:error="onImgError()" :src="userImage.presignedUrl"></v-img>
                <img name="userImg" v-else src="../../../assets/flow/user_img_placeholder.png">
              </v-avatar>
            </template>
            <v-card class="user-image-hover-container">
              <v-img name="userImg" v-if="loadComplete && userImage && userImage.presignedUrl" :src="userImage.presignedUrl"></v-img>
              <img name="userImg" v-else src="../../../assets/flow/user_img_placeholder.png">
            </v-card>
          </v-tooltip>
          <form enctype="multipart/form-data" novalidate v-if="changePhoto">
            <input
                type="file"
                :accept="acceptedFileTypes"
                class="file-input clickable"
                @change="uploadUserImage($event.target.files, attachmentTypeId, userId, 2097152)"
                name="avatar"
            >
            <br/><span>* Cannot exceed 2MB</span>
          </form>
          {{user.firstName}} {{user.lastName}}
          <span v-if="null != user.primaryPosition" class="ml-1"> - {{ user.primaryPosition}}</span>

          <a-btn
              class="ml-3 elevation-2"
              v-if="userCanMasquerade && !userIsMasquerading && userId !== loggedInUserId && user.hasAccess"
              color="white"
              icon
              html-style="background-color: var(--v-primary-base);"
              @click="masquerade()"
              append-icon="mdi-account-switch"
          ></a-btn>
          <v-spacer></v-spacer>
          <v-toolbar-items :slot="constants.IS_MOBILE ? 'extension' : 'default'">
            <v-tabs background-color="transparent">
              <v-tab :to="`/user/${userId}/details`">
                Details
              </v-tab>
              <v-tab :to="`/user/${userId}/positions`">
                Positions
              </v-tab>
              <v-tab :to="`/user/${userId}/access`" v-if="userStore.userHasFeatureAccessLevel('ACCESS_CONTROL', 'VIEW')">
                Access
              </v-tab>
            </v-tabs>
          </v-toolbar-items>
        </v-toolbar>
      </v-col>
    </v-row>
    <!--    <v-row>-->
    <!--      <v-col cols="12" style="padding-top: 0">-->
    <router-view ref="userRouterViewContainer"/>
    <!--      </v-col>-->
    <!---->
    <!--    </v-row>-->
  </v-container>
</template>

<script setup>

import axios from 'axios'
import {handleHidingGlobalLoader, getRequest, } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import { useFileStore } from '@/stores/FileStore.js'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter, onBeforeRouteLeave} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import { useScheduleStore } from '@/stores/ScheduleStore.js'

const appStore = useAppStore()
const fileStore = useFileStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const scheduleStore = useScheduleStore()


const breadcrumbs = ref([
  {text: 'Back to Users',disabled: false,exact: true,to: `/users`},
])
const changePhoto = ref(false)
const acceptedFileTypes = ref(constants.STANDARD_IMAGES_ONLY)
const user = ref({})
const userId = ref(parseInt(route.params.id))
const userImage = ref({})
const unsavedFieldsModal = ref(false)
const hasDirtyFields = ref(false)
const hasDirtyNotes = ref(false)
const toPath = ref(null)
const navigationOverride = ref(false)
const loadComplete = ref(false)
const userStatusTypes = ref([])
const attachmentTypeId = ref(9)
const imageFailed = ref(false)
const userRouterViewContainer = ref(null)

onMounted(() => {
  getUser()
  getUserImage()
})

onBeforeRouteLeave(async (to, from, next) => {
  // called when the route that renders this component is about to
  // be navigated away from.
  // has access to `this` component instance.
  if(typeof userRouterViewContainer.value?.hasDirtyFields === 'function') {
    hasDirtyFields.value = userRouterViewContainer.value.hasDirtyFields()
  }

  if(typeof userRouterViewContainer.value?.hasDirtyNotes === 'function') {
    hasDirtyNotes.value = userRouterViewContainer.value?.hasDirtyNotes()
  }

  if (to.path === '/login' || navigationOverride.value || (!hasDirtyFields.value && !hasDirtyNotes.value)) {
    to.params.useSavedFilters = "true"
    //navigationOverride gets set to true if they click "Yes" to continue. if you don't override then it just hits the else again before navigating
    next()
  } else {
    toPath.value = to.path
    unsavedFieldsModal.value = true
  }
})

const companyId = computed(() => {
  return userStore.details.companyId
})
const loggedInUserId = computed(() => {
  return userStore.details.id
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('USERS', 'EDIT')
})
const userCanMasquerade = computed(() => {
  return userStore.userHasFeatureAccessLevel('MASQUERADE', 'ADMIN')
})
const userIsMasquerading = computed(() => {
  return userStore?.details?.masqueradingUserId != null
})

const doChangePhoto = () => {
  if(userCanEdit.value) {
    changePhoto.value = !changePhoto.value
  }
}
const getDirtyText = () => {
  return hasDirtyNotes.value && hasDirtyFields.value ?
      'fields and notes' : hasDirtyNotes.value ? 'notes' : 'fields'
}
const goToPath = (path) => {
  router.push(path)
}
const onImgError =  () => {
  imageFailed.value = true
}
const masquerade = async () => {
  appStore.loading = true
  try {
    const {data} = await axios.get(`${constants.VUE_APP_BASE_API}/auth/masquerade/${userId.value}`)
    if(data && data.token) {
      userStore.jwt = data.token
      //update the user
      const {data: currentUser} = await getRequest(`/user/current`)
      userStore.details = currentUser
	  scheduleStore.timezone = currentUser.timezone
      //then reload the screen
      window.location.reload()
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Aliasing as User')

    appStore.loading = false
  }
}
const getUser = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/user/${userId.value}`)
    user.value = data

    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving User')

    appStore.loading = false
  }
}
const uploadUserImage = async (files, attachmentTypeId, sourceId, sizeLimit) => {
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
          appStore.showSnack('ERROR', error.errorMsg)

          appStore.loading = false
        } else {
          userImage.value = img
          changePhoto.value = false
          appStore.showSnack('SUCCESS', 'Image Uploaded')

          appStore.loading = false
        }
      }
    })
  } catch(e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Uploading File')

    appStore.loading = false
  }
}
const getUserImage = async () => {
  try {
    await fileStore.getOne({
      attachmentTypeId: attachmentTypeId.value,
      sourceId: userId.value,
      callback: async (img) => {
        userImage.value = img
        loadComplete.value = true
      }
    })
  } catch(e) {
    console.error('*** ERROR ***', e)
    loadComplete.value = true
  }
}
</script>

<style lang="scss" scoped>

.user-header-breadcrumbs {
  background-color: var(--v-grey-lighten2);
}
.user-header {
  border-bottom: solid 1px #EAEAF4;
  background-color: var(--v-grey-lighten2);
}
.user-image-hover-container {
  max-width: 100%;
  height: auto;
}
.user-img-tooltip {
  background-color: transparent;
  opacity: 1 !important;
  z-index: 200 !important;
}
</style>

