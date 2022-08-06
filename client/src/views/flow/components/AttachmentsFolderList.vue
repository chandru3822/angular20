<template>
  <div>
    <div v-if="activityTab" class="px-5">
      <v-text-field
        v-model="search"
        prepend-inner-icon="search"
        label="Search all project documents"
        single-line
        hide-details
      ></v-text-field>

      <v-btn color="primary" class="my-4">
        Compare
      </v-btn>
    </div>
    <div v-if="showTitle" class="attachment-section-title">{{title}}</div>
    <v-expansion-panels accordion multiple flat class=".rounded-0" v-if="!attachmentTypesLoading">
    <div v-if="attachmentTypes.length === 0">No attachments available</div>
    <v-expansion-panel v-for="type in attachmentTypes" :key="type.attachmentTypeId">
      <v-expansion-panel-header class="expansion-panel-header">
        <template v-slot:default="{ open }">
          <v-row no-gutters class="align-center" :class="{'bold' : open}">
            {{`${type.attachmentType} (${getTypeCount(type.attachmentTypeId)})`}}
            <v-spacer></v-spacer>
            <div class="expansion-panel-header-open" v-if="open"
                 key="0">
              <input
                  :id="`fileInput${type.attachmentTypeId}`"
                  type="file"
                  multiple
                  :accept="acceptedFileTypes"
                  @change='uploadDocument($event.target.files, type.attachmentTypeId)'
                  style="display: none"
                  @click.stop=""
                  ref='fileInput'
              >
              <v-btn v-if="allowUpload || forceShowUploadBtn" @click.native.stop="selectFile(type.attachmentTypeId)"
                     @dragenter="dragTypeId=type.attachmentTypeId"
                     @dragleave="dragTypeId=null"
                     @dragend="dragTypeId=null"
                     :class="{'file-hover': dragTypeId === type.attachmentTypeId}"
                     @drop.prevent="addDragDocument($event, type.attachmentTypeId)"
                     @dragover.prevent="dragTypeId=type.attachmentTypeId"
                     elevation="0" text color="primary" class="expansion-panel-btn upload-button">
                Upload
              </v-btn>

            </div>
            <span
                v-else
                key="1"
            >
                </span>
          </v-row>
        </template>
      </v-expansion-panel-header>
      <v-expansion-panel-content>
        <AttachmentsTable
            :display-type="type"
            :show-linked="linkable"
            :attachments="attachments"
        ></AttachmentsTable>
      </v-expansion-panel-content>
    </v-expansion-panel>
  </v-expansion-panels>
  </div>
</template>

<script>
import {
  getRequest,
  getRequestWithParams,
  getSnackbar,
  logError
} from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";
import orderBy from "lodash.orderby";
import {Actions} from "@/store";
import AttachmentsTable from "@/views/flow/components/AttachmentsTable";
import constants from "@/helpers/constants";

