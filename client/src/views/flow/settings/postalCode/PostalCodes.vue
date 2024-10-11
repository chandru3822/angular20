<template>
  <v-container id="postal-codes" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">Postal Codes</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
              variant="text"
              color="primary"
              @click="
                ;[(addNew = !addNew), (newPostalCode = {}), getAllStates()]
              "
              v-if="userCanAdd"
              :text="!addNew ? 'Add New' : 'Cancel'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card class="pa-5 mb-2" v-if="addNew">
            <v-form ref="postalCodeForm">
              <a-text-field
                label="Postal Code"
                tabindex="1"
                counter
                :maxlength="10"
                :rules="postalCodeRules"
                v-model="newPostalCode.postalCode"
              ></a-text-field>
              <a-text-field
                label="Place Name"
                tabindex="1"
                v-model="newPostalCode.placeName"
              ></a-text-field>
              <a-autocomplete
                :items="states"
                item-value="id"
                item-title="state"
                clearable
                label="State"
                v-model="newPostalCode.stateId"
              ></a-autocomplete>
              <a-btn
                color="primary"
                :disabled="
                  !newPostalCode.postalCode ||
                  !newPostalCode.placeName ||
                  !newPostalCode.stateId
                "
                @click="validateForm"
                class="mb-3"
                text="Save"
              ></a-btn>
            </v-form>
          </v-card>
          <v-divider v-if="addNew"></v-divider>
          <v-card class="square-card">
            <v-card-title class="pt-0">
              <a-text-field
                v-model="search"
                clearable
                prepend-inner-icon="search"
                label="Search postal codes"
                single-line
                hide-details
              ></a-text-field>
            </v-card-title>
            <v-data-table
              :headers="headers"
              :search="search"
              :items="filteredPostalCodes"
              :fixed-header="true"
              :options.sync="options"
              :footer-props="footerProps"
              :loading="dataLoading"
              class="elevation-1 round-robin-table table-striped"
            >
              <template #item.postalCode="{ item, index }" class="text-left">
                <router-link :to="`/settings/zip/postalCode/${item.id}`">
                  {{ item.postalCode }}
                </router-link>
              </template>
              <template #item.placeName="{ item, index }" class="text-left">
                <router-link :to="`/settings/zip/postalCode/${item.id}`">
                  {{ item.placeName }}
                </router-link>
              </template>
              <template #item.zoneName="{ item, index }" class="text-left">
                <router-link
                  :to="`/settings/zip/zone/${item.postalCodeZoneId}`"
                >
                  {{ item.zoneName }}
                </router-link>
              </template>
              <template #item.state="{ item, index }" class="text-left">
                {{ item.stateAbbreviation }}
              </template>
              <template
                #item.roundRobinName="{ item, index }"
                class="text-left"
              >
                <router-link
                  :to="`/settings/roundRobin/${item.roundRobinId}/codes`"
                >
                  {{ item.roundRobinName }}
                </router-link>
              </template>
              <template #item.callGroupName="{ item, index }" class="text-left">
                <router-link
                  :to="`/settings/callGroup/${item.callGroupId}/codes`"
                >
                  {{ item.callGroupName }}
                </router-link>
              </template>
              <template #item.disqualified="{ item, index }" class="text-left">
                <v-checkbox
                  disabled
                  readonly
                  dense
                  hide-details
                  v-model="item.disqualified"
                ></v-checkbox>
              </template>
              <template #item.selfGenOnly="{ item, index }" class="text-left">
                <v-checkbox
                  disabled
                  readonly
                  dense
                  hide-details
                  v-model="item.selfGen"
                ></v-checkbox>
              </template>
              <template #item.insideSales="{ item, index }" class="text-left">
                <v-checkbox
                  disabled
                  readonly
                  dense
                  hide-details
                  v-model="item.insideSales"
                ></v-checkbox>
              </template>
              <template #item.salesPartners="{ item, index }" class="text-left">
                <v-checkbox
                  disabled
                  readonly
                  dense
                  hide-details
                  v-model="item.salesPartners"
                ></v-checkbox>
              </template>
              <template #item.icons="{ item, index }" class="text-right">
                <a-btn
                  icon
                  color="primary"
                  :to="`/settings/zip/postalCode/${item.id}`"
                  prepend-icon="edit"
                  :size="$vuetify.breakpoint.smAndDown ? 'large' : 'small'"
                ></a-btn>

                <a-btn
                  v-if="userCanDelete"
                  icon
                  color="primary"
                  @click=";[(itemToDelete = item), (showDeleteDialog = true)]"
                  prepend-icon="delete"
                  :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                ></a-btn>
              </template>
            </v-data-table>
          </v-card>
        </v-container>
      </v-col>
    </v-row>
    <ConfirmationDialog
      :open-dialog="showDeleteDialog"
      @confirm="deletePostalCode"
      @close-dialog="closeDeleteDialog"
    >
      Are you sure you want to delete this postal code:
      <strong>{{ itemToDeleteName }}</strong>
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  postRequest,
  getSnackbar
} from '@/helpers/helpers'
import ConfirmationDialog from '@/components/ConfirmationDialog'
import constants from '@/helpers/constants'
import { getStates } from '@/services/stateService'
import { getCurrentInstance, computed, ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
import { useRouter } from 'vue-router/composables'
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const addNew = ref(false)
const search = ref(null)
const newPostalCode = ref({})
const states = ref([])
const dataLoading = ref(true)
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 1000],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const options = ref({
  itemsPerPage: 100
})
const postalCodeRules = ref(constants.POSTAL_CODE_FIVE_REQUIRED_RULES)
const postalCodes = ref([])
const showDeleteDialog = ref(false)
const itemToDelete = ref(null)
const headers = ref([
  { text: 'Postal Code', value: 'postalCode', show: true },
  { text: 'Name', value: 'placeName', show: true },
  { text: 'Zone', value: 'zoneName', show: true },
  { text: 'State', value: 'state', show: true },
  { text: 'Round Robin', value: 'roundRobinName', show: true },
  { text: 'Call Group', value: 'callGroupName', show: true },
  { text: 'Disqualified', value: 'disqualified', show: true },
  { text: 'Self-Gen Only', value: 'selfGenOnly', show: true },
  { text: 'Inside Sales', value: 'insideSales', show: true },
  { text: 'Sales Partners', value: 'salesPartners', show: true },
  { text: '', value: 'icons', show: true }
])

