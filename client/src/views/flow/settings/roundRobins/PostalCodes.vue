<template>
  <v-container class="pa-0" id="codes-container">
    <v-row>
      <v-col class="pt-0">
        <v-toolbar flat>
          <v-toolbar-title>
            Postal Codes
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn icon  color="primary" v-if="userCanAdd"
                             @click="[reloadAvailable(), addCode = !addCode, newCode = {}]"
                             :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                             :prepend-icon="addCode ? 'remove' : 'add'">
            </a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addCode" class="square-card text-left pa-5">
          <a-autocomplete
              :items="availablePostalCodes"
              item-value="id"
              item-title="postalCode"
              label="Postal Code"
              return-object
              v-model="newCode"
          ></a-autocomplete>
          <div class="error-text mb-3" v-if="showError">{{ errorMsg }}</div>
          <a-btn color="primary" class="mr-3 " @click="addCodeToRoundRobin()"
                           :disabled="!newCode.id" text="Add"></a-btn>
        </v-card>
        <v-divider v-if="addCode"></v-divider>
        <v-card-title class="pt-0">
          <a-text-field
              v-model="codeSearch"
              prepend-inner-icon="search"
              label="Search"
              single-line
              hide-details
          ></a-text-field>
        </v-card-title>
        <v-divider></v-divider>
        <v-data-table id="round-robin-codes-table"
                      :headers="codeHeaders"
                      :items="filteredPostalCodes"
                      :fixed-header="true"
                      :items-per-page="-1"
                      disable-sort
                      :search="codeSearch"
                      :loading="dataLoading"
                      class="elevation-0 table-striped"
        >
          <template #no-data>
            <span class="default-text-color">No available postal codes</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available postal codes</span>
          </template>

          <template #item="{ item, index }">
            <tr>
              <td class="text-left code-col">{{ item.postalCode }}</td>
              <td :class="{'text-right': $vuetify.breakpoint.smAndDown}">
                <a-btn
                    v-if="userCanEdit"
                    icon
                    color="primary"
                    @click="[itemToDelete=item, showDeleteDialog=true]"
                    prepend-icon="delete"
                    :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                ></a-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog"
                        @confirm="deleteCodeFromRoundRobin"
                        @close-dialog="closeDeleteDialog">
      Are you sure you want to remove this postal code: <strong>{{ itemToDeletePostalCode }}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>

import {handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar} from '@/helpers/helpers'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import {getCurrentInstance, computed, ref, onMounted} from 'vue'

import {useUserStore} from '@/stores/UserStore.js'
import {useRoute} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const userStore = useUserStore()
const route = useRoute()


const postalCodes = ref([])
const showError = ref(false)
const errorMsg = ref('')
const dataLoading = ref(true)
const addCode = ref(false)
const codeDeleted = ref(false)
const newCode = ref({})
const availablePostalCodes = ref([])
const codeSearch = ref('')
const showDeleteDialog = ref(false)
const itemToDelete = ref(null)
const codeHeaders = ref([
  {text: 'Postal Code', value: 'postalCode', show: true},
  {text: '', value: 'icons', show: true},
])

const roundRobinId = computed(() => {
  return route.params.id
})
const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'EDIT')
})
const userCanDelete = computed(() => {
  return userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'DELETE')
})
const itemToDeletePostalCode = computed(() => {
  return itemToDelete.value ? itemToDelete.value.postalCode : ''
})
const filteredPostalCodes = computed(() => {
  return postalCodes.value.filter(pc => {
    return !pc.archived
  })
})

onMounted(() => {
  getCodesAssignedToRoundRobin()
  getAvailablePostalCodes()
})

const reloadAvailable = () => {
  if (codeDeleted.value) {
    getAvailablePostalCodes()
  }
}

const getAvailablePostalCodes = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/roundRobin/${roundRobinId.value}/availableCodes`)
    availablePostalCodes.value = data
    //this makes it reload the available list any time one has been deleted locally
    codeDeleted.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const getCodesAssignedToRoundRobin = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/roundRobin/${roundRobinId.value}/codes`)
    postalCodes.value = data
    dataLoading.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const deleteCodeFromRoundRobin = async () => {
  const code = itemToDelete.value
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/roundRobin/code/${code.id}`)
    code.archived = true
    codeDeleted.value = true
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Removing Postal Code')
    appStore.loading = false
  }
  closeDeleteDialog()
}
const addCodeToRoundRobin = async () => {
  if (newCode.value.id) {
    showError.value = false
    errorMsg.value = ''
    appStore.loading = true
    try {
      // let params = {
      //   postalCode:
      // }
      const {data, status} = await postRequest(`/roundRobin/${roundRobinId.value}/addCode`, newCode.value)
      postalCodes.value.push(data)
      availablePostalCodes.value = availablePostalCodes.value.filter(apc => apc.id !== data.id)
      addCode.value = false
      availablePostalCodes.value = availablePostalCodes.value.filter(apc => apc.id !== newCode.value.id)
      newCode.value = {}
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      let msg = e.data?.message?.includes('Postal Code Already In Use') ? e.data.message : 'Error Adding Postal Code'
      snackbar('ERROR', msg)
      appStore.loading = false
    }
  } else {
    showError.value = true
    errorMsg.value = 'ERROR: Postal Code must be 5 digits'
  }
}
const closeDeleteDialog = () => {
  showDeleteDialog.value = false
  itemToDelete.value = null
}
</script>
<style scoped lang="scss">
@media (max-width: 770px) {
  .code-col {
    width: 100%;
  }
}
</style>
<style lang="scss">
#codes-container .v-data-table__wrapper {
  max-height: calc(100vh - 410px);
  min-height: 300px;
}

@media (max-width: 770px) {
  #round-robin-codes-table {
    padding-bottom: 12px;

    div.v-data-footer {
      display: inline-block;
      width: 100%;
      padding-bottom: 12px;

      div.v-data-footer__select {
        justify-content: center;
      }

      div.v-data-footer__pagination {

      }

      div.v-data-footer__icons-before {
        display: inline;
        margin-left: calc(50% - 36px);
      }

      div.v-data-footer__icons-after {
        display: inline;
      }

    }
  }
}

</style>


