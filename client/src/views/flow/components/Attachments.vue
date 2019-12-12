<template>
<v-col>
  <v-row>
    <v-col class="text-left">
      <h3>Documents</h3>
    </v-col>
  </v-row>
  <v-row v-if="displayType === null">
    <v-col v-for="type in attachmentTypes" class="d-flex justify-space-around">
      <v-text-field :label="type.attachmentType + '(' + getTypeCount(type.attachmentTypeId) + ')'" @click="drillDown(type)"/>
    </v-col>
  </v-row>
  <v-row v-else>
    <v-col>
     <v-row>
       <v-col class="d-flex justify-start">
         <v-btn @click="displayType = null">Back</v-btn>
       </v-col>
     </v-row>
     <v-row>
       <v-col cols="12">
         <v-file-input
           label="Upload project document"
           @change="uploadDocument"
         />
       </v-col>
       <v-col cols="12">
         <v-row>
           <v-col v-for="a in drillDownAttachments" class="d-flex justify-space-around">
             <v-btn :href="a.presignedUrl">{{ a.filename }}</v-btn>
           </v-col>
         </v-row>
       </v-col>
     </v-row>
    </v-col>
  </v-row>
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

</style>
