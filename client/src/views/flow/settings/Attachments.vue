<template>
  <v-container id="attachment-type-container" class="custom-field-group-container">
    <v-dialog width="700"
              v-model="deleteError"
    >
      <v-card>
        <v-card-title class="text-h5 grey lighten-2 error--text">
          Error Deleting Attachment Type
        </v-card-title>

        <v-card-text class="pt-5">
          <div v-if="cannotDeleteReasons && cannotDeleteReasons.length > 0" class="mb-5">
            <div class="mb-3">* This attachment type is currently in use. You must remove it from the following
              locations before deleting.
            </div>
            <div v-for="a in cannotDeleteReasons" :key="a.id" class="ml-5">
              <strong>{{ a.processStepName }}</strong>
            </div>
          </div>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>

          <AlbatrossButton
            color="primary"
            dark
            @click="deleteError = false"
            text="OK"
          ></AlbatrossButton>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">Attachment Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton v-if="store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')"
              variant="text"
              @click="[addNew = !addNew, newType = {}]"
              color="primary"
              :hide-text-on-mobile="constants.IS_MOBILE"
              :text="!addNew ? 'Add New' : 'Cancel'"
              :prepend-icon="addNew ? 'close' : 'add'"
            >
            </AlbatrossButton>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card color="transparent" flat v-if="addNew" class="mb-3 pa-2">
            <v-text-field v-if="addNew"
                          v-model="newType.attachmentType"
                          placeholder="Enter a type"
                          label="Attachment Type">
            </v-text-field>
            <AlbatrossButton v-if="addNew"
                             color="primary"
                             :disabled="!newType.attachmentType"
                             @click="addNewType"
                             text="Save"/>
          </v-card>
          <v-divider v-if="addNew"></v-divider>
          <v-card class="square-card">
            <v-card-title class="pt-0">
              <v-text-field
                v-model="search"
                prepend-inner-icon="search"
                label="Search"
                single-line
                hide-details
              ></v-text-field>
            </v-card-title>
            <v-data-table
              :headers="headers"
              :items="filterTypes"
              :fixed-header="true"
              :items-per-page="100"
              :search="search"
              :footer-props="footerProps"
              hide-default-header
              class="elevation-1 square-card"
            >
              <template #item="{ item, index }">
                <tr :class="{'shaded-row': index % 2}">
                  <td class="text-left clickable" @click="goToType(item.id)">{{ item.attachmentType }}</td>
                  <td class="text-right" :class="{'d-flex flex-column align-end': vuetify.breakpoint.xsOnly}">
                    <AlbatrossButton
                      size="small"
                      variant="text"
                      color="primary"
                      @click="goToType(item.id)"
                      prepend-icon="edit"
                    />
                  </td>
                </tr>
              </template>
            </v-data-table>
          </v-card>
          <ConfirmationDialog :open-dialog="showDeleteDialog"
                              @confirm=deleteType
                              @close-dialog="closeDeleteDialog"
          >Are you sure you want to delete this attachment type:
            <strong>{{ itemToDeleteAttachmentType }}</strong></ConfirmationDialog>
        </v-container>
      </v-col>
    </v-row>

  </v-container>
</template>


<script setup>
  import { getCurrentInstance, ref, computed, onMounted} from "vue";
  import {AppMutations} from '@/stores/AppStore'
  import orderBy from 'lodash.orderby'
  import AlbatrossButton from "../../../components/customVuetify/AlbatrossButton.vue";
  import {
    handleHidingGlobalLoader,
    getRequest,
    deleteRequest,
    postRequest,
  } from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import ConfirmationDialog from "@/components/ConfirmationDialog";

  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const store = vueInstance.$store
  const router = vueInstance.$router
  const vuetify = vueInstance.$vuetify

  const attachmentTypes =  ref([])
  const search =  ref('')
  const addNew =  ref(false)
  const newType =  ref({})
  const selectedAttachmentTypeId =  ref(null)
  const userId =  ref(store.state.user.details.id)
  const companyId =  ref(store.state.user.details.companyId)
  const cannotDeleteReasons =  ref({})
  const deleteError =  ref(false)
  const headers =  ref([
    {text: 'Attachment Type', value: 'attachmentType', show: true},
    {text: '', value: 'icons', show: true},
  ])
  const footerProps =  ref({
    'items-per-page-options': [25, 50, 100, 1000],
    'items-per-page-text': 'Rows per page:'
  })
  const showDeleteDialog =  ref(false)
  const itemToDelete =  ref(null)

  const itemToDeleteAttachmentType = computed(() => {
    return itemToDelete.value ? itemToDelete.value.attachmentType : ''
  })

  const filterTypes = computed(() => {
    return attachmentTypes.value.filter(e => {
      return !e.archived
    })
  })

  onMounted(() => {
    getAttachmentTypes()
  })
  const goToType = (typeId) => {
    router.push({path: `/settings/attachment/${typeId}/customFieldGroups`})
  }
  const getAttachmentTypes = async () => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await getRequest(`/attachmentType/types`)
      attachmentTypes.value = orderBy(data, [a => a.attachmentType.toLowerCase()])

      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Attachment Types')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const deleteType = async () => {
    const item = itemToDelete.value
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {status} = await deleteRequest(`/attachmentType/delete/${item.id}`)
      item.archived = true
      snackbar('SUCCESS', 'Successfully Deleted Attachment Type')
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      if (e.status === 400) {
        item.deleteConfirm = false
        deleteError.value = true
        cannotDeleteReasons.value = e.data
      }
      snackbar('ERROR', 'Error Deleting Attachment Type')
      store.commit(AppMutations.SET_LOADING, false)
    }
    closeDeleteDialog()
  }

  const addNewType = async () => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      newType.value.companyId = companyId.value
      const {data, status} = await postRequest(`/attachmentType/type`, newType.value, null, [])

      snackbar('SUCCESS', 'Action Type Added')

      // add it to the records already on the screen
      attachmentTypes.value.push(data)
      attachmentTypes.value = orderBy(attachmentTypes.value, [a => a.attachmentType.toLowerCase()])

      // reset the new process fields
      addNew.value = false
      newType.value = {}

      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Adding Attachment Type')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const closeDeleteDialog = () => {
    showDeleteDialog.value = false
    itemToDelete.value = null
  }

</script>

<style lang="scss">
#attachment-type-container .v-data-table__wrapper {
  height: calc(100vh - 310px);
  min-height: 300px;
}

</style>
