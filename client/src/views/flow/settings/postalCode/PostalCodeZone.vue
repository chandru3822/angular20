<template>
  <v-container id="postal-codes" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">{{postalCodeZone.zoneName}}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="savePostalCodeZone"
                   color="primary" v-if="userStore.userHasFeatureAccessLevel('POSTAL_CODE', 'EDIT')">
              <v-icon>save</v-icon>
              Save
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card class="square-card" elevation="0">
            <v-text-field class="mt-4"
              v-model="postalCodeZone.zoneName"
              label="Zone Name"
              hide-details
            ></v-text-field>
            <v-autocomplete v-model="postalCodeZone.metroAreaId"
                            :items="metroAreas"
                            class="mt-4"
                            label="Metro Area"
                            clearable
                            hide-details
                            item-text="name"
                            item-value="id"
                            autocomplete="off"
                            attach
            ></v-autocomplete>
            <v-text-field  class="my-4"
              v-model.number="postalCodeZone.adderAmount"
              label="Adder Amount"
              type="number"
              hide-details
            ></v-text-field>
            <v-btn class="my-3" @click="[addPostalCode = !addPostalCode, getAvailablePostalCodes()]"
                   color="primary" v-if="userStore.userHasFeatureAccessLevel('USERS', 'EDIT')">
              Add Postal Code to Zone
            </v-btn>
            <v-card v-if="addPostalCode" class="pa-3 mb-3">
              <v-autocomplete
                  :items="availablePostalCodes"
                  item-value="id"
                  item-text="postalCode"
                  label="New Postal Code"
                  return-object
                  v-model="selectedPostalCode"
                  @input="savePostalCodeToZone"
              ></v-autocomplete>
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
                    <v-btn small text color="primary"
                           @click="[itemToDelete = item, showDeleteDialog = true]">
                      <v-icon>delete</v-icon>
                    </v-btn>
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
  import {AppMutations} from '@/stores/AppStore'
  import {  handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";
  import { getCurrentInstance, computed, ref, onMounted } from 'vue'
  import {useUserStore} from '@/stores/UserStorePinia.js'
  import {useRoute} from "vue-router/composables";
  const route = useRoute()
  const userStore = useUserStore()
  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store

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
        store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/customField/${metroAreaCustomFieldId.value}`)
          metroAreas.value = data?.listOfValues
        } catch (e) {
          console.error('*** ERROR ***', e)
          getSnackbar('ERROR', 'Error Retrieving Data')
        }
      }
      const getPostalCodeZone = async() => {
        dataLoading.value = true
        store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/postalCode/zone/${postalCodeZoneId.value}`)
          postalCodeZone.value = data
          dataLoading.value = false
          handleHidingGlobalLoader(vueInstance, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          dataLoading.value = false
          getSnackbar('ERROR', 'Error Retrieving Data')
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
      const getAvailablePostalCodes = async() => {
        if(addPostalCode.value) {
          store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data, status} = await getRequest(`/postalCode/zone/${postalCodeZoneId.value}/availableCodes`)
            availablePostalCodes.value = data
            handleHidingGlobalLoader(vueInstance, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            getSnackbar('ERROR', 'Error Retrieving Data')
            store.commit(AppMutations.SET_LOADING, false)
          }
        }
      }
      const savePostalCodeZone = async() => {
        store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/postalCode/zone`, postalCodeZone.value)
          getSnackbar('SUCCESS', 'Postal Code Zone Saved')
          handleHidingGlobalLoader(vueInstance, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          getSnackbar('ERROR', 'Error Saving Postal Code Zone')
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
      const savePostalCodeToZone = async() => {
        store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/postalCode/zone/${postalCodeZoneId.value}/postalCode`, selectedPostalCode.value)
          postalCodeZone.value.postalCodes.push(data)
          availablePostalCodes.value = availablePostalCodes.value.filter(apc => apc.id !== data.id)
          selectedPostalCode.value = {}
          getSnackbar('SUCCESS', 'Postal Code Saved to Zone')
          handleHidingGlobalLoader(vueInstance, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          getSnackbar('ERROR', 'Error Saving Postal Code to Zone')
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
      const deletePostalCodeFromZone = async() => {
        store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/postalCode/zone/${postalCodeZoneId.value}/postalCode/${itemToDelete.value.id}`)
          itemToDelete.value.archived = true
          getSnackbar('SUCCESS', 'Postal Code Removed from Zone')
          handleHidingGlobalLoader(vueInstance, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          getSnackbar('ERROR', 'Error Removing Postal Code from Zone')
          store.commit(AppMutations.SET_LOADING, false)
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

