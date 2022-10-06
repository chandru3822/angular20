<template>
  <div id="attachment-folder-list">
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
    <v-dialog persistent width="90%" v-model="showCompareModal">
      <AttachmentCompareModal :show-modal="showCompareModal"
                              :attachments="selectedAttachmentsForCompare"
                              :close-callback="closeCompareModal">
      </AttachmentCompareModal>
    </v-dialog>
    <div v-if="loadingDetails" class="one-hunned text-center">
      <SpinnerInline :size="40" color="primary"/>
    </div>
    <div v-else-if="attachmentTypes.length > 0" :class="{'px-3': isCard}">
      <div v-if="activityTab" class="px-5 sticky-compare-bar">
        <v-text-field
          v-model="search"
          prepend-inner-icon="search"
          clearable
          label="Search all project documents"
          single-line
          hide-details
        ></v-text-field>

        <v-btn class="my-4 mr-3" small @click="compare = false" v-if="compare">
          Cancel Comparison
        </v-btn>
        <v-btn color="primary" small class="my-4" @click="showCompareModal = true" v-if="compare"
               :disabled="selectedAttachmentsForCompare.length === 0">
          Confirm Comparison
        </v-btn>
        <v-btn small color="primary" class="my-4" @click="compare = true" v-else>
          Compare
        </v-btn>
      </div>
      <v-toolbar v-if="title" dense color="transparent" class="elevation-0 process-step-toolbar cfg-name-toolbar">
        <v-toolbar-title :class="{'albatross-header-4-new': !this.smallTitle,
                                  'albatross-body-2': this.smallTitle}">
          {{ title }}
        </v-toolbar-title>
      </v-toolbar>
      <v-card class="text-left square-card" :class="{'elevation-0': !isCard}">
        <v-expansion-panels accordion multiple flat class=".rounded-0 condensed" v-if="!attachmentTypesLoading">
          <v-expansion-panel v-for="(type, index) in attachmentTypes" :key="type.attachmentTypeId">
            <v-expansion-panel-header class="albatross-body-1">
              <template v-slot:default="{ open }">
                <v-row v-if="(allowUpload || forceShowUploadBtn)"
                       class="file-hover d-flex"
                       :class="{'file-hover-active': dragTypeId === type.attachmentTypeId, 'file-hover-inactive': dragTypeId === null || dragTypeId !== type.attachmentTypeId}"
                       @dragenter="(allowUpload || forceShowUploadBtn) ? dragTypeId = type.attachmentTypeId : dragTypeId = null"
                       @dragend="dragTypeId = null"
                       @dragleave="dragTypeId = null"
                       @drop.prevent="addDragDocument($event, type)"
                       @dragover.prevent="(allowUpload || forceShowUploadBtn) ? dragTypeId = type.attachmentTypeId : dragTypeId = null"
                >
                  <v-icon class="child-drag-elements" color="primary">upload</v-icon>
                </v-row>
                <v-row no-gutters class="align-center" :class="{'bold' : open}">
                  <v-icon class="mr-3" :color="dragTypeId===type.attachmentTypeId ? 'grey lighten-1' : 'grey darken-1'">
                    folder
                  </v-icon>
                  {{ `${type.attachmentType} (${getTypeCount(type.attachmentTypeId)})` }}
                  <v-spacer></v-spacer>

                  <input
                    :id="`fileInput${type.attachmentTypeId}`"
                    type="file"
                    :accept="acceptedFileTypes"
                    @change='doUpload($event.target.files, type)'
                    style="display: none"
                    @click.stop=""
                    :ref="`fileInput${type.attachmentTypeId}`"
                  >
                  <div class="expansion-panel-header-open" v-if="open"
                       key="0">
                  </div>
                  <span
                    v-else
                    key="1"
                  >
                </span>
                  <v-btn v-if="allowUpload || forceShowUploadBtn" @click.native.stop="selectFile(type.attachmentTypeId)"
                         elevation="0" text color="primary" class="text-capitalize"
                         :disabled="dragTypeId === type.attachmentTypeId">
                    Upload
                  </v-btn>
                </v-row>
              </template>
            </v-expansion-panel-header>
            <v-expansion-panel-content>
              <AttachmentsTable
                :search="search"
                :display-type="type"
                :allow-upload="allowUpload || forceShowUploadBtn"
                :load-linked="loadLinked"
                :attachments="attachments"
                :projectId="projectId"
                :projectProcessStepId="projectProcessStepId"
                :userId="userId"
                :contactId="contactId"
                :compare="!allowUpload && !loadLinked && compare"
                :orgId="orgId"
                :objectTypeId="objectTypeId"
                :projectProcessStepEventId="projectProcessStepEventId"
                :compare-callback="toggleAttachmentToCompare"
                :delete-callback="attachmentDeleted"
                :count-selected="selectedAttachmentsForCompare.length"
              ></AttachmentsTable>
            </v-expansion-panel-content>
            <v-divider v-if="index !== attachmentTypes.length - 1" class="mx-3"></v-divider>
          </v-expansion-panel>
        </v-expansion-panels>
      </v-card>

    </div>
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
import {ProjectMutations} from "@/stores/ProjectStore";
import SpinnerInline from '@/components/SpinnerInline'
import cloneDeep from 'lodash.clonedeep'

