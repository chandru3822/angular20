<template>
  <v-container class="pt-0">
    <v-dialog width="500" v-model="unsavedFieldsModal">
      <v-card>
        <v-card-title
          class="text-h5 grey lighten-2"
          primary-title
        >
          Confirm
        </v-card-title>

        <v-card-text class="pt-4">
          You have unsaved {{getDirtyText()}}. <br/>
          Are you sure you want to continue without saving?
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            @click="unsavedFieldsModal = false">
            No
          </v-btn>
          <v-btn
            color="primaryCustom"
            text
            @click="[navigationOverride = true, goToPath(toPath)]">
            Yes
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-row>
      <v-col cols="12" style="padding-bottom: 0; padding-top: 0;" class="text-left">
        <v-btn small text :to="`/users`">
          <v-icon small>mdi-chevron-left</v-icon>
          Back to users
        </v-btn>
      </v-col>
    </v-row>
    <v-row class="user-header">
      <v-col cols="12" class="py-0">
        <v-toolbar flat color="transparent" class="app-toolbar">
            <v-tooltip bottom max-width="300px" content-class="user-img-tooltip">
              <template v-slot:activator="{ on:tooltip }">
                <v-avatar :tile="false"
                          v-on="{ ...tooltip }"
                          :size="50"
                          color="grey lighten-4"
                          @click="doChangePhoto()"
                          class="clickable account-img mr-3"
                >
                  <v-img name="userImg" alt="user-image" v-if="loadComplete && userImage && userImage.presignedUrl && !imageFailed" v-on:error="onImgError()" :src="userImage.presignedUrl"></v-img>
                  <img name="userImg" v-else src="../../../assets/flow/user_img_placeholder.png">
                </v-avatar>
              </template>
              <v-card class="user-image-hover-container">
                <v-img name="userImg" v-if="loadComplete && userImage && userImage.presignedUrl" :src="userImage.presignedUrl"></v-img>
                <img name="userImg" v-else src="../../../assets/flow/user_img_placeholder.png">
              </v-card>
            </v-tooltip>
            <form enctype="multipart/form-data" novalidate v-if="changePhoto">
              <input
                type="file"
                :accept="acceptedFileTypes"
                class="file-input clickable"
                @change="uploadUserImage($event.target.files, attachmentTypeId, userId, 2097152)"
                name="avatar"
              >
              <br/><span>* Cannot exceed 2MB</span>
            </form>
          {{user.firstName}} {{user.lastName}}
          <span v-if="null != user.primaryPosition" class="ml-1"> - {{ user.primaryPosition}}</span>

          <v-btn class="ml-3 elevation-2" dark small fab
                 v-if="userCanMasquerade && !userIsMasquerading && userId !== loggedInUserId"
                 color="primaryCustom"
                 @click="masquerade()">
            <v-icon>mdi-account-switch</v-icon>
          </v-btn>
          <v-spacer></v-spacer>
          <v-toolbar-items :slot="constants.IS_MOBILE ? 'extension' : 'default'">
            <v-tabs background-color="transparent">
              <v-tab :to="`/user/${userId}/details`">
                Details
              </v-tab>
              <v-tab :to="`/user/${userId}/positions`">
                Positions
              </v-tab>
              <v-tab :to="`/user/${userId}/access`" v-if="$store.getters.userHasFeatureAccessLevel('ACCESS_CONTROL', 'VIEW')">
                Access
              </v-tab>
            </v-tabs>
          </v-toolbar-items>
        </v-toolbar>
      </v-col>
    </v-row>
<!--    <v-row>-->
<!--      <v-col cols="12" style="padding-top: 0">-->
        <router-view ref="userRouterViewContainer"/>
<!--      </v-col>-->
<!---->
<!--    </v-row>-->
  </v-container>
</template>

