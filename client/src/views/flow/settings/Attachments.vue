<template>
  <v-container
    id="attachment-type-container"
    class="custom-field-group-container"
  >
    <v-dialog width="700" v-model="deleteError">
      <v-card>
        <v-card-title class="text-h5 grey lighten-2 error--text">
          Error Deleting Attachment Type
        </v-card-title>

        <v-card-text class="pt-5">
          <div
            v-if="cannotDeleteReasons && cannotDeleteReasons.length > 0"
            class="mb-5"
          >
            <div class="mb-3">
              * This attachment type is currently in use. You must remove it
              from the following locations before deleting.
            </div>
            <div v-for="a in cannotDeleteReasons" :key="a.id" class="ml-5">
              <strong>{{ a.processStepName }}</strong>
            </div>
          </div>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>

          <a-btn
            color="primary"
            dark
            @click="deleteError = false"
            text="Ok"
          ></a-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">
            Attachment Types
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
              v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')"
              variant="text"
              @click=";[(addNew = !addNew), (newType = {})]"
              color="primary"
              :hide-text-on-mobile="constants.IS_MOBILE"
              :text="!addNew ? 'Add New' : 'Cancel'"
              :prepend-icon="addNew ? 'close' : 'add'"
            >
            </a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card v-if="addNew" class="mb-2 pa-5">
            <a-text-field
              v-if="addNew"
              v-model="newType.attachmentType"
              placeholder="Enter a type"
              label="Attachment Type"
            >
            </a-text-field>
            <v-select
              v-model="newType.objectCategoryIds"
              multiple
              :items="objectCategories"
              item-text="name"
              item-value="id"
              label="Object Category"
            >
            </v-select>
            <a-btn
              v-if="addNew"
              color="primary"
              :disabled="
                !newType.attachmentType &&
                (!newType.objectCategoryIds ||
                  newType.objectCategoryIds.length < 1)
              "
              @click="addNewType"
              text="Save"
            />
          </v-card>
          <v-divider v-if="addNew"></v-divider>
          <v-card class="square-card">
            <v-card-title class="pt-0">
              <a-text-field
                v-model="search"
                prepend-inner-icon="search"
                label="Search"
                single-line
                hide-details
              ></a-text-field>
            </v-card-title>
            <v-data-table
              id="attachments-table"
              :headers="headers"
              :items="filterTypes"
              :fixed-header="true"
              :items-per-page="100"
              :search="search"
              :footer-props="footerProps"
              :sort-by="['attachmentType']"
              hide-default-header
              class="elevation-1 square-card"
            >
              <template #item="{ item, index }">
                <tr
                  :class="{
                    'shaded-row': index % 2,
                    'mobile-tr': vuetify.breakpoint.xsOnly
                  }"
                >
                  <td class="text-left clickable">
                    <router-link :to="getPath(item.id)" class="router-link-td">
                      {{ item.attachmentType }}
                    </router-link>
                  </td>
                  <td
                    class="text-right"
                    :class="{
                      'd-flex flex-column align-end': vuetify.breakpoint.xsOnly
                    }"
                  >
                    <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      @click="router.push(getPath(item.id))"
                      prepend-icon="edit"
                    />
                  </td>
                </tr>
              </template>
            </v-data-table>
          </v-card>
          <ConfirmationDialog
            :open-dialog="showDeleteDialog"
            @confirm="deleteType"
            @close-dialog="closeDeleteDialog"
          >
            Are you sure you want to delete this attachment type:
            <strong>
              {{ itemToDeleteAttachmentType }}
            </strong>
          </ConfirmationDialog>
        </v-container>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import { getCurrentInstance, ref, computed, onMounted } from 'vue'

import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  postRequest
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from '@/components/ConfirmationDialog'
import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStore.js'
import { useRouter } from 'vue-router/composables'

const vueInstance = getCurrentInstance().proxy

const userStore = useUserStore()
const appStore = useAppStore()
const router = useRouter()
const vuetify = vueInstance.$vuetify
const attachmentTypes = ref([])
const search = ref('')
const addNew = ref(false)
const newType = ref({})
const companyId = ref(userStore.details.companyId)
const cannotDeleteReasons = ref({})
const deleteError = ref(false)
const headers = ref([
  { text: 'Attachment Type', value: 'attachmentType', show: true },
  { text: '', value: 'icons', show: true }
])
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 1000],
  'items-per-page-text': 'Rows per page:'
})
const showDeleteDialog = ref(false)
const itemToDelete = ref(null)
const objectCategories = ref([])

const itemToDeleteAttachmentType = computed(() => {
  return itemToDelete.value ? itemToDelete.value.attachmentType : ''
})

const filterTypes = computed(() => {
  const types = attachmentTypes.value?.filter((e) => {
    return !e.archived
  })

  return types
})

onMounted(() => {
  Promise.allSettled([getAttachmentTypes(), getObjectCategories()])
})

const getObjectCategories = async () => {
  try {
    const { data } = await getRequest(`/objectCategory?objectTypeId=1`)
    objectCategories.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Object Categories')
  }
}

const getPath = (typeId) => {
  return { path: `/settings/attachment/${typeId}/customFieldGroups` }
}

const getAttachmentTypes = async () => {
  appStore.loading = true
  try {
    const { data, status } = await getRequest(`/attachmentType/types`)
    attachmentTypes.value = data

    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Attachment Types')
    appStore.loading = false
  }
}

const deleteType = async () => {
  const item = itemToDelete.value
  appStore.loading = true
  try {
    const { status } = await deleteRequest(`/attachmentType/${item.id}`)
    item.archived = true
    appStore.showSnack('SUCCESS', 'Successfully Deleted Attachment Type')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    if (e.status === 400) {
      item.deleteConfirm = false
      deleteError.value = true
      cannotDeleteReasons.value = e.data
    }
    appStore.showSnack('ERROR', 'Error Deleting Attachment Type')
    appStore.loading = false
  }
  closeDeleteDialog()
}

const addNewType = async () => {
  appStore.loading = true
  try {
    newType.value.companyId = companyId.value
    const { data, status } = await postRequest(
      `/attachmentType/type`,
      newType.value,
      null,
      []
    )

    appStore.showSnack('SUCCESS', 'Attachment Type Added')

    // add it to the records already on the screen
    attachmentTypes.value.push(data)

    // reset the new process fields
    addNew.value = false
    newType.value = {}

    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Adding Attachment Type')
    appStore.loading = false
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

@media (max-width: 770px) {
  #attachments-table {
    padding-bottom: 12px;
    div.v-data-footer {
      display: inline-block;
      width: 100%;
      height: auto;

      div.v-data-footer__select {
        justify-content: center;
      }

      div.v-data-footer__icons-before {
        display: inline;
        margin-left: calc(50% - 36px);
      }

      div.v-data-footer__icons-after {
        display: inline;
      }
    }
  }
}

.mobile-tr {
  display: flex;
  flex-direction: column;
  align-items: center;
  border-bottom: thin solid rgba(0, 0, 0, 0.12);
  width: calc(100vw - 100px);
  td {
    border-bottom: none !important;
  }
}
</style>
