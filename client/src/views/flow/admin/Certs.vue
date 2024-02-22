<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Certs & Other Stuff</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <div class="mt-4">
              <AlbatrossButton text="Send Email Notices" @click="sendEmails()" v-if="constants.VUE_APP_ENV === 'local'">
              </AlbatrossButton>
            </div>
            <AlbatrossButton :hide-text-on-mobile="true"
                             variant="text"
                             :text="addNew ? 'Cancel' : 'Add New'"
                             :prepend-icon="addNew ? 'close' : 'add'"
                             @click="[addNew = !addNew, selectedCert = {}]">
            </AlbatrossButton>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat>
          <h3>Add</h3>
          <div class="mb-3">
            <v-text-field text label="Enter name"
                          v-model="selectedCert.certName"></v-text-field>
            <DatetimePickerInput
                v-model="selectedCert.expirationDate"
                :timezone="timezone"
                :type="'date'"
                :format="'MM/DD/YYYY'"
                label="Expiration Date"
            />
            <v-textarea class="body-medium" hide-details
                        auto-grow
                        rows="4"
                        label="Notes (optional)"
                        outlined v-model="selectedCert.notes">
            </v-textarea>
          </div>
          <AlbatrossButton variant="text" text="Cancel" @click="[addNew = !addNew, selectedCert = {}]"></AlbatrossButton>
          <AlbatrossButton :disabled="!selectedCert || !selectedCert.certName || !selectedCert.expirationDate"
                 text="Save" class="ml-2"
                 @click="saveCert(true, selectedCert)">
          </AlbatrossButton>
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
                <v-text-field text label="Enter name"
                              v-model="item.certName"></v-text-field>
                <DatetimePickerInput
                    v-model="item.expirationDate"
                    :timezone="timezone"
                    :type="'date'"
                    :format="'MM/DD/YYYY'"
                    label="Expiration Date"
                />
                <v-textarea class="body-medium" hide-details
                            auto-grow
                            rows="4"
                            label="Notes (optional)"
                            outlined v-model="item.notes">
                </v-textarea>
              </div>
              <AlbatrossButton :disabled="!item.certName || !item.expirationDate"
                     text="Save" class="mr-2"
                     @click="saveCert(false, item)">
              </AlbatrossButton>
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
                <AlbatrossButton variant="text" size="small" prepend-icon="edit" v-if="!expanded.includes(item)" @click="expanded = [item]">
                </AlbatrossButton>
                <AlbatrossButton size="small" text="cancel" v-if="expanded.includes(item)" @click="expanded = []"></AlbatrossButton>
                <AlbatrossButton variant="text" size="small" prepend-icon="delete" @click="certToDelete=item">
                </AlbatrossButton>
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
import {AppMutations} from '@/stores/AppStore'
import {
  handleHidingGlobalLoader,
  getRequest,
  postRequest,
  deleteRequest,
  putRequest,
  getSnackbar
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import DatetimePickerInput from "@/components/DatetimePickerInput.vue";
import moment from 'moment'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton"

import {getCurrentInstance, computed, onMounted, ref} from 'vue'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const addNew = ref(false)
const timezone = ref(store.state.user.details.timezone.value)
const certs = ref([])
const selectedCert = ref({})
const selectedCertId = ref(null)
const expanded = ref([])
const certToDelete = ref(null)
const userId = ref(store.state.user.details.id)
const companyId = ref(store.state.user.details.companyId)
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
  store.commit(AppMutations.SET_LOADING, true)
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
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', isNew ? 'Error Adding Cert' : 'Error Updating Cert')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const sendEmails = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await postRequest(`/cert/sendEmails`, {})
    snackbar('SUCCESS', 'Emails Sent')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Sending Emails')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getCerts = async () => {

  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequest(`/cert`)
    certs.value = data
    certs.value.forEach(c => {
      c.daysToExpiration = moment(c.expirationDate).diff(moment(), 'days')
    })
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Certs')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const deleteCert = async () => {

  const cert = certToDelete.value
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await deleteRequest(`/cert/${cert.id}`)
    cert.archived = true
    snackbar('SUCCESS', 'Cert Deleted')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Cert')
    store.commit(AppMutations.SET_LOADING, false)
  }
}

</script>

<style scoped lang="scss">
.status-badge {
  margin-bottom: 3px;
  margin-right: 10px;
}
</style>

