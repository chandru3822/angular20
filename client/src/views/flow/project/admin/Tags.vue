<template>
  <div>

    <v-row v-if="userIsAdmin">

        <v-col cols="12" class="pt-0">

          <v-toolbar flat dense class="project-header">
            <v-toolbar-title>Assigned Project Tags</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>

            </v-toolbar-items>
          </v-toolbar>


          put tags here...
        </v-col>
    </v-row>

  </div>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {
  handleHidingGlobalLoader,
  getRequest,
  getRequestWithParams,
  postRequest,
  deleteRequest,
  getSnackbar,
  logError
} from '@/helpers/helpers'
import {getCompanyAssignedToProcessStep, getCancelledCompanyStatusTypes} from '@/services/processStepStatusTypeService'

export default {
  name: 'ProjectTags.vue',
  props: {
  },
  data() {
    return {
      projectId: parseInt(this.$route.params.projectId),
      userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('PROJECTS', 'ADMIN'),
    }
  },
  components: {
  },
  computed: {

  },
  async created() {

  },
  methods: {

  }
}
</script>

<style scoped lang="scss">

</style>
