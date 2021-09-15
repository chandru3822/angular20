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
          <v-text-field v-model="user.username"
                        placeholder="Enter a value"
                        required
                        type="search"
                        :rules="usernameRules"
                        label="Username">
          </v-text-field>
          <v-text-field v-model="user.phoneNumber"
                        placeholder="Enter a value"
                        required
                        label="Phone">
          </v-text-field>
        </v-col>
        <v-col cols="12" md="6">
          <v-select attach v-model="user.notificationTypeId"
                    :items="userNotificationTypes"
                    label="Notification"
                    item-text="userNotificationType"
                    item-value="id"
                    autocomplete="off">
          </v-select>
          <v-text-field v-model="user.newPassword"
                        v-if="!userIsMasquerading"
                        placeholder="Enter a new password"
                        required
                        autocomplete="new-password"
                        type="password"
                        :rules="[passwordRule]"
                        label="Change Password">
          </v-text-field>
          <v-text-field v-model="user.newPasswordConfirm"
                        v-if="!userIsMasquerading"
                        placeholder="Verify password"
                        required
                        type="password"
                        autocomplete="new-password"
                        :rules="[passwordRule]"
                        label="Confirm Password">
          </v-text-field>
          <v-autocomplete v-if="!userIsAlbatross"
                          v-model="user.homePageCompanyFeatureId"
                          :items="homePages"
                          label="Default Home Page"
                          clearable
                          item-text="featureName"
                          item-value="id"
                          autocomplete="off"
                          type="search"
                          attach
          ></v-autocomplete>
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
                  @change="uploadFile($event.target.files, attachmentTypeId, userId, 2097152)"
                  name="avatar"
              >
              <br/><span>* Due to render times associated with this file it cannot exceed 2MB</span>
            </form>
          </div>
          <img class="user-profile-image" v-else-if="profileImage.presignedUrl" :src="profileImage.presignedUrl">
          <div class="mt-4" v-else>
            No image uploaded
          </div>
        </div>
      </v-col>
    </v-row>
  </v-container>
</template>


<script>
import { Actions } from '@/store'
import { UserMutations } from '@/stores/UserStore'
import {AppMutations} from '@/stores/AppStore'
import moment from 'moment'
import {getRequest, putRequest, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'

export default {
  name: 'UserProfile',
  data () {
    return {
      loadComplete: false,
      constants,
      addImage: false,
      snackbar: {},
      // timeValue: '2014-06-01T12:00:00Z',
      // timeValue: moment.utc().format('YYYY-MM-DD HH:mm Z'),
      timeValue: moment.utc().format('YYYY-MM-DDTHH:mm:ssZ'),
      user: {},
      homePages: [],
      userIsAlbatross: false,
      userIsMasquerading: this.$store.state.user?.details?.masqueradingUserId != null,
      requiredRules: constants.BASIC_REQUIRED_RULE,
      emailRules: constants.EMAIL_RULES,
      usernameRules: constants.USERNAME_RULES,
      acceptedFileTypes: constants.STANDARD_IMAGES_ONLY,
      savingUserImage: false,
      attachmentTypeId: 9,
      userId: this.$store.state.user.details.id,
      profileImage: {},
      userNotificationTypes: [
        {
          id: 1,
          userNotificationType: 'Email'
        },
        {
          id: 2,
          userNotificationType: 'SMS'
        }
      ]
    }
  },
  computed: {},
  async created () {
    if(this.$store.state.user.details.highestCompanyId === 1) {
      //this was all super dumb because we can't load albatross users the same way as regular users
      this.userIsAlbatross = true
      this.getUser(this.userIsAlbatross)
    } else {
      this.getHomePages()
      this.getUser(false)
    }
    this.loadProfileImage()
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
    async getHomePages () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/feature/homePages`)
        this.homePages = data.filter(d => {
          return this.$store.getters.userHasFeature(d.featureCode)
        })
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Home Pages')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getUser (userIsAlbatross) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/user/${this.userId}?userIsAlbatross=${userIsAlbatross}`)
        this.user = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving User')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveUser () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await putRequest(`/user?userIsAlbatross=${this.userIsAlbatross}`, this.user)
        this.user.newPassword = null
        this.user.newPasswordConfirm = null
        this.snackbar = getSnackbar('SUCCESS', 'Saved Changes')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        let errorMsg = e?.message ? 'Error Saving User: ' + e.message : e?.data?.message ? 'Error Saving User: ' + e.data.message :'Error Saving User'
        this.snackbar = getSnackbar('ERROR', errorMsg)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
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
    async uploadFile (files, attachmentTypeId, sourceId, sizeLimit) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await this.$store.dispatch(Actions.FILE_UPLOAD, {
          file: files[0],
          attachmentTypeId,
          sizeLimit,
          sourceId,
          callback: async (img, error) => {
            if(error?.error) {
              this.snackbar = getSnackbar('ERROR', error.errorMsg)
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
            } else {
              this.profileImage = img
              this.$store.commit(UserMutations.SET_USER_IMAGE, img)
              this.addImage = false
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
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
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
