<template>
<v-container fluid>
  <v-flex xs12>
    <v-form v-model="formValid">
      <v-layout row wrap align-start justify-space-between>
        <v-flex xs12 md4>
          <v-card class="section">
            <v-card-title>Personal</v-card-title>
            <v-card-text>
              <v-text-field
                label="First Name"
                v-model="user.firstName"
              ></v-text-field>
              <v-text-field
                label="Last Name"
                v-model="user.lastName"
              ></v-text-field>
              <v-text-field
                label="Primary E-Mail"
                v-model="user.email"
              ></v-text-field>
              <v-text-field
                label="Secondary E-Mail"
                v-model="user.personalEmail"
              ></v-text-field>
              <v-text-field
                label="Cell Number"
                v-model="user.phoneNumber"
              ></v-text-field>
              <v-text-field
                label="Office Extension"
                v-model="user.phoneExtension"
              ></v-text-field>
              <v-text-field
                label="Employee ID"
                v-model="user.employeeId"
              ></v-text-field>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="Uniform/Badge Date"
                  readonly
                  v-model="user.tshirtHatDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.tshirtHatDate"
                ></v-date-picker>
              </v-menu>
              <v-select
                v-model="user.hat"
                :items="HatItems"
                label="Hat"
              ></v-select>
              <v-text-field
                label="Accuity Appointment ID"
                v-model="user.accuityAppointmentId"
              ></v-text-field>
              <v-img
                :src="imageUrl"
                contain
              ></v-img>
              <v-flex xs12 text-xs-left>
                <form enctype="multipart/form-data" novalidate class="relative">
                  <v-btn
                    dark
                    color="primaryButton"
                    class="app-button"

                  >Upload File</v-btn>
                  <input
                    type="file"
                    accept="image/*"
                    class="file-input"
                    @change="uploadUserImage($event.target.files)"
                  >
                </form>
              </v-flex>
            </v-card-text>
          </v-card>
        </v-flex>
        <v-flex sm12 md4 >
          <v-card class="section">
            <v-card-title>Onboarding</v-card-title>
            <v-card-text>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="Offer Letter Date"
                  readonly
                  v-model="user.offerLetterDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.offerLetterDate"
                ></v-date-picker>
              </v-menu>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="Contract Request Date"
                  readonly
                  v-model="user.docusignRequestedDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.docusignRequestedDate"
                ></v-date-picker>
              </v-menu>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="Contract Received Date"
                  readonly
                  v-model="user.docusignReceivedDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.docusignReceivedDate"
                ></v-date-picker>
              </v-menu>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="Contract Saved Date"
                  readonly
                  v-model="user.docusignSavedDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.docusignSavedDate"
                ></v-date-picker>
              </v-menu>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="Background Check Submitted Date"
                  readonly
                  v-model="user.backgroundCheckSubmittedDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.backgroundCheckSubmittedDate"
                ></v-date-picker>
              </v-menu>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="Background Check Received Date"
                  readonly
                  v-model="user.backgroundCheckDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.backgroundCheckDate"
                ></v-date-picker>
              </v-menu>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="Welcome E-Mail Date"
                  readonly
                  v-model="user.welcomeEmailDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.welcomeEmailDate"
                ></v-date-picker>
              </v-menu>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="Photo Date"
                  readonly
                  v-model="user.photoDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.photoDate"
                ></v-date-picker>
              </v-menu>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="Voided Check Date"
                  readonly
                  v-model="user.voidedCheckDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.voidedCheckDate"
                ></v-date-picker>
              </v-menu>
              <v-text-field
                label="Password"
                v-model="user.password"
              ></v-text-field>
            </v-card-text>
          </v-card>
        </v-flex>
        <v-flex sm12 md4 >
          <v-card class="section">
            <v-card-title>HR</v-card-title>
            <v-card-text>
              <v-select
                v-model="user.userStatusTypeId"
                label="Status"
                :items="statuses"
                item-text="userStatusType"
                item-value="id"
              ></v-select>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="Hire Date"
                  readonly
                  v-model="user.hireDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.hireDate"
                ></v-date-picker>
              </v-menu>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="Re-Hire Date"
                  readonly
                  v-model="user.reHireDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.reHireDate"
                ></v-date-picker>
              </v-menu>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="Pending Termination Date"
                  readonly
                  v-model="user.pendingTerminationDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.pendingTerminationDate"
                ></v-date-picker>
              </v-menu>
              <v-textarea
                outline
                label="Termination Reason"
                v-model="user.terminationReason"
              ></v-textarea>
              <v-select
                v-model="user.employmentTypeId"
                label="Employment Type"
                :items="employmentTypes"
                item-text="employmentType"
                item-value="id"
              ></v-select>
              <v-select
                v-model="user.compensationTypeId"
                label="Compensation Type"
                :items="compensationTypes"
                item-text="compensationType"
                item-value="id"
              ></v-select>
              <v-select
                v-model="user.recruitedByUserId"
                label="Recruited By"
                :items="recruiters"
                item-text="fullName"
                item-value="id"
              ></v-select>
              <v-autocomplete
                v-model="user.referredByUserId"
                :items="activeUsers"
                :label="`Referred By`"
                item-text="fullName"
                item-value="id"
                :hint="`Type to search`"
                persistent-hint
              ></v-autocomplete>
              <v-text-field
                v-if="onboardedUser.firstName"
                label="Submitted By"
                :value="onboardedUser.firstName + ' ' + onboardedUser.lastName"
                readonly
              ></v-text-field>
            </v-card-text>
          </v-card>
        </v-flex>

        <v-flex xs12 md4>
          <v-card class="section">
            <v-card-title>Systems</v-card-title>
            <v-card-text>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="Namely Date"
                  readonly
                  v-model="user.enterInSolvedDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.enterInSolvedDate"
                ></v-date-picker>
              </v-menu>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="E-Mail Setup Date"
                  readonly
                  v-model="user.emailSetupDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.emailSetupDate"
                ></v-date-picker>
              </v-menu>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="Request Base Date"
                  readonly
                  v-model="user.requestBaseDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.requestBaseDate"
                ></v-date-picker>
              </v-menu>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="Base Contact Created Date"
                  readonly
                  v-model="user.baseContactCreatedDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.baseContactCreatedDate"
                ></v-date-picker>
              </v-menu>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="Mosaic Date"
                  readonly
                  v-model="user.mosaicDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.mosaicDate"
                ></v-date-picker>
              </v-menu>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="Litmos Date"
                  readonly
                  v-model="user.trumpiaDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.trumpiaDate"
                ></v-date-picker>
              </v-menu>
              <v-menu full-width>
                <v-text-field
                  slot="activator"
                  label="T-Sheets Date"
                  readonly
                  v-model="user.timesheetsDate"
                ></v-text-field>
                <v-date-picker
                  v-model="user.timesheetsDate"
                ></v-date-picker>
              </v-menu>
            </v-card-text>
          </v-card>
        </v-flex>

        <v-flex xs12 md4>
          <v-card class="section">
            <v-card-title>Termination</v-card-title>
            <v-card-text>
              <v-text-field
                label="Cancelled Namely Date"
                v-model="user.cancelledIsolvedDate"
                readonly
              ></v-text-field>
              <v-text-field
                label="E-Mail Removed Date"
                v-model="user.emailRemovedDate"
                readonly
              ></v-text-field>
              <v-text-field
                label="Cancelled Base Date"
                v-model="user.removedBaseDate"
                readonly
              ></v-text-field>
              <v-text-field
                label="Base Contact Deleted Date"
                v-model="user.cancelledBaseContactDate"
                readonly
              ></v-text-field>
              <v-text-field
                label="Cancelled Mosaic Date"
                v-model="user.cancelledMosaicDate"
                readonly
              ></v-text-field>
              <v-text-field
                label="Cancelled Litmos Date"
                v-model="user.cancelledTrumpiaDate"
                readonly
              ></v-text-field>
              <v-text-field
                label="Cancelled T-Sheets Date"
                v-model="user.timesheetCancelledDate"
                readonly
              ></v-text-field>
            </v-card-text>
          </v-card>
        </v-flex>

        <v-flex xs12 md4>
          <v-layout row wrap>
            <v-flex xs12>
              <v-card class="section">
                <v-card-title>Notes</v-card-title>
                <v-card-text>
                  <v-textarea
                    outline
                    v-model="user.notes"
                  ></v-textarea>
                </v-card-text>
              </v-card>
            </v-flex>
            <v-flex xs12>
              <v-card class="section">
                <v-card-title>Assets</v-card-title>
                <v-card-text>
                  <v-data-table
                    :headers="assetsTableHeaders"
                    :items="assets"
                    item-key="id"
                    hide-actions
                  >
                    <template slot="items" slot-scope="props">
                      <tr>
                        <td>{{ props.item.tag }}</td>
                        <td>{{ props.item.assetType }}</td>
                        <td>{{ props.item.model }}</td>
                        <td>{{ (props.item.active) ? 'Yes' : 'No' }}</td>
                      </tr>
                    </template>
                  </v-data-table>
                </v-card-text>
              </v-card>
            </v-flex>
          </v-layout>
        </v-flex>
      </v-layout>
    </v-form>
  </v-flex>
