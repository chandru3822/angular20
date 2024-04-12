<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar" v-if="vuetify.breakpoint.smAndUp">
          <v-toolbar-title class="title-large">Company Settings</v-toolbar-title>
        </v-toolbar>
      </v-col>
    </v-row>
    <v-form ref="companyForm" v-model="validForm">
      <v-row>
        <v-col cols="12">
          <a-text-field v-model="company.companyName"
                        placeholder="Enter a value"
                        required
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        class="body-large"
                        label="Company Name">
          </a-text-field>
          <a-text-field v-model="company.defaultPassword"
                        placeholder="Enter a value"
                        required
                        :rules="[passwordRule]"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        class="body-large"
                        label="Default Password">
          </a-text-field>
          <a-text-field v-model.number="company.minuteIncrement"
                        placeholder="Enter a value"
                        required
                        :rules="rules"
                        @input="forceInteger"
                        :step="1"
                        clearable
                        :key="damnKeyThing"
                        type="number"
                        class="minute-increment-field body-large"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        label="Minute Increment">
          </a-text-field>
          <div>
            <div class="color-swatch d-inline-block mr-3"
                 :style="{'background-color': company.bannerColor}"></div>
            <a-text-field v-model="company.bannerColor"
                          placeholder="Enter a color HEX"
                          clearable
                          :rules="[hexRule]"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          class="body-large color-field d-inline-block"
                          label="Banner Color">
            </a-text-field>
          </div>
          <div>
            <div class="color-swatch d-inline-block mr-3"
                 :style="{'background-color': company.primaryColor}"></div>
            <a-text-field v-model="company.primaryColor"
                          placeholder="Enter a color HEX"
                          clearable
                          :rules="[hexRule]"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          class="body-large color-field d-inline-block"
                          label="Primary Color">
            </a-text-field>

            <div>
              <a-btn text="Primary" class="mr-3" color="primary"/>
              <a-btn text="Lighten 3" class="mr-3" color="primary lighten-3"/>
              <a-btn text="Lighten 5" class="mr-3" color="primary lighten-5"/>
              <a-btn text="Lighten 9" class="mr-3" color="primary lighten-9"/>
            </div>
          </div>
        </v-col>
      </v-row>
      <v-row>
        <v-col cols="12" class="text-center">
          <a-btn :large="vuetify.breakpoint.smAndDown"
                 :disabled="!company.companyName || !company.defaultPassword || ((company.minuteIncrement || company.minuteIncrement === 0) && (company.minuteIncrement < 0 || company.minuteIncrement > 60))"
                 color="primary" @click="saveCompany" v-if="userCanEdit"
                 :class="{'one-hunned': vuetify.breakpoint.smAndDown}"
                 prepend-icon="mdi-content-save"
                           hide-text-on-mobile
                 text="SAVE CHANGES"
          />
        </v-col>
      </v-row>
    </v-form>
    <v-divider class="mt-3" v-if="is7oaksAdmin"></v-divider>
    <v-row v-if="is7oaksAdmin">
      <v-col cols="12" class="pt-0">
        <v-toolbar flat class="app-toolbar" v-if="vuetify.breakpoint.smAndUp">
          <v-toolbar-title class="title-large">Test User Password</v-toolbar-title>
        </v-toolbar>
        <div class="px-3">
          <a-text-field v-model="testUserPassword"
                        placeholder="Enter a new password"
                        required
                        :rules="[passwordRule]"
                        class="body-large"
                        label="Test User Password">
          </a-text-field>
          <a-btn :large="vuetify.breakpoint.smAndDown" :disabled="!testUserPassword"
                 color="primary" @click="saveTestUserPassword"
                 prepend-icon="mdi-content-save"
                 text="SAVE TEST USER PASSWORD"
          />
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
            <a-btn variant="text" icon :large="vuetify.breakpoint.smAndDown" color="primary"
                   v-if="!logoType.saving && !logoType.image?.presignedUrl" @click="logoType.add = !logoType.add"
                   :prepend-icon="logoType.add ? 'remove' : 'add'"
            />
            <a-btn variant="text" icon :large="vuetify.breakpoint.smAndDown" color="primary" v-else
                   @click="logoToDelete=logoType"
                   prepend-icon="delete"
            />
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


