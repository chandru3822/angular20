<template>
  <div class="coversheet-container">
    <v-card class="coversheet-card">
      <v-card-text class="pb-0 pl-0">
        <v-row class="">
          <v-col :cols="leftCols" class="left-column">
            <a-btn
                id="back-btn"
                color="primary"
                variant="text"
                class="pl-1 pr-2"
                @click="closeCallback"
                prepend-icon="mdi-chevron-left"
                text="Back"
            ></a-btn>
          </v-col>
          <v-col :cols="12 - leftCols">
            <v-toolbar flat dense class="app-toolbar coversheet-title">
              <v-toolbar-title class="app-title">Document Comparison</v-toolbar-title>
            </v-toolbar>
          </v-col>
        </v-row>
        <v-row class="">
          <v-col :cols="leftCols" class="left-column">
            <div class="left-column-header thumbnail-container">
              File
            </div>
          </v-col>
          <v-col :cols="attachmentCols" v-for="(a, idx) in attachmentsCopy" :key="idx" class="thumbnail-file-container">
            <v-toolbar flat dense class="compare-file-title coversheet-title">
              <v-toolbar-title class="file-name">{{ a.displayName }}</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <a-btn
                    size="x-small"
                    variant="text"
                    color="primary"
                    @click="removeAttachmentFromView(a)"
                    prepend-icon="close"
                ></a-btn>
              </v-toolbar-items>
            </v-toolbar>
            <!--            we removed the preview for now -->
            <!--            <div class="mt-3 preview-main-container">-->
            <!--              <div v-if="a.isImage" class="one-hunned">-->
            <!--                <v-img name="coversheetPreview"-->
            <!--                       class="preview-image"-->
            <!--                       :src="a.presignedUrl"></v-img>-->
            <!--              </div>-->
            <!--              <div v-else-if="a.isPdf" class="one-hunned">-->
            <!--                <v-card class="square-card no-preview-container">-->
            <!--                  <div class="text-center">-->
            <!--                    <v-icon :size="200" color="white">mdi-file-pdf-box</v-icon>-->

            <!--                    <div class="mt-5">PDF Preview Unavailable</div>-->
            <!--                  </div>-->
            <!--                </v-card>-->
            <!--                <div v-if="pdfIsLoading" class="text-center">-->
            <!--                  <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>-->
            <!--                </div>-->
            <!--                <vue-pdf-embed-->
            <!--                  ref="pdfRef"-->
            <!--                  :source="a.presignedUrl"-->
            <!--                  :page="pdfPage"-->
            <!--                  @rendered="handleDocumentRender"-->
            <!--                />-->
            <!--              </div>-->
            <!--              <div v-else class="height-one-hunned one-hunned">-->
            <!--                <v-card class="square-card no-preview-container">-->
            <!--                  <div class="text-center">-->
            <!--                    <v-icon :size="200" color="white">mdi-image-frame</v-icon>-->

            <!--                    <div class="mt-5">No Preview Available</div>-->
            <!--                  </div>-->
            <!--                </v-card>-->
            <!--              </div>-->
            <!--            </div>-->
            <div class="compare-view-btns">
              <a-btn
                  size="small"
                  @click="closeModal(a)"
                  class="mr-4"
                  color="unset"
                  text="View"
              ></a-btn>
              <a-btn
                  size="small"
                  color="primary"
                  :href="a.presignedUrl"
                  text="Download"
              ></a-btn>
            </div>
          </v-col>
        </v-row>
        <v-row class="">
          <v-col :cols="leftCols" class="left-column">
            <span class="left-column-header">Upload Details</span><br>
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
            <span class="left-column-header">Document Information</span><br>
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
            />
          </v-col>
        </v-row>
      </v-card-text>
    </v-card>
  </div>
</template>

<script setup>
import {

  handleHidingGlobalLoader, postRequest
} from "@/helpers/helpers";

import constants from "@/helpers/constants"
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import orderBy from 'lodash.orderby'
// import VuePdfEmbed from 'vue-pdf-embed/dist/vue2-pdf-embed'
import SpinnerInline from '@/components/SpinnerInline'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const props = defineProps({
  showModal: Boolean,
  closeCallback: Function,
  attachments: Array,
})
const { showModal, closeCallback, attachments } = toRefs(props)

