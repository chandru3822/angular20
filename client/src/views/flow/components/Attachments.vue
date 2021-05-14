<template>
<v-col v-if="attachmentTypes.length > 0" class="pt-0">
  <v-row>
    <v-col class="text-left py-0">
      <v-toolbar color="transparent" class="elevation-0">
        <v-toolbar-title>Documents</v-toolbar-title>
      </v-toolbar>
    </v-col>
  </v-row>
  <v-sheet color="#fff" class="elevation-2 mx-4 square-card">
    <v-col cols="12">
      <v-row v-if="displayType === null" class="d-flex justify-start">
        <v-col
          cols="2"
          class="type text-center pb-0"
          @click="drillDown(type)"
          v-for="type in attachmentTypes"
        >
          <v-icon x-large color="yellow accent-4">folder</v-icon>
          <div>{{ type.attachmentType }}</div>
          <div>{{`(${getTypeCount(type.attachmentTypeId)})`}}</div>
        </v-col>
      </v-row>
      <v-row v-else>
        <v-col cols="4" class="text-left" pb-0>
          <v-btn @click="displayType = null">Back</v-btn>
        </v-col>
        <v-col cols="3" class="text-left py-0">
          <v-checkbox label="Show non-primary Documents"
                      v-model="showNonPrimaryDocs"></v-checkbox>
        </v-col>
        <v-col cols="5" class="py-3" v-if="!displayType.readOnly">
            <v-file-input
              dense
              ref="fileInput"
              hide-details
              :show-size="error.error"
              outlined
              label="Upload document"
              @change="uploadDocument"
            />
          <span class="error-text" v-if="error.message">{{error.message}}</span>
        </v-col>
        <v-row class="d-flex flex-wrap justify-start">
          <v-col
            cols="12"
            class="type"
          >
            <v-data-table
              :headers="headers"
              :items="drillDownAttachments"
              :fixed-header="true"
              :items-per-page="-1"
              :mobile-breakpoint="0"
              hide-default-footer
              hide-default-header
              class="elevation-0 square-card attachment-table"
              :key="renderTicker"
            >
              <template #no-data>
                No Attachments Available
              </template>

              <template #no-results>
                No Attachments Available
              </template>

              <template #item="{ item }">
                <tr  class="text-left"  :class="{'primary-row': item.main}">
                  <td class="text-left">
                    <v-btn
                      width="100%"
                      icon
                      text
                      :href="item.presignedUrl" class="type">
                      <v-icon large color="grey">
                        {{ getIconForFile(item) }}
                      </v-icon>
                    </v-btn>
                  </td>
                  <td class="text-left">
                    <a v-if="!item.edit" :href="item.presignedUrl"
                       class="type link text-center">
                      {{ item.editableName }}
                    </a>
                    <v-text-field
                      v-else
                      hide-details
                      label="Filename"
                      class="my-2"
                      v-model="item.editableName"
                    ></v-text-field>
                  </td>
                  <td>
                    <span class="text-center" v-if="item.projectProcessStepId != null">
                      {{ item.processStepName }} - {{ item.projectProcessStepId }}<br/>
                      <strong>Primary:</strong> {{ item.main ? 'Y' : 'N' }}<br/>
                      <strong>Uploaded By:</strong> {{item.uploadedBy}}<br/>
                      <strong>Uploaded Date: </strong>{{item.dateCreated | formatDate('timestamp', 'MM/DD/YYYY')}}<br/>
                    </span>
                  </td>
                  <td class="text-right" v-if="(projectProcessStepId == null && item.projectProcessStepId == null) || projectProcessStepId != null">
                    <v-btn small text v-if="!item.edit" @click="[item.edit = true, renderTicker++]">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <v-btn small text v-if="item.edit" @click="saveFilename(item)">
                      <v-icon>save</v-icon>
                    </v-btn>
                    <v-btn small text v-if="item.edit" @click="[item.edit = false, renderTicker++]">
                      cancel
                    </v-btn>
                    <v-dialog
                      v-model="item.deleteConfirm"
                      width="500">
                      <template #activator="{ on }">
                        <v-btn small text v-on="on">
                          <v-icon>delete</v-icon>
                        </v-btn>
                      </template>
                      <v-card>
                        <v-card-title
                          class="headline grey lighten-2"
                          primary-title>
                          Confirm
                        </v-card-title>

                        <v-card-text class="pt-4">
                          Are you sure you want to delete <strong>{{item.filename}}</strong>?
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
                            @click="[item.archived = true, deleteAttachment(item.id)]">
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
      </v-row>
    </v-col>
  </v-sheet>
</v-col>
</template>

