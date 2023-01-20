<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar" v-if="!constants.IS_MOBILE">
          <v-toolbar-title class="app-title">Company Settings</v-toolbar-title>
        </v-toolbar>
      </v-col>
    </v-row>
    <v-form ref="companyForm" v-model="validForm">
      <v-row>
        <v-col cols="12">
          <v-text-field v-model="company.companyName"
                        placeholder="Enter a value"
                        required
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        label="Company Name">
          </v-text-field>
          <v-text-field v-model="company.defaultPassword"
                        placeholder="Enter a value"
                        required
                        :rules="[passwordRule]"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        label="Default Password">
          </v-text-field>
          <v-text-field v-model.number="company.minuteIncrement"
                        placeholder="Enter a value"
                        required
                        :rules="rules"
                        @input="forceInteger"
                        :step="1"
                        :key="damnKeyThing"
                        type="number"
                        class="minute-increment-field"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        label="Minute Increment">
          </v-text-field>
        </v-col>
      </v-row>
      <v-row>
        <v-col cols="12" class="text-center">
          <v-btn :disabled="!company.companyName || !company.defaultPassword || ((company.minuteIncrement || company.minuteIncrement === 0) && (company.minuteIncrement < 0 || company.minuteIncrement > 60))"
                 color="primary" @click="saveCompany" v-if="userCanEdit">
            <v-icon class="pr-2">mdi-content-save</v-icon>
            Save Changes
          </v-btn>
        </v-col>
      </v-row>
    </v-form>
    <v-divider class="mt-3 mb-3"></v-divider>
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Company Logo</v-toolbar-title>
          <v-spacer></v-spacer>
          <div v-if="userCanEdit">
            <v-btn text color="primary" v-if="!savingCompanyLogo && !companyLogo.presignedUrl"  @click="addImage = !addImage">
              <v-icon v-if="addImage">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
            <v-btn text color="primary" v-else @click="logoToDelete=LogoTypeEnum.Company"><v-icon>delete</v-icon></v-btn>
          </div>
        </v-toolbar>
        <div class="text-center">
          <div class="mt-4" v-if="addImage">
            <form enctype="multipart/form-data" novalidate>
              <input
                  type="file"
                  :accept="acceptedFileTypes"
                  class="file-input clickable"
                  :disabled="savingCompanyLogo"
                  @change="uploadFile(true, $event.target.files, attachmentTypeId, companyId, 1048576)"
                  name="avatar"
              >
              <br/><span>* Due to render times associated with this file it cannot exceed 1MB</span>
            </form>
          </div>
          <div class="company-logo-background" v-else-if="companyLogo.presignedUrl">
            <img class="company-logo" :src="companyLogo.presignedUrl">
          </div>
          <div class="mt-4" v-else>
            No image uploaded
          </div>
        </div>
      </v-col>
    </v-row>


    <v-divider class="mt-3 mb-3"></v-divider>
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Home Page Logo</v-toolbar-title>
          <v-spacer></v-spacer>
          <div v-if="userCanEdit">
            <v-btn text color="primary" v-if="!savingHomePageLogo && !homePageLogo.presignedUrl"  @click="addHomePageImage = !addHomePageImage">
              <v-icon v-if="addHomePageImage">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
            <v-btn text color="primary" v-else @click="logoToDelete=LogoTypeEnum.HomePage"><v-icon>delete</v-icon></v-btn>
          </div>
        </v-toolbar>
        <div class="text-center">
          <div class="mt-4" v-if="addHomePageImage">
            <form enctype="multipart/form-data" novalidate>
              <input
                type="file"
                :accept="acceptedFileTypes"
                class="file-input clickable"
                :disabled="savingHomePageLogo"
                @change="uploadFile(false, $event.target.files, homePageAttachmentTypeId, companyId, 1048576)"
                name="avatar"
              >
              <br/><span>* Due to render times associated with this file it cannot exceed 1MB</span>
            </form>
          </div>
          <div class="company-logo-background" v-else-if="homePageLogo.presignedUrl">
            <img class="company-logo" :src="homePageLogo.presignedUrl">
          </div>
          <div class="mt-4" v-else>
            No image uploaded
          </div>
        </div>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!logoToDelete" @confirm="deleteAttachment(logoToDeleteId)" @close-dialog="logoToDelete=null">
      {{deleteLogoDialogText}}
    </ConfirmationDialog>
  </v-container>
</template>


<script>
import { Actions } from '@/store'
import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, getRequest, putRequest, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from "@/components/ConfirmationDialog";

