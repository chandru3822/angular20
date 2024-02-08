<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Certs & Other Stuff</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <div class="mt-4">
              <v-btn color="primary" @click="sendEmails()" v-if="constants.VUE_APP_ENV === 'local'">
                Send Email Notices
              </v-btn>
            </div>
            <v-btn text color="primary" @click="[addNew = !addNew, selectedCert = {}]">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat >
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
          <v-btn text color="primary" @click="[addNew = !addNew, selectedCert = {}]">Cancel</v-btn>
          <v-btn :disabled="!selectedCert || !selectedCert.certName || !selectedCert.expirationDate"
                 color="primary" class="mr-2"
                 @click="saveCert(true, selectedCert)">
            Save
          </v-btn>
        </v-card>
        <v-data-table
            :headers="headers"
            :items="filterCerts()"
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
              <v-btn :disabled="!item.certName || !item.expirationDate"
                     color="primary" class="white--text mr-2"
                     @click="saveCert(false, item)">
                Save
              </v-btn>
            </td>
          </template>

          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': certs.indexOf(item) % 2}">
              <td class="text-left">
                <v-badge dot class="status-badge" v-if="item.daysToExpiration <= 30"
                         :color="item.daysToExpiration > 0 && item.daysToExpiration <= 7 ? 'error lighten-1' : 'orange'"
                ></v-badge>
                {{ item.certName }}
              </td>
              <td class="text-left">{{ item.expirationDate | formatDate('date', 'MM/DD/YYYY')}}</td>
              <td class="text-left">{{ item.daysToExpiration}}</td>
              <td class="text-right">
                <v-btn small text color="primary" v-if="!expanded.includes(item)" @click="expanded = [item]">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text color="primary" v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>
                <v-btn small text color="primary" @click="certToDelete=item"><v-icon>delete</v-icon></v-btn>
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

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, postRequest, deleteRequest, putRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import ConfirmationDialog from "@/components/ConfirmationDialog";
  import DatetimePickerInput from "@/components/DatetimePickerInput.vue";
  import moment from 'moment'

  export default {
    name: 'Certs',
    components: {DatetimePickerInput, ConfirmationDialog},
    data() {
      return {
        constants,
        snackbar: {},
        addNew: false,
        timezone: this.$store.state.user.details.timezone.value,
        certs: [],
        selectedCert: {},
        selectedCertId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        headers: [
          { text: 'Cert Name', value: 'certName', show: true },
          { text: 'Expiration Date', value: 'expirationDate', show: true },
          { text: 'Days to Expiration', value: 'daysToExpiration', show: true },
          { text: null, value: 'icons', show: true, sortable: false }
        ],
        expanded: [],
        certToDelete: null
      }
    },
    computed: {
      certToDeleteName(){
        return this.certToDelete ? this.certToDelete.certName : ''
      }
    },
    async created () {
      this.getCerts()
    },
    methods: {
      async saveCert(isNew, cert) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await putRequest(`/cert`, cert)
          if(isNew){
            this.certs.push(data)
            this.addNew = false
            this.selectedCert = {}
            this.snackbar = getSnackbar('SUCCESS', 'Cert Added')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          } else {
            this.expanded = []
            this.snackbar = getSnackbar('SUCCESS', 'Cert Updated')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', isNew ? 'Error Adding Cert' : 'Error Updating Cert')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async sendEmails() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await postRequest(`/cert/sendEmails`, {})
          this.snackbar = getSnackbar('SUCCESS', 'Emails Sent')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Sending Emails')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCerts() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/cert`)
          this.certs = data
          this.certs.forEach(c => {
            c.daysToExpiration = moment(c.expirationDate).diff(moment(), 'days')
          })
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Certs')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteCert() {
        const cert = this.certToDelete
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/cert/${cert.id}`)
          cert.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'Cert Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Cert')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterCerts () {
        return this.certs.filter(cf => { return !cf.archived})
      },
    }
  }
</script>

<style scoped lang="scss">
.status-badge {
  margin-bottom: 3px;
  margin-right: 10px;
}
</style>

