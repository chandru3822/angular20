<script setup>
/*
*@name TournamentAppearance
*@author jess
*@date 1/9/24
*
*@description
*
*/
import {getCurrentInstance, ref} from "vue";
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
import {AppMutations} from "@/stores/AppStore";
import {getSnackbar} from "@/helpers/helpers";
import {Actions} from "@/store";
import constants from "@/helpers/constants";

const ImageTypeEnum = {
  TOURNAMENT_HEADER_LOGO: {
    key: "TOURNAMENT_HEADER_LOGO", //this needs to match the key, cuz dumb
    header: 'Tournament Header Logo',
    description: 'Logo at the top of the Closer and Setter Incentive Dashboards',
    label: 'dashboard header',
    attachmentTypeId: 29,
    add: false,
    saving: false,
    image: {}
  },
  TOURNAMENT_BACKGROUND: {
    key: "TOURNAMENT_BACKGROUND", //this needs to match the key, cuz dumb
    header: 'Tournament Background Image',
    description: 'Background of the Closer and Setter Incentive Dashboards',
    label: 'dashboard background',
    attachmentTypeId: 333,
    add: false,
    saving: false,
    image: {}
  }
}

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const companyId = store.state.user.details.companyId
const acceptedFileTypes = constants.STANDARD_IMAGES_ONLY


let imageToDelete = ref(null)

const uploadFile = async(imageType, files, attachmentTypeId, sourceId, sizeLimit) => {
  let snackbar
  try {
    store.commit(AppMutations.SET_LOADING, true)
    let file = files[0]
    await store.dispatch(Actions.FILE_UPLOAD, {
      file: file,
      sizeLimit,
      attachmentTypeId,
      sourceId,
      displayName: file.name.substr(0, file.name.lastIndexOf('.')),
      callback: async (img, error) => {
        if (error?.error) {
          snackbar = getSnackbar('ERROR', error.errorMsg)
        } else {
          LogoTypeEnum[logoType.key].image = img
          LogoTypeEnum[logoType.key].add = false
          LogoTypeEnum[logoType.key].saving = false
          snackbar = getSnackbar('SUCCESS', 'Image Uploaded')
        }
      }
      })
  } catch (e) {
    console.error('*** ERROR ***', e)
    this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
  } finally {
    store.commit(AppMutations.SHOW_SNACK, snackbar)
    store.commit(AppMutations.SET_LOADING, false)
  }
}

const deleteAttachment = async() => {
  let snackbar
  try {
    store.commit(AppMutations.SET_LOADING, true)
    await store.dispatch(Actions.FILE_DELETE, {
      id: imageToDelete.value?.image?.id,
      callback: async () => {
        ImageTypeEnum[imageToDelete.value.key].image = {}
        snackbar = getSnackbar('SUCCESS', 'Image Deleted')
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar = getSnackbar('ERROR', 'Error Deleting File')
  } finally {
    store.commit(AppMutations.SHOW_SNACK, snackbar)
    store.commit(AppMutations.SET_LOADING, false)
    imageToDelete.value = null
  }
}

</script>

<template>
<v-container class="custom-field-group-container">
  <v-row>
    <v-col cols="12">
      <v-toolbar flat class="app-toolbar">
        <v-toolbar-title class="app-title">Tournament Appearance</v-toolbar-title>
      </v-toolbar>
    </v-col>
  </v-row>
  <v-row v-for="([key, imageType], idx) in Object.entries(ImageTypeEnum)">
    <v-col cols="12">
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="title-large">{{imageType.header}}</v-toolbar-title>
        <v-spacer/>
        <div>
          <v-btn icon :large="$vuetify.breakpoint.smAndDown" color="primary"
                 v-if="!imageType.saving && !imageType.image?.presignedUrl" @click="imageType.add = !imageType.add">
            <v-icon v-if="imageType.add">remove</v-icon>
            <v-icon v-else>add</v-icon>
          </v-btn>
          <v-btn icon :large="$vuetify.breakpoint.smAndDown" color="primary" v-else
                 @click="imageToDelete=imageType">
            <v-icon>delete</v-icon>
          </v-btn>
        </div>
      </v-toolbar>
      <div class="text-center">
        <div class="mt-4" v-if="imageType.add">
          <form enctype="multipart/form-data" novalidate>
            <input
                type="file"
                :accept="acceptedFileTypes"
                class="file-input clickable body-medium mx-6"
                :disabled="imageType.saving"
                @change="uploadFile(imageType, $event.target.files, imageType.attachmentTypeId, companyId, 1048576)"
                name="avatar"
            >
            <br/><span>* Due to render times associated with this file it cannot exceed 1MB</span>
          </form>
        </div>
        <div class="company-logo-background" v-else-if="imageType.image?.presignedUrl">
          <img class="company-logo" :src="imageType.image.presignedUrl">
        </div>
        <div class="mt-4" v-else>
          No image uploaded
        </div>
      </div>
    </v-col>
  </v-row>
  <ConfirmationDialog :open-dialog="!!imageToDelete" @confirm="deleteAttachment" @close-dialog="imageToDelete = null"></ConfirmationDialog>
</v-container>
</template>

<style scoped lang="scss">
</style>
