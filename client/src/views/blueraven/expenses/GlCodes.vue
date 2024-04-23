<template>
  <v-container id="gl-code-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">GL Codes</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                @click="[createNew = !createNew, newGlCode = {}]"
                :prepend-icon="!createNew ? 'add' : 'close'"
                hide-text-on-mobile
                :text="createNew ? 'cancel' : 'Add GL Code'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card flat v-if="createNew" class="pa-4">
          <h3>New GL Code</h3>
          <a-text-field
                        type="text"
                        label="GL Code"
                        v-model="newGlCode.code">
          </a-text-field>
          <a-text-field
                        type="text"
                        label="Description"
                        v-model="newGlCode.description">
          </a-text-field>
          <a-btn
              color="primary"
              :disabled="!newGlCode.code || !newGlCode.description"
              @click="saveGlCode(newGlCode, true)"
              text="Save"
          ></a-btn>
        </v-card>
        <v-divider v-if="createNew" ></v-divider>
        <v-data-table
            :headers="headers"
            :items="filteredGlCodes"
            :items-per-page="100"
            fixed-header
            :loading="dataLoading"
            :mobile-breakpoint="0"
            :footer-props="footerProps"
            class="elevation-1 fix-column-width-bug square-card"
        >
          <template #no-data>
            <span class="default-text-color">No GL Codes</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No GL Codes</span>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">
                <a-text-field
                              type="text"
                              v-if="index === editIndex"
                              label="GL Code"
                              v-model="item.code">
                </a-text-field>
                <div v-else>
                  {{ item.code }}
                </div>
              </td>
              <td class="text-left">
                <a-text-field
                              type="text"
                              v-if="index === editIndex"
                              label="Description"
                              v-model="item.description">
                </a-text-field>
                <div v-else>
                  {{ item.description }}
                </div>
              </td>
              <td>
                <div style="display: flex; justify-content: flex-end">
                  <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      @click="editIndex = index"
                      v-if="index !== editIndex"
                      prepend-icon="edit"
                  ></a-btn>
                  <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      @click="saveGlCode(item, false)"
                      v-if="index === editIndex"
                      prepend-icon="save"
                  ></a-btn>
                  <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      @click="editIndex = null"
                      v-if="index === editIndex"
                      text="Cancel"
                  ></a-btn>
                  <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      @click="[deleteConfirm=true, itemToDelete=item]"
                      prepend-icon="delete"
                  ></a-btn>
                </div>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog
        :open-dialog = deleteConfirm
        @confirm=deleteGlCode(itemToDelete)
        @close-dialog="closeDeleteDialog">
      Are you sure you want to delete this GL Code <strong>{{codeToDelete}}</strong>?

    </ConfirmationDialog>
  </v-container>
</template>

<script setup>

import {handleHidingGlobalLoader, deleteRequest, postRequest, } from '@/helpers/helpers'
import {getGlCodes} from './expenseService'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import constants from "@/helpers/constants.js";

import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
 const vuetify = vueInstance.$vuetify

const createNew = ref(false)
const dataLoading = ref(true)
const newGlCode = ref({})
const editIndex = ref(null)
const glCodes = ref([])
const headers = ref([
  {text: 'Code', value: 'code', show: true},
  {text: 'Description', value: 'description', show: true},
  {text: null, value: 'icons', show: true}
])
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const deleteConfirm = ref(false)
const itemToDelete = ref({})

const codeToDelete = computed(() => {
  return itemToDelete.value ? itemToDelete.value.code : ''
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})
const filteredGlCodes = computed(() => {
  return glCodes.value.filter(glc => !glc.archived)
})

onMounted(() => {
  getTheGlCodes()
})

const getTheGlCodes = async() => {
  dataLoading.value = true
  try {
    const {data, status} = await getGlCodes()
    glCodes.value = data
    dataLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')

  }
}
const deleteGlCode = async(item) => {
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/glCodes/${item.id}`, 'blueraven')
    item.archived = true
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Deleting GL Code')

    appStore.loading = false
  }
  closeDeleteDialog()
}
const saveGlCode = async(item, isNew) => {
  appStore.loading = true
  try {
    const {data, status} = await postRequest(`/glCodes`, item, 'blueraven')
    if(isNew) {
      glCodes.value.push(data)
      newGlCode.value = {}
      createNew.value = false
    } else {
      editIndex.value = null
    }
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving GL Code')

    appStore.loading = false
  }
}
const closeDeleteDialog = () => {
  deleteConfirm.value = false
  itemToDelete.value = null
}
</script>

<style lang="scss">
#gl-code-container .v-data-table__wrapper {
  height: calc(100vh - 290px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>
#gl-code-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}
</style>