</v-container>
</template>
<script>
import axios from 'axios'
import {Actions} from '@/store'

const {VUE_APP_BASE_API} = process.env

const HatItems = [
  {text: 'Y', value: 'Y'},
  {text: 'N', value: 'N'}
]

export default {
  name: 'user',
  data () {
    return {
      HatItems,
      formValid: false,
      user: {},
      statuses: [],
      employmentTypes: [],
      compensationTypes: [],
      recruiters: [],
      activeUsers: [],
      onboardedUser: {},
      assets: [],
      assetsTableHeaders: [
        {text: 'Tag#', value: 'tag'},
        {text: 'Type', value: 'type'},
        {text: 'Model', value: 'model'},
        {text: 'Active', value: 'active'}
      ],
      imageUrl: '',
      imageAsset: {}
    }
  },
  computed: {

  },
  methods: {
    async fetchUserById (id) {
      return await axios.get(`${VUE_APP_BASE_API}/users/${id}`)
    },
    async fetchStatuses () {
      // @TODO: Possibly stuff in the store when fetching on the users page to prevent redundant http requests
      const {data} = await axios.get(`${VUE_APP_BASE_API}/users/statuses`)
      this.statuses = data
    },
    async fetchEmploymentTypes () {
      const {data} = await axios.get(`${VUE_APP_BASE_API}/users/employmentTypes`)
      this.employmentTypes = data
    },
    async fetchCompensationTypes () {
      const {data} = await axios.get(`${VUE_APP_BASE_API}/users/compensationTypes`)
      this.compensationTypes = data
    },
    async fetchRecruiters () {
      const {data} = await axios.get(`${VUE_APP_BASE_API}/recruiters`)
      this.recruiters = data
    },
    async fetchActiveUsers () {
      const {data} = await axios.get(`${VUE_APP_BASE_API}/users/active`)
      this.activeUsers = data
    },
    async fetchUserAssets () {
      const {data} = await axios.get(`${VUE_APP_BASE_API}/users/${this.user.id}/assets`)
      this.assets = data
    },
    async fetchUserImageData () {
      const {data} = await axios.get(`${VUE_APP_BASE_API}/getPresignedUrl`, {
        params: {
          sourceId: this.user.id,
          attachmentSourceTypeId: 9
        }
      })
      return (data.assetUrl === null) ? null : data
    },
    async deleteUserImage() {
        const {status} = await axios.delete(`${VUE_APP_BASE_API}/deleteAttachment/${this.imageAsset.id}`)
        return status === 204
    },
    async uploadUserImage (files) {
      const file = files[0]
      await this.$store.dispatch(Actions.FILE_UPLOAD, {
        file,
        attachmentSourceTypeId: 9,
        sourceId: this.user.id,
        callback: async () => {
          await this.deleteUserImage()
          const asset = await this.fetchUserImageData()
          if (asset !== null) {
            this.imageUrl = asset.assetUrl
            this.imageAsset = asset.asset
          }
        }
      })
    },
  },
  async created () {
    // @TODO: Do these calls like Org.vue to be better parallelized
    const {data} = await this.fetchUserById(this.$route.params.id)
    this.user = data
    const asset = await this.fetchUserImageData()
    if (asset !== null) {
      this.imageUrl = asset.assetUrl
      this.imageAsset = asset.asset
    }
    if (this.user.onboardedByUserId != null) {
      const {data: onboardedData} = await this.fetchUserById(this.user.onboardedByUserId)
      this.onboardedUser = onboardedData
    }
    this.fetchStatuses()
    this.fetchEmploymentTypes()
    this.fetchCompensationTypes()
    this.fetchRecruiters()
    this.fetchActiveUsers()
    this.fetchUserAssets()
  }
}
</script>
<style lang="scss" scoped>
  .section {
    min-width: 250px;
    margin-left: 10px;
    margin-right: 10px;
    margin-top: 15px;
  }

  .file-input {
    opacity: 0;
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
  }
</style>
