<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Project Status Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newType = {}]" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat v-if="addNew" class="px-5 py-2 square-card" color="rowShadeCustom">
          <h3>Add Project Status</h3>
          <v-text-field label="Project Status" v-model="newType.projectStatusType">
          </v-text-field>
          <v-autocomplete single-line
                    :items="rootStatusTypes"
                    v-model="newType.projectStatusTypeId"
                    item-value="id"
                    label="Select a Category"
                    item-text="projectStatusType"></v-autocomplete>
          <v-btn :disabled="!newType.projectStatusTypeId || !newType.projectStatusType" @click="saveType(newType, true)">Save</v-btn>
        </v-card>
        <v-data-table
          :headers="headers"
          :items="filterProjectStatuses()"
          :fixed-header="true"
          :expanded.sync="expanded"
          single-expand
          :items-per-page="-1"
          hide-default-footer
          :sort-by="['displayOrder']"
          :sort-desc="[false]"
          class="elevation-1"
        >
          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left" :class="{'shaded-row': statusTypes.indexOf(item) % 2}">
              <h3 class="mb-3">Edit Status Type</h3>
              <v-text-field v-model="item.projectStatusType"
                            label="Status Type"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
              ></v-text-field>
              <v-autocomplete
                        :items="rootStatusTypes"
                        v-model="item.projectStatusTypeId"
                        item-value="id"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        label="Select a Category"
                        item-text="projectStatusType"></v-autocomplete>
              <div  v-if="!item.isDefault" class="mb-3">
                <v-dialog
                  v-model="item.setInitialConfirm"
                  width="500">
                  <template #activator="{ on }">
                    <v-btn v-on="on">
                      Set as Initial
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title
                      class="headline grey lighten-2"
                      primary-title>
                      Confirm
                    </v-card-title>

                    <v-card-text class="pt-4">
                      Setting this Project Status Type as default will unset the other initial status. Are you sure you want to continue?
                    </v-card-text>

                    <v-divider></v-divider>

                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn
                        @click="item.setInitialConfirm = false">
                        No
                      </v-btn>
                      <v-btn
                        color="primaryCustom"
                        text
                        @click="setAsInitial(item)">
                        Yes
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-dialog>
              </div>
              <div class="my-2" v-if="item.icon && item.icon.id != null">
                <label>Status Type Icon</label>
                <div class="flex-display ma-2">
                  <img class="status-icon" :src="item.icon.presignedUrl">
                  <v-btn x-small text @click="deleteAttachment(item)">
                    <v-icon>close</v-icon>
                  </v-btn>
                </div>
              </div>
              <div class="my-2" v-else>
                <label>Status Type Icon</label>
                <form enctype="multipart/form-data" novalidate>
                  <input
                    type="file"
                    :accept="acceptedFileTypes"
                    class="file-input clickable"
                    :disabled="savingTypeLogo"
                    @change="uploadFile(item, $event.target.files, attachmentTypeId, item.id, 1048576)"
                    name="avatar"
                  >
                  <br/><span>* Due to render times associated with this file it cannot exceed 1MB</span>
                </form>
              </div>
              <v-btn color="primaryCustom" dark class="white--text"
                     :disabled="!item.projectStatusType || !item.projectStatusTypeId"
                     @click="saveType(item, false)">Save</v-btn>
            </td>
          </template>
          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td style="width: 50px">
                <v-btn text icon small class="handle" v-if="userCanEdit">
                  <v-icon>drag_handle</v-icon>
                </v-btn>
              </td>
              <td class="text-left">
                {{item.projectStatusType}}
              </td>
              <td class="text-left">
                {{item.rootProjectStatusType}}
              </td>
              <td class="text-left">
                <input v-if="item.isDefault" type="checkbox" v-model="item.isDefault" disabled readonly>
              </td>
              <td class="text-left">
                <img v-if="item.icon && item.icon.presignedUrl"
                     class="status-icon-grid" :src="item.icon.presignedUrl">
              </td>
              <td class="text-right">
                <v-btn small text v-if="!expanded.includes(item)" @click="expanded = [item]">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>
                <v-dialog v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                          v-model="item.deleteConfirm" width="500">
                  <template #activator="{ on }">
                    <v-btn small text v-on="on">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title
                      class="headline grey lighten-2"
                      primary-title
                    >
                      Confirm
                    </v-card-title>

                    <v-card-text>
                      Are you sure you want to delete this status type: <strong>{{ item.projectStatusType }}</strong>?
                    </v-card-text>

                    <v-divider></v-divider>

                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn
                        @click="item.deleteConfirm = false">
                        No
                      </v-btn>
                      <v-btn
                        color="primaryCustom"
                        text
                        @click="[item.archived = true, deleteType(item)]">
                        Yes
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-dialog>
              </td>

            </tr>
          </template>
        </v-data-table>
      </v-col>

    </v-row>
  </v-container>
