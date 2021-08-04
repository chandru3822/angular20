<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col class="shrink pt-0" cols="12">
        <v-toolbar flat>
          <v-toolbar-title class="app-title">Attachment Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="getAttachmentTypesForProjects" v-if="userCanAdd">
              <v-icon v-if="!addNewType">add</v-icon>
              {{ addNewType ? 'Cancel' : 'Add Type'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-select attach v-if="addNewType"
                  v-model="newType.attachmentTypeId"
                  :items="availableAttachmentTypes"
                  label="Select Attachment Type"
                  item-text="attachmentType"
                  item-value="id"
                  @input="assignNewType"
        ></v-select>
        <v-card flat >
          <draggable v-model="projectAttachmentTypes" group="projectAttachmentTypes"
                     :disabled="!userCanEdit"
                     id="proj-attachment-draggable"
                     @change="saveAttachmentTypeOrder(projectAttachmentTypes)"
                     @start="drag=true" @end="drag=false">
            <v-list v-for="(a, index) in filterBy(projectAttachmentTypes, false, 'archived')"
                    :key="index">
              <v-list-item class="grab" dense :class="{'shaded-row': index % 2}">
                <v-list-item-action>
                  <v-icon>drag_handle</v-icon>
                </v-list-item-action>
                <v-list-item-content>
                  {{a.attachmentType}}
                </v-list-item-content>
                <v-checkbox  style="display: flex; justify-content: flex-end" v-model="a.readOnly" label="Read-Only" @change="updateReadOnly(a)"></v-checkbox>
                <v-dialog
                  v-if="userCanEdit"
                  v-model="a.deleteConfirm"
                  width="500">
                  <template v-slot:activator="{ on }">
                    <v-list-item-action class="clickable" v-on="on">
                      <v-icon>delete</v-icon>
                    </v-list-item-action>
                  </template>
                  <v-card>
                    <v-card-title
                      class="headline grey lighten-2"
                      primary-title
                    >
                      Confirm
                    </v-card-title>

                    <v-card-text>
                      Are you sure you want to delete this attachment type: <strong>{{ a.attachmentType }}</strong>?
                    </v-card-text>

                    <v-divider></v-divider>

                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn
                        @click="a.deleteConfirm = false">
                        No
                      </v-btn>
                      <v-btn
                        color="primaryCustom"
                        text
                        @click="[a.archived = true, deleteAttachmentType(a.id)]">
                        Yes
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-dialog>
              </v-list-item>
            </v-list>
          </draggable>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from "@/stores/AppStore";
import draggable from 'vuedraggable'
import {deleteRequest, getRequest, getSnackbar, postRequest, putRequest} from "@/helpers/helpers";
import Vue2Filters from "vue2-filters";

export default {
  name: 'ProjectAttachments',
  mixins: [Vue2Filters.mixin],
  components: {
    draggable
  },
  data () {
    return {
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
      addNewType: false,
      newType: {},
      availableAttachmentTypes: [],
      projectAttachmentTypes: []
    }
  },
  watch: {},
  created () {
    this.getProjectAttachmentTypes()
  },
  methods: {
    async getProjectAttachmentTypes () {
      //this one loads attachment types already assigned to a project
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const { data } = await getRequest(`/attachmentType/projectTypes`)
        this.projectAttachmentTypes = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getAttachmentTypesForProjects () {
      //this one loads attachment types AVAILABLE TO BE assigned to a project ...idk maybe this should be one function
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addNewType = !this.addNewType
        if(this.addNewType){
          const { data } = await getRequest(`/attachmentType/typesForProjects`)
          this.availableAttachmentTypes = data
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async assignNewType () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newType.processStepId = this.$route.params.id
        const { data } = await postRequest(`/attachmentType/projectType`, this.newType)
        this.projectAttachmentTypes.push(data)
        // reset fields
        this.addNewType = false
        this.newType = {}
        this.snackbar = getSnackbar('SUCCESS', 'Attachment Type Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Attachment Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteAttachmentType (id) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addNewType = false
        await deleteRequest(`/attachmentType/projectType/${id}`)
        // this.availableAttachmentTypes = data
        this.snackbar = getSnackbar('SUCCESS', 'Attachment Type Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Attachment Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveAttachmentTypeOrder (attachmentTypes) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        // if the fieldOrder of any item does not match idx + 1, it means it was changed and needs to be saved
        // pull those needing to be saved out of list
        let typesToSave = []
        attachmentTypes.forEach((f, idx) => {
          let order = idx + 1
          if(f.displayOrder !== order){
            f.displayOrder = order
            typesToSave.push(f)
          }
        })
        // save them here
        if(typesToSave.length > 0) {
          await putRequest(`/attachmentType/updateOrderInProject`, typesToSave)
        }
        this.snackbar = getSnackbar('SUCCESS', 'Attachment Types Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Attachment Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateReadOnly(attachmentType) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await putRequest(`/attachmentType/updateReadOnly/`, attachmentType)
        this.snackbar = getSnackbar('SUCCESS', 'Attachment Type updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error updating Attachment Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
#proj-attachment-draggable .v-list {
  padding-top: 0;
  padding-bottom: 0;
}
</style>
