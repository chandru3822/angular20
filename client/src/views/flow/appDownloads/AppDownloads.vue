<template>
  <v-container>
    <v-toolbar flat class="app-toolbar">
      <v-toolbar-title class="app-title">Apps</v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-menu v-if="isAdmin"
                v-model="buildMenu"
                bottom
                offset-y
                min-width="350"
                :close-on-content-click="false"
        >
          <template #activator="{on}">
            <AlbatrossButton
                :activation-handler="on"
                variant="text"
                color="primary"
                text="Build App"
            ></AlbatrossButton>
          </template>

          <v-card class="pa-5">
            <!--    cant change this part cuz the steps used are different depending on if the user is an admin or not -->
            <v-autocomplete v-model="newBuild.branch"
                            :items="branches"
                            label="Branch"
                            placeholder="Select one..."
            />
            <v-autocomplete v-model="newBuild.dataSource"
                            :items="dataSources"
                            label="Pointed At Data Source"
                            placeholder="Select one..."
            />
            <v-text-field v-model="newBuild.version"
                          persistent-hint
                          hint="example 2.0.1"
                          placeholder="Version..."/>

            <AlbatrossButton
                class="mt-3"
                :disabled="!newBuild.branch || !newBuild.dataSource || !newBuild.version"
                @click="testBuild"
                color="unset"
                text="Start Build"
            ></AlbatrossButton>
          </v-card>
        </v-menu>
      </v-toolbar-items>
    </v-toolbar>
    <v-row>
      <v-col cols="12" md="6">
        <AppList :apps="apps" :is-ios="true" @versionNumberLoaded="setVersionNumber($event)"></AppList>
      </v-col>
      <v-col cols="12" md="6">
        <AppList :apps="apps" :is-ios="false"></AppList>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
;
import constants from '@/helpers/constants'
import AppList from '@/views/flow/appDownloads/AppList'
import { handleHidingGlobalLoader, putRequest, postRequest } from "@/helpers/helpers";

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

const newBuild = ref({})
const buildMenu = ref(false)
const apps = ref([])
const branches = ref(['stage', 'uat', 'master'])
const dataSources = ref(['stage', 'uat', 'prod', 'flux'])
const headers = ref([
  {text: 'Filename', value: 'filename', show: true},
  {text: 'Version', value: 'version', show: true},
  {text: 'Created', value: 'dateCreated', show: true},
  {text: '', value: 'icons', show: true},
])
onMounted(() => {
  if(is7oaksAdmin.value) {
    branches.value.push('develop')
  }
})

const is7oaksAdmin = computed(() => {
  return userStore.isSystemAdmin
})
const isAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('APP_DOWNLOADS', 'ADMIN')
})

const setVersionNumber = (version) => {
  newBuild.value.version = version || '0.0.0'
}
const testBuild = async() => {
  try {
    let params = {
      version: newBuild.value.version,
      branch: newBuild.value.branch,
      dataSource: newBuild.value.dataSource
    }
    const {status} = await postRequest(`/bitrise/build`, params, 'blueraven')
    snackbar('SUCCESS', 'Build Succeeded')
    buildMenu.value = false

    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Building App')

    appStore.loading = false
  }
}

</script>