const imageFileExtensions = ref(constants.IMAGE_FILE_EXTENSIONS)
const attachmentsCopy = ref([])
const attachmentWithFields = ref([])
const allFields = ref([])
const leftCols = ref(2)
const attachmentCols = ref(2)
const isImage = ref(false)
const isPdf = ref(false)
const pdfPage = ref(1)
const pdfIsLoading = ref(true)

watch(showModal, (visible) => {
  if (visible) {
    doPageLoad()
  }
})

onMounted(() => {
  doPageLoad()
})

const getFieldValue = (a, field) => {
  let match = attachmentWithFields.value?.find(f => f.attachmentId === a.id)
  if (match) {
    let matchingValue = match.fieldValues?.find(fv => {
      return fv.defaultFieldId ? fv.defaultFieldId === field.defaultFieldId : fv.ancillaryCustomFieldId ?
          fv.ancillaryCustomFieldId === field.ancillaryCustomFieldId : fv.customFieldId === field.customFieldId
    })
    return matchingValue ? matchingValue : null
  }
  return null
}
const showField = (a, field) => {
  let match = attachmentWithFields.value?.find(f => f.attachmentId === a.id)
  if (match) {
    let matchingValue = match.fieldValues?.find(fv => {
      // return fv.defaultFieldId ? fv.defaultFieldId === field.defaultFieldId : fv.customFieldId === field.customFieldId
      return fv.defaultFieldId ? fv.defaultFieldId === field.defaultFieldId : fv.ancillaryCustomFieldId ?
          fv.ancillaryCustomFieldId === field.ancillaryCustomFieldId : fv.customFieldId === field.customFieldId
    })
    return matchingValue !== undefined && (
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
}
const goToPath = (path) => {
  if (null != path) {
    closeModal()
    router.push(path)
  }
}
const closeModal = (a) => {
  closeCallback(a)
}
const removeAttachmentFromView = (item) => {
  attachmentsCopy.value = attachmentsCopy.value.filter(a => a.id !== item.id)
  if(attachmentsCopy.value?.length === 0) {
    closeModal()
  }
}
const doPageLoad = async() => {
  allFields.value = []
  attachmentsCopy.value = []
  attachmentWithFields.value = []
  isPdf.value = false
  isImage.value = false
  pdfPage.value = 1

  switch(attachments.value.length) {
    case 1:
      attachmentCols.value = 10
      break
    case 2:
      attachmentCols.value = 5
      break
    case 3:
      attachmentCols.value = 3
      break
    case 4:
      attachmentCols.value = 2
      break
    default:
      attachmentCols.value = 2
  }

  //required since we cant mutate props that come from parent
  attachmentsCopy.value = attachments.value

  attachmentsCopy.value.forEach(a => {
    //need to determine if file is image or is pdf
    a.isImage = imageFileExtensions.value.includes(a.fileExtension.toLowerCase())
    a.isPdf = a.fileExtension === 'pdf'
  })
  await getCustomFields()
}
const handleDocumentRender = () => {
  pdfIsLoading.value = false
}
const getCustomFields = async() => {
  appStore.loading = true
  try {
    let params = {
      attachmentIds: attachmentsCopy.value.map(a => a.id)
    }
    const {data, status} = await postRequest(`/customFieldValues/attachmentTypeComparison`, params)
    attachmentWithFields.value = data

    //get cfIds and fieldNames across all attachments
    attachmentWithFields.value.forEach((f, idx) => {
      //push all into one, will de-dupe after
      allFields.value = allFields.value.concat(f.fieldValues)
    })

    //this removes duplicate fields (unless ancillary
    allFields.value = allFields.value.reduce((unique, o) => {
      if (!unique.some(obj => (obj.customFieldId != null && obj.customFieldId === o.customFieldId) ||
          (obj.ancillaryCustomFieldId != null && obj.ancillaryCustomFieldId === o.ancillaryCustomFieldId))) {
        unique.push(o);
      }
      return unique;
    }, []);

    allFields.value = orderBy(allFields.value, [a => a.fieldName.toLowerCase(), a => a.customFieldId])
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    appStore.loading = false
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
  justify-content: start;
  //justify-content: center;
  //margin-top: 20px;
}

.thumbnail-file-container {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
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

.compare-file-title {
  max-height: 48px;
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