export default {
  name: "AttachmentsFolderList",
  components: {
    AttachmentsTable,
    AttachmentCoversheetModal,
    AttachmentCompareModal,
    SpinnerInline
  },
  props: {
    allowUpload: Boolean,
    loadLinked: Boolean,
    focused: Boolean,
    smallTitle: Boolean,
    title: String,
    activityTab: Boolean, //this tells us whether to show the search and compare buttons
    forceShowUploadBtn: Boolean,
    projectId: Number,
    userId: Number,
    contactId: Number,
    orgId: Number,
    objectTypeId: Number,
    isCard: Boolean,
    reloadOnKeyChange: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      processStepId: null,
      eventId: null,
      tempFile: {},
      fileToUpload: null,
      loadingDetails: true,
      projectProcessStepId: null,
      projectProcessStepEventId: null,
      selectedAttachmentsForCompare: [],
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
        {text: null, value: 'fileIcon', show: true},
        {text: null, value: 'filename', show: true},
        {text: null, value: 'icons', show: true},
      ],
      search: '',
      compare: false,
      showCompareModal: false,
    }
  },
  watch: {
    focused: function () {
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
      if (this.reloadOnKeyChange) {
        // reset the selected item
        this.updateProcessStepAndEventIds()
        this.loadAllPageDetails()
      }
    }
  },
  created() {
    this.updateProcessStepAndEventIds();
    this.loadAllPageDetails();
  },
  computed: {},
  mounted() {
    if (this.loadLinked) {
      //if in the linked section and a new record was linked, add it here
      this.$root.$on('newAttachmentLinked', data => {
        let clone = cloneDeep(data)
        clone.linked = true //if you dont clone it here then it updates the root obj in the calling fn which borks stuff
        this.attachments.push(clone)
      })
      //if in the linked section and a linked attachment is archived, remove it
      this.$root.$on('attachmentDeleted', id => {
        this.attachments = this.attachments.filter(a => a.id !== id)
      })
    }
  },
  methods: {
    closeCoversheet(attachmentTypeId) {
      this.showCoversheetModal = false
      //if you cancel the coversheet the file-input files prop is not getting reset. do manually here
      //could not get it to reset using the vue $ref stuff. but this way with getElementById does work
      document.getElementById(`fileInput${attachmentTypeId}`).value = null
    },
    closeCompareModal(a) {
      if (a && null != a.id) {
        //use if compare modal needs to close and the coversheet needs to open
        this.tempFile = a
        this.showCoversheetModal = true
      }
      this.showCompareModal = false
    },
    toggleAttachmentToCompare(attachment) {
      if (attachment.compare) {
        this.selectedAttachmentsForCompare.push(attachment)
      } else {
        this.selectedAttachmentsForCompare = this.selectedAttachmentsForCompare.filter(a => a.id !== attachment.id)
      }
    },
    attachmentDeleted(id) {
      this.attachments = this.attachments.filter(a => a.id !== id)
    },
    fileUploaded(attachment, error) {
      if (error) {
        this.snackbar = getSnackbar('ERROR', error.message)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } else {
        this.attachments.push(attachment)
        if(!this.forceShowUploadBtn) {
          //so far, if forceShowUploadBtn, then it is on org, user, contact, etc so it is already where it needs to be and doesn't need to refresh again
          //this value tells the right pane to update when a file is uploaded
          this.$store.commit(ProjectMutations.INCREMENT_RELOAD_KEY)
        }
      }
      this.$store.commit(AppMutations.SET_LOADING, false)
    },
    updateProcessStepAndEventIds() {
      this.processStepId = this.$route.query.processStepId
      this.projectProcessStepId = parseInt(this.$route.params.processStepId) || null
      this.projectProcessStepEventId = parseInt(this.$route.params.ppsEventId) || null
    },
    async loadAllPageDetails() {
      //if not objectTypeId(org,contact,user) and should be "all" then use these endpoints to get combined list
      this.loadingDetails = true
      let params = {}
      if ((!this.objectTypeId || this.objectTypeId === 1) && !this.allowUpload && !this.loadLinked) {
        this.typePath = `/combined/project`
        this.attachmentPath = `/project/${this.projectId}/combinedAttachments`
        params.ppsEventId = this.projectProcessStepEventId
        params.ppsId = this.projectProcessStepId
      } else {
        if (this.projectProcessStepEventId) {
          this.typePath = `/eventTypesByPpsEventId/${this.projectProcessStepEventId}`
          this.attachmentPath = `/projectProcessStep/${this.projectProcessStepId}/event/${this.projectProcessStepEventId}/attachments`
        } else if (this.projectProcessStepId) {
          this.typePath = `/processStepTypes/${this.projectProcessStepId}`
          this.attachmentPath = `/projectProcessStep/${this.projectProcessStepId}/attachments`
        } else if (this.projectId) {
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

      //if focused then override attachment path to get all in project
      // if (this.focused) {
      //   this.attachmentPath = `/project/${this.projectId}/combinedAttachments`
      //   params.ppsEventId = this.projectProcessStepEventId
      //   params.ppsId = this.projectProcessStepId
      // }

      if (this.typePath && this.attachmentPath) {
        let requests = [this.fetchAttachmentTypes(params), this.fetchAttachments(params)]
        await Promise.all(requests)
      }
      this.loadingDetails = false
    },
    fetchAttachmentTypes: async function (typeParams) {
      this.attachmentTypesLoading = true
      const {data} = await getRequestWithParams(`/attachmentType${this.typePath}`, {
        params: {
          ...typeParams,
          linkable: this.loadLinked,
          allowUpload: this.allowUpload,
          focused: this.focused
        }
      })
      this.attachmentTypes = data
      this.attachmentTypesLoading = false
    },
    fetchAttachments: async function (extraParams) {
      const {data} = await getRequestWithParams(this.attachmentPath, {
        params: {
          ...extraParams,
          linked: this.loadLinked
        }
      })
      data.forEach(d => {
        let tempFileName = d.filename.substr(0, d.filename.lastIndexOf('.'))
        d.editableName = tempFileName !== null && tempFileName !== '' ? tempFileName : d.filename
        //adding this "copy" so that if they edit a name then click cancel we dont update the ui with their change
        d.editableNameCopy = d.editableName
      })

      this.attachments = orderBy(data, [a => a.dateCreated], 'desc')
    },
    getTypeCount: function (typeId) {
      try {
        return this.attachments.filter(a => {
          return a.attachmentTypeId === typeId && !a.archived && a.linked === this.loadLinked
            && ((this.search != null && this.search !== '') ? a.filename.toLowerCase().includes(this.search.toLowerCase()) : true)
        })?.length || 0
      } catch {
        return 0
      }
    },
    addDragDocument: async function (e, type) {
      this.dragTypeId = null
      if (this.allowUpload || this.forceShowUploadBtn) {
        let files = e.dataTransfer.files
        await this.doUpload(files, type)
      }
    },
    selectFile: function (typeId) {
      document.getElementById(`fileInput${typeId}`)?.click();
    },
    async doUpload(files, type) {
      if (files?.length > 0) {
        let file = files[0]
        if (type.hasFieldsAssigned) {
          this.setTempFile(file, type)
        } else {
          await this.uploadDocument(file, type)
        }
      }
    },
    setTempFile: function (file, type) {
      this.tempFile = {}
      this.fileToUpload = null
      //we dont upload new files until after they fill in custom fields, need to pass file to next screen
      this.fileToUpload = file
      this.tempFile.attachmentTypeId = type.attachmentTypeId
      this.tempFile.attachmentType = type.attachmentType
      let displayName = this.fileToUpload.name.substr(0, this.fileToUpload.name.lastIndexOf('.'))
      this.tempFile.displayName = displayName
      this.showCoversheetModal = true
    },
    uploadDocument: async function (file, type) {
      //this should only get called if the attachment type doesn't have any native fields
      try {
        //reset error message when trying to upload new file
        this.error = {}
        if (file && file.size > 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          let displayName = file.name.substr(0, file.name.lastIndexOf('.'))
          await this.$store.dispatch(null != this.projectProcessStepEventId ? Actions.PROJECT_PROCESS_STEP_EVENT_FILE_UPLOAD :
            null != this.projectProcessStepId ? Actions.PROJECT_PROCESS_STEP_FILE_UPLOAD :
              (this.projectId) ? Actions.PROJECT_FILE_UPLOAD :
                Actions.OBJECT_TYPE_FILE_UPLOAD, {
            file,
            attachmentTypeId: type.attachmentTypeId,
            displayName,
            projectId: this.projectId,
            projectProcessStepId: this.projectProcessStepId,
            userId: this.userId,
            contactId: this.contactId,
            orgId: this.orgId,
            objectTypeId: this.objectTypeId,
            projectProcessStepEventId: this.projectProcessStepEventId,
            callback: this.fileUploaded
          })
        }
      } catch (e) {
        this.$store.commit(AppMutations.SET_LOADING, false)
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }

    },
  }
}
</script>

<style lang="scss">

</style>

<style lang="scss" scoped>
.sticky-compare-bar {
  position: sticky;
  top: 0;
  z-index: 2;
  background: white;
}

.v-expansion-panels.condensed .v-expansion-panel-header {
  padding-top: 6px;
  padding-bottom: 6px;
  min-height: auto;
}
.v-expansion-panels.condensed
.v-expansion-panel--active
.v-expansion-panel-header {
  padding-top: 12px;
  padding-bottom: 12px;
}
.v-expansion-panels.condensed .v-expansion-panel--active:not(:first-child),
.v-expansion-panels.condensed .v-expansion-panel--active + .v-expansion-panel {
  margin-top: 2px;
}


.bold {
  font-weight: bold;
}

.expansion-panel-header-open {
  display: flex;
  align-items: center;
}

.file-hover {
  width: inherit;
  position: absolute;
  height: 100%;
  margin: -24px;
  padding: 24px;

  i {
    width: 100%;
  }
}

.file-hover-inactive {
  hidden: true;

  i {
    display: none;
  }
}

.file-hover-active {
  hidden: false;
  background-color: rgba(#e3eff7, 90%);

  i {
    display: inline-flex;
  }
}

.theme--light.v-btn.v-btn--disabled.v-btn--has-bg {
  background-color: transparent !important;
}

.child-drag-elements {
  pointer-events: none;
}
</style>
