<template>
  <v-container id="postal-codes" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">{{postalCodeZone.zoneName}}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                @click="savePostalCodeZone"
                color="primary"
                v-if="userStore.userHasFeatureAccessLevel('POSTAL_CODE', 'EDIT')"
                prepend-icon="save"
                text="Save"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card class="square-card" elevation="0">
            <a-text-field class="mt-4"
              v-model="postalCodeZone.zoneName"
              label="Zone Name"
              hide-details
            ></a-text-field>
            <a-autocomplete v-model="postalCodeZone.metroAreaId"
                            :items="metroAreas"
                            class="mt-4"
                            label="Metro Area"
                            clearable
                            hide-details
                            item-title="name"
                            item-value="id"
                            autocomplete="off"
                            attach
            ></a-autocomplete>
            <a-text-field  class="my-4"
              v-model.number="postalCodeZone.adderAmount"
              label="Adder Amount"
              type="number"
              hide-details
            ></a-text-field>
            <a-btn
                class="my-3"
                @click="[addPostalCode = !addPostalCode, getAvailablePostalCodes()]"
                color="primary"
                v-if="userStore.userHasFeatureAccessLevel('USERS', 'EDIT')"
                text="Add Postal Code to Zone"
            ></a-btn>
            <v-card v-if="addPostalCode" class="pa-3 mb-3">
              <a-autocomplete
                  :items="availablePostalCodes"
                  item-value="id"
                  item-title="postalCode"
                  label="New Postal Code"
                  return-object
                  v-model="selectedPostalCode"
                  @input="savePostalCodeToZone"
              ></a-autocomplete>
            </v-card>
            <v-data-table
                :headers="headers"
                :items="filteredPostalCodes"
                :fixed-header="true"
                :items-per-page="-1"
                hide-default-footer
                class="elevation-1"
            >
              <template #item="{ item, index }">
                <tr :class="{'shaded-row': index % 2}">
                  <td class="text-left">
                    {{item.postalCode}}
                  </td>
                  <td class="text-right">
                    <a-btn
                        size="small"
                        variant="text"
                        color="primary"
                        @click="[itemToDelete = item, showDeleteDialog = true]"
                        prepend-icon="delete"
                    ></a-btn>
                  </td>
                </tr>
              </template>
            </v-data-table>

          </v-card>
        </v-container>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog" @confirm="deletePostalCodeFromZone"
                        @close-dialog="showDeleteDialog=false">
      Are you sure you want to delete this postal code: <strong>{{ itemToDelete.postalCode }}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>


  import {  handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";
  import { getCurrentInstance, computed, ref, onMounted } from 'vue'
  import {useUserStore} from '@/stores/UserStore.js'
  import {useRoute} from "vue-router/composables"
  import { useAppStore } from '@/stores/AppStore.js'
  const appStore = useAppStore()
  const route = useRoute()
  const userStore = useUserStore()
  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store
  const snackbar = vueInstance.$snackbar

        const dataLoading = ref(true)
        const itemToDelete = ref({})
        const showDeleteDialog = ref(false)
        const addPostalCode = ref(false)
        const postalCodeZone = ref({})
        const selectedPostalCode = ref({})
        const availablePostalCodes = ref([])
        const metroAreas = ref([])
        const metroAreaCustomFieldId = ref(185)
        const headers = ref([
          {text: 'Postal Code', value: 'postalCode', show: true},
          {text: '', value: 'icons', show: true},
        ])

  const filteredPostalCodes = computed(() => {
    return postalCodeZone.value?.postalCodes?.filter(o => !o.archived)
  })
  const postalCodeZoneId = computed(() => {
    return route.params.id
  })

  onMounted(() => {
      getMetroAreas()
      getPostalCodeZone()
  })
      const getMetroAreas = async() => {
        appStore.loading = true
        try {
          const {data, status} = await getRequest(`/customField/${metroAreaCustomFieldId.value}`)
          metroAreas.value = data?.listOfValues
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Retrieving Data')
        }
      }
      const getPostalCodeZone = async() => {
        dataLoading.value = true
        appStore.loading = true
        try {
          const {data, status} = await getRequest(`/postalCode/zone/${postalCodeZoneId.value}`)
          postalCodeZone.value = data
          dataLoading.value = false
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          dataLoading.value = false
          snackbar('ERROR', 'Error Retrieving Data')
          appStore.loading = false
        }
      }
      const getAvailablePostalCodes = async() => {
        if(addPostalCode.value) {
          appStore.loading = true
          try {
            const {data, status} = await getRequest(`/postalCode/zone/${postalCodeZoneId.value}/availableCodes`)
            availablePostalCodes.value = data
            handleHidingGlobalLoader(status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            snackbar('ERROR', 'Error Retrieving Data')
            appStore.loading = false
          }
        }
      }
      const savePostalCodeZone = async() => {
        appStore.loading = true
        try {
          const {data, status} = await postRequest(`/postalCode/zone`, postalCodeZone.value)
          snackbar('SUCCESS', 'Postal Code Zone Saved')
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Saving Postal Code Zone')
          appStore.loading = false
        }
      }
      const savePostalCodeToZone = async() => {
        appStore.loading = true
        try {
          const {data, status} = await postRequest(`/postalCode/zone/${postalCodeZoneId.value}/postalCode`, selectedPostalCode.value)
          postalCodeZone.value.postalCodes.push(data)
          availablePostalCodes.value = availablePostalCodes.value.filter(apc => apc.id !== data.id)
          selectedPostalCode.value = {}
          snackbar('SUCCESS', 'Postal Code Saved to Zone')
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Saving Postal Code to Zone')
          appStore.loading = false
        }
      }
      const deletePostalCodeFromZone = async() => {
        appStore.loading = true
        try {
          await deleteRequest(`/postalCode/zone/${postalCodeZoneId.value}/postalCode/${itemToDelete.value.id}`)
          itemToDelete.value.archived = true
          snackbar('SUCCESS', 'Postal Code Removed from Zone')
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Removing Postal Code from Zone')
          appStore.loading = false
        }
      }
</script>

<style lang="scss">
  #postal-codes .v-data-table__wrapper {
    height: calc(100vh - 300px);
    min-height: 300px;
    border-top: solid 1px #E0E0E0;
  }
</style>

