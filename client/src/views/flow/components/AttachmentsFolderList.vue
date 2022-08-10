<template>
  <div>
    <v-dialog persistent :width="1000" v-model="showCoversheetModal"
              content-class="coversheet-modal-content">
      <AttachmentCoversheetModal :existing-attachment="tempFile"
                                 :file="fileToUpload"
                                 :show-modal="showCoversheetModal"
                                 :close-callback="closeCoversheet"
                                 :file-uploaded-callback="fileUploaded"
                                 :projectId="projectId"
                                 :projectProcessStepId="projectProcessStepId"
                                 :userId="userId"
                                 :contactId="contactId"
                                 :orgId="orgId"
                                 :objectTypeId="objectTypeId"
                                 :projectProcessStepEventId="projectProcessStepEventId"
      >
      </AttachmentCoversheetModal>
    </v-dialog>
    <v-dialog persistent :width="1000" v-model="showCompareModal">
      <AttachmentCompareModal :show-modal="showCompareModal"
                              :close-callback="closeCompareModal">
      </AttachmentCompareModal>
    </v-dialog>
    <div v-if="activityTab" class="px-5">
      <v-text-field
        v-model="search"
        prepend-inner-icon="search"
        label="Search all project documents"
        single-line
        hide-details
      ></v-text-field>

      <v-btn class="my-4" @click="compare = false" v-if="compare">
        Cancel Comparison
      </v-btn>
      <v-btn color="primary" class="my-4" @click="showCompareModal = true" v-if="compare">
        Confirm Comparison
      </v-btn>
      <v-btn color="primary" class="my-4" @click="compare = true" v-else>
        Compare
      </v-btn>
    </div>
    <div v-if="attachmentTypes.length === 0" class="text-center albatross-body-2">No attachments available</div>
    <v-card v-else class="text-left square-card" :class="{'elevation-0': !isCard || attachments.length === 0}">
    <v-expansion-panels accordion multiple flat class=".rounded-0" v-if="!attachmentTypesLoading">
    <v-expansion-panel v-for="(type, index) in attachmentTypes" :key="type.attachmentTypeId">
      <v-expansion-panel-header class="albatross-body-1">
        <template v-slot:default="{ open }">
          <v-row no-gutters class="align-center" :class="{'bold' : open}">
           <v-icon color="grey darken-1" class="mr-3">folder</v-icon> {{`${type.attachmentType} (${getTypeCount(type.attachmentTypeId)})`}}
            <v-spacer></v-spacer>
            <div class="expansion-panel-header-open" v-if="open"
                 key="0">
              <input
                  :id="`fileInput${type.attachmentTypeId}`"
                  type="file"
                  :accept="acceptedFileTypes"
                  @change='setTempFile($event.target.files, type)'
                  style="display: none"
                  @click.stop=""
                  ref='fileInput'
              >
            </div>
            <span
                v-else
                key="1"
            >
                </span>
            <v-btn v-if="allowUpload || forceShowUploadBtn" @click.native.stop="selectFile(type.attachmentTypeId)"
                   @dragenter="dragTypeId=type.attachmentTypeId"
                   @dragleave="dragTypeId=null"
                   @dragend="dragTypeId=null"
                   :class="{'file-hover': dragTypeId === type.attachmentTypeId}"
                   @drop.prevent="addDragDocument($event, type)"
                   @dragover.prevent="dragTypeId=type.attachmentTypeId"
                   elevation="0" text color="primary" class="text-capitalize">
              Upload
            </v-btn>
          </v-row>
        </template>
      </v-expansion-panel-header>
      <v-expansion-panel-content>
        <AttachmentsTable
            :search="search"
            :display-type="type"
            :allow-upload="allowUpload"
            :show-linked="linkable"
            :attachments="attachments"
            :projectId="projectId"
            :projectProcessStepId="projectProcessStepId"
            :userId="userId"
            :contactId="contactId"
            :compare="!allowUpload && !linkable && compare"
            :orgId="orgId"
            :objectTypeId="objectTypeId"
            :projectProcessStepEventId="projectProcessStepEventId"
        ></AttachmentsTable>
      </v-expansion-panel-content>
      <v-divider v-if="index != attachmentTypes.length - 1" class="mx-3"></v-divider>
    </v-expansion-panel>
  </v-expansion-panels>
    </v-card>

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
import AttachmentCoversheetModal from '@/views/flow/components/AttachmentCoversheetModal'
import AttachmentCompareModal from '@/views/flow/components/AttachmentCompareModal'
import constants from "@/helpers/constants";

