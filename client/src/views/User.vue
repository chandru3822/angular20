<template>
  <v-container fluid>
    <v-col cols="12">
      <v-form v-model="formValid">
        <v-row align="start" justify="space-between">
          <v-col cols="12" md="4">
            <v-card class="section">
              <v-card-title class="title">Personal</v-card-title>
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
                <v-col class="text-left" cols="12">
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
                </v-col>
              </v-card-text>
            </v-card>
          </v-col>
          <v-col sm="12" md="4" >
            <v-card class="section">
              <v-card-title class="title">Onboarding</v-card-title>
              <v-card-text>

                <v-menu min-width="290px">
                  <template #activator="{on}">
                    <v-text-field
                      label="Offer Letter Date"
                      readonly
                      :value="user.offerLetterDate | formatDate"
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="user.offerLetterDate"></v-date-picker>
                </v-menu>

                <v-menu min-width="290px">
                  <template #activator="{on}">
                    <v-text-field
                      label="Contract Request Date"
                      readonly
                      :value="user.docusignRequestedDate | formatDate"
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="user.docusignRequestedDate"></v-date-picker>
                </v-menu>

                <v-menu min-width="290px">
                  <template #activator="{on}">
                    <v-text-field
                      label="Contract Received Date"
                      readonly
                      :value="user.docusignReceivedDate | formatDate"
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="user.docusignReceivedDate"></v-date-picker>
                </v-menu>

                <v-menu min-width="290px">
                  <template #activator="{on}">
                    <v-text-field
                      label="Contract Saved Date"
                      readonly
                      :value="user.docusignSavedDate | formatDate"
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="user.docusignSavedDate"></v-date-picker>
                </v-menu>

                <v-menu min-width="290px">
                  <template #activator="{on}">
                    <v-text-field
                      label="Background Check Submitted Date"
                      readonly
                      :value="user.backgroundCheckSubmittedDate | formatDate"
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="user.backgroundCheckSubmittedDate"></v-date-picker>
                </v-menu>

                <v-menu min-width="290px">
                  <template #activator="{on}">
                    <v-text-field
                      label="Background Check Received Date"
                      readonly
                      :value="user.backgroundCheckDate | formatDate"
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="user.backgroundCheckDate"></v-date-picker>
                </v-menu>

                <v-menu min-width="290px">
                  <template #activator="{on}">
                    <v-text-field
                      label="Welcome E-Mail Date"
                      readonly
                      :value="user.welcomeEmailDate | formatDate"
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="user.welcomeEmailDate"></v-date-picker>
                </v-menu>

                <v-menu min-width="290px">
                  <template #activator="{on}">
                    <v-text-field
                      label="Photo Date"
                      readonly
                      :value="user.photoDate | formatDate"
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="user.photoDate"></v-date-picker>
                </v-menu>

                <v-menu min-width="290px">
                  <template #activator="{on}">
                    <v-text-field
                      label="Voided Check Date"
                      readonly
                      :value="user.voidedCheckDate | formatDate"
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="user.voidedCheckDate"></v-date-picker>
                </v-menu>

                <v-text-field
                  label="Password"
                  v-model="user.password"
                ></v-text-field>
              </v-card-text>
            </v-card>
          </v-col>

          <v-col sm="12" md="4">
            <v-card class="section">
              <v-card-title class="title">HR</v-card-title>
              <v-card-text>

                <v-select
                  v-model="user.userStatusTypeId"
                  label="Status"
                  :items="statuses"
                  item-text="userStatusType"
                  item-value="id"
                ></v-select>

                <v-menu min-width="290px">
                  <template #activator="{on}">
                    <v-text-field
                      label="Hire Date"
                      readonly
                      :value="user.hireDate | formatDate"
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="user.hireDate"></v-date-picker>
                </v-menu>

                <v-menu min-width="290px">
                  <template #activator="{on}">
                    <v-text-field
                      label="Re-Hire Date"
                      readonly
                      :value="user.reHireDate | formatDate"
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="user.reHireDate"></v-date-picker>
                </v-menu>

                <v-menu min-width="290px">
                  <template #activator="{on}">
                    <v-text-field
                      label="Pending Termination Date"
                      readonly
                      :value="user.pendingTerminationDate | formatDate"
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="user.pendingTerminationDate"></v-date-picker>
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
          </v-col>

          <v-col cols="12" md="4">
            <v-card class="section">
              <v-card-title class="title">Systems</v-card-title>
              <v-card-text>

                <v-menu min-width="290px">
                  <template #activator="{on}">
                    <v-text-field
                      label="Namely Date"
                      readonly
                      :value="user.enterInSolvedDate | formatDate"
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="user.enterInSolvedDate"></v-date-picker>
                </v-menu>

                <v-menu min-width="290px">
                  <template #activator="{on}">
                    <v-text-field
                      label="E-Mail Setup Date"
                      readonly
                      :value="user.emailSetupDate | formatDate"
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="user.emailSetupDate"></v-date-picker>
                </v-menu>

                <v-menu min-width="290px">
                  <template #activator="{on}">
                    <v-text-field
                      label="Request Base Date"
                      readonly
                      :value="user.requestBaseDate | formatDate"
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="user.requestBaseDate"></v-date-picker>
                </v-menu>

                <v-menu min-width="290px">
                  <template #activator="{on}">
                    <v-text-field
                      label="Base Contact Created Date"
                      readonly
                      :value="user.baseContactCreatedDate | formatDate"
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="user.baseContactCreatedDate"></v-date-picker>
                </v-menu>

                <v-menu min-width="290px">
                  <template #activator="{on}">
                    <v-text-field
                      label="Mosaic Date"
                      readonly
                      :value="user.mosaicDate | formatDate"
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="user.mosaicDate"></v-date-picker>
                </v-menu>

                <v-menu min-width="290px">
                  <template #activator="{on}">
                    <v-text-field
                      label="Litmos Date"
                      readonly
                      :value="user.trumpiaDate | formatDate"
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="user.trumpiaDate"></v-date-picker>
                </v-menu>

                <v-menu min-width="290px">
                  <template #activator="{on}">
                    <v-text-field
                      label="T-Sheets Date"
                      readonly
                      :value="user.timesheetsDate | formatDate"
                      v-on="on"
                    ></v-text-field>
                  </template>
                  <v-date-picker v-model="user.timesheetsDate"></v-date-picker>
                </v-menu>
              </v-card-text>
            </v-card>
          </v-col>

          <v-col cols="12" md="4">
            <v-card class="section">
              <v-card-title class="title">Termination</v-card-title>
              <v-card-text>
                <v-text-field
                  label="Cancelled Namely Date"
                  :value="user.cancelledIsolvedDate | formatDate"
                  readonly
                  disabled
                ></v-text-field>
                <v-text-field
                  label="E-Mail Removed Date"
                  :value="user.emailRemovedDate | formatDate"
                  readonly
                  disabled
                ></v-text-field>
                <v-text-field
                  label="Cancelled Base Date"
                  :value="user.removedBaseDate | formatDate"
                  readonly
                  disabled
                ></v-text-field>
                <v-text-field
                  label="Base Contact Deleted Date"
                  :value="user.cancelledBaseContactDate | formatDate"
                  readonly
                  disabled
                ></v-text-field>
                <v-text-field
                  label="Cancelled Mosaic Date"
                  :value="user.cancelledMosaicDate | formatDate"
                  readonly
                  disabled
                ></v-text-field>
                <v-text-field
                  label="Cancelled Litmos Date"
                  :value="user.cancelledTrumpiaDate | formatDate"
                  readonly
                  disabled
                ></v-text-field>
                <v-text-field
                  label="Cancelled T-Sheets Date"
                  :value="user.timesheetCancelledDate | formatDate"
                  readonly
                  disabled
                ></v-text-field>
              </v-card-text>
            </v-card>
          </v-col>

          <v-col cols="12" md="4">
            <v-row>
              <v-col cols="12">
                <v-card class="section">
                  <v-card-title class="title">Notes</v-card-title>
                  <v-card-text>
                    <v-textarea
                      outline
                      v-model="user.notes"
                    ></v-textarea>
                  </v-card-text>
                </v-card>
              </v-col>
              <v-col cols="12">
                <v-card class="section">
                  <v-card-title class="title">Assets</v-card-title>
                  <v-card-text>
                    <v-data-table
                      :headers="assetsTableHeaders"
                      :items="assets"
                      item-key="id"
                      hide-default-footer
                    >
                      <template #items="props">
                        <tr>
                          <td>{{ props.item.tag }}</td>
                          <td>{{ props.item.assetType }}</td>
                          <td>{{ com.albatross.api.v1.company.blueraven.models }}</td>
                          <td>{{ (props.item.active) ? 'Yes' : 'No' }}</td>
                        </tr>
                      </template>
                    </v-data-table>
                  </v-card-text>
                </v-card>
              </v-col>
            </v-row>
          </v-col>
        </v-row>
      </v-form>
    </v-col>
  </v-container>
