<template>
<v-expansion-panels accordion multiple>
  <v-expansion-panel v-for="type in attachmentTypes" :key="type.attachmentTypeId">
    <v-expansion-panel-header>
      <template v-slot:default="{ open }">
        <v-row no-gutters>
        {{`${type.attachmentType} (${getTypeCount(type.attachmentTypeId)})`}}
          <v-spacer></v-spacer>
        <v-fade-transition leave-absolute>
          <v-col  v-if="open"
                  key="0">
            <v-row>
                <v-btn
                  v-if="!projectProcessStepId"
                  @click.native.stop="toggleShowNonPrimary"
                >
                  Show non-primary
                </v-btn>
              <v-file-input @click.native.stop=""
                            hide-input
                            dense
                            multiple
                            ref='fileInput'
                            @change='uploadDocument($event, type.attachmentTypeId)'
              ></v-file-input>
            </v-row>
          </v-col>
          <span
              v-else
              key="1"
          >
                </span>
        </v-fade-transition>
        </v-row>
      </template>
    </v-expansion-panel-header>
    <v-expansion-panel-content>
        <AttachmentsTable
            :display-type="type"
            :attachments="attachments"
            :show-non-primary-docs="showNonPrimaryDocs || !!projectProcessStepId"
        ></AttachmentsTable>
    </v-expansion-panel-content>
  </v-expansion-panel>
</v-expansion-panels>
</template>

<script>
import {
  getRequest,
  getRequestWithParams,
  getSnackbar,
  handleHidingGlobalLoader, logError,
  putRequest
} from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";
import {deleteAttachment} from "@/services/attachmentService";
import orderBy from "lodash.orderby";
import {Actions} from "@/store";
import AttachmentsTable from "@/views/flow/components/AttachmentsTable";

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
    objectTypeId: Number,
    userId: Number,
    contactId: Number,
    orgId: Number,
  },
  watch: {
    // whenever pps id changes, this function will run
    '$route.params.processStepId': async function () {
      // reset the selected item
      this.processStepId = this.$route.query.processStepId
      this.projectProcessStepId = parseInt(this.$route.params.processStepId)
      this.projectProcessStepEventId = parseInt(this.$route.params.ppsEventId)
      this.loadAllPageDetails()
    },
  },
  created () {
    this.projectProcessStepId = parseInt(this.$route.params.processStepId)
    this.projectProcessStepEventId = parseInt(this.$route.params.ppsEventId)
    this.loadAllPageDetails();
  },
  computed: {

  },
  methods: {
    loadAllPageDetails() {
      if (this.projectProcessStepEventId) {
        console.log('ppsEventId: ' + this.projectProcessStepEventId)
        this.typePath = `/eventAndPsTypes/${this.projectProcessStepEventId}`
        this.attachmentPath = `/projectProcessStep/${this.projectProcessStepId}/event/${this.projectProcessStepEventId}/attachments`
      } else if (this.projectProcessStepId) {
        console.log('ppsId: ' + this.projectProcessStepId)
        this.typePath = `/typesForStep/${this.projectProcessStepId}`
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
        return this.attachments.filter(a => a.attachmentTypeId === typeId && !a.archived)?.length || 0
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

<style scoped>

</style>
