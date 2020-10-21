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
        <v-col cols="6" class="text-left" pb-0>
          <v-btn @click="displayType = null">Back</v-btn>
        </v-col>
        <v-col cols="6" class="pb-0">
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
            class="type"
            v-for="a in drillDownAttachments"
          >
            <div class="text-right">
              <v-dialog
                v-model="a.deleteConfirm"
                width="500">
                <template #activator="{ on }">
                  <v-btn x-small text v-on="on">
                    <v-icon>close</v-icon>
                  </v-btn>
                </template>
                <v-card>
                  <v-card-title
                    class="headline grey lighten-2"
                    primary-title>
                    Confirm
                  </v-card-title>

                  <v-card-text class="pt-4">
                    Are you sure you want to delete <strong>{{a.filename}}</strong>?
                  </v-card-text>

                  <v-divider></v-divider>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn
                      @click="a.deleteConfirm = false">
                      No
                    </v-btn>
                    <v-btn
                      color="primaryCustom"
                      text
                      @click="[a.archived = true, deleteAttachment(a.id)]">
                      Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>
            </div>
            <div class=" d-flex flex-wrap justify-center">
              <v-btn
                width="100%"
                icon
                text
                :href="a.presignedUrl" class="type">
                <v-icon x-large color="grey">insert_drive_file</v-icon>
              </v-btn>
              <a :href="a.presignedUrl" class="type link text-center">{{ a.filename }}</a>
            </div>
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
import {getRequest, getRequestWithParams, logError, getSnackbar} from '@/helpers/helpers'
import {deleteAttachment} from '@/services/attachmentService'

// @TODO: need to generisize this so it can be used for any object type (project, process step, contact, user, org)

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
        return this.attachments.filter(a => !a.archived && a.attachmentTypeId === this.displayType.attachmentTypeId)
      }
    }
  },
  methods: {
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
      this.attachments = data
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
