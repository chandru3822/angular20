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
              <v-btn color="primary" class="white--text mr-2"
                     @click="saveCompanyUserStatusType(item)">
                Save
              </v-btn>
            </td>
          </template>

          <template #item="{ item }">
            <tr class="text-left" :class="{'shaded-row': statusTypes.indexOf(item) % 2}">
              <td class="text-left">{{ item.userStatusType }}</td>
              <td>
                <input type="checkbox" v-model="item.hasAccess" disabled readonly>
              </td>
              <td>
                <v-btn small text color="primary" v-if="!expanded.includes(item)" @click="expanded = [item]">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text color="primary" v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>
import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, putRequest} from '@/helpers/helpers'
import {getUserStatusTypes} from '@/services/userService'
import {getCurrentInstance, onMounted, ref} from 'vue'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const statusTypes = ref([])
const userId = ref(store.state.user.details.id)
const companyId = ref(store.state.user.details.companyId)
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
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getUserStatusTypes()
    statusTypes.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Company User Status Types')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveCompanyUserStatusType = async (type) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await putRequest(`/user/statusType`, type)
    expanded.value = []
    snackbar('SUCCESS', 'User Status Type Updated')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Updating User Status')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
</script>