</template>

<script>
  import {Actions} from '@/store'

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
          {text: 'Model', value: 'models'},
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
        // const { data } = await this.$apollo.query({
        //   query: GET_USER,
        //   fetchPolicy: 'no-cache',
        //   variables: {
        //     idStringInput: {
        //       id
        //     }
        //   },
        //   debounce: 500
        // })
        // const { getUser } = data

        // let {data} = await axios.get(`${VUE_APP_BASE_API}/users/${id}`)

        // Dates are being returned in the format of `YYYY-MM-DDTHH:mm:ss.SSSZ`, which breaks Vuetify's datepicker. It required `YYYY-MM-DD`.
        // So, reformat all dates to match `YYYY-MM-DD`
        // Object.entries(getUser).forEach(([key, val]) => {
        //   if (/(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}).(\d{3})Z/.test(val)) {
        //     data[key] = val.substr(0, 10)
        //   }
        // })
        // return getUser
      },
      async fetchStatuses () {
        // @TODO: Possibly stuff in the store when fetching on the users page to prevent redundant http requests
        // const { data } = await this.$apollo.query({
        //   query: USER_STATUSES,
        //   fetchPolicy: 'no-cache',
        //   variables: {},
        //   debounce: 500
        // })
        // const { userStatuses } = data
        // this.statuses = userStatuses
      },
      async fetchEmploymentTypes () {
        // const { data } = await this.$apollo.query({
        //   query: EMPLOYMENT_TYPES,
        //   fetchPolicy: 'no-cache',
        //   variables: {},
        //   debounce: 500
        // })
        // const { employmentTypes } = data
        // this.employmentTypes = employmentTypes
      },
      async fetchCompensationTypes () {
        // const { data } = await this.$apollo.query({
        //   query: COMPENSATION_TYPES,
        //   fetchPolicy: 'no-cache',
        //   variables: {},
        //   debounce: 500
        // })
        // const { compensationTypes } = data
        // this.compensationTypes = compensationTypes
      },
      async fetchRecruiters () {
        // const { data } = await this.$apollo.query({
        //   query: RECRUITERS,
        //   fetchPolicy: 'no-cache',
        //   variables: {},
        //   debounce: 500
        // })
        // const { recruiters } = data
        // this.recruiters = recruiters
      },
      async fetchActiveUsers () {
        // const { data } = await this.$apollo.query({
        //   query: ACTIVE_USERS,
        //   fetchPolicy: 'no-cache',
        //   variables: {},
        //   debounce: 500
        // })
        // const { activeUsers } = data
        // this.activeUsers = activeUsers
      },
      async fetchUserAssets () {
        // const { data } = await this.$apollo.query({
        //   query: USER_ASSETS,
        //   fetchPolicy: 'no-cache',
        //   variables: {
        //     idInput: {
        //       id: this.user.id
        //     }
        //   },
        //   debounce: 500
        // })
        // const { assets } = data
        // this.assets = assets
      },
      async fetchUserImageData () {
        // const {data} = await axios.get(`${VUE_APP_BASE_API}/getPresignedUrl`, {
        //   params: {
        //     sourceId: this.user.id,
        //     attachmentSourceTypeId: 9
        //   }
        // })
        // return (data.assetUrl === null) ? null : data

        //haven't tested this yet either but should be close
        // const { data } = await this.$apollo.query({
        //   query: PRESIGNED_URL,
        //   fetchPolicy: 'no-cache',
        //   variables: {
        //     presignedUrlInput: {
        //       sourceId: this.user.id,
        //       attachmentSourceTypeId: 9
        //     }
        //   },
        //   debounce: 500
        // })
        // const { presignedUrl } = data
        // return presignedUrl && presignedUrl.assetUrl !== null ? presignedUrl : null

      },
      async deleteUserImage() {
        // I haven't tested this out yet
        // await this.$apollo.mutate({
        //   mutation: DELETE_ATTACHMENT,
        //   fetchPolicy: 'no-cache',
        //   variables: {
        //     idInput: {
        //       id: this.imageAsset.id
        //     }
        //   },
        //   debounce: 500
        // })
        // const {status} = await axios.delete(`${VUE_APP_BASE_API}/deleteAttachment/${this.imageAsset.id}`)
        // return status === 204
      },
      async uploadUserImage (files) {
        const file = files[0]
        // await this.$store.dispatch(Actions.FILE_UPLOAD, {
        //   apolloClient: this.$apollo,
        //   file,
        //   attachmentSourceTypeId: 9,
        //   sourceId: this.user.id,
        //   callback: async () => {
        //     await this.deleteUserImage()
        //     const asset = await this.fetchUserImageData()
        //     if (asset !== null) {
        //       this.imageUrl = asset.assetUrl
        //       this.imageAsset = asset.asset
        //     }
        //   }
        // })
      },
    },
    async created () {
      // @TODO: Do these calls like Org.vue to be better parallelized
      this.user = await this.fetchUserById(this.$route.params.id)
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