export default {
  name: "AttachmentsFolderList",
  components: {
    AttachmentsTable
  },
  props: {
    projectId: Number,
    objectTypeId: Number,
    userId: Number,
    contactId: Number,
    orgId: Number,
    allowUpload: Boolean,
    linkable: Boolean,
    focused: Boolean,
    showTitle: Boolean,
    title: String,
    activityTab: Boolean, //this tells us whether to show the search and compare buttons
    forceShowUploadBtn: Boolean
  },
  data () {
    return {
      processStepId: null,
      eventId: null,
      projectProcessStepId: null,
      projectProcessStepEventId: null,
      attachmentTypes: [],
      attachments: [],
      dragTypeId: null,
      attachmentTypesLoading: true,
      error: {},
      maxFiles: constants.MAX_FILE_UPLOADS,
      renderTicker: 0,
      acceptedFileTypes: constants.STANDARD_IMAGES_AND_DOCS,
      companyId: this.$store.state.user.details.companyId,
      headers: [
        { text: null, value: 'fileIcon', show: true },
        { text: null, value: 'filename', show: true },
        { text: null, value: 'icons', show: true },
      ],
      search: ''
    }
  },
  watch: {
    focused: function() {
      this.loadAllPageDetails()
    },
    // // whenever pps id changes, this function will run
    '$route.params.processStepId': async function () {
      // reset the selected item
      this.updateProcessStepAndEventIds()
      this.loadAllPageDetails()
    },
    // // whenever pps event id changes, this function will run
    '$route.params.ppsEventId': async function () {
      // reset the selected item
      this.updateProcessStepAndEventIds()
      this.loadAllPageDetails()
    },
    // // whenever the project store forces a reload - do this
    // '$store.state.project.forceReloadKey': async function () {
    //   // reset the selected item
    //   this.updateProcessStepAndEventIds()
    //   this.loadAllPageDetails()
    // }
  },
  created () {
    this.updateProcessStepAndEventIds();
    this.loadAllPageDetails();
  },
  computed: {

  },
  methods: {
    updateProcessStepAndEventIds(){
      this.processStepId = this.$route.query.processStepId
      this.projectProcessStepId = parseInt(this.$route.params.processStepId) || null
      this.projectProcessStepEventId = parseInt(this.$route.params.ppsEventId) || null
    },
    loadAllPageDetails() {
      // if (this.projectProcessStepEventId) {
      //   this.typePath = `/project/${this.projectId}/pps/${this.projectProcessStepId}/eventTypesByPpsEventId/${this.projectProcessStepEventId}`
      //   this.attachmentPath = `/projectProcessStep/${this.projectProcessStepId}/event/${this.projectProcessStepEventId}/attachments`
      // } else if (this.projectProcessStepId) {
      //   this.typePath = `/project/${this.projectId}/processStepTypes/${this.projectProcessStepId}`
      //   this.attachmentPath = `/projectProcessStep/${this.projectProcessStepId}/attachments`
      // } else if (this.projectId) {
      //   this.typePath = '/projectTypes'
      //   this.attachmentPath = `/project/${this.projectId}/attachments`
      // } else if (this.objectTypeId === 3) {
      //   //user
      //   this.typePath = `/objectTypes/user`
      //   this.attachmentPath = `/user/${this.userId}/attachments`
      // } else if (this.objectTypeId === 2) {
      //   //contact
      //   this.typePath = `/objectTypes/contact`
      //   this.attachmentPath = `/contact/${this.contactId}/attachments`
      // } else if (this.objectTypeId === 5) {
      //   //org
      //   this.typePath = `/objectTypes/org`
      //   this.attachmentPath = `/org/${this.orgId}/attachments`
      // }
      //this part has to completely change

      if(this.projectProcessStepEventId) {
        this.typePath = `/eventTypesByPpsEventId/${this.projectProcessStepEventId}`
        this.attachmentPath = `/projectProcessStep/${this.projectProcessStepId}/event/${this.projectProcessStepEventId}/attachments`
      } else if(this.projectProcessStepId) {
        this.typePath = `/processStepTypes/${this.projectProcessStepId}`
        this.attachmentPath = `/projectProcessStep/${this.projectProcessStepId}/attachments`
      } else if(this.projectId) {
        this.typePath = `/objectType/project`
        this.attachmentPath = `/project/${this.projectId}/attachments`
      } else if (this.objectTypeId === 2) {
        //contact
        this.typePath = `/objectType/contact`
        this.attachmentPath = `/contact/${this.contactId}/attachments`
      } else if (this.objectTypeId === 5) {
        //org
        this.typePath = `/objectType/org`
        this.attachmentPath = `/org/${this.orgId}/attachments`
      } else if (this.objectTypeId === 3) {
        //user
        this.typePath = `/objectType/user`
        this.attachmentPath = `/user/${this.userId}/attachments`
      }

      if(this.typePath && this.attachmentPath) {
        this.fetchAttachmentTypes()
        this.fetchAttachments()
      }
    },
    fetchAttachmentTypes: async function () {
      this.attachmentTypesLoading = true
      const {data} = await getRequestWithParams(`/attachmentType${this.typePath}`, { params: {
          linkable: this.linkable,
          allowUpload: this.allowUpload,
          focused: this.focused
        }})
      this.attachmentTypes = data
      this.attachmentTypesLoading = false
    },
    fetchAttachments: async function () {
      const {data} = await getRequest(this.attachmentPath, null, [])
      data.forEach(d => {
        let tempFileName = d.filename.substr(0, d.filename.lastIndexOf('.'))
        d.editableName = tempFileName !== null && tempFileName !== '' ? tempFileName : d.filename
        //adding this "copy" so that if they edit a name then click cancel we dont update the ui with their change
        d.editableNameCopy = d.editableName
      })

      this.attachments = orderBy(data,  [a => a.dateCreated], 'desc')
    },
    getTypeCount: function(typeId) {
      try {
        return this.attachments.filter(a => a.attachmentTypeId === typeId && !a.archived && a.linked === this.linkable)?.length || 0
      } catch {
        return 0
      }
    },
    addDragDocument: async function (e, attachmentTypeId) {
      let files = e.dataTransfer.files
      await this.uploadDocument(files, attachmentTypeId)
    },
    selectFile: function(typeId){
      document.getElementById(`fileInput${typeId}`)?.click();
    },
    uploadDocument: async function (files, attachmentTypeId) {
      if (files?.length > this.maxFiles) {
        this.snackbar = getSnackbar('ERROR', `Cannot upload more than ${this.maxFiles} files at one time. Please try again and select fewer files.`)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } else if (files?.length > 0) {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          //reset error message when trying to upload new file
          this.error = {}
          // @TODO: The actions needs to change when genericising this component. Writing this line made me feel dirty
          for (let i = 0; i < files.length; ++i) {
            let file = files[i];
            if (file && file.size > 0) {
              await this.$store.dispatch(null != this.projectProcessStepEventId ? Actions.PROJECT_PROCESS_STEP_EVENT_FILE_UPLOAD :
                  null != this.projectProcessStepId ? Actions.PROJECT_PROCESS_STEP_FILE_UPLOAD :
                      (this.projectId) ? Actions.PROJECT_FILE_UPLOAD :
                          Actions.OBJECT_TYPE_FILE_UPLOAD, {
                file,
                attachmentTypeId: attachmentTypeId,
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
        //adding this "copy" so that if they edit a name then click cancel we dont update the ui with their change
        newAttachment.editableNameCopy = newAttachment.editableName
        this.snackbar = getSnackbar('SUCCESS', 'Document Uploaded')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.attachments = [...this.attachments, newAttachment]
      }
      this.$store.commit(AppMutations.SET_LOADING, false)
    }
  }
}
</script>

<style lang="scss" scoped>
.expansion-panel-header{
  font-size: 14px;
  color: var(--v-primaryText-base);
}

.bold {
  font-weight: bold;
}

.expansion-panel-header-open{
  display: flex;
  align-items: center;
}

.expansion-panel-btn {
  font-size: 12px;
  font-weight: bold;
  text-transform: capitalize;
  margin: 0;
}

.file-hover {
  background: #EEF0F4 !important;
}

.theme--light.v-btn.v-btn--disabled.v-btn--has-bg {
  background-color: transparent !important;
}

.attachment-section-title {
  font-weight: 700;
  font-size: 18px;
}
</style>
