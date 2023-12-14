<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar" v-if="$vuetify.breakpoint.smAndUp">
          <v-toolbar-title class="title-large">Company Settings</v-toolbar-title>
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
                        class="body-large"
                        label="Company Name">
          </v-text-field>
          <v-text-field v-model="company.defaultPassword"
                        placeholder="Enter a value"
                        required
                        :rules="[passwordRule]"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        class="body-large"
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
                        class="minute-increment-field body-large"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        label="Minute Increment">
          </v-text-field>
          <div>
            <div class="color-swatch d-inline-block mr-3"
                 :style="{'background-color': company.bannerColor}"></div>
            <v-text-field v-model="company.bannerColor"
                          placeholder="Enter a color HEX"
                          required
                          :rules="[hexRule]"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          class="body-large color-field d-inline-block"
                          label="Banner Color">
            </v-text-field>
          </div>
          <div>
            <div class="color-swatch d-inline-block mr-3"
                 :style="{'background-color': company.primaryColor}"></div>
            <v-text-field v-model="company.primaryColor"
                          placeholder="Enter a color HEX"
                          required
                          :rules="[hexRule]"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          class="body-large color-field d-inline-block"
                          label="Primary Color">
            </v-text-field>
          </div>
        </v-col>
      </v-row>
      <v-row>
        <v-col cols="12" class="text-center">
          <v-btn :large="$vuetify.breakpoint.smAndDown"
                 :disabled="!company.companyName || !company.defaultPassword || ((company.minuteIncrement || company.minuteIncrement === 0) && (company.minuteIncrement < 0 || company.minuteIncrement > 60))"
                 color="primary" @click="saveCompany" v-if="userCanEdit"
                 :class="{'one-hunned': $vuetify.breakpoint.smAndDown}">
            <v-icon :large="$vuetify.breakpoint.smAndDown" class="pr-2">mdi-content-save</v-icon>
            <span class="body-medium text-capitalize">Save Changes</span>
          </v-btn>

        </v-col>
      </v-row>
    </v-form>
    <v-divider class="mt-3" v-if="is7oaksAdmin"></v-divider>
    <v-row v-if="is7oaksAdmin">
      <v-col cols="12" class="pt-0">
        <v-toolbar flat class="app-toolbar" v-if="$vuetify.breakpoint.smAndUp">
          <v-toolbar-title class="title-large">Test User Password</v-toolbar-title>
        </v-toolbar>
        <div class="px-3">
          <v-text-field v-model="testUserPassword"
                        placeholder="Enter a new password"
                        required
                        :rules="[passwordRule]"
                        class="body-large"
                        label="Test User Password">
          </v-text-field>
          <v-btn :large="$vuetify.breakpoint.smAndDown" :disabled="!testUserPassword"
                 color="primary" @click="saveTestUserPassword">
            <v-icon :large="$vuetify.breakpoint.smAndDown" class="pr-2">mdi-content-save</v-icon>
            <span class="body-medium text-capitalize">Save Test User Password</span>
          </v-btn>
        </div>
      </v-col>
    </v-row>
    <v-divider class="mt-3 mb-3"></v-divider>
    <v-row v-for="([key, logoType], idx) in Object.entries(LogoTypeEnum)">
      <v-col cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="title-large">{{logoType.header}}</v-toolbar-title>
          <v-spacer></v-spacer>
          <div v-if="userCanEdit">
            <v-btn icon :large="$vuetify.breakpoint.smAndDown" color="primary"
                   v-if="!logoType.saving && !logoType.image?.presignedUrl" @click="logoType.add = !logoType.add">
              <v-icon v-if="logoType.add">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
            <v-btn icon :large="$vuetify.breakpoint.smAndDown" color="primary" v-else
                   @click="logoToDelete=logoType">
              <v-icon>delete</v-icon>
            </v-btn>
          </div>
        </v-toolbar>
        <div class="text-center">
          <div class="mt-4" v-if="logoType.add">
            <form enctype="multipart/form-data" novalidate>
              <input
                  type="file"
                  :accept="acceptedFileTypes"
                  class="file-input clickable body-medium mx-6"
                  :disabled="logoType.saving"
                  @change="uploadFile(logoType, $event.target.files, logoType.attachmentTypeId, companyId, 1048576)"
                  name="avatar"
              >
              <br/><span>* Due to render times associated with this file it cannot exceed 1MB</span>
            </form>
          </div>
          <div class="company-logo-background" v-else-if="logoType.image?.presignedUrl">
            <img class="company-logo" :src="logoType.image.presignedUrl">
          </div>
          <div class="mt-4" v-else>
            No image uploaded
          </div>
        </div>
      </v-col>
    </v-row>

    <ConfirmationDialog :open-dialog="!!logoToDelete" @confirm="deleteAttachment(logoToDelete)"
                        @close-dialog="logoToDelete=null">
      {{ deleteLogoDialogText }}
    </ConfirmationDialog>
  </v-container>
</template>


