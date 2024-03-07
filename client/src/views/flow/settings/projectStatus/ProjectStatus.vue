<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-btn text class="pl-1 pr-2 anchor" :to="'/settings/projectStatuses'">
          <v-icon>arrow_left</v-icon>
          <span>Back</span>
        </v-btn>

        <v-toolbar flat class="app-toolbar">
          <span class="headline-small">{{ status.projectStatusType }}</span>
          <v-spacer></v-spacer>
          <v-toolbar-items>
          </v-toolbar-items>
        </v-toolbar>

        <v-tabs class="tabs-bar tabs-border-bottom" v-model="activeTab">
          <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path"
                 class="text-capitalize ma-0"
                 :style="{'margin-left': index === 0 ? '12px !important' : '0'}">
            {{ tab.label }}
          </v-tab>
        </v-tabs>
      </v-col>

      <router-view />
    </v-row>
  </v-container>
</template>


<script>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import draggable from 'vuedraggable'
import {getCompanyProjectStatusType} from '@/services/projectStatusTypeService'
import {handleHidingGlobalLoader, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from '@/components/ConfirmationDialog.vue'

export default {
  name: 'ProjectStatus',
  mixins: [Vue2Filters.mixin],
  components: {
    ConfirmationDialog,
    draggable,
  },
  data() {
    return {
      snackbar: {},
      constants,
      activeTab: '',
      status: {},
      rootStatusTypes: [],
      acceptedFileTypes: constants.STANDARD_IMAGES_ONLY,
      savingTypeLogo: false,
      //463 = project status type attachment
      attachmentTypeId: 463,
      statusId: this.$route.params.id,
      tabs: [
        {
          id: 1,
          label: 'Components',
          path: `/settings/projectStatus/${this.$route.params.id}/components`,
        },
        {
          id: 2,
          label: 'Fields',
          path: `/settings/projectStatus/${this.$route.params.id}/fields`,
        }
      ]
    }
  },
  computed: {},
  methods: {
    async getStatusInfo() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getCompanyProjectStatusType(this.statusId)
        this.status = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  },
  async created() {
    this.getStatusInfo()
  }
}
</script>

<style scoped lang="scss">
.tabs-border-bottom {
  border-bottom: 1px solid #E6E6E6;
}
</style>
