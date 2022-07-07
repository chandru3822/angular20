<template>
  <v-container class="pt-0">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat>
          <v-toolbar-title class="app-title">{{ selectedAttachment.attachmentType }}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>

          </v-toolbar-items>
        </v-toolbar>

        put custom field groups here
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import Vue2Filters from 'vue2-filters'
import {AppMutations} from '@/stores/AppStore'
import {
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
  getSnackbar, logError, handleHidingGlobalLoader
} from '@/helpers/helpers'
import orderBy from 'lodash.orderby'
import Sortable from "sortablejs"
import cloneDeep from 'lodash.clonedeep'

export default {
  name: 'ProcessStepAttachmentType',
  mixins: [Vue2Filters.mixin],
  components: {},
  data() {
    return {
      snackbar: {},
      selectedAttachment: {},
      attachmentLoading: true,
      processStepId: this.$route.params.id,
      attachmentTypeId: parseInt(this.$route.params.attachmentTypeId),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
    }
  },
  computed: {},
  async created() {
    await this.getTypeDetails()
  },
  methods: {
    async getTypeDetails() {
      try {
        this.attachmentLoading = true
        const {data} = await getRequest(`/processStep/${this.processStepId}/attachmentType/${this.attachmentTypeId}`)
        this.selectedAttachment = data
        this.attachmentLoading = false
      } catch (e) {
        this.attachmentLoading = true
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Attachment Type Details')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.companyStatusesLoading = false
      }
    },
  }

}
</script>

<style lang="scss">


</style>

<style scoped lang="scss">

</style>
