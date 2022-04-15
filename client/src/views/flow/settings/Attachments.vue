<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Attachment Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newType = {}]" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
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
          <v-btn v-if="addNew" :disabled="!newType.attachmentType" @click="addNewType">Save</v-btn>
          <v-list v-for="(a, index) in filterBy(attachmentTypes, false, 'archived')"
                  :key="index" class="pa-0">
            <v-list-item :class="{'shaded-row': index % 2}">
              <v-list-item-content class="text-left">
                <v-text-field class="one-hunned" v-if="selectedAttachmentTypeId === a.id" v-model="a.attachmentType">
                </v-text-field>
                <div v-else>{{a.attachmentType}}</div>
              </v-list-item-content>
              <v-list-item-action class="clickable" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
                <v-icon v-if="selectedAttachmentTypeId === a.id" @click="saveType(a)">save</v-icon>
                <v-icon v-else @click="selectedAttachmentTypeId = a.id">edit</v-icon>
              </v-list-item-action>
              <confirm-delete-dialog
                  v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                  label="this attachment type: "
                  :item-to-delete="a.attachmentType"
                  @confirm-delete="[a.archived = true, deleteType(a.id)]"
              ></confirm-delete-dialog>
            </v-list-item>
          </v-list>
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

  export default {
    name: 'Attachments',
    components: {ConfirmDeleteDialog},
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
        companyId: this.$store.state.user.details.companyId
      }
    },
    computed: {},
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
      async deleteType(typeId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/attachmentType/type/${typeId}`)
          this.snackbar = getSnackbar('SUCCESS', 'Successfully Deleted Attachment Type')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Attachment Type')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
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
      }
    },
    async created() {
      this.getAttachmentTypes()
    }
  }
</script>
