<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar" v-if="!constants.IS_MOBILE">
          <v-toolbar-title class="app-title">User Profile</v-toolbar-title>
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
    <v-form ref="userForm">
      <v-row>
        <v-col cols="12" md="6">
          <v-text-field v-model="user.firstName"
                        placeholder="Enter a value"
                        required
                        :rules="requiredRules"
                        label="First Name">
          </v-text-field>
          <v-text-field v-model="user.lastName"
                        placeholder="Enter a value"
                        required
                        :rules="requiredRules"
                        label="Last Name">
          </v-text-field>
          <v-text-field v-model="user.email"
                        placeholder="Enter a value"
                        required
                        :rules="emailRules"
                        label="E-mail">
          </v-text-field>
        </v-col>
        <v-col cols="12" md="6">
          <v-text-field v-model="user.newPassword"
                        placeholder="Enter a new password"
                        required
                        :rules="[passwordRule]"
                        label="Change Password">
          </v-text-field>
          <v-text-field v-model="user.newPasswordConfirm"
                        placeholder="Verify password"
                        required
                        :rules="[passwordRule]"
                        label="Confirm Password">
          </v-text-field>
        </v-col>
      </v-row>
      <v-row>
        <v-col cols="12" class="text-center">
          <v-btn @click="validate">
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
          <v-toolbar-title class="app-title">Profile Image</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-btn text v-if="!savingUserImage && !profileImage.presignedUrl"  @click="addImage = !addImage">
            <v-icon v-if="addImage">remove</v-icon>
            <v-icon v-else>add</v-icon>
          </v-btn>
          <v-btn v-else text class="mr-2" @click="deleteAttachment(profileImage.id)">
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
                  :disabled="savingUserImage"
                  @change="uploadFile($event.target.files, attachmentTypeId, userId)"
                  name="avatar"
              >
            </form>
          </div>
          <img class="user-profile-image" v-else-if="profileImage.presignedUrl" :src="profileImage.presignedUrl">
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
import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import Snackbar from '@/components/Snackbar.vue'

export default {
  name: 'UserProfile',
  components: {
    Snackbar
  },
  data () {
    return {
      loadComplete: false,
      constants,
      addImage: false,
      snackbar: {},
      // timeValue: '2014-06-01T12:00:00Z',
      // timeValue: moment.utc().format('YYYY-MM-DD HH:mm Z'),
      timeValue: moment.utc().format('YYYY-MM-DDTHH:mm:ssZ'),
      user: this.$store.state.user.details,
      requiredRules: constants.BASIC_REQUIRED_RULE,
      emailRules: constants.EMAIL_RULES,
      acceptedFileTypes: constants.STANDARD_IMAGES_ONLY,
      savingUserImage: false,
      attachmentTypeId: 9,
      userId: this.$store.state.user.details.id,
      profileImage: {}
    }
  },
  computed: {
  },
  methods: {
    validate () {
      if (this.$refs.userForm.validate()) {
        this.saveUser()
      }
    },
    passwordRule (value) {
      if (value && value.length < 8) {
        return 'Password must be at least 8 characters'
      } else if ((this.user.newPassword && !this.user.newPasswordConfirm) || (this.user.newPasswordConfirm && !this.user.newPassword)) {
        return 'Both Password Fields Are Required'
      } else if (value && this.user.newPasswordConfirm && this.user.newPassword !== this.user.newPasswordConfirm) {
        return 'Password Fields Must Match'
      } else {
        return true
      }
    },
    saveUser () {
      this.user.newPassword = null
      this.user.newPasswordConfirm = null
    },
    async deleteAttachment (id) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await this.$store.dispatch(Actions.FILE_DELETE, {
          id,
          callback: async (status) => {
            this.profileImage = {}
            this.$store.commit(UserMutations.SET_USER_IMAGE, {})
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
            this.profileImage = img
            this.$store.commit(UserMutations.SET_USER_IMAGE, img)
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
    async loadProfileImage () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await this.$store.dispatch(Actions.FILE_GET_ONE, {
          attachmentTypeId: this.attachmentTypeId,
          sourceId: this.userId,
          callback: async (img) => {
            this.profileImage = img
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
    this.loadProfileImage()
  }
}
</script>

<style scoped lang="scss">
.user-profile-image {
  margin-top: 15px;
  max-width: 200px;
  height: auto;
  border-radius: 50%;
}
</style>
