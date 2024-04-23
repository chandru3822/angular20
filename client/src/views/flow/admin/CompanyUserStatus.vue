<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Company User Status</v-toolbar-title>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="statusTypes"
            :fixed-header="true"
            :items-per-page="-1"
            single-expand
            :expanded.sync="expanded"
            :mobile-breakpoint="0"
            hide-default-footer
            class="elevation-1 org-type-table"
        >
          <template #no-data>
            <span class="default-text-color">NO DATA HERE!</span>
          </template>

          <template #no-results>
            <span class="default-text-color">NO DATA HERE!</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': statusTypes.indexOf(item) % 2}">
              <h3>Edit User Status</h3>
              <div class="mb-3">
                <label>Has Access:</label>
                <input class="ml-3" type="checkbox" v-model="item.hasAccess">
              </div>
              <a-btn class="mr-2" text="Save"
                     @click="saveCompanyUserStatusType(item)">
              </a-btn>
            </td>
          </template>

          <template #item="{ item }">
            <tr class="text-left" :class="{'shaded-row': statusTypes.indexOf(item) % 2}">
              <td class="text-left">{{ item.userStatusType }}</td>
              <td>
                <input type="checkbox" v-model="item.hasAccess" disabled readonly>
              </td>
              <td class="text-right">
                <a-btn variant="text" size="small" v-if="!expanded.includes(item)" @click="expanded = [item]">
                  <v-icon>edit</v-icon>
                </a-btn>
                <a-btn size="small" text="Cancel" v-if="expanded.includes(item)" @click="expanded = []"></a-btn>
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>
import {handleHidingGlobalLoader, putRequest} from '@/helpers/helpers'
import {getUserStatusTypes} from '@/services/userService'
import {getCurrentInstance, onMounted, ref} from 'vue'

import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()


const statusTypes = ref([])
const userId = ref(userStore.details.id)
const companyId = ref(userStore.details.companyId)
const expanded = ref([])
const headers = ref([
  {text: 'User Status Type', value: 'userStatusType', show: true},
  {text: 'Has Access', value: 'hasAccess', show: true},
  {text: null, value: 'icons', show: true, sortable: false}
])

onMounted(() => {
  getCompanyUserStatusTypes()
})

const getCompanyUserStatusTypes = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getUserStatusTypes()
    statusTypes.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Loading Company User Status Types')
    appStore.loading = false
  }
}
const saveCompanyUserStatusType = async (type) => {
  appStore.loading = true
  try {
    const {status} = await putRequest(`/user/statusType`, type)
    expanded.value = []
    appStore.showSnack('SUCCESS', 'User Status Type Updated')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Updating User Status')
    appStore.loading = false
  }
}
</script>
