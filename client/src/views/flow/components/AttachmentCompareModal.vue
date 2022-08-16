<template>
  <div class="coversheet-container">
    <v-card class="coversheet-card">
      <v-card-text class="pb-0 pl-0">
        <v-row class="">
          <v-col :cols="leftCols" class="left-column">
            <v-btn @click="closeCallback">Back</v-btn>
            <div class="left-column-header">
              Thumbnail
            </div>
          </v-col>
          <v-col :cols="attachmentCols" v-for="(a, idx) in attachmentsCopy" :key="idx" class="">
            <div>
              {{ a.displayName }}
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
          <v-col :cols="leftCols" class="left-column">
            <span class="left-column-header">File Details</span><br>
            <span class="left-column-subheader">Uploaded Date</span><br>
            <span class="left-column-subheader">Uploaded By</span><br>
            <span class="left-column-subheader">Document Type</span><br>
            <span class="left-column-subheader">Document Location</span>
          </v-col>
          <v-col :cols="attachmentCols" v-for="(a, idx) in attachmentsCopy" :key="idx" class="">
            <br>
            <span class="left-column-subheader">{{ a.dateCreated | formatDate('date') }} </span><br>
            <span class="left-column-subheader">{{ a.uploadedBy }} </span><br>
            <span class="left-column-subheader">{{ a.attachmentType }} </span><br>
            <a class="left-column-subheader" @click="goToPath(a.originPath)">
              {{ a.originLocation }}
            </a>
          </v-col>
        </v-row>
        <v-row>
          <v-col :cols="leftCols" class="left-column">
            <span class="left-column-header">Additional File Details</span><br>
          </v-col>
        </v-row>
        <v-row v-for="field in allFields"  class="">
          <v-col :cols="leftCols" class="left-column field-container">
            <div>
              <div class="left-column-subheader">
                {{ field.fieldName }}
              </div>
              <div v-if="field.ancillaryCustomFieldId" class="left-column-subheader">
                (Ancillary)
              </div>
            </div>
          </v-col>
          <v-col :cols="attachmentCols" v-for="(a, idx) in attachmentsCopy" :key="idx" class="">
            <CustomValueInput
              v-if="showField(a, field)"
              :readonly="true"
              :hide-details="true"
              :show-field-name="false"
              :hide-label="true"
              :field="getFieldValue(a, field)"
              :filled-style="false"
            />
          </v-col>
        </v-row>
      </v-card-text>
    </v-card>
  </div>
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
import orderBy from 'lodash.orderby'

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
      attachmentsCopy: [],
      attachmentWithFields: [],
      allFields: [],
      leftCols: 2,
      attachmentCols: 2
    }
  },
  created() {
    this.doPageLoad()
  },
  methods: {
    getFieldValue(a, field) {
      let match = this.attachmentWithFields?.find(f => f.attachmentId === a.id)
      if (match) {
        let matchingValue = match.fieldValues?.find(fv => {
          return fv.defaultFieldId ? fv.defaultFieldId === field.defaultFieldId : fv.ancillaryCustomFieldId ?
            fv.ancillaryCustomFieldId === field.ancillaryCustomFieldId : fv.customFieldId === field.customFieldId
        })
        return matchingValue
      }
      return null
    },
    showField(a, field) {
      let match = this.attachmentWithFields?.find(f => f.attachmentId === a.id)
      if (match) {
        let matchingValue = match.fieldValues?.find(fv => {
          return fv.defaultFieldId ? fv.defaultFieldId === field.defaultFieldId : fv.customFieldId === field.customFieldId
        })
        return (
          matchingValue?.dateValue != null ||
          matchingValue?.timestampValue != null ||
          matchingValue?.textValue != null ||
          matchingValue?.numericValue != null ||
          matchingValue?.intValue != null ||
          matchingValue?.intArrayValue != null ||
          matchingValue?.richTextValue != null ||
          matchingValue?.dataTypeId === 3
        )
      }
      return false
    },
    goToPath(path) {
      if (null != path) {
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
      this.allFields = []
      this.attachmentsCopy = []
      this.attachmentWithFields = []

      //required since we cant mutate props that come from parent
      this.attachmentsCopy = this.attachments
      await this.getCustomFields()
    },
    async getCustomFields() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {
          attachmentIds: this.attachmentsCopy.map(a => a.id)
        }
        const {data, status} = await postRequest(`/customFieldValues/attachmentTypeComparison`, params)
        this.attachmentWithFields = data

        //get cfIds and fieldNames across all attachments
        this.attachmentWithFields.forEach((f, idx) => {
          console.log('randaLogger', f.fieldValues)
          //push all into one, will de-dupe after
          this.allFields = this.allFields.concat(f.fieldValues)
        })

        //this removes duplicate fields (unless ancillary
        this.allFields = this.allFields.reduce((unique, o) => {
          console.log('unique: ',unique)
          console.log('oooooo: ',o)
          if(!unique.some(obj => (obj.customFieldId != null && obj.customFieldId === o.customFieldId) ||
            (obj.ancillaryCustomFieldId != null && obj.ancillaryCustomFieldId === o.ancillaryCustomFieldId))) {
            unique.push(o);
          }
          return unique;
        },[]);

        this.allFields = orderBy(this.allFields, [a => a.fieldName.toLowerCase(), a => a.customFieldId])
        console.log('ALL FIelds', this.allFields)
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

.coversheet-card {
  min-height: 100%;
}

.left-column {
  padding-left: 25px;
  border-right: solid 1px #C4C4C4;
  /*box-shadow: 4px 0 15px rgba(0, 0, 0, 0.1);*/
  /*clip-path: inset(0px -15px 0px 0px);*/
}

.left-column-header {
  font-weight: 700;
  font-size: 18px;
  line-height: 25px;
}

.field-container {
  display: flex;
  align-items: start;
}

.left-column-subheader {
  font-weight: 400;
  font-size: 16px;
  line-height: 25px;
}

</style>
