<template>
  <v-container class="pt-0">
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
                          @click="changePhoto = !changePhoto"
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
    <v-row>
      <v-col cols="12" style="padding-top: 0">
        <router-view/>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
  import { Actions } from '@/store'
  import {AppMutations} from '@/stores/AppStore'

  import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
  import NotesAndActivity from '@/views/flow/components/NotesAndActivity.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import {UserMutations} from "@/stores/UserStore";

  export default {
    name: 'User',
    components: {

      CustomValueInput,
      NotesAndActivity
    },
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
        userId: this.$route.params.id,
        companyId: this.$store.state.user.details.companyId,
        userImage: {},
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
    methods: {
      onImgError () {
        this.imageFailed = true
      },
      async getUser () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/user/${this.userId}`)
          this.user = data

          this.$store.commit(AppMutations.SET_LOADING, false)
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
}
</style>

