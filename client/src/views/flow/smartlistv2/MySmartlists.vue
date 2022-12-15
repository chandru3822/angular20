<template>
  <v-container id="my-smartlists">
    <v-row>
      <v-col cols="12">
        <v-card flat class="square-card pb-3 px-3" color="white">
          <v-text-field
            v-model="search"
            append-icon="mdi-magnify"
            label="Search"
            single-line
            hide-details
          ></v-text-field>
        </v-card>
        <v-divider></v-divider>
        <v-data-table
          class="elevation-1"
          :headers="headers"
          :items="smartlists"
          fixed-header
          multi-sort
          :search="search"
          :items-per-page="25"
          :footer-props="footerProps"
          :loading="isLoading"
        >
          <template #no-data>
            <span class="default-text-color">No available smartlists</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available smartlists</span>
          </template>

          <template #item="{item: smartlist}">
            <tr class="clickable" @click="$router.push({name: 'smartlistEditor', params: {smartlistId: smartlist.id}})">
              <td class="text-left">{{ smartlist.name }}</td>
              <td class="text-left">{{ smartlist.owner }}</td>
              <td>
                <smartlist-copy
                  :smartlist="smartlist"
                  @copied="(newSmartlist) => smartlists = [newSmartlist, ...smartlists]"
                />
              </td>
              <td>
                <v-icon>mdi-share-variant</v-icon>
              </td>
              <td>
                <smartlist-export :smartlist="smartlist" />
              </td>
              <td>
                <v-icon @click.stop="[deletingSmartlistId = smartlist.id, showDeleteDialog = true]">mdi-delete</v-icon>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>

    <ConfirmationDialog
      :parent-close="true"
      :open-dialog="showDeleteDialog"
      @confirm="deleteSmartlist"
      @close-dialog="[deletingSmartlistId = null, showDeleteDialog = false]"
    >
      Do you want to delete this smartlist?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import { ref, onMounted, getCurrentInstance } from 'vue'
import { getRequest, logError, getSnackbar, deleteRequest, handleHidingGlobalLoader, postRequest } from '@/helpers/helpers'
import { AppMutations} from '@/stores/AppStore'
import ConfirmationDialog from '@/ConfirmationDialog'
import SmartlistExport from '@/views/flow/smartlistv2/SmartlistExport.vue'
import SmartlistCopy from '@/views/flow/smartlistv2/SmartlistCopy.vue'

const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500]
})

const headers = ref([
  {text: 'Name', value: 'name'},
  {text: 'Owner', value: 'owner'},
  {text: 'Duplicate'},
  {text: 'Share'},
  {text: 'Export'},
  {text: 'Delete'}
])

const search = ref('')
const isLoading = ref(false)
const showDeleteDialog = ref(false)
const deletingSmartlistId = ref(null)

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

let smartlists = ref([])

onMounted(async () => await getSmartlists())

let getSmartlists = async () => {
  try {
    isLoading.value = true
    const {data} = await getRequest(`/smartlistv2/mine`)
    smartlists.value = data
  } catch (e) {
    logError(e)
  } finally {
    isLoading.value = false
  }
}

let deleteSmartlist = async () => {

  let snackbar

  try {
    store.commit(AppMutations.SET_LOADING, true)
    const {status} = await deleteRequest(`/smartlist/${deletingSmartlistId.value}`)
    handleHidingGlobalLoader(vueInstance, status)
    smartlists.value = smartlists.value.filter(s => s.id !== deletingSmartlistId.value)
    snackbar = getSnackbar('SUCCESS', 'Smartlist Deleted')
  } catch (e) {
    logError(e)
    snackbar = getSnackbar('ERROR', 'Unable to delete smartlist')
  } finally {
    store.commit(AppMutations.SET_LOADING, false)
    store.commit(AppMutations.SHOW_SNACK, snackbar)
    deletingSmartlistId.value = null
    showDeleteDialog.value = false
  }
}
</script>

<style scoped lang="scss">

</style>