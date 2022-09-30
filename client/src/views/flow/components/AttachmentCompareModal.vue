<template>
  <div class="coversheet-container">
    <v-card class="coversheet-card">
      <v-card-text class="pb-0 pl-0">
        <v-row class="">
          <v-col :cols="leftCols" class="left-column">
            <v-btn id="back-btn" color="primary" text class="pl-1 pr-2" @click="closeCallback">
              <v-icon class="pr-2">mdi-chevron-left</v-icon>
              <span id="back-btn-text">Back</span>
            </v-btn>
          </v-col>
          <v-col :cols="12 - leftCols">
            <v-toolbar flat dense class="app-toolbar coversheet-title">
              <v-toolbar-title class="app-title">Document Comparison</v-toolbar-title>
            </v-toolbar>
          </v-col>
        </v-row>
        <v-row class="">
          <v-col :cols="leftCols" class="left-column">
            <!--            <v-btn @click="closeCallback">Back</v-btn>-->
            <div class="left-column-header thumbnail-container">
              Thumbnail
            </div>
          </v-col>
          <v-col :cols="attachmentCols" v-for="(a, idx) in attachmentsCopy" :key="idx" class="">
            <v-toolbar flat dense class="coversheet-title">
              <v-toolbar-title class="file-name">{{ a.displayName }}</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn x-small text color="primary" @click="removeAttachmentFromView(a)">
                  <v-icon>close</v-icon>
                </v-btn>
              </v-toolbar-items>
            </v-toolbar>
            <!--            <div>-->
            <!--              {{ a.displayName }}-->
            <!--              <v-btn x-small text color="primary" @click="removeAttachmentFromView(a)">-->
            <!--                <v-icon>close</v-icon>-->
            <!--              </v-btn>-->
            <!--            </div>-->
            <div class="mt-3 preview-main-container">
              <div v-if="a.isImage" class="one-hunned">
                <v-img name="coversheetPreview"
                       class="preview-image"
                       :src="a.presignedUrl"></v-img>
              </div>
              <div v-else-if="a.isPdf" class="one-hunned">
                <div v-if="pdfIsLoading" class="text-center">
                  <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
                </div>
                <vue-pdf-embed
                  ref="pdfRef"
                  :source="a.presignedUrl"
                  :page="pdfPage"
                  @rendered="handleDocumentRender"
                />
              </div>
              <div v-else class="height-one-hunned one-hunned">
                <v-card class="square-card no-preview-container">
                  <div class="text-center">
                    <v-icon :size="200" color="white">mdi-image-frame</v-icon>

                    <div class="mt-5">No Preview Available</div>
                  </div>
                </v-card>
              </div>
            </div>
            <div class="compare-view-btns">
              <v-btn small @click="closeModal(a)" class="mr-4">
                View
              </v-btn>
              <v-btn small color="primary"
                     :href="a.presignedUrl">
                Download
              </v-btn>
            </div>
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
          <v-col :cols="leftCols" class="left-column" v-if="allFields.length > 0">
            <span class="left-column-header">Additional Details</span><br>
          </v-col>
        </v-row>
        <v-row v-for="field in allFields" class="">
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
import VuePdfEmbed from 'vue-pdf-embed/dist/vue2-pdf-embed'
import SpinnerInline from '@/components/SpinnerInline'

export default {
  name: "AttachmentCompareModal",
  props: {
    showModal: Boolean,
    closeCallback: Function,
    attachments: Array,
  },
  components: {
    DatetimePickerInput,
    CustomValueInput,
    VuePdfEmbed,
    SpinnerInline
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
      imageFileExtensions: constants.IMAGE_FILE_EXTENSIONS,
      attachmentsCopy: [],
      attachmentWithFields: [],
      allFields: [],
      leftCols: 2,
      attachmentCols: 2,
      isImage: false,
      isPdf: false,
      pdfPage: 1,
      pdfIsLoading: true,
    }
  },
  created() {
    this.doPageLoad()

    // this.attachmentCols = (12 - this.leftCols) / (this.attachments.length)
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
      this.isPdf = false
      this.isImage = false
      this.pdfPage = 1

      switch(this.attachments.length) {
        case 1:
          this.attachmentCols = 10
          break
        case 2:
          this.attachmentCols = 5
          break
        case 3:
          this.attachmentCols = 3
          break
        case 4:
          this.attachmentCols = 2
          break
        default:
          this.attachmentCols = 2
      }

      //required since we cant mutate props that come from parent
      this.attachmentsCopy = this.attachments

      this.attachmentsCopy.forEach(a => {
        //need to determine if file is image or is pdf
        a.isImage = this.imageFileExtensions.includes(a.fileExtension)
        a.isPdf = a.fileExtension === 'pdf'
      })
      await this.getCustomFields()
    },
    handleDocumentRender() {
      this.pdfIsLoading = false
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
          if (!unique.some(obj => (obj.customFieldId != null && obj.customFieldId === o.customFieldId) ||
            (obj.ancillaryCustomFieldId != null && obj.ancillaryCustomFieldId === o.ancillaryCustomFieldId))) {
            unique.push(o);
          }
          return unique;
        }, []);

        this.allFields = orderBy(this.allFields, [a => a.fieldName.toLowerCase(), a => a.customFieldId])
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

<style scoped lang="scss">

#back-btn {
  text-transform: unset;
  letter-spacing: unset;

  &:before {
    background-color: initial;
  }

  #back-btn-text:hover {
    text-decoration: underline;
  }
}

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
  font-size: 16px;
  line-height: 30px;
}

.file-name {
  font-weight: 700;
  font-size: 16px;
}

.field-container {
  display: flex;
  align-items: start;
}

.compare-view-btns {
  display: flex;
  justify-content: center;
}

.thumbnail-container {
  height: 100%;
  display: flex;
  align-items: center;
}

.left-column-subheader {
  font-weight: 400;
  font-size: 14px;
  line-height: 30px;
}

.no-preview-container {
  background-color: var(--v-grey-lighten2);
  height: 100%;
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
