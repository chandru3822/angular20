<template>
  <div>
    <v-expansion-panels accordion multiple flat class=".rounded-0">
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
                    :id="`fileInput${type.attachmentTypeId}`"
                    type="file"
                    multiple
                    :accept="acceptedFileTypes"
                    @change='uploadDocument($event.target.files, type.attachmentTypeId)'
                    style="display: none"
                    @click.stop=""
                    ref='fileInput'
                >
                <v-btn @click.native.stop="selectFile(type.attachmentTypeId)"
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
              ></span>
            </v-row>
          </template>
        </v-expansion-panel-header>
        <v-expansion-panel-content>
          <AttachmentsTable
              :display-type="type"
              :attachments="attachments"
              :show-non-primary-docs="true"
              :allow-edit="false"
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
  name: "AhjAttachments",
  components: {
    AttachmentsTable
  },
  data () {
    return {
      dragTypeId: null,
      error: {},
      maxFiles: 1,
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
    attachmentTypes: Array,
    attachments: Array,
    sourceId: Number,
    userCanEdit: Boolean,
    objectTypeId: Number,
    userId: Number,
    contactId: Number,
    orgId: Number,
  },
  watch: {
    attachments(){
      console.log(this.attachments)
}
  },
  created () {
  },
  computed: {

  },
  methods: {
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
    selectFile: function(typeId){
      document.getElementById(`fileInput${typeId}`)?.click();
    },
    uploadDocument: async function (files, attachmentTypeId) {
      if (files?.length > this.maxFiles) {
        this.snackbar = getSnackbar('ERROR', `Cannot upload more than ${this.maxFiles} files at one time. Please try again and select fewer files.`)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } else if (files?.length > 0) {
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          await this.$store.dispatch(Actions.FILE_UPLOAD, {
            file: files[0],
            attachmentTypeId: attachmentTypeId,
            sourceId: this.sourceId,
            deleteFirst: false,
            callback: async (document) => {
              this.attachments.push(document)
              this.snackbar = getSnackbar('SUCCESS', 'Successfully uploaded document')
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            }
          })
        } catch(e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error uploading document')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
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
</style>