<script>
  import { Actions } from '@/store'
  import {AppMutations} from '@/stores/AppStore'
  import axios from 'axios'
  import {handleHidingGlobalLoader, getRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import {UserMutations} from "@/stores/UserStore";

  export default {
    name: 'User',
    components: {},
    data () {
      return {
        breadcrumbs: [
          {
            text: 'Back to Users',
            disabled: false,
            exact: true,
            to: `/users`
          },
        ],
        constants,
        changePhoto: false,
        acceptedFileTypes: constants.STANDARD_IMAGES_ONLY,
        snackbar: {},
        user: {},
        userId: parseInt(this.$route.params.id),
        companyId: this.$store.state.user.details.companyId,
        loggedInUserId: this.$store.state.user.details.id,
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('USERS', 'EDIT'),
        userCanMasquerade: this.$store.getters.userHasFeatureAccessLevel('MASQUERADE', 'ADMIN'),
        userIsMasquerading: this.$store.state.user?.details?.masqueradingUserId != null,
        userImage: {},
        unsavedFieldsModal: false,
        hasDirtyFields: false,
        hasDirtyNotes: false,
        toPath: null,
        navigationOverride: false,
        loadComplete: false,
        userStatusTypes: [],
        attachmentTypeId: 9,
        imageFailed: false
      }
    },
    created () {
      this.getUser()
      this.getUserImage()
    },
    beforeRouteLeave (to, from, next) {
      // called when the route that renders this component is about to
      // be navigated away from.
      // has access to `this` component instance.
      if(typeof this.$refs.userRouterViewContainer?.hasDirtyFields === 'function') {
        this.hasDirtyFields = this.$refs.userRouterViewContainer.hasDirtyFields()
      }

      if(typeof this.$refs.userRouterViewContainer?.hasDirtyNotes === 'function') {
        this.hasDirtyNotes = this.$refs.userRouterViewContainer?.hasDirtyNotes()
      }

      if (this.navigationOverride || (!this.hasDirtyFields && !this.hasDirtyNotes)) {
        //navigationOverride gets set to true if they click "Yes" to continue. if you don't override then it just hits the else again before navigating
        next()
      } else {
        this.toPath = to.path
        this.unsavedFieldsModal = true
      }
    },
    methods: {
      doChangePhoto() {
        if(this.userCanEdit) {
          this.changePhoto = !this.changePhoto
        }
      },
      getDirtyText() {
        return this.hasDirtyNotes && this.hasDirtyFields ?
          'fields and notes' : this.hasDirtyNotes ? 'notes' : 'fields'
      },
      goToPath(path) {
        this.$router.push(path)
      },
      onImgError () {
        this.imageFailed = true
      },
      async masquerade () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await axios.get(`${constants.VUE_APP_BASE_API}/auth/masquerade/${this.userId}`)
          if(data && data.token) {
            this.$store.commit(UserMutations.SET_JWT, data.token)
            //update the user
            const {data: currentUser} = await getRequest(`/user/current`)
            await this.$store.commit(UserMutations.SET_DETAILS, currentUser);
            //then reload the screen
            window.location.reload()
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Aliasing as User')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getUser () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/user/${this.userId}`)
          this.user = data

          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving User')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async uploadUserImage (files, attachmentTypeId, sourceId, sizeLimit) {
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
                this.userImage = img
                this.changePhoto = false
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
      async getUserImage () {
        try {
          await this.$store.dispatch(Actions.FILE_GET_ONE, {
            attachmentTypeId: this.attachmentTypeId,
            sourceId: this.userId,
            callback: async (img) => {
              this.userImage = img
              this.loadComplete = true
            }
          })
        } catch(e) {
          console.error('*** ERROR ***', e)
          this.loadComplete = true
        }
      },
    }
  }
</script>

<style lang="scss" scoped>
.user-header {
  border-bottom: solid 1px #EAEAF4
}
.user-image-hover-container {
  max-width: 100%;
  height: auto;
}
.user-img-tooltip {
  background-color: transparent;
  opacity: 1 !important;
  z-index: 200 !important;
}
</style>

