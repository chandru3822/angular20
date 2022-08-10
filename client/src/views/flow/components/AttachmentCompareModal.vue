<template>
  <v-card class="">
    <v-card-text class="pb-0 pl-0">
      <v-row class="">
        <v-col cols="4" class="coversheet-left-pane">
            <v-btn @click="closeCallback">Back</v-btn>
        </v-col>
        <v-col cols="8" class="coversheet-right-pane">
          other stuffs
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

export default {
  name: "AttachmentCompareModal",
  props: {
    showModal: Boolean,
    closeCallback: Function,
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
    }
  },
  created() {
    this.doPageLoad()
  },
  computed: {},
  methods: {
    closeModal() {
      this.closeCallback()
    },
    async doPageLoad() {
      console.log('do some stuff')
    }
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
