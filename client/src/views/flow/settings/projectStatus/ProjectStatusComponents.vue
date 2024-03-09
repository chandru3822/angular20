<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <div class="px-5">
          <v-text-field v-model="projectStatus.projectStatusType"
                        label="Status Type"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
          ></v-text-field>
          <v-autocomplete
              :items="rootStatusTypes"
              v-model="projectStatus.projectStatusTypeId"
              item-value="id"
              :readonly="!userCanEdit"
              :disabled="!userCanEdit"
              label="Select a Category"
              item-text="projectStatusType"
              attach></v-autocomplete>
          <v-textarea
              label="Description"
              outlined
              hide-details
              auto-grow
              v-model="projectStatus.description"
          ></v-textarea>

          <v-checkbox label="Use as Milestone"
                      class="default-text-color"
                      v-model="projectStatus.isMilestone"
          />

          <div v-if="!projectStatus.isDefault" class="mb-3">
            <v-dialog
                v-model="projectStatus.setInitialConfirm"
                width="500">
              <template #activator="{ on }">
                <AlbatrossButton
                    :activation-handler="on"
                    text="Set as Initial"
                ></AlbatrossButton>
              </template>
              <v-card>
                <v-card-title
                    class="text-h5 grey lighten-2"
                    primary-title>
                  Confirm
                </v-card-title>

                <v-card-text class="pt-4">
                  Setting this Project Status Type as default will unset the other initial status. Are you sure you want
                  to continue?
                </v-card-text>

                <v-divider></v-divider>

                <v-card-actions>
                  <v-spacer></v-spacer>
                  <AlbatrossButton
                      @click="projectStatus.setInitialConfirm = false"
                      text="No"
                  ></AlbatrossButton>

                  <AlbatrossButton
                      color="primary"
                      variant="text"
                      @click="setAsInitial(projectStatus)"
                      text="Yes"
                  ></AlbatrossButton>

                </v-card-actions>
              </v-card>
            </v-dialog>
          </div>

          <v-card class="fifty-cent">
            <v-text-field v-model="projectStatus.iconTag"
                          label="Material Icon Tag"
                          hide-details
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
            ></v-text-field>
            <div class="mt-3">
              Preview:
              <v-icon v-if="projectStatus.iconTag">{{ projectStatus.iconTag }}</v-icon>
            </div>
          </v-card>
        </div>
        
        <AlbatrossButton
            v-if="userCanEdit"
            :disabled="!projectStatus.projectStatusType || !projectStatus.projectStatusTypeId"
            color="primary"
            class="d-inline-block mt-5"
            @click="saveType(projectStatus)"
            prepend-icon="save"
            text="Save"
        ></AlbatrossButton>

      </v-col>

    </v-row>
  </v-container>
</template>


<script setup>
import {AppMutations} from '@/stores/AppStore'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton"
import {getCompanyProjectStatusType, getProjectStatusTypes} from '@/services/projectStatusTypeService'
import {handleHidingGlobalLoader, putRequest, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import {getCurrentInstance, computed, ref, onMounted} from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute} from "vue-router/composables";
import { useFileStore } from '@/stores/FileStore.js'
const route = useRoute()

const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const fileStore = useFileStore()

// const colorOptions = ref({
//   canvasHeight: 75,
//   width: 200,
//   mode: 'hexa',
//   hideModeSwitch: true
// })
const projectStatus = ref({})
const rootStatusTypes = ref([])
const acceptedFileTypes = ref(constants.STANDARD_IMAGES_ONLY)
const savingTypeLogo = ref(false)
const attachmentTypeId = ref(463)

const statusId = computed(() => {
  return route.params.id
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})

onMounted(() => {
  getStatusInfo()
  getTheseProjectStatusTypes()
})


const initItemColor = (item) => {
  item.color = item.color ?? '#FFFFFF'
}
const uploadFile = async (item, files, attachmentTypeId, sourceId, sizeLimit) => {
  try {
    store.commit(AppMutations.SET_LOADING, true)
    let file = files[0]
    await fileStore.uploadFile({
      file: file,
      sizeLimit,
      attachmentTypeId,
      sourceId,
      displayName: file.name.substr(0, file.name.lastIndexOf('.')),
      callback: async (img, error) => {
        if (error?.error) {
          snackbar('ERROR', error.errorMsg)
          store.commit(AppMutations.SET_LOADING, false)
        } else {
          item.icon = img

          snackbar('SUCCESS', 'Image Uploaded')
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Uploading File')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const deleteAttachment = async (item) => {
  try {
    store.commit(AppMutations.SET_LOADING, true)
    await fileStore.deleteFile({
      id: item.icon.id,
      callback: async () => {
        item.icon = {}
        snackbar('SUCCESS', 'Image Deleted')
        store.commit(AppMutations.SET_LOADING, false)
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting File')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getStatusInfo = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getCompanyProjectStatusType(statusId.value)
    projectStatus.value = data
    initItemColor(projectStatus.value)
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getTheseProjectStatusTypes = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getProjectStatusTypes()
    rootStatusTypes.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveType = async (type) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await putRequest(`/projectStatus/company`, type)
    snackbar('SUCCESS', 'Project Status Saved')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Project Status')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const setAsInitial = async (item) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await putRequest(`/projectStatus/company/initial/${item.id}`,)
    item.isDefault = true
    snackbar('SUCCESS', 'Status Updated')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Updating Status')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
</script>

<style scoped lang="scss">
.status-icon {
  margin-top: 15px;
  max-width: 50px;
  height: auto;
}

.status-icon-grid {
  margin-top: 5px;
  max-width: 40px;
  height: auto;
}

.fifty-cent {
  width: 50%;
  padding: 15px 20px;
}
</style>
