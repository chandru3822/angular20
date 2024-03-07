<template>
  <v-container v-if="logoLoaded" class="home-page home-background"
               :style="{'background-image': null != homePageLogo.presignedUrl
                  ? `url(${homePageLogo.presignedUrl})` : ''}">
    <v-card color="white" class="home-card">
      <v-card-title>Welcome to Albatross!</v-card-title>
      <v-card-text>
        <v-autocomplete v-if="!userIsAlbatross"
                        v-model="user.homePageCompanyFeatureId"
                        :items="homePages"
                        label="Set a Default Home Page"
                        clearable
                        item-text="featureName"
                        item-value="id"
                        autocomplete="off"
                        persistent-hint
                        hint="* This will be used the next time you log in and can be changed at any time under Settings - User Profile"
                        type="search"
                        attach
        ></v-autocomplete>
        <AlbatrossButton @click="saveUserHomePage"
               v-if="!userIsAlbatross"
               text="Save"
               class="mt-4">
        </AlbatrossButton>
      </v-card-text>
    </v-card>
  </v-container>
</template>

<script setup>

import {AppMutations} from "@/stores/AppStore";
import {handleHidingGlobalLoader, getRequest, getSnackbar, putRequest} from "@/helpers/helpers";
import {Actions} from "@/store";
import {getCurrentInstance, onMounted, ref} from 'vue'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton"
import { useUserStore } from '@/stores/UserStorePinia.js'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
const router = vueInstance.$router
const snackbar = vueInstance.$snackbar

const logoLoaded = ref(false)
const homePages = ref([])
const homePageLogo = ref({})
const homePageAttachmentTypeId = 333
const companyId = ref(userStore.details.companyId)
const userIsAlbatross = ref(userStore.details.highestCompanyId === 1)
const user = ref(userStore.details)

onMounted(() => {
  loadHomePageLogo()
  getHomePages()
})

const saveUserHomePage = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    let tempUsr = {
      homePageCompanyFeatureId: user.value.homePageCompanyFeatureId
    }
    const {status} = await putRequest(`/user/homePage`, tempUsr)
    snackbar('SUCCESS', 'Default Home Page Saved')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Default Home Page')
  }
}
const getHomePages = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequest(`/feature/homePages`)
    if (status) {
      homePages.value = data.filter(d => {
        return userStore.userHasFeature(d.featureCode)
      })
    }
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Home Pages')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const loadHomePageLogo = async () => {
  try {
    store.commit(AppMutations.SET_LOADING, true)
    await store.dispatch(Actions.FILE_GET_ONE, {
      attachmentTypeId: homePageAttachmentTypeId,
      sourceId: companyId.value,
      callback: async (img) => {
        homePageLogo.value = img
        logoLoaded.value = true
        store.commit(AppMutations.SET_LOADING, false)
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Background Image')
    store.commit(AppMutations.SET_LOADING, false)
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
