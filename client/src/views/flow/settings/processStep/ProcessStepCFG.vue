<template>
  <v-container class="custom-field-group-container py-0">
    <v-row>
      <v-col cols="12" class="py-0">
            <ProcessStepCustomFieldGroups :customFieldGroups="processStep.customFieldGroups"></ProcessStepCustomFieldGroups>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'

  import ProcessStepCustomFieldGroups from './ProcessStepCustomFieldGroups'
  import { handleHidingGlobalLoader, getRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: 'ProcessStepCFG',
    components: {
      ProcessStepCustomFieldGroups,
    },
    data () {
      return {
        snackbar: {},
        loading: true,
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
        processStepId: this.$route.params.id,
        companyId: this.$store.state.user.details.companyId,
        processStep: {},
        breadcrumbs: [
          {
            text: 'Back',
            disabled: false,
            exact: true,
            to: `/settings/processSteps`
          },
        ]
      }
    },
    computed: {
    },
    async created () {
      await this.getProcessStepDetails()
    },
    methods: {
      async getProcessStepDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.loading = true
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {data, status} = await getRequest(`/processStep/${this.processStepId}`)
          this.processStep = data
          this.loading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }

  }
</script>

<style scoped lang="scss">
.name-container {
  background-color: var(--v-primary-lighten9) !important;
  border-radius: 5px;
}
</style>
