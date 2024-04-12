<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Certs & Other Stuff</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <div class="mt-4">
              <a-btn text="Send Email Notices" @click="sendEmails()" v-if="constants.VUE_APP_ENV === 'local'">
              </a-btn>
            </div>
            <a-btn :hide-text-on-mobile="true"
                             variant="text"
                             :text="addNew ? 'Cancel' : 'Add New'"
                             :prepend-icon="addNew ? 'close' : 'add'"
                             @click="[addNew = !addNew, selectedCert = {}]">
            </a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat>
          <h3>Add</h3>
          <div class="mb-3">
            <a-text-field  label="Enter name"
                          v-model="selectedCert.certName"></a-text-field>
            <DatetimePickerInput
                v-model="selectedCert.expirationDate"
                :timezone="timezone"
                :type="'date'"
                :format="'MM/DD/YYYY'"
                label="Expiration Date"
            />
            <a-textarea class="body-medium" hide-details
                        auto-grow
                        rows="4"
                        label="Notes (optional)"
                        variant="outlined"
                        v-model="selectedCert.notes">
            </a-textarea>
          </div>
          <a-btn variant="text" text="Cancel" @click="[addNew = !addNew, selectedCert = {}]"></a-btn>
          <a-btn :disabled="!selectedCert || !selectedCert.certName || !selectedCert.expirationDate"
                 text="Save" class="ml-2"
                 @click="saveCert(true, selectedCert)">
          </a-btn>
        </v-card>
        <v-data-table
            :headers="headers"
            :items="filteredCerts"
            :fixed-header="true"
            :items-per-page="-1"
            single-expand
            :mobile-breakpoint="0"
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1 org-type-table"
        >
          <template #no-data>
            <span class="default-text-color">NO DATA HERE!</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No parameters exist for this function</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': certs.indexOf(item) % 2}">
              <h3>Edit Cert</h3>
              <div class="mb-3">
                <a-text-field  label="Enter name"
                              v-model="item.certName"></a-text-field>
                <DatetimePickerInput
                    v-model="item.expirationDate"
                    :timezone="timezone"
                    :type="'date'"
                    :format="'MM/DD/YYYY'"
                    label="Expiration Date"
                />
                <a-textarea class="body-medium" hide-details
                            auto-grow
                            rows="4"
                            label="Notes (optional)"
                            variant="outlined"
                            v-model="item.notes">
                </a-textarea>
              </div>
              <a-btn :disabled="!item.certName || !item.expirationDate"
                     text="Save" class="mr-2"
                     @click="saveCert(false, item)">
              </a-btn>
            </td>
          </template>

          <template #item="{ item }">
            <tr class="text-left" :class="{'shaded-row': certs.indexOf(item) % 2}">
              <td class="text-left">
                <v-badge dot class="status-badge" v-if="item.daysToExpiration <= 30"
                         :color="item.daysToExpiration > 0 && item.daysToExpiration <= 7 ? 'error lighten-1' : 'orange'"
                ></v-badge>
                {{ item.certName }}
              </td>
              <td class="text-left">{{ item.expirationDate | formatDate('date', 'MM/DD/YYYY') }}</td>
              <td class="text-left">{{ item.daysToExpiration }}</td>
              <td class="text-right">
                <a-btn variant="text" size="small" prepend-icon="edit" v-if="!expanded.includes(item)" @click="expanded = [item]">
                </a-btn>
                <a-btn size="small" text="cancel" v-if="expanded.includes(item)" @click="expanded = []"></a-btn>
                <a-btn variant="text" size="small" prepend-icon="delete" @click="certToDelete=item">
                </a-btn>
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!certToDelete" @confirm="deleteCert" @close-dialog="certToDelete = null">
      Are you sure you want to delete this cert: <b>{{ certToDeleteName }}</b>?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import {
  handleHidingGlobalLoader,
  getRequest,
  postRequest,
  deleteRequest,
  putRequest
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from '@/components/ConfirmationDialog'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import moment from 'moment'

import {getCurrentInstance, computed, onMounted, ref} from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
const snackbar = vueInstance.$snackbar

const addNew = ref(false)
const timezone = ref(userStore.timezone.value)
const certs = ref([])
const selectedCert = ref({})
const selectedCertId = ref(null)
const expanded = ref([])
const certToDelete = ref(null)
const userId = ref(userStore.details.id)
const companyId = ref(userStore.details.companyId)
const headers = ref([
  {text: 'Cert Name', value: 'certName', show: true},
  {text: 'Expiration Date', value: 'expirationDate', show: true},
  {text: 'Days to Expiration', value: 'daysToExpiration', show: true},
  {text: null, value: 'icons', show: true, width: 200, sortable: false}
])

const certToDeleteName = computed(() => {
  return certToDelete.value ? certToDelete.value.certName : ''
})

const filteredCerts = computed(() => {
  return certs.value.filter(cf => {
    return !cf.archived
  })
})

onMounted(() => {
  getCerts()
})

const saveCert = async (isNew, cert) => {
  appStore.loading = true
  try {
    const {data, status} = await putRequest(`/cert`, cert)
    if (isNew) {
      certs.value.push(data)
      addNew.value = false
      selectedCert.value = {}
      snackbar('SUCCESS', 'Cert Added')
    } else {
      expanded.value = []
      snackbar('SUCCESS', 'Cert Updated')
    }
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', isNew ? 'Error Adding Cert' : 'Error Updating Cert')
    appStore.loading = false
  }
}
const sendEmails = async () => {
  appStore.loading = true
  try {
    const {status} = await postRequest(`/cert/sendEmails`, {})
    snackbar('SUCCESS', 'Emails Sent')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Sending Emails')
    appStore.loading = false
  }
}
const getCerts = async () => {

  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/cert`)
    certs.value = data
    certs.value.forEach(c => {
      c.daysToExpiration = moment(c.expirationDate).diff(moment(), 'days')
    })
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Certs')
    appStore.loading = false
  }
}
const deleteCert = async () => {

  const cert = certToDelete.value
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/cert/${cert.id}`)
    cert.archived = true
    snackbar('SUCCESS', 'Cert Deleted')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Cert')
    appStore.loading = false
  }
}

</script>

<style scoped lang="scss">
.status-badge {
  margin-bottom: 3px;
  margin-right: 10px;
}
</style>

