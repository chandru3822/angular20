<template>
<v-col v-if="attachmentTypes.length > 0">
  <v-row>
    <v-col class="text-left">
      <h3>Documents</h3>
    </v-col>
  </v-row>
  <v-sheet color="#fff" class="elevation-2">
    <v-col cols="12">
      <v-row v-if="displayType === null" class="d-flex justify-start">
        <v-col
          cols="2"
          class="type text-center"
          @click="drillDown(type)"
          v-for="type in attachmentTypes"
        >
          <v-icon x-large color="yellow accent-4">folder</v-icon>
          <div>{{ type.attachmentType }}</div>
          <div>{{`(${getTypeCount(type.attachmentTypeId)})`}}</div>
        </v-col>
      </v-row>
      <v-row v-else>
        <v-col cols="6" class="text-left">
          <v-btn @click="displayType = null">Back</v-btn>
        </v-col>
        <v-col cols="6">
            <v-file-input
              dense
              outlined
              label="Upload project document"
              @change="uploadDocument"
            />
        </v-col>
        <v-row class="d-flex flex-wrap justify-start">
          <v-col
            cols="2"
            class="type d-flex flex-wrap justify-center"
            v-for="a in drillDownAttachments"
          >
            <v-btn
              width="100%"
              icon
              text
              :href="a.presignedUrl" class="type">
              <v-icon x-large color="grey">insert_drive_file</v-icon>
            </v-btn>
            <a :href="a.presignedUrl" class="type link text-center">{{ a.filename }}</a>
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
import {getRequest, logError, getSnackbar} from '@/helpers/helpers'

// @TODO: need to generisize this so it can be used for any object type (project, process step, customer, user, org)

export default {
  name: "Attachments",
  data () {
    return {
      attachmentTypes: [],
      attachments: [],
      displayType: null,
      typePath: null,
      attachmentPath: null
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
        return this.attachments.filter(a => a.attachmentTypeId === this.displayType.attachmentTypeId)
      }
    }
  },
  methods: {
    fetchAttachmentTypes: async function () {
      const {data} = await getRequest(`/attachmentType${this.typePath}`)
      this.attachmentTypes = data
    },
    fetchAttachments: async function () {
      const {data} = await getRequest(this.attachmentPath)
      this.attachments = data
    },
    drillDown: function(type) {
     this.displayType = type
    },
    getTypeCount: function(typeId) {
      try {
        return this.attachments.filter(a => a.attachmentTypeId === typeId).length
      } catch {
        return 0
      }
    },
    uploadDocument: async function (file) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        // @TODO: The actions needs to change when genericising this component. Writing this line made me feel dirty
        await this.$store.dispatch((this.projectId) ? Actions.PROJECT_FILE_UPLOAD : Actions.PROJECT_PROCESS_STEP_FILE_UPLOAD, {
          file,
          attachmentTypeId: this.displayType.attachmentTypeId,
          projectId: this.projectId,
          projectProcessStepId: this.projectProcessStepId,
          callback: async (newAttachment) => {
            this.$store.commit(AppMutations.SET_LOADING, false)
            this.attachments = [...this.attachments, newAttachment]
          }
        })
      } catch(e) {
        this.$store.commit(AppMutations.SET_LOADING, false)
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
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
</style>
