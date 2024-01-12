<script setup>
/*
*@name CloserDashboardSettings
*@author jess
*@date 1/11/24
*
*@description
*
*/
import {computed, getCurrentInstance, ref} from "vue";
import constants from "@/helpers/constants";
import {AppMutations} from "@/stores/AppStore";
import {Actions} from "@/store";
import {getSnackbar} from "@/helpers/helpers";
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";

const ImageTypeEnum = ref({
  CLOSER_DASH_TOURNAMENT_HEADER_LOGO: {
    key: "CLOSER_DASH_TOURNAMENT_HEADER_LOGO", //this needs to match the key, cuz dumb
    header: 'Closer/Setter Dashboard Header Image',
    description: 'Logo at the top of the Closer and Setter Incentive Dashboards',
    label: 'dashboard header',
    attachmentTypeId: 991,
    add: false,
    saving: false,
    image: {}
  },
  TOURNAMENT_BACKGROUND: {
    key: "CLOSER_DASH_TOURNAMENT_BACKGROUND", //this needs to match the key, cuz dumb
    header: 'Closer/Setter Dashboard Background Image',
    description: 'Background of the Closer and Setter Incentive Dashboards',
    label: 'dashboard background',
    attachmentTypeId: 992,
    add: false,
    saving: false,
    image: {}
  }
})

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const companyId = store.state.user.details.companyId
const acceptedFileTypes = constants.STANDARD_IMAGES_ONLY

const userCanEdit= store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')

let imageToDelete = ref(null)

const deleteImageDialogText = computed(() => {
  return `Are you sure you want to delete the ${ imageToDelete.value?.label } logo?`
})

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
          ImageTypeEnum[imageType.key].image = img
          ImageTypeEnum[imageType.key].add = false
          ImageTypeEnum[imageType.key].saving = false
          snackbar = getSnackbar('SUCCESS', 'Image Uploaded')
          store.commit(AppMutations.SHOW_SNACK, snackbar)
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar = getSnackbar('ERROR', 'Error Uploading File')
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
        store.commit(AppMutations.SHOW_SNACK, snackbar)
        store.commit(AppMutations.SET_LOADING, false)
        imageToDelete.value = null
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar = getSnackbar('ERROR', 'Error Deleting File')
    store.commit(AppMutations.SHOW_SNACK, snackbar)
    store.commit(AppMutations.SET_LOADING, false)
    imageToDelete.value = null
  }
}


</script>

<template>
  <v-container>
  <v-row v-for="([key, imageType], idx) in Object.entries(ImageTypeEnum)">
    <v-col cols="12">
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="title-large">{{ imageType.header }}</v-toolbar-title>
        <v-spacer></v-spacer>
        <div v-if="userCanEdit">
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
          <img class="company-logo" :src="imageType.image.presignedUrl" alt="image preview">
        </div>
        <div class="mt-4" v-else>
          No image uploaded
        </div>
      </div>
    </v-col>
  </v-row>

  <ConfirmationDialog :open-dialog="!!imageToDelete" @confirm="deleteAttachment"
                      @close-dialog="imageToDelete=null">
    {{ deleteImageDialogText }}
  </ConfirmationDialog>
  </v-container>
</template>

<style scoped lang="scss">

</style>
