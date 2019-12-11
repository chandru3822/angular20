<template>
<v-col>
  <v-row v-if="displayType === null">
    <v-col v-for="type in attachmentTypes" class="d-flex justify-space-around">
      <v-text-field :label="type.attachmentType + '(' +attachments.filter(a => a.attachmentTypeId === type.attachmentTypeId).length + ')'" @click="drillDown(type)"/>
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
      displayType: null
    }
  },
  props: {
    projectId: Number,
  },
  created () {
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
      const {data} = await getRequest(`/attachmentType/projectTypes`)
      this.attachmentTypes = data
    },
    fetchAttachments: async function () {
      const {data} = await getRequest(`/project/${this.projectId}/attachments`)
      this.attachments = data
    },
    drillDown: function(type) {
     this.displayType = type
    },
    uploadDocument: async function (file) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await this.$store.dispatch(Actions.PROJECT_FILE_UPLOAD, {
          file,
          attachmentTypeId: this.displayType.attachmentTypeId,
          projectId: this.projectId,
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