<script>
import { Actions } from '@/store'
import {AppMutations} from '@/stores/AppStore'
import {getRequest, putRequest, getFileIcon, getRequestWithParams, logError, getSnackbar} from '@/helpers/helpers'
import {deleteAttachment} from '@/services/attachmentService'
import orderBy from 'lodash.orderby'

// @TODO: need to generisize this so it can be used for any object type (project, process step, contact, user, org)

export default {
  name: "Attachments",
  data () {
    return {
      attachmentTypes: [],
      attachments: [],
      displayType: null,
      typePath: null,
      attachmentPath: null,
      error: {},
      renderTicker: 0,
      headers: [
        { text: null, value: 'fileIcon', show: true },
        { text: null, value: 'filename', show: true },
        { text: null, value: 'icons', show: true },
      ],
      showNonPrimaryDocs: false
    }
  },
  props: {
    projectId: Number,
    processStepId: Number,
    projectProcessStepId: Number
  },
  created () {
    if (this.projectId) {
      this.typePath = '/projectTypes'
      this.attachmentPath = `/project/${this.projectId}/attachments`
    } else if (this.projectProcessStepId) {
      this.typePath = `/processStepTypes/${this.processStepId}`
      this.attachmentPath = `/projectProcessStep/${this.projectProcessStepId}/attachments`
    }

    this.fetchAttachmentTypes()
    this.fetchAttachments()
  },
  computed: {
    drillDownAttachments () {
      if (this.displayType === null) {
        return []
      } else {
        if (this.showNonPrimaryDocs) {
          return this.attachments.filter(a => !a.archived && a.attachmentTypeId === this.displayType.attachmentTypeId)
        }
        else {
          return this.attachments.filter(a => !a.archived && a.attachmentTypeId === this.displayType.attachmentTypeId && a.main)
        }
      }
    },
  },
  methods: {
    getIconForFile (item) {
      return getFileIcon(item)
    },
    async saveFilename(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let newFileName = item.editableName
        if(item.fileExtension) {
          newFileName += '.' + item.fileExtension
        }
        item.filename = newFileName
        const {data} = await putRequest(`/attachment/${item.id}`, item)
        item.presignedUrl = data.presignedUrl
        item.edit = false
        this.renderTicker++
        this.snackbar = getSnackbar('SUCCESS', 'Saved Changes')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Changes')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    fetchAttachmentTypes: async function () {
      const {data} = await getRequestWithParams(`/attachmentType${this.typePath}`, { params: {
          projectId: this.projectId
        }})
      this.attachmentTypes = data
    },
    deleteAttachment: async function (id) {
      await deleteAttachment(id)
    },
    fetchAttachments: async function () {
      const {data} = await getRequest(this.attachmentPath)
      data.forEach(d => {
        let tempFileName = d.filename.substr(0, d.filename.lastIndexOf('.'))
        d.editableName = tempFileName !== null && tempFileName !== '' ? tempFileName : d.filename
      })

      this.attachments = orderBy(data,  [a => a.dateCreated], 'desc')
    },
    drillDown: function(type) {
     this.displayType = type
    },
    getTypeCount: function(typeId) {
      try {
        return this.attachments.filter(a => a.attachmentTypeId === typeId && !a.archived).length
      } catch {
        return 0
      }
    },
    uploadDocument: async function (file) {
      try {
        if(file && file.size > 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          //reset error message when trying to upload new file
          this.error = {}
          // @TODO: The actions needs to change when genericising this component. Writing this line made me feel dirty
          await this.$store.dispatch((this.projectId) ? Actions.PROJECT_FILE_UPLOAD : Actions.PROJECT_PROCESS_STEP_FILE_UPLOAD, {
            file,
            attachmentTypeId: this.displayType.attachmentTypeId,
            projectId: this.projectId,
            projectProcessStepId: this.projectProcessStepId,
            callback: async (newAttachment, error) => {
              if(error) {
                this.error = error
                this.snackbar = getSnackbar('ERROR', error.message)
                this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              } else {
                let tempFileName = newAttachment.filename.substr(0, newAttachment.filename.lastIndexOf('.'))
                newAttachment.editableName = tempFileName !== null && tempFileName !== '' ? tempFileName : newAttachment.filename

                this.attachments = [...this.attachments, newAttachment]
              }
              this.$refs.fileInput.reset()
              this.$store.commit(AppMutations.SET_LOADING, false)
            }
          })
        }
      } catch(e) {
        this.$store.commit(AppMutations.SET_LOADING, false)
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    }
  }
}
</script>

<style scoped lang="scss">
  .v-btn:before {
    display: none;
  }
  .type {
    font-size: 12px;
  }
  .link {
    color: inherit;
    text-decoration: none;
  }
  .attachment-table {
    border-top: solid 2px #E0E0E0;
    border-bottom: solid 2px #E0E0E0;
  }
  .primary-row{
    background-color: #ebf5ff !important;
  }
</style>
