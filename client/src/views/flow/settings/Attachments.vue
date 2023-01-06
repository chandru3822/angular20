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

          <v-btn
            color="primary"
            dark
            class="white--text"
            @click="deleteError = false"
          >
            OK
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Attachment Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newType = {}]"
                   v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              <span>{{ addNew ? 'Cancel' : 'Add New' }}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card color="transparent" flat v-if="addNew" class="mb-3 pa-2">
            <v-text-field v-if="addNew"
                          v-model="newType.attachmentType"
                          placeholder="Enter a type"
                          label="Attachment Type">
            </v-text-field>
            <v-btn v-if="addNew" :disabled="!newType.attachmentType" @click="addNewType">Save</v-btn>
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
              :items="filterTypes()"
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
                  <td class="text-right">
                    <v-btn small text @click="goToType(item.id)">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <ConfirmationDialog :open-dialog="showDeleteDialog"
                                        @confirm=deleteType
                                        @close-dialog="closeDeleteDialog"
                    >Are you sure you want to delete this attachment type:
                      <strong>{{ itemToDeleteAttachmentType }}</strong></ConfirmationDialog>
                  </td>

                </tr>
              </template>
            </v-data-table>
          </v-card>
        </v-container>
      </v-col>
    </v-row>

  </v-container>
</template>


<script>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import orderBy from 'lodash.orderby'

import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
  getSnackbar
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from "@/ConfirmationDialog";

export default {
  name: 'Attachments',
  components: {ConfirmationDialog},
  mixins: [Vue2Filters.mixin],

  data() {
    return {
      snackbar: {},
      constants,
      attachmentTypes: [],
      search: '',
      addNew: false,
      newType: {},
      selectedAttachmentTypeId: null,
      userId: this.$store.state.user.details.id,
      companyId: this.$store.state.user.details.companyId,
      cannotDeleteReasons: {},
      deleteError: false,
      headers: [
        {text: 'Attachment Type', value: 'attachmentType', show: true},
        {text: '', value: 'icons', show: true},
      ],
      footerProps: {
        'items-per-page-options': [25, 50, 100, 1000],
        'items-per-page-text': 'Rows per page:'
      },
      showDeleteDialog: false,
      itemToDelete: null
    }
  },
  computed: {
    itemToDeleteAttachmentType() {
      return this.itemToDelete ? this.itemToDelete.attachmentType : ''
    }
  },
  async created() {
    await this.getAttachmentTypes()
  },
  methods: {
    goToType(typeId) {
      this.$router.push({path: `/settings/attachment/${typeId}/customFieldGroups`})
    },
    async getAttachmentTypes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/attachmentType/types`)
        this.attachmentTypes = orderBy(data, [a => a.attachmentType.toLowerCase()])

        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Attachment Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteType() {
      const item = this.itemToDelete
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await deleteRequest(`/attachmentType/delete/${item.id}`)
        item.archived = true
        this.snackbar = getSnackbar('SUCCESS', 'Successfully Deleted Attachment Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        if (e.status === 400) {
          item.deleteConfirm = false
          this.deleteError = true
          this.cannotDeleteReasons = e.data
        }
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Attachment Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.closeDeleteDialog()
    },
    async addNewType() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newType.companyId = this.companyId
        const {data, status} = await postRequest(`/attachmentType/type`, this.newType, null, [])

        this.snackbar = getSnackbar('SUCCESS', 'Action Type Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)

        // add it to the records already on the screen
        this.attachmentTypes.push(data)
        this.attachmentTypes = orderBy(this.attachmentTypes, [a => a.attachmentType.toLowerCase()])

        // reset the new process fields
        this.addNew = false
        this.newType = {}

        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Attachment Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    closeDeleteDialog() {
      this.showDeleteDialog = false
      this.itemToDelete = null
    },
    filterTypes() {
      return this.attachmentTypes.filter(e => {
        return !e.archived
      })
    },
  },

}
</script>

<style lang="scss">
#attachment-type-container .v-data-table__wrapper {
  height: calc(100vh - 310px);
  min-height: 300px;
}

</style>
