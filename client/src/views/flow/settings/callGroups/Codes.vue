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
            <AlbatrossButton variant="text" icon
                             :large="vuetify.breakpoint.smAndDown"
                             color="primary"
                             v-if="userCanAdd"
                             @click="[reloadAvailable(), addCode = !addCode, newCode = {}]"
                             :prepend-icon="addCode ? 'remove' : 'add'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addCode" class="square-card text-left pa-5 mt-3">
          <v-autocomplete
            :items="availablePostalCodes"
            item-value="id"
            item-text="postalCode"
            clearable
            return-object
            label="Postal Code"
            @change="addCodeToZone()"
            v-model="newCode"
          ></v-autocomplete>
        </v-card>
        <v-divider v-if="addCode"></v-divider>
        <v-card-title class="pt-0">
          <v-text-field
            v-model="codeSearch"
            prepend-inner-icon="search"
            label="Search"
            single-line
            hide-details
          ></v-text-field>
        </v-card-title>
        <v-divider></v-divider>
        <v-data-table
          :headers="codeHeaders"
          :items="filterPostalCodes"
          :fixed-header="true"
          :items-per-page="-1"
          disable-sort
          :search="codeSearch"
          :loading="dataLoading"
          class="elevation-0"
        >
          <template #no-data>
            <span class="default-text-color">No available postal codes</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available postal codes</span>
          </template>

          <template #item="{ item, index }">
            <tr>
              <td class="text-left code-col">{{item.postalCode}}</td>
              <td class="text-right">
                <AlbatrossButton size="small" variant="text"
                                 icon
                                 :large="vuetify.breakpoint.smAndDown"
                                 color="primary"
                                 v-if="userCanDelete"
                                 @click="postalCodeToDelete=item"
                                 prepend-icon="delete"
                />
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!postalCodeToDelete" @confirm="deleteCodeFromGroup" @close-dialog="postalCodeToDelete = null">
      Are you sure you want to delete code: <strong>{{postalCodeToDeleteCode}}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>

  import {handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";

  import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
  import {getCurrentInstance, onMounted, ref, computed} from "vue";
  import { useUserStore } from '@/stores/UserStorePinia.js'
  import {useRoute} from "vue-router/composables"
  import { useAppStore } from '@/stores/AppStorePinia.js'
  const appStore = useAppStore()

  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const vuetify = vueInstance.$vuetify
  const store = vueInstance.$store
  const userStore = useUserStore()
  const route = useRoute()

  const postalCodes = ref([])
  const availablePostalCodes = ref([])
  const showError = ref(false)
  const codeDeleted = ref(false)
  const errorMsg = ref('')
  const callGroupId = ref(parseInt(route.params.id))
  const dataLoading = ref(true)
  const addCode = ref(false)
  const newCode = ref({})
  const codeSearch = ref('')
  const codeHeaders = ref([
    {text: 'Postal Code', value: 'postalCode', show: true},
    {text: '', value: 'icons', show: true},
  ])
  const postalCodeToDelete = ref(null)

  const userCanAdd = computed(() => {
    return userStore.userHasFeatureAccessLevel('CALL_GROUPS', 'ADD')
  })
  const userCanEdit = computed(() => {
    return userStore.userHasFeatureAccessLevel('CALL_GROUPS', 'EDIT')
  })
  const userCanDelete = computed(() => {
    return userStore.userHasFeatureAccessLevel('CALL_GROUPS', 'DELETE')
  })
  const postalCodeToDeleteCode = computed(() => {
    return postalCodeToDelete.value ? postalCodeToDelete.value.postalCode : ''
  })

  onMounted (() => {
    getCodesForZone()
    getAvailablePostalCodes()
  })
  const reloadAvailable = () => {
    if(codeDeleted.value) {
      getAvailablePostalCodes()
    }
  }
  const getAvailablePostalCodes = async () => {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/callGroup/${callGroupId.value}/availableCodes`, 'blueraven')
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
  const filterPostalCodes = computed(() =>{
    return postalCodes.value?.length ? postalCodes.value.filter(pc => { return !pc.archived}) : []
  })
  const getCodesForZone = async () => {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/callGroup/${callGroupId.value}/codes`, 'blueraven')
      postalCodes.value = data
      dataLoading.value = false
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')

      appStore.loading = false
    }
  }
  const deleteCodeFromGroup = async () => {
    const code = postalCodeToDelete.value
    appStore.loading = true
    try {
      const {status} = await deleteRequest(`/callGroup/code/${code.id}`, 'blueraven')
      code.archived = true
      codeDeleted.value = true
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Removing Postal Code')

      appStore.loading = false
    }
    postalCodeToDelete.value = null
  }
  const addCodeToZone = async () => {
    appStore.loading = true
    try {
      newCode.value.callGroupId = callGroupId.value
      const {data, status} = await postRequest(`/callGroup/addCode`, newCode.value, 'blueraven')
      postalCodes.value.push(data)
      availablePostalCodes.value = availablePostalCodes.value.filter(apc => apc.id !== data.id)
      addCode.value = false
      newCode.value = {}
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      let msg = e.data?.message?.includes('Postal Code Already In Use') ? e.data.message : 'Error Adding Postal Code'
      snackbar('ERROR', msg)

      appStore.loading = false
    }
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
</style>