<script setup>
import {
  handleHidingGlobalLoader,
  postRequestWithRequestParams,
  getRequest,
  putRequest
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from '@/components/ConfirmationDialog'
import {getCurrentInstance, onMounted, ref, computed} from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
import { useFileStore } from '@/stores/FileStore.js'
import {useRoute} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy

const vuetify = vueInstance.$vuetify
const store = vueInstance.$store
const userStore = useUserStore()
const fileStore = useFileStore()
const route = useRoute()

const LogoTypeEnum = ref({
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
})

const companyForm = ref(null)
const loadComplete = ref(false)
const company = ref({})
const rules = ref([
  v => v >= 0 || 'Value must be greater than or equal to 0',
  v => v <= 60 || 'Value must be less than or equal to 60',
])
const colorOptions = ref({
  canvasHeight: 75,
  width: 200,
  mode: 'hexa',
  hideModeSwitch: true
})
const validForm = ref(false)
const testUserPassword = ref('')
const acceptedFileTypes = ref(constants.STANDARD_IMAGES_ONLY)
const damnKeyThing = ref(0)
const logoToDelete = ref(null)

const is7oaksAdmin = computed(() => {
  return userStore.isSystemAdmin
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})
const companyId = computed(() => {
  return userStore.details.companyId
})


const deleteLogoDialogText = computed(() => {
  return `Are you sure you want to delete the ${ logoToDelete.value?.label } logo?`
})
const logoToDeleteId = computed(() => {
  return logoToDelete.value?.image?.id
})

    const forceInteger = () => {
      if (company.value.minuteIncrement % 1 !== 0) {
        company.value.minuteIncrement = Math.floor(company.value.minuteIncrement);
        damnKeyThing.value++
      }
    }
    const hexRule = (value) => {
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
    }
    const passwordRule = (value) => {
      if (value && value.length < 8) {
        return 'Password must be at least 8 characters'
      } else {
        return true
      }
    }
    const loadCompany = async () => {
      appStore.loading = true
      try {
        const {data, status} = await getRequest(`/companies/${companyId.value}`)
        company.value = data

        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'Error Retrieving Company')

        appStore.loading = false
      }
    }
    const saveTestUserPassword = async () => {
      if (companyForm.value.validate()) {
        appStore.loading = true
        try {
          let params = {
            password: testUserPassword.value
          }
          const {status} = await postRequestWithRequestParams(`/user/updateTestAccounts`, null, params)
          testUserPassword.value = ''
          appStore.showSnack('SUCCESS', 'Test User Password Saved')

          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          appStore.loading = false
        }
      }
    }
    const saveCompany = async () => {
      if (companyForm.value.validate()) {
        appStore.loading = true
        try {
          const {status} = await putRequest(`/companies`, company.value)
          appStore.showSnack('SUCCESS', 'Saved Company')
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          appStore.showSnack('ERROR', 'Error Saving Company')

          appStore.loading = false
        }
      }
    }
    const deleteAttachment = async (logoToDelete) => {
      try {
        appStore.loading = true
        await fileStore.deleteFile({
          id: logoToDelete.image?.id,
          callback: async () => {
            LogoTypeEnum.value[logoToDelete.key].image = {}
            appStore.showSnack('SUCCESS', 'Image Deleted')

            appStore.loading = false
          }
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'Error Deleting File')

        appStore.loading = false
      }
    }
    const uploadFile = async (logoType, files, attachmentTypeId, sourceId, sizeLimit) => {
      try {
        appStore.loading = true
        let file = files[0]
        await fileStore.uploadFile({
          file: file,
          sizeLimit,
          attachmentTypeId,
          sourceId,
          displayName: file.name.substr(0, file.name.lastIndexOf('.')),
          callback: async (img, error) => {
            if (error?.error) {
              appStore.showSnack('ERROR', error.errorMsg)

              appStore.loading = false
            } else {
              LogoTypeEnum.value[logoType.key].image = img
              LogoTypeEnum.value[logoType.key].add = false
              LogoTypeEnum.value[logoType.key].saving = false
              appStore.showSnack('SUCCESS', 'Image Uploaded')

              appStore.loading = false
            }
          }
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'Error Uploading File')

        appStore.loading = false
      }
    }
    const loadImage = async (logoType) => {
      try {
        appStore.loading = true
        await fileStore.getOne({
          attachmentTypeId: logoType.attachmentTypeId,
          sourceId: companyId.value,
          callback: async (img) => {
            logoType.image = img
            appStore.loading = false
          }
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'Error Loading Image')
        appStore.loading = false
      }
    }
  onMounted(() => {
    loadCompany()
    //load each image for
    Object.entries(LogoTypeEnum.value).forEach( ([key, value], idx) => {
      loadImage(value)
    })
  })
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
