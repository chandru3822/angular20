<template>
  <v-container v-if="logoLoaded" class="home-page home-background"
               :style="{'background-image': null != homePageLogo.presignedUrl
                  ? `url(${homePageLogo.presignedUrl})` : ''}">
    <v-card color="white" class="home-card">
      <v-card-title>Welcome to Albatross!</v-card-title>
      <v-card-text>
        <a-autocomplete v-if="!userIsAlbatross"
                        v-model="user.homePageCompanyFeatureId"
                        :items="homePages"
                        label="Set a Default Home Page"
                        clearable
                        item-title="featureName"
                        item-value="id"
                        autocomplete="off"
                        persistent-hint
                        hint="* This will be used the next time you log in and can be changed at any time under Settings - User Profile"
                        type="search"
                        attach
        ></a-autocomplete>
        <a-btn @click="saveUserHomePage"
               v-if="!userIsAlbatross"
               text="Save"
               class="mt-4">
        </a-btn>
      </v-card-text>
    </v-card>
  </v-container>
</template>

<script setup>

import {handleHidingGlobalLoader, getRequest, putRequest} from "@/helpers/helpers";
import {computed, getCurrentInstance, onMounted, ref} from 'vue'

import { useUserStore } from '@/stores/UserStorePinia.js'
import { useAppStore } from '@/stores/AppStorePinia.js'
import { useFileStore } from '@/stores/FileStore.js'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
const appStore = useAppStore()
const fileStore = useFileStore()
const snackbar = vueInstance.$snackbar

const logoLoaded = ref(false)
const homePages = ref([])
const homePageLogo = ref({})
const homePageAttachmentTypeId = 333

const companyId = computed(() => {
  return userStore.details.companyId
})
const userIsAlbatross = computed(() => {
  return userStore.details.highestCompanyId === 1
})
const user = computed(() => {
  return userStore.details
})

onMounted(() => {
  loadHomePageLogo()
  getHomePages()
})

const saveUserHomePage = async () => {
  appStore.loading = true
  try {
    let tempUsr = {
      homePageCompanyFeatureId: user.value.homePageCompanyFeatureId
    }
    const {status} = await putRequest(`/user/homePage`, tempUsr)
    snackbar('SUCCESS', 'Default Home Page Saved')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Default Home Page')
  }
}
const getHomePages = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/feature/homePages`)
    if (status) {
      homePages.value = data.filter(d => {
        return userStore.userHasFeature(d.featureCode)
      })
    }
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Home Pages')
    appStore.loading = false
  }
}
const loadHomePageLogo = async () => {
  try {
    appStore.loading = true
    await fileStore.getOne({
      attachmentTypeId: homePageAttachmentTypeId,
      sourceId: companyId.value,
      callback: async (img) => {
        homePageLogo.value = img
        logoLoaded.value = true
        appStore.loading = false
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Background Image')
    appStore.loading = false
  }
}
</script>

<style scoped lang="scss">
.home-page {
  height: 100%;
}

.home-card {
  height: 235px;
  width: 50%;
  min-width: 300px;
  margin: auto;
  padding-top: 15px;
  margin-top: 15px;
}

.home-background {
  background-repeat: no-repeat;
  background-size: cover;
  background-position: center;
}
</style>
