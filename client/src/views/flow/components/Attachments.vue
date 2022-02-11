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
          :class="{'file-hover': dragTypeId === type.attachmentTypeId}"
          class="type text-center pb-0"
          @click="drillDown(type)"
          @dragenter="dragTypeId=type.attachmentTypeId"
          @dragleave="dragTypeId=null"
          @dragend="dragTypeId=null"
          @drop.prevent="addDragDocument($event, type.attachmentTypeId)"
          @dragover.prevent="dragTypeId=type.attachmentTypeId"
          v-for="type in attachmentTypes"
        >
          <div>
            <v-icon x-large color="yellow accent-4" @dragleave.prevent>folder</v-icon>
            <div @dragleave.prevent>{{ type.attachmentType }}</div>
            <div @dragleave.prevent>{{`(${getTypeCount(type.attachmentTypeId)})`}}</div>
          </div>
        </v-col>
      </v-row>
      <v-row v-else>
        <v-col cols="4" class="text-left pb-0">
          <v-btn @click="displayType = null">Back</v-btn>
        </v-col>
        <v-col cols="3" class="text-left py-0">
          <v-checkbox v-if="null != projectId || null != projectProcessStepId" label="Show non-primary Documents"
                      v-model="showNonPrimaryDocs"></v-checkbox>
        </v-col>
        <v-col cols="5" class="py-3" v-if="!displayType.readOnly" >
          <AttachmentUpload :project-id="projectId" :project-process-step-id="projectProcessStepId"
                            :user-id="userId" :contact-id="contactId" :object-type-id="objectTypeId"
                            :org-id="orgId" :attachment-type-id="displayType.attachmentTypeId"
                            :callback="uploadCallback"></AttachmentUpload>
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
                          class="text-h5 grey lighten-2"
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
import {handleHidingGlobalLoader, getRequest, putRequest, getFileIcon, getRequestWithParams, logError, getSnackbar} from '@/helpers/helpers'
import {deleteAttachment} from '@/services/attachmentService'
import AttachmentUpload from "@/views/flow/components/AttachmentUpload";
import orderBy from 'lodash.orderby'

// @TODO: need to generisize this so it can be used for any object type (project, process step, contact, user, org)

export default {
  name: "Attachments",
  components: {
    AttachmentUpload
  },
  data () {
    return {
      attachmentTypes: [],
      attachments: [],
      displayType: null,
      dragTypeId: null,
      typePath: null,
      attachmentPath: null,
      error: {},
      renderTicker: 0,
      companyId: this.$store.state.user.details.companyId,
      headers: [
        { text: null, value: 'fileIcon', show: true },
        { text: null, value: 'filename', show: true },
        { text: null, value: 'icons', show: true },
      ],
      showNonPrimaryDocs: false,
    }
  },
  props: {
    projectId: Number,
    processStepId: Number,
    projectProcessStepId: Number,
    eventId: Number,
    projectProcessStepEventId: Number,
    objectTypeId: Number,
    userId: Number,
    contactId: Number,
    orgId: Number,
  },
  created () {
    if (this.projectId) {
      this.typePath = '/projectTypes'
      this.attachmentPath = `/project/${this.projectId}/attachments`
    } else if (this.processStepId) {
      this.typePath = `/processStepTypes/${this.processStepId}`
      this.attachmentPath = `/projectProcessStep/${this.projectProcessStepId}/attachments`
    } else if (this.eventId) {
      this.typePath = `/eventTypes/${this.eventId}`
      this.attachmentPath = `/projectProcessStep/${this.projectProcessStepId}/event/${this.projectProcessStepEventId}/attachments`
    } else if (this.objectTypeId === 3) {
      //user
      this.typePath = `/objectTypes/user`
      this.attachmentPath = `/user/${this.userId}/attachments`
    } else if (this.objectTypeId === 2) {
      //contact
      this.typePath = `/objectTypes/contact`
      this.attachmentPath = `/contact/${this.contactId}/attachments`
    } else if (this.objectTypeId === 5) {
      //org
      this.typePath = `/objectTypes/org`
      this.attachmentPath = `/org/${this.orgId}/attachments`
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
          return this.attachments.filter(a => !a.archived && a.attachmentTypeId === this.displayType.attachmentTypeId && ((this.projectProcessStepId == null && this.projectId == null) || a.main))
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
        const {data, status} = await putRequest(`/attachment/${item.id}`, item)
        item.presignedUrl = data.presignedUrl
        item.edit = false
        this.renderTicker++
        this.snackbar = getSnackbar('SUCCESS', 'Saved Changes')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Changes')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    fetchAttachmentTypes: async function () {
      const {data} = await getRequestWithParams(`/attachmentType${this.typePath}`, { params: {
          projectId: this.projectId,
          companyId: this.companyId
        }})
      this.attachmentTypes = data
    },
    deleteAttachment: async function (id) {
      await deleteAttachment(id)
    },
    fetchAttachments: async function () {
      const {data} = await getRequest(this.attachmentPath, null, [])
      data.forEach(d => {
        let tempFileName = d.filename.substr(0, d.filename.lastIndexOf('.'))
        d.editableName = tempFileName !== null && tempFileName !== '' ? tempFileName : d.filename
      })

      this.attachments = orderBy(data,  [a => a.dateCreated], 'desc')
    },
    drillDown: function(type) {
      this.displayType = type
      //not sure why i am having to unset this value
      this.dragTypeId = null
    },
    getTypeCount: function(typeId) {
      try {
        return this.attachments.filter(a => a.attachmentTypeId === typeId && !a.archived).length
      } catch {
        return 0
      }
    },
    addDragDocument: async function (e, attachmentTypeId) {
      let files = e.dataTransfer.files
      await this.uploadDocument(files, attachmentTypeId)
    },
    uploadDocument: async function (files, attachmentTypeId) {
      if (files?.length > 0) {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          //reset error message when trying to upload new file
          this.error = {}
          // @TODO: The actions needs to change when genericising this component. Writing this line made me feel dirty
          for (let i = 0; i < files.length; ++i) {
            let file = files[i];
            if (file && file.size > 0) {
              await this.$store.dispatch((this.projectId) ? Actions.PROJECT_FILE_UPLOAD :
                null != this.projectProcessStepId ? Actions.PROJECT_PROCESS_STEP_FILE_UPLOAD : Actions.OBJECT_TYPE_FILE_UPLOAD, {
                file,
                attachmentTypeId: attachmentTypeId ?? this.displayType?.attachmentTypeId,
                projectId: this.projectId,
                projectProcessStepId: this.projectProcessStepId,
                userId: this.userId,
                contactId: this.contactId,
                orgId: this.orgId,
                objectTypeId: this.objectTypeId,
                projectProcessStepEventId: this.projectProcessStepEventId,
                callback: this.uploadCallback
              })
            }
          }
          // this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          this.$store.commit(AppMutations.SET_LOADING, false)
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      }
    },
    async uploadCallback(newAttachment, error) {
      if (error) {
        this.error = error
        this.snackbar = getSnackbar('ERROR', error.message)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } else {
        let tempFileName = newAttachment.filename.substr(0, newAttachment.filename.lastIndexOf('.'))
        newAttachment.editableName = tempFileName !== null && tempFileName !== '' ? tempFileName : newAttachment.filename

        this.attachments = [...this.attachments, newAttachment]
      }
      this.$store.commit(AppMutations.SET_LOADING, false)
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
  .file-hover {
    background: #F6F7F8;
  }
</style>
