<template>
  <v-container>
    <v-row xs-12>
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">User Profile</v-toolbar-title>
      </v-toolbar>
      <v-container style="background: aliceblue">
        <div class="pt-5">
          Changing the timezone in the account menu should change this value: <br/>
          (this is section just temporary for testing)
        </div>
        <div class="pt-5 font-weight-bold">
          {{ timeValue | formatDate('timestamp', $store.state.user.details.timezone) }}
        </div>

      </v-container>
    </v-row>
    <v-form ref="userForm">
      <v-row wrap>
        <v-col xs-12 md-6>
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
        <v-col xs-12 md-6>
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
      <v-row wrap>
        <v-col xs-12>
          <v-btn @click="validate">
            <v-icon>save</v-icon>
            Save Changes
          </v-btn>
        </v-col>
      </v-row>
    </v-form>
    <v-divider class="mt-3 mb-3"></v-divider>
    <v-row>
      <v-col xs-12>
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Profile Image</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-btn text v-if="!profileImage.isSaving && !profileImage.assetUrl"  @click="addImage = !addImage">
            <v-icon v-if="addImage">remove</v-icon>
            <v-icon v-else>add</v-icon>
          </v-btn>
          <v-btn v-else text class="mr-2" @click="deleteProfileImage(profileImage)">
            <v-icon>delete</v-icon>
          </v-btn>
        </v-toolbar>
        <div class="mt-4" v-if="addImage">
          <form enctype="multipart/form-data" novalidate>
            <input
                type="file"
                :accept="acceptedFileTypes"
                class="file-input clickable"
                :disabled="profileImage.isSaving"
                @change="uploadFile($event.target.files, profileImage)"
                name="avatar"
            >
          </form>
          <img name="companyLogo" class="company-logo" v-if="loadComplete && profileImage.assetUrl" :src="profileImage.assetUrl">
        </div>
        <div class="mt-4" v-else>
          No image uploaded
        </div>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>


<script>
import { Actions } from '@/store'
import {AppMutations} from '@/stores/AppStore'
import moment from 'moment'
import {getRequest, deleteRequest, putRequest, postRequest, EMAIL_RULES, STANDARD_IMAGES_ONLY} from '@/helpers/helpers'
import Snackbar from '@/components/Snackbar.vue'
import { SNACKBAR_SUCCESS, SNACKBAR_ERROR } from '@/helpers/helpers'

export default {
  name: 'UserProfile',
  components: {
    Snackbar
  },
  data () {
    return {
      loadComplete: false,
      addImage: false,
      snackbar: {},
      // timeValue: '2014-06-01T12:00:00Z',
      // timeValue: moment.utc().format('YYYY-MM-DD HH:mm Z'),
      timeValue: moment.utc().format('YYYY-MM-DDTHH:mm:ssZ'),
      user: this.$store.state.user.details,
      requiredRules: [
        v => !!v || 'Field is required'
      ],
      emailRules: EMAIL_RULES,
      acceptedFileTypes: STANDARD_IMAGES_ONLY,
      profileImage: {
        // 9 = USER_IMAGE
        id: null,
        isSaving: false,
        assetUrl: null,
        attachmentSourceTypeId: 9,
        sourceId: this.$store.state.user.details.id
    },
    }
  },
  computed: {
  },
  methods: {
    validate () {
      if (this.$refs.userForm.validate()) {
        console.log('randaLogger form is valid')
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
      console.log('SAVE CHANGES HERE', this.user)
      this.user.newPassword = null
      this.user.newPasswordConfirm = null
    },
    deleteProfileImage () {
      console.log('deleteHere')
    },
    async uploadFile (files, item) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await this.$store.dispatch(Actions.FILE_UPLOAD, {
          file: files[0],
          attachmentSourceTypeId: item.attachmentSourceTypeId,
          sourceId: item.sourceId,
          callback: async (img) => {
            console.log('saved image', img)
            this.profileImage = img
            this.snackbar = SNACKBAR_SUCCESS
            this.snackbar.text = 'Successfully Uploaded Image'
            this.snackbar.enabled = true
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        })
      } catch(e) {
        console.log('EEEEEEEEEEEEEEEEEEee', e)
        this.snackbar = SNACKBAR_ERROR
        this.snackbar.text = 'Error Uploading Document'
        this.snackbar.enabled = true
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async loadProfileImage () {
      // TODO: need to make a universal endpoint for getting an s3 asset
      // also, the current save endpoing is specific to documents
    }
  },
  async created () {
  }
}
</script>

<style scoped lang="scss">

</style>