const LogoTypeEnum = Object.freeze({
  Company: "CompanyLogo",
  HomePage: "HomePageLogo"
})

export default {
  name: 'CompanySettings',
  components: {ConfirmationDialog},
  data () {
    return {
      loadComplete: false,
      constants,
      addImage: false,
      snackbar: {},
      company: {},
      rules: [
        v => v >= 0 || 'Value must be greater than or equal to 0',
        v => v <= 60 || 'Value must be less than or equal to 60',
      ],
      validForm: false,
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      companyId: this.$store.state.user.details.companyId,
      acceptedFileTypes: constants.STANDARD_IMAGES_ONLY,
      savingCompanyLogo: false,
      //todo: 29 = company logo - do this on backend?
      attachmentTypeId: 29,
      companyLogo: {},
      addHomePageImage: false,
      savingHomePageLogo: false,
      homePageLogo: {},
      //todo: 333 = home page logo - do this on backend?
      homePageAttachmentTypeId: 333,
      damnKeyThing: 0,
      LogoTypeEnum,
      logoToDelete: null
    }
  },
  computed: {
    deleteLogoDialogText() {
      switch (this.logoToDelete) {
        case LogoTypeEnum.Company:
          return "Are you sure you want to delete the company logo?"
        case LogoTypeEnum.HomePage:
          return "Are you sure you want to delete the home page logo?"
        default:
          return ""
      }
    },
    logoToDeleteId() {
      switch (this.logoToDelete) {
        case LogoTypeEnum.Company:
          return this.companyLogo.id
        case LogoTypeEnum.HomePage:
          return this.homePageLogo.id
        default:
          return null
      }
    }
  },
  methods: {
    forceInteger() {
      if(this.company.minuteIncrement % 1 !== 0) {
        this.company.minuteIncrement = Math.floor(this.company.minuteIncrement);
        this.damnKeyThing++
      }
    },
    passwordRule (value) {
      if (value && value.length < 8) {
        return 'Password must be at least 8 characters'
      } else {
        return true
      }
    },
    async loadCompany () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/companies/${this.companyId}`)
        this.company = data

        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Company')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveCompany () {
      if (this.$refs.companyForm.validate()) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await putRequest(`/companies`, this.company)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Company')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async deleteAttachment (id) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await this.$store.dispatch(Actions.FILE_DELETE, {
          id,
          callback: async () => {
            if(this.logoToDelete == LogoTypeEnum.Company){
              this.companyLogo = {}
            } else {
              this.homePageLogo = {}
            }
            // this.$store.commit(UserMutations.SET_USER_IMAGE, {})
            this.snackbar = getSnackbar('SUCCESS', 'Image Deleted')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        })
      } catch(e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting File')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async uploadFile (isCompanyLogo, files, attachmentTypeId, sourceId, sizeLimit) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        let file = files[0]
        await this.$store.dispatch(Actions.FILE_UPLOAD, {
          file: file,
          sizeLimit,
          attachmentTypeId,
          sourceId,
          displayName: file.name.substr(0, file.name.lastIndexOf('.')),
          callback: async (img, error) => {
            if(error?.error) {
              this.snackbar = getSnackbar('ERROR', error.errorMsg)
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
            } else {
              if(isCompanyLogo) {
                this.companyLogo = img
                this.addImage = false
              } else {
                this.homePageLogo = img
                this.addHomePageImage = false
              }
              this.snackbar = getSnackbar('SUCCESS', 'Image Uploaded')
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
            }
          }
        })
      } catch(e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async loadCompanyLogo () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await this.$store.dispatch(Actions.FILE_GET_ONE, {
          attachmentTypeId: this.attachmentTypeId,
          sourceId: this.companyId,
          callback: async (img) => {
            this.companyLogo = img
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        })
      } catch(e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Loading Image')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async loadHomePageLogo () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await this.$store.dispatch(Actions.FILE_GET_ONE, {
          attachmentTypeId: this.homePageAttachmentTypeId,
          sourceId: this.companyId,
          callback: async (img) => {
            this.homePageLogo = img
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        })
      } catch(e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Loading Image')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  },
  async created () {
    this.loadCompany()
    this.loadCompanyLogo()
    this.loadHomePageLogo()
  }
}
</script>

<style scoped lang="scss">
.company-logo {
  margin-top: 15px;
  max-width: 100%;
  height: auto;
}

.company-logo-background {
  background-color: #bbbbbb;
}

.minute-increment-field {
  width: 200px;
}
</style>
