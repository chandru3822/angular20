<template>
  <v-card class="coversheet-container">
    <v-card-text class="pb-0 pl-0">
      <v-row class="">
        <v-col cols="3" class="">
            <v-btn @click="closeCallback">Back</v-btn>
          Thumbnail
        </v-col>
        <v-col cols="3" v-for="(a, idx) in attachmentsCopy" :key="idx" class="">
          <div>
            {{a.displayName}}
            <v-btn x-small text color="primary" @click="removeAttachmentFromView(a)">
              <v-icon>close</v-icon>
            </v-btn>
          </div>
          <v-btn @click="closeModal(a)">
            View
          </v-btn>
          <v-btn color="primary"
                 :href="a.presignedUrl">
            Download
          </v-btn>
        </v-col>
      </v-row>
      <v-row class="">
        <v-col cols="3" class="">
          File Details<br>
          Uploaded Date<br>
          Uploaded By<br>
          Document Type<br>
          Document Location
        </v-col>
        <v-col cols="3" v-for="(a, idx) in attachmentsCopy" :key="idx" class="">
          <br>
          {{a.dateCreated | formatDate('date')}} <br>
          {{a.uploadedBy}} <br>
          {{a.attachmentType}} <br>
          <a @click="goToPath(a.originPath)">
            {{a.originLocation}}
          </a>
        </v-col>
      </v-row>
    </v-card-text>
  </v-card>
</template>

<script>
import {
  getRequest,
  getRequestWithParams,
  getSnackbar,
  handleHidingGlobalLoader, logError, postRequest,
  putRequest
} from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";
import {Actions} from "@/store";
import {ProjectMutations} from '@/stores/ProjectStore'
import constants from "@/helpers/constants"
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import cloneDeep from 'lodash.clonedeep'
import {getCompanyProjectStatusTypes} from "@/services/projectStatusTypeService";

export default {
  name: "AttachmentCompareModal",
  props: {
    showModal: Boolean,
    closeCallback: Function,
    attachments: Array,
  },
  components: {
    DatetimePickerInput,
    CustomValueInput
  },
  watch: {
    showModal: function (visible) {
      //created only gets called the first time the modal opens. this forces it to load every time (the watcher doesn't get call on the first time the modal opens, so no double loading to worry about)
      if (visible) {
        this.doPageLoad()
      }
    }
  },
  data() {
    return {
      timezone: this.$store.state.user.details.timezone.value,
      attachmentsCopy: []
    }
  },
  created() {
    this.doPageLoad()
  },
  methods: {
    goToPath(path) {
      if(null != path) {
        this.closeModal()
        this.$router.push(path)
      }
    },
    closeModal(a) {
      this.closeCallback(a)
    },
    removeAttachmentFromView(item) {
      this.attachmentsCopy = this.attachmentsCopy.filter(a => a.id !== item.id)
    },
    async doPageLoad() {
      //required since we cant mutate props that come from parent
      this.attachmentsCopy = this.attachments
      console.log('do some stuff', this.attachmentsCopy)
      await this.getCustomFields()
    },
    async getCustomFields () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {
          attachmentIds: this.attachmentsCopy.map(a => a.id)
        }
        console.log('randaLogger',params)
        const {data, status} = await postRequest(`/customFieldValues/attachmentTypeComparison`, params)
        this.statusTypes = data
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

<style>
.coversheet-save-bar .v-toolbar__content {
  padding: 0 !important;
}
</style>

<style scoped>
.coversheet-container {
  height: 90vh;
  max-height: 90vh;
}

.coversheet-left-pane {
  box-shadow: 4px 0 15px rgba(0, 0, 0, 0.1);
  padding-left: 25px;
  height: 90vh;
  max-height: 90vh;
  overflow-y: auto;
  padding-bottom: 0;
}

.coversheet-right-pane {
  height: 90vh;
  max-height: 90vh;
  overflow-y: auto;
}
</style>
