<template>
  <v-container class="custom-field-group-container">
    <v-dialog width="700"
              v-model="deleteError"
    >
      <v-card>
        <v-card-title class="text-h5 grey lighten-2 error--text">
          Error Deleting Attachment Type
        </v-card-title>

        <v-card-text class="pt-5">
          <div v-if="cannotDeleteReasons && cannotDeleteReasons.length > 0" class="mb-5">
            <div class="mb-3">* This attachment type is currently in use.  You must remove it from the following locations before deleting.</div>
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
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Attachment Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNew = !addNew, newType = {}]" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-text-field v-if="addNew"
                        v-model="newType.attachmentType"
                        placeholder="Enter a type"
                        label="Attachment Type">
          </v-text-field>
          <v-btn v-if="addNew" color="primary" :disabled="!newType.attachmentType" @click="addNewType">Save</v-btn>
          <v-list v-for="(a, index) in filterBy(attachmentTypes, false, 'archived')"
                  :key="index" class="pa-0">
            <v-list-item :class="{'shaded-row': index % 2}">
              <v-list-item-content class="text-left">
                <v-text-field class="one-hunned" v-if="selectedAttachmentTypeId === a.id" v-model="a.attachmentType">
                </v-text-field>
                <div v-else>{{a.attachmentType}}</div>
              </v-list-item-content>
              <v-list-item-action class="clickable" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
                <v-icon v-if="selectedAttachmentTypeId === a.id" color="primary" @click="saveType(a)">save</v-icon>
                <v-icon v-else color="primary" @click="selectedAttachmentTypeId = a.id">edit</v-icon>
              </v-list-item-action>
              <v-btn v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')" text color="primary" @click="[itemToDelete=a, showDeleteDialog=true]"><v-icon>delete</v-icon></v-btn>
            </v-list-item>
          </v-list>
          <ConfirmationDialog :open-dialog="showDeleteDialog"
                                       @confirm = deleteType
                                       @close-dialog="closeDeleteDialog"
          >Are you sure you want to delete this attachment type: <strong>{{itemToDeleteAttachmentType}}</strong></ConfirmationDialog>
        </v-container>
      </v-col>
    </v-row>

  </v-container>
</template>


<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import orderBy from 'lodash.orderby'

  import {handleHidingGlobalLoader, getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import ConfirmDeleteDialog from "@/ConfirmDeleteDialog";
  import ConfirmationDialog from "@/ConfirmationDialog";

  export default {
    name: 'Attachments',
    components: {ConfirmationDialog, ConfirmDeleteDialog},
    mixins: [Vue2Filters.mixin],

    data() {
      return {
        snackbar: {},
        constants,
        attachmentTypes: [],
        addNew: false,
        newType: {},
        selectedAttachmentTypeId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        cannotDeleteReasons: {},
        deleteError: false,
        showDeleteDialog: false,
        itemToDelete: null
      }
    },
    computed: {
      itemToDeleteAttachmentType() {
        return this.itemToDelete ? this.itemToDelete.attachmentType : ''
      }
    },
    methods: {
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
      async saveType(a) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.selectedAttachmentTypeId = null
          a.modifiedById = this.userId
          const {status} = await putRequest(`/attachmentType/type`, a)
          this.snackbar = getSnackbar('SUCCESS')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Attachment Type')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      closeDeleteDialog(){
        this.showDeleteDialog = false
        this.itemToDelete = null
      }
    },
    async created() {
      this.getAttachmentTypes()
    }
  }
</script>