</template>


<script>
  import { Actions } from '@/store'
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import draggable from 'vuedraggable'
  import cloneDeep from 'lodash.clonedeep'
  import Sortable from 'sortablejs'

  import orderBy from 'lodash.orderby'
  import {getCompanyProjectStatusTypes, getProjectStatusTypes} from '@/services/projectStatusTypeService'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'ProjectStatuses',
    mixins: [Vue2Filters.mixin],
    components: {
      draggable,
    },
    data () {
      return {
        snackbar: {},
        constants,
        statusTypes: [],
        expanded: [],
        rootStatusTypes: [],
        acceptedFileTypes: constants.STANDARD_IMAGES_ONLY,
        savingTypeLogo: false,
        //463 = project status type attachment
        attachmentTypeId: 463,
        headers: [
          { text: null, value: 'draggable', width: '50px', show: true },
          {text: 'Project Status', value: 'projectStatusType', show: true},
          {text: 'Category', value: 'rootProjectStatusType', show: true},
          {text: 'Initial', value: 'initial', show: true},
          {text: 'Icon', value: 'icon', show: true},
          {text: '', value: 'icons', show: true},
        ],
        addNew: false,
        newType: {},
        selectedStatusTypeId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      }
    },
    mounted() {
      let table = document.querySelector('tbody')
      const _self = this
      Sortable.create(table, {
        handle: '.handle',
        onEnd({ newIndex, oldIndex }) {
          const rowSelected = _self.statusTypes.splice(oldIndex, 1)[0]
          _self.statusTypes.splice(newIndex, 0, rowSelected)
          let statusTypesClone = cloneDeep(_self.statusTypes)
          statusTypesClone.forEach((g, idx) => {
            g.displayOrder = idx
          })
          _self.saveOrderChanges(statusTypesClone)
        }
      })
    },
    computed: {
    },
    methods: {
      async saveOrderChanges (types) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequest(`/project/companyStatuses`, types)
          this.snackbar = getSnackbar('SUCCESS', 'Status Types Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Status Type Changes')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async uploadFile (item, files, attachmentTypeId, sourceId, sizeLimit) {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          await this.$store.dispatch(Actions.FILE_UPLOAD, {
            file: files[0],
            sizeLimit,
            attachmentTypeId,
            sourceId,
            callback: async (img, error) => {
              if(error?.error) {
                this.snackbar = getSnackbar('ERROR', error.errorMsg)
                this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
                this.$store.commit(AppMutations.SET_LOADING, false)
              } else {
                item.icon = img

                this.snackbar = getSnackbar('SUCCESS', 'Image Uploaded')
                this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
                this.$store.commit(AppMutations.SET_LOADING, false)
              }
            }
          })
        } catch(e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteAttachment (item) {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          await this.$store.dispatch(Actions.FILE_DELETE, {
            id: item.icon.id,
            callback: async (status) => {
              item.icon = {}
              // this.$store.commit(UserMutations.SET_USER_IMAGE, {})
              this.snackbar = getSnackbar('SUCCESS', 'Image Deleted')
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
            }
          })
        } catch(e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting File')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCompanyStatusTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getCompanyProjectStatusTypes()
          this.statusTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getProjectStatusTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getProjectStatusTypes()
          this.rootStatusTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteType (item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/project/companyStatus/${item.id}`)
          this.snackbar = getSnackbar('SUCCESS', 'Status Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Status')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveType (type, isNew) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/project/companyStatus`, type)

          if(isNew) {
            // add it to the records already on the screen
            this.statusTypes.push(data)
            this.statusTypes = orderBy(this.statusTypes, [s => s.projectStatusType.toLowerCase()])

            // reset the new process fields
            this.addNew = false
            this.newType = {}
          }
          this.expanded = []
          this.selectedStatusTypeId = null
          this.snackbar = getSnackbar('SUCCESS', 'Project Status Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Project Status')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterProjectStatuses () {
        return this.statusTypes.filter(s => { return !s.archived})
      },
      async setAsInitial (item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequest(`/project/companyStatus/initial/${item.id}`, )
          this.statusTypes.forEach(st => {
            st.isDefault = false
          })
          item.isDefault = true
          this.expanded = []
          this.snackbar = getSnackbar('SUCCESS', 'Status Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Status')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    },
    async created () {
      this.getCompanyStatusTypes()
      this.getProjectStatusTypes()
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
</style>