export default {
  name: "AttachmentsFolderList",
  components: {
    AttachmentsTable,
    AttachmentCoversheetModal,
    AttachmentCompareModal
  },
  props: {
    allowUpload: Boolean,
    linkable: Boolean,
    focused: Boolean,
    activityTab: Boolean, //this tells us whether to show the search and compare buttons
    forceShowUploadBtn: Boolean,
    projectId: Number,
    userId: Number,
    contactId: Number,
    orgId: Number,
    objectTypeId: Number,
    isCard: Boolean
  },
  data () {
    return {
      processStepId: null,
      eventId: null,
      tempFile: {},
      fileToUpload: null,
      projectProcessStepId: null,
      projectProcessStepEventId: null,
      attachmentTypes: [],
      attachments: [],
      dragTypeId: null,
      showCoversheetModal: false,
      coversheetSelectedTypeId: null,
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
      search: '',
      compare: false,
      showCompareModal: false,
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
    // // whenever the project store forces a reload - do this - i cant remember why atm
    '$store.state.project.forceReloadKey': async function () {
      // reset the selected item
      this.updateProcessStepAndEventIds()
      this.loadAllPageDetails()
    }
  },
  created () {
    this.updateProcessStepAndEventIds();
    this.loadAllPageDetails();
  },
  computed: {

  },
  methods: {
    closeCoversheet() {
      this.showCoversheetModal = false
    },
    closeCompareModal() {
      this.showCompareModal = false
    },
    fileUploaded(attachment) {
      console.log('file was uploaded',attachment)
      this.attachments.push(attachment)
    },
    updateProcessStepAndEventIds(){
      this.processStepId = this.$route.query.processStepId
      this.projectProcessStepId = parseInt(this.$route.params.processStepId) || null
      this.projectProcessStepEventId = parseInt(this.$route.params.ppsEventId) || null
    },
    loadAllPageDetails() {
      //if not objectTypeId(org,contact,user) and should be "all" then use these endpoints to get combined list
      if((!this.objectTypeId || this.objectTypeId === 1) && !this.focused && !this.allowUpload && !this.linkable) {
        this.typePath = `/combined/project`
        this.attachmentPath = `/project/${this.projectId}/combinedAttachments`
      } else {
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
      }

      //if focused override attachment path to get all in project
      if(this.focused) {
        this.attachmentPath = `/project/${this.projectId}/combinedAttachments`
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
      const {data} = await getRequestWithParams(this.attachmentPath, { params: {
          linked: this.linkable
        }})
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
        return this.attachments.filter(a => {
          return a.attachmentTypeId === typeId && !a.archived && a.linked === this.linkable
            && ((this.search != null && this.search !== '') ? a.filename.toLowerCase().includes(this.search.toLowerCase()) : true)
        })?.length || 0
      } catch {
        return 0
      }
    },
    addDragDocument: async function (e, type) {
      let files = e.dataTransfer.files
      await this.setTempFile(files, type)
    },
    selectFile: function(typeId){
      document.getElementById(`fileInput${typeId}`)?.click();
    },
    setTempFile: function(files, type) {
      this.tempFile = {}
      this.fileToUpload = null
      if(files?.length > 0) {
        //we dont upload new files until after they fill in custom fields, need to pass file to next screen
        this.fileToUpload = files[0]
        this.tempFile.attachmentTypeId = type.attachmentTypeId
        this.tempFile.attachmentType = type.attachmentType
        let displayName = this.fileToUpload.name.substr(0, this.fileToUpload.name.lastIndexOf('.'))
        this.tempFile.displayName = displayName
        console.log('name',displayName)
        this.showCoversheetModal = true
      }
    }
  }
}
</script>

<style lang="scss" scoped>

.bold {
  font-weight: bold;
}

.expansion-panel-header-open{
  display: flex;
  align-items: center;
}

.file-hover {
  background: #EEF0F4 !important;
}

.theme--light.v-btn.v-btn--disabled.v-btn--has-bg {
  background-color: transparent !important;
}
</style>
