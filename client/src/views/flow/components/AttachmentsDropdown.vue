<template>
  <div>
    <v-expansion-panels accordion multiple flat class=".rounded-0" v-if="!attachmentTypesLoading">
    <div v-if="!attachmentTypes.length">No attachments available</div>
    <v-expansion-panel v-for="type in attachmentTypes" :key="type.attachmentTypeId">
      <v-expansion-panel-header class="expansion-panel-header">
        <template v-slot:default="{ open }">
          <v-row no-gutters class="align-center" :class="{'bold' : open}">
            {{`${type.attachmentType} (${getTypeCount(type.attachmentTypeId)})`}}
            <v-spacer></v-spacer>
            <div class="expansion-panel-header-open" v-if="open"
                 key="0">
              <input
                  id="fileInput"
                  type="file"
                  multiple
                  :accept="acceptedFileTypes"
                  @change='uploadDocument($event.target.files, type.attachmentTypeId)'
                  style="display: none"
                  @click.stop=""
                  ref='fileInput'
              >
              <v-btn v-if="!type.readOnly || !!projectProcessStepId" @click.native.stop="selectFile"
                     @dragenter="dragTypeId=type.attachmentTypeId"
                     @dragleave="dragTypeId=null"
                     @dragend="dragTypeId=null"
                     :class="{'file-hover': dragTypeId === type.attachmentTypeId}"
                     @drop.prevent="addDragDocument($event, type.attachmentTypeId)"
                     @dragover.prevent="dragTypeId=type.attachmentTypeId"
                     elevation="0" color="transparent" class="expansion-panel-btn upload-button">
                Upload
              </v-btn>

              <v-btn
                  v-if="!projectProcessStepId && getNonPrimaryCount(type.attachmentTypeId) != 0"
                  @click.native.stop="type.showNonPrimary = !type.showNonPrimary"
                  elevation="0"

                  class="expansion-panel-btn"
              >
                <span v-if="type.showNonPrimary">Hide non-primary</span>
                <span v-else>Show non-primary</span>
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
            :attachments="attachments"
            :show-non-primary-docs="type.showNonPrimary || !!projectProcessStepId"
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
  name: "AttachmentsDropdown",
  components: {
    AttachmentsTable
  },
  data () {
    return {
      processStepId: null,
      projectProcessStepId: null,
      eventId: null,
      projectProcessStepEventId: null,
      attachmentTypes: [],
      attachments: [],
      dragTypeId: null,
      attachmentTypesLoading: true,
      error: {},
      renderTicker: 0,
      acceptedFileTypes: constants.STANDARD_IMAGES_AND_DOCS,
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
    objectTypeId: Number,
    userId: Number,
    contactId: Number,
    orgId: Number,
  },
  watch: {
    // whenever pps id changes, this function will run
    '$route.params.processStepId': async function () {
      // reset the selected item
      this.updateProcessStepAndEventIds()
      this.loadAllPageDetails()
    },
    // whenever pps event id changes, this function will run
    '$route.params.ppsEventId': async function () {
      // reset the selected item
      this.updateProcessStepAndEventIds()
      this.loadAllPageDetails()
    },
    // whenever the project store forces a reload - do this
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
    updateProcessStepAndEventIds(){
      this.processStepId = this.$route.query.processStepId
      this.projectProcessStepId = parseInt(this.$route.params.processStepId) || null
      this.projectProcessStepEventId = parseInt(this.$route.params.ppsEventId) || null
    },
    loadAllPageDetails() {
      if (this.projectProcessStepEventId) {
        this.typePath = `/eventTypesByPpsEventId/${this.projectProcessStepEventId}`
        this.attachmentPath = `/projectProcessStep/${this.projectProcessStepId}/event/${this.projectProcessStepEventId}/attachments`
      } else if (this.projectProcessStepId) {
        this.typePath = `/processStepTypes/${this.processStepId}`
        this.attachmentPath = `/projectProcessStep/${this.projectProcessStepId}/attachments`
      } else if (this.projectId) {
        this.typePath = '/projectTypes'
        this.attachmentPath = `/project/${this.projectId}/attachments`
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
    toggleShowNonPrimary(){
      this.showNonPrimaryDocs = !this.showNonPrimaryDocs;
    },

    fetchAttachmentTypes: async function () {
      this.attachmentTypesLoading = true
      const {data} = await getRequestWithParams(`/attachmentType${this.typePath}`, { params: {
          projectId: this.projectId,
          companyId: this.companyId
        }})
      this.attachmentTypes = data
      this.attachmentTypesLoading = false
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
        return this.attachments.filter(a => a.attachmentTypeId === typeId && !a.archived)?.length || 0
      } catch {
        return 0
      }
    },
    getNonPrimaryCount: function(typeId) {
      try {
        return this.attachments?.filter(a => a.attachmentTypeId === typeId && !a.archived && !a.main).length || 0
      } catch {
        return 0
      }
    },
    addDragDocument: async function (e, attachmentTypeId) {
      let files = e.dataTransfer.files
      await this.uploadDocument(files, attachmentTypeId)
    },
    selectFile: function(){
      document.getElementById('fileInput')?.click();
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
              await this.$store.dispatch(null != this.projectProcessStepEventId ? Actions.PROJECT_PROCESS_STEP_EVENT_FILE_UPLOAD :
                  null != this.projectProcessStepId ? Actions.PROJECT_PROCESS_STEP_FILE_UPLOAD :
                      (this.projectId) ? Actions.PROJECT_FILE_UPLOAD :
                          Actions.OBJECT_TYPE_FILE_UPLOAD, {
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

<style scoped>
.expansion-panel-header{
  font-size: 14px;
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
</style>
