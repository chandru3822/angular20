<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <div class="px-5">
          <a-text-field v-model="projectStatus.projectStatusType"
                        label="Status Type"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
          ></a-text-field>
          <a-autocomplete
              :items="rootStatusTypes"
              v-model="projectStatus.projectStatusTypeId"
              item-value="id"
              :readonly="!userCanEdit"
              :disabled="!userCanEdit"
              label="Select a Category"
              item-title="projectStatusType"
              attach></a-autocomplete>
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
                <a-btn
                    :activation-handler="on"
                    text="Set as Initial"
                ></a-btn>
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
                  <a-btn
                      @click="projectStatus.setInitialConfirm = false"
                      text="No"
                  ></a-btn>

                  <a-btn
                      color="primary"
                      variant="text"
                      @click="setAsInitial(projectStatus)"
                      text="Yes"
                  ></a-btn>

                </v-card-actions>
              </v-card>
            </v-dialog>
          </div>

          <v-card class="fifty-cent">
            <a-text-field v-model="projectStatus.iconTag"
                          label="Material Icon Tag"
                          hide-details
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
            ></a-text-field>
            <div class="mt-3">
              Preview:
              <v-icon v-if="projectStatus.iconTag">{{ projectStatus.iconTag }}</v-icon>
            </div>
          </v-card>
        </div>
        
        <a-btn
            v-if="userCanEdit"
            :disabled="!projectStatus.projectStatusType || !projectStatus.projectStatusTypeId"
            color="primary"
            class="d-inline-block mt-5"
            @click="saveType(projectStatus)"
            prepend-icon="save"
            text="Save"
        ></a-btn>

      </v-col>

    </v-row>
  </v-container>
</template>


<script setup>


import {getCompanyProjectStatusType, getProjectStatusTypes} from '@/services/projectStatusTypeService'
import {handleHidingGlobalLoader, putRequest, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import {getCurrentInstance, computed, ref, onMounted} from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute} from "vue-router/composables";
import { useFileStore } from '@/stores/FileStore.js'
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
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
          snackbar('ERROR', error.errorMsg)
          appStore.loading = false
        } else {
          item.icon = img

          snackbar('SUCCESS', 'Image Uploaded')
          appStore.loading = false
        }
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Uploading File')
    appStore.loading = false
  }
}
const deleteAttachment = async (item) => {
  try {
    appStore.loading = true
    await fileStore.deleteFile({
      id: item.icon.id,
      callback: async () => {
        item.icon = {}
        snackbar('SUCCESS', 'Image Deleted')
        appStore.loading = false
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting File')
    appStore.loading = false
  }
}
const getStatusInfo = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getCompanyProjectStatusType(statusId.value)
    projectStatus.value = data
    initItemColor(projectStatus.value)
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const getTheseProjectStatusTypes = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getProjectStatusTypes()
    rootStatusTypes.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const saveType = async (type) => {
  appStore.loading = true
  try {
    const {data, status} = await putRequest(`/projectStatus/company`, type)
    snackbar('SUCCESS', 'Project Status Saved')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Project Status')
    appStore.loading = false
  }
}
const setAsInitial = async (item) => {
  appStore.loading = true
  try {
    const {status} = await putRequest(`/projectStatus/company/initial/${item.id}`,)
    item.isDefault = true
    snackbar('SUCCESS', 'Status Updated')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Updating Status')
    appStore.loading = false
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
