<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar" v-if="!IS_MOBILE">
          <v-toolbar-title class="app-title">Company Settings</v-toolbar-title>
        </v-toolbar>
<!--        <v-card flat style="background: aliceblue" class="text-center">-->
<!--          <div class="pt-5">-->
<!--            Changing the timezone in the account menu should change this value: <br/>-->
<!--            (this section is just temporary for testing)-->
<!--          </div>-->
<!--          <div class="pt-5 font-weight-bold">-->
<!--            {{ timeValue | formatDate('timestamp', $store.state.user.details.timezone.value) }}-->
<!--          </div>-->
<!--        </v-card>-->
      </v-col>
    </v-row>
    <v-form ref="companyForm">
      <v-row>
        <v-col cols="12">
          <v-text-field v-model="company.companyName"
                        placeholder="Enter a value"
                        required
                        label="Company Name">
          </v-text-field>
          <v-text-field v-model="company.defaultPassword"
                        placeholder="Enter a value"
                        required
                        label="Default Password">
          </v-text-field>
        </v-col>
      </v-row>
      <v-row>
        <v-col cols="12" class="text-center">
          <v-btn :disabled="!company.companyName || !company.defaultPassword" @click="saveCompany">
            <v-icon>mdi-content-save</v-icon>
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
          <v-btn text v-if="!savingCompanyLogo && !companyLogo.presignedUrl"  @click="addImage = !addImage">
            <v-icon v-if="addImage">remove</v-icon>
            <v-icon v-else>add</v-icon>
          </v-btn>
          <v-btn v-else text class="mr-2" @click="deleteAttachment(companyLogo.id)">
            <v-icon>delete</v-icon>
          </v-btn>
        </v-toolbar>
        <div class="text-center">
          <div class="mt-4" v-if="addImage">
            <form enctype="multipart/form-data" novalidate>
              <input
                  type="file"
                  :accept="acceptedFileTypes"
                  class="file-input clickable"
                  :disabled="savingCompanyLogo"
                  @change="uploadFile($event.target.files, attachmentTypeId, companyId)"
                  name="avatar"
              >
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
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>


<script>
import { Actions } from '@/store'
import { UserMutations } from '@/stores/UserStore'
import {AppMutations} from '@/stores/AppStore'
import moment from 'moment'
import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar, EMAIL_RULES, BASIC_REQUIRED_RULE, STANDARD_IMAGES_ONLY, IS_MOBILE} from '@/helpers/helpers'
import Snackbar from '@/components/Snackbar.vue'

export default {
  name: 'UserProfile',
  components: {
    Snackbar
  },
  data () {
    return {
      loadComplete: false,
      IS_MOBILE,
      addImage: false,
      snackbar: {},
      company: {},
      companyId: this.$store.state.user.details.companyId,
      acceptedFileTypes: STANDARD_IMAGES_ONLY,
      savingCompanyLogo: false,
      //todo: 29 = company logo - do this on backend?
      attachmentTypeId: 29,
      companyLogo: {}
    }
  },
  computed: {
  },
  methods: {
    async loadCompany () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/companies/${this.companyId}`)
        this.company = data

        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Company')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveCompany () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await putRequest(`/companies`, this.company)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Company')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteAttachment (id) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await this.$store.dispatch(Actions.FILE_DELETE, {
          id,
          callback: async (status) => {
            console.log('attachment deleted', status)
            this.companyLogo = {}
            // this.$store.commit(UserMutations.SET_USER_IMAGE, {})
            this.snackbar = getSnackbar('SUCCESS', 'Image Deleted')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        })
      } catch(e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting File')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async uploadFile (files, attachmentTypeId, sourceId) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await this.$store.dispatch(Actions.FILE_UPLOAD, {
          file: files[0],
          attachmentTypeId,
          sourceId,
          callback: async (img) => {
            console.log('saved image', img)
            this.companyLogo = img

            // this.$store.commit(UserMutations.SET_USER_IMAGE, img)
            this.addImage = false
            this.snackbar = getSnackbar('SUCCESS', 'Image Uploaded')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        })
      } catch(e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
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
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  },
  async created () {
    this.loadCompany()
    this.loadCompanyLogo()
  }
}
</script>

<style scoped lang="scss">
.company-logo {
  margin-top: 15px;
  max-width: 200px;
  height: auto;
}

.company-logo-background {
  background-color: #bbbbbb;
}
</style>