const postalCodeForm = ref(null)

const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'EDIT')
})
const userCanDelete = computed(() => {
  return userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'DELETE')
})
const userId = computed(() => {
  return userStore.details.id
})
const companyId = computed(() => {
  return userStore.details.companyId
})
const itemToDeleteName = computed(() => {
  return itemToDelete.value?.postalCode || ''
})
const filteredPostalCodes = computed(() => {
  return postalCodes.value.filter((pcz) => {
    return !pcz.archived
  })
})

onMounted(() => {
  getPostalCodes()
})

const validateForm = async () => {
  if (postalCodeForm.value.validate()) {
    await addPostalCode()
  }
}
const getAllStates = async () => {
  if (addNew.value) {
    try {
      const { data, status } = await getStates()
      states.value = data
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Data')
    }
  }
}

const getPostalCodes = async () => {
  dataLoading.value = true
  appStore.loading = true
  try {
    const { data, status } = await getRequest(`/postalCode`)
    postalCodes.value = data
    dataLoading.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    dataLoading.value = false
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const deletePostalCode = async () => {
  itemToDelete.value.archived = true
  const postalCodeId = itemToDelete.value.id
  appStore.loading = true
  try {
    const { status } = await deleteRequest(`/postalCode/${postalCodeId}`)
    appStore.showSnack('SUCCESS', 'Postal Code Deleted')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Deleting Postal Code')
    appStore.loading = false
  }
  closeDeleteDialog()
}
const addPostalCode = async () => {
  appStore.loading = true
  try {
    const { data, status } = await postRequest(
      `/postalCode`,
      newPostalCode.value
    )
    router.push({ path: `/settings/zip/postalCode/${data.id}` })
    appStore.showSnack('SUCCESS', 'Postal Code Added')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    let msg = e?.data?.message ? e.data.message : 'Error Adding Postal Code'
    appStore.showSnack('ERROR', msg)
    appStore.loading = false
  }
}
const closeDeleteDialog = () => {
  showDeleteDialog.value = false
  itemToDelete.value = null
}
</script>

<style lang="scss">
#postal-codes .v-data-table__wrapper {
  height: calc(100vh - 300px);
  min-height: 300px;
  border-top: solid 1px #e0e0e0;
}
#postal-codes
  > div.row
  > div
  > div
  > div
  > div.v-data-table.round-robin-table.v-data-table--mobile
  > div.v-data-table__wrapper
  > table
  > tbody
  > tr
  > td {
  min-height: 36px;
}
</style>
