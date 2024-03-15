<template>
  <v-container id="postal-codes" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">Postal Code Zones</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                @click="[addNew = !addNew, newZone = {}]"
                v-if="userCanAdd"
                :text="!addNew ? 'Add New' : 'Cancel'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card color="transparent" flat v-if="addNew">
            <v-text-field
                label="Zone Name"
                tabindex=1
                v-model="newZone.zoneName"
            ></v-text-field>

            <a-btn
                color="primary"
                :disabled="!newZone.zoneName"
                @click="addPostalCodeZone"
                class="mb-3"
                text="Save"
            ></a-btn>
          </v-card>
          <v-divider v-if="addNew"></v-divider>
          <v-card class="square-card">
            <v-card-title class="pt-0">
              <v-text-field
                v-model="search"
                prepend-inner-icon="search"
                label="Search zones"
                single-line
                hide-details
              ></v-text-field>
            </v-card-title>
            <v-data-table
              :headers="headers"
              :search="search"
              :items="filteredPostalCodeZones"
              :fixed-header="true"
              :options.sync="options"
              :footer-props="footerProps"
              disable-sort
              :mobile-breakpoint="0"
              :loading="dataLoading"
              class="elevation-1 round-robin-table table-striped"
            >

              <template #item="{ item, index }">
                <tr class="">
                  <td class="clickable text-left"  @click="goToZone(item)">
                    {{ item.zoneName }}
                  </td>
                  <td class="clickable text-left"  @click="goToZone(item)">
                    {{ item.metroArea }}
                  </td>
                  <td class="text-right">
                    <a-btn
                        icon
                        @click="goToZone(item)"
                        color="primary"
                        prepend-icon="edit"
                        :size="$vuetify.breakpoint.smAndDown ? 'large' : 'small'"
                    ></a-btn>
                    <a-btn
                        v-if="userCanDelete"
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
          </v-card>
        </v-container>
      </v-col>
    </v-row>
    <ConfirmationDialog
        :open-dialog="showDeleteDialog"
        @confirm="deletePostalCodeZone"
        @close-dialog="closeDeleteDialog">
      Are you sure you want to delete this zone: <strong>{{itemToDeleteName}}</strong>

    </ConfirmationDialog>
  </v-container>
</template>

<script setup>


  import {  handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";
  import constants from "@/helpers/constants";
  import { getCurrentInstance, computed, ref, onMounted } from 'vue'
  import {useUserStore} from '@/stores/UserStorePinia.js'
  import {useRouter} from "vue-router/composables"
  import { useAppStore } from '@/stores/AppStorePinia.js'
  const appStore = useAppStore()
  const router = useRouter()
  const userStore = useUserStore()
  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store
  const snackbar = vueInstance.$snackbar

        const addNew = ref(false)
        const search = ref(null)
        const newZone = ref({})
        const dataLoading = ref(true)
        const postalCodeZones = ref([])
        const showDeleteDialog = ref(false)
        const itemToDelete = ref(null)
        const footerProps = ref({
          'items-per-page-options': [25, 50, 100, 1000],
          'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
        })
        const options = ref({
          itemsPerPage: 100
        })
        const headers = ref([
          {text: 'Zone Name', value: 'zoneName', show: true},
          {text: 'Metro Area', value: 'metroArea', show: true},
          {text: '', value: 'icons', show: true, width: "100"},
        ])

  const userCanAdd = computed(() => {
    return userStore.userHasFeatureAccessLevel('POSTAL_CODE', 'ADD')
  })
  const userCanEdit = computed(() => {
    return userStore.userHasFeatureAccessLevel('POSTAL_CODE', 'EDIT')
  })
  const userCanDelete = computed(() => {
    return userStore.userHasFeatureAccessLevel('POSTAL_CODE', 'DELETE')
  })
  const companyId = computed(() => {
    return userStore.details.companyId
  })
  const userId = computed(() => {
    return userStore.details.id
  })
  const itemToDeleteName = computed(() => {
    return itemToDelete.value?.postalCode || ''
  })
  const filteredPostalCodeZones = computed(() => {
    return postalCodeZones.value.filter(pcz => { return !pcz.archived})
  })

  onMounted(() => {
    getPostalCodeZones()
  })

      const goToZone = (zone) => {
        router.push({path: `/settings/zip/zone/${zone.id}`})
      }
      const getPostalCodeZones = async() => {
        dataLoading.value = true
        appStore.loading = true
        try {
          const {data, status} = await getRequest(`/postalCode/zones`)
          postalCodeZones.value = data
          dataLoading.value = false
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          dataLoading.value = false
          snackbar('ERROR', 'Error Retrieving Data')
          appStore.loading = false
        }
      }
      const deletePostalCodeZone = async() => {
        itemToDelete.value.archived = true
        const postalCodeZoneId = itemToDelete.value.id
        appStore.loading = true
        try {
          const {status} = await deleteRequest(`/postalCode/zone/${postalCodeZoneId}`)
          snackbar('SUCCESS', 'Postal Code Deleted')
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Deleting Postal Code')
          appStore.loading = false
        }
        closeDeleteDialog()
      }
      const addPostalCodeZone = async() => {
        appStore.loading = true
        try {
          const {data, status} = await postRequest(`/postalCode/zone`, newZone.value)
          goToZone(data)
          snackbar('SUCCESS', 'Postal Code Zone Added')
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Adding Postal Code Zone')
          appStore.loading = false
        }
      }
      const closeDeleteDialog = () => {
        showDeleteDialog.value = false;
        itemToDelete.value = null;
      }
</script>

<style lang="scss">
  #postal-codes .v-data-table__wrapper {
    height: calc(100vh - 300px);
    min-height: 300px;
    border-top: solid 1px #E0E0E0;
  }
</style>

