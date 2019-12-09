<template>
<v-file-input
  label="Upload project document"
  @change="uploadAttachment"
/>
</template>

<script>
import { Actions } from '@/store'
import {AppMutations} from '@/stores/AppStore'
import {logError, getSnackbar, ATTACHMENT_TYPES} from '@/helpers/helpers'

export default {
  name: "Documents",
  data () {
    return {

    }
  },
  props: {
    projectId: Number
  },
  methods: {
    uploadAttachment: async function (file) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await this.$store.dispatch(Actions.FILE_UPLOAD, {
          file,
          attachmentTypeId: ATTACHMENT_TYPES.PROJECT,
          sourceId: this.projectId,
          deleteFirst: false,
          callback: async (doc) => {
            console.log('saved doc', doc)
            this.$store.commit(AppMutations.SET_LOADING, false)
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