<script>
import {Actions} from '@/store'
import {AppMutations} from '@/stores/AppStore'
import {
  handleHidingGlobalLoader,
  postRequestWithRequestParams,
  getRequest,
  putRequest,
  getSnackbar
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from "@/components/ConfirmationDialog";

const LogoTypeEnum = {
  COMPANY: {
    key: "COMPANY", //this needs to match the key, cuz dumb
    header: 'Company Logo',
    description: '(Top Left Icon)',
    label: 'company',
    attachmentTypeId: 29,
    add: false,
    saving: false,
    image: {}
  },
  HOME_PAGE: {
    key: "HOME_PAGE", //this needs to match the key, cuz dumb
    header: 'Home Page Logo',
    description: '',
    label: 'home page',
    attachmentTypeId: 333,
    add: false,
    saving: false,
    image: {}
  },
  LOADING_SPINNER: {
    key: "LOADING_SPINNER", //this needs to match the key, cuz dumb
    header: 'Loading Spinner',
    description: '(Page Load Indicator)',
    label: 'loading spinner',
    attachmentTypeId: 987,
    add: false,
    saving: false,
    image: {}
  }
}

export default {
  name: 'CompanySettings',
  components: {ConfirmationDialog},
  data() {
    return {
      loadComplete: false,
      constants,
      colorOptions: {
        canvasHeight: 75,
        width: 200,
        mode: 'hexa',
        hideModeSwitch: true
      },
      snackbar: {},
      company: {},
      rules: [
        v => v >= 0 || 'Value must be greater than or equal to 0',
        v => v <= 60 || 'Value must be less than or equal to 60',
      ],
      validForm: false,
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      is7oaksAdmin: this.$store.getters.isFullAdmin,
      testUserPassword: '',
      companyId: this.$store.state.user.details.companyId,
      acceptedFileTypes: constants.STANDARD_IMAGES_ONLY,
      damnKeyThing: 0,
      LogoTypeEnum,
      logoToDelete: null
    }
  },
  computed: {
    deleteLogoDialogText() {
      return `Are you sure you want to delete the ${ this.logoToDelete?.label } logo?`
    },
    logoToDeleteId() {
      return this.logoToDelete?.image?.id
    }
  },
  methods: {
    forceInteger() {
      if (this.company.minuteIncrement % 1 !== 0) {
        this.company.minuteIncrement = Math.floor(this.company.minuteIncrement);
        this.damnKeyThing++
      }
    },
    hexRule(value) {
      let regEx = /^#[0-9A-Fa-f]{6}/g
      if(value && value.charAt(0) !== '#') {
        return 'First character must be #'
      } else if (value && value.length !== 7) {
        return 'Color HEX must be exactly 7 characters'
      } else if (value && !regEx.test(value)) {
        return 'Can only contain 1-9 and A-F'
      } else {
        return true
      }
    },
    passwordRule(value) {
      if (value && value.length < 8) {
        return 'Password must be at least 8 characters'
      } else {
        return true
      }
    },
    async loadCompany() {
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
    async saveTestUserPassword() {
      if (this.$refs.companyForm.validate()) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            password: this.testUserPassword
          }
          const {status} = await postRequestWithRequestParams(`/user/updateTestAccounts`, null, params)
          this.testUserPassword = ''
          this.snackbar = getSnackbar('SUCCESS', 'Test User Password Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async saveCompany() {
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
    async deleteAttachment(logoToDelete) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await this.$store.dispatch(Actions.FILE_DELETE, {
          id: logoToDelete.image?.id,
          callback: async () => {
            LogoTypeEnum[logoToDelete.key].image = {}
            // this.$store.commit(UserMutations.SET_USER_IMAGE, {})
            this.snackbar = getSnackbar('SUCCESS', 'Image Deleted')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting File')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async uploadFile(logoType, files, attachmentTypeId, sourceId, sizeLimit) {
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
            if (error?.error) {
              this.snackbar = getSnackbar('ERROR', error.errorMsg)
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
            } else {
              LogoTypeEnum[logoType.key].image = img
              LogoTypeEnum[logoType.key].add = false
              LogoTypeEnum[logoType.key].saving = false
              this.snackbar = getSnackbar('SUCCESS', 'Image Uploaded')
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
            }
          }
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async loadImage(logoType) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await this.$store.dispatch(Actions.FILE_GET_ONE, {
          attachmentTypeId: logoType.attachmentTypeId,
          sourceId: this.companyId,
          callback: async (img) => {
            logoType.image = img
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Loading Image')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  },
  async created() {
    this.loadCompany()
    //load each image for
    Object.entries(LogoTypeEnum).forEach( ([key, value], idx) => {
      this.loadImage(value)
    })
  }
}
</script>

<style lang="scss">

</style>

<style scoped lang="scss">
.company-logo {
  margin-top: 15px;
  max-width: 100%;
  height: auto;
  max-height: 300px;
}

.color-swatch {
  height: 30px;
  width: 30px;
  border-radius: 50%;
  border: solid 1px black;
}

.color-field {
  width: 50%;
}

.company-logo-background {
  background-color: #bbbbbb;
}

.minute-increment-field {
  @media (min-width: 960px) {
    width: 200px;
  }
}

.file-input {
  max-width: calc(100vw - 100px);
}


</style>
