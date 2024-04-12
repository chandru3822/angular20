<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large" :class="{'ml-n6': constants.IS_MOBILE}">
            <a-btn variant="text" icon color="primary" v-if="userIsAdmin && constants.IS_MOBILE" :to="`/settings/userProfile`" prepend-icon="mdi-chevron-left"/>

            User Profile Admin
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items v-if="!constants.IS_MOBILE">
            <a-btn
              variant="text" color="primary" v-if="userIsAdmin"
              :to="`/settings/userProfile`" text="Back to User Profile"
            />
          </v-toolbar-items>
        </v-toolbar>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12" md="6">
        <v-data-table
          :headers="headers"
          :mobile-breakpoint="0"
          :items="userProfileDefaultFields"
          disable-sort
          hide-default-footer
          :fixed-header="true"
          :items-per-page="-1"
          class="elevation-1">

          <template #no-data>
            <span class="default-text-color">No available default fields</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available default fields</span>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.fieldName}}</td>
              <td class="text-center">
                <v-checkbox v-model="item.showOnUserProfile"
                            @change="updateShowOnUserProfile(item)"
                ></v-checkbox>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
  </v-container>
</template>


<script setup>

import {getUserProfileDefaultFields} from '@/services/userService'
import {handleHidingGlobalLoader, putRequest, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'

import {getCurrentInstance, onMounted, ref, computed, watch} from "vue";

import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const store = vueInstance.$store
const userStore = useUserStore()

const userProfileDefaultFields = ref([])
const headers = ref([
  {text: 'Field Name', value: 'fieldName'},
  {text: 'Show On User Profile', value: 'showOnUserProfile'},
])

const userIsAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('USERS', 'ADMIN')
})


onMounted(async () => {
  getAllUserProfileDefaultFields()
})

const getAllUserProfileDefaultFields = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getUserProfileDefaultFields()
    userProfileDefaultFields.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Default Fields')
    loadingUserProfileCustomFields.value = false
    appStore.loading = false
  }
}
const updateShowOnUserProfile = async (item) => {
  appStore.loading = true
  try {
    const {status} = await putRequest(`/defaultField`, item)
    snackbar('SUCCESS', 'Saved Changes')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Changes')
    appStore.loading = false
  }
}
</script>
<style scoped lang="scss">
  .app-toolbar {
    width: 100vw;
    }

</style>
