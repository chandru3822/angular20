<template>
  <div>
    <v-row class="d-flex justify-space-between align-center">
      <v-col v-if="showFieldName">
        <span
          :title="`ID: ${field.id}, DataType: (${field.dataType}) ${field.dataTypeId} `"
        >
          {{ field.fieldName }}
        </span>
        <span class="ancillary" v-if="field.ancillaryCustomFieldHint">
          {{ field.ancillaryCustomFieldHint }}
        </span>
        <span class="ancillary" v-else-if="field.useParentData">(Parent)</span>
        <span
          class="ancillary"
          v-else-if="field.ancillaryCustomFieldGroupAssignmentId"
        >
          (Primary)
        </span>
      </v-col>

      <v-col class="d-flex justify-start align-self-start py-0">
        <DatetimePickerInput
          v-if="field.dataTypeId === 1"
          v-model="field.dateValue"
          :timezone="timezone"
          :type="'date'"
          :allow-now="field.allowNow"
          :required="required"
          :min-date="minDate"
          :max-date="maxDate"
          :variant="variant"
          :format="'MMMM DD, YYYY'"
          :label="getFieldName()"
          :hide-details="hideDetails"
          :readonly="readonly"
          :custom-class="
            customClass
              ? customClass.concat(readonly ? ' error--text' : '')
              : readonly
              ? ' error--text'
              : ''
          "
          @input="props.callback(field)"
        />

        <DatetimePickerInput
          v-if="field.dataTypeId === 2"
          v-model="field.timestampValue"
          :timezone="timezone"
          type="timestamp"
          :allow-now="field.allowNow"
          :required="required"
          :variant="variant"
          :format="'MMMM DD, YYYY, h:mm A'"
          :label="getFieldName()"
          :hide-details="hideDetails"
          :readonly="readonly"
          :custom-class="
            customClass
              ? customClass.concat(readonly ? ' error--text' : '')
              : readonly
              ? ' error--text'
              : ''
          "
          @input="props.callback(field)"
        />

        <v-checkbox
          v-if="field.dataTypeId === 3"
          v-model="field.booleanValue"
          :required="required"
          :label="getFieldName()"
          :hide-details="hideDetails"
          :rules="rules"
          :filled="filled"
          :disabled="readonly"
          :readonly="readonly"
          :ripple="false"
          @change="props.callback(field)"
          :class="customClass"
          :hint="hint"
        />

        <a-text-field
          v-if="field.dataTypeId === 4"
          :required="required"
          :readonly="readonly"
          :disabled="readonly"
          :class="[customClass, { 'error--text': readonly }]"
          placeholder=" "
          :rules="rules"
          :label="getFieldName()"
          :hide-details="hideDetails"
          :hint="hint"
          type="number"
          :variant="variant"
          v-model.number="field.numericValue"
          @change="handleInput(field)"
          autocomplete="off"
          :append-inner-icon="appendIcon ? appendIcon : null"
          @click:append="props.appendCallback(field.numericValue)"
        />

        <!--        12 is the new SYSTEM_readonly field. but i think we can use this same field as id=10 will ALWAYS be readonly and (never required i think)-->
        <a-textarea
          v-if="
            field.dataTypeId === 5 ||
            field.dataTypeId === 12 ||
            (field.dataTypeId === 8 && field.systemReadonly)
          "
          auto-grow
          rows="1"
          :required="required"
          :readonly="readonly || field.dataTypeId === 12"
          :disabled="readonly || field.dataTypeId === 12"
          :class="[customClass, { 'error--text': readonly || required }]"
          placeholder=" "
          :rules="rules"
          :variant="variant"
          :label="getFieldName()"
          :hide-details="hideDetails"
          v-model="field.textValue"
          @change="handleInput(field)"
          autocomplete="off"
        />

        <a-text-field
          v-if="field.dataTypeId === 6 && !field.hasListValues"
          :required="required"
          :readonly="readonly"
          :disabled="readonly"
          :class="[customClass, { 'error--text': readonly }]"
          :label="getFieldName()"
          :hide-details="hideDetails"
          placeholder=" "
          :variant="variant"
          :rules="rules"
          type="number"
          v-model.number="field.intValue"
          @change="handleInput(field)"
          autocomplete="off"
        />

        <a-autocomplete
          v-if="field.dataTypeId === 6 && field.hasListValues"
          v-model="field.intValue"
          :variant="filled ? 'filled' : 'text'"
          attach
          :hide-no-data="field.lazyLoadValues"
          :required="required"
          :clearable="!readonly"
          :readonly="readonly"
          :disabled="readonly"
          :custom-classes="classesAsString"
          :loading="isLoading"
          placeholder=" "
          item-disabled="archived"
          :rules="rules"
          :items="getListOfValues()"
          :label="getFieldName()"
          :hide-details="hideDetails"
          :hint="hint"
          item-value="id"
          item-title="name"
          @input="handleInput"
          autocomplete="off"
        >
          <template #item="{ item }">
            <v-list-item-content>
              <v-list-item-title v-text="item.name" />
              <v-list-item-subtitle
                v-if="item.description"
                v-text="item.description"
              />
            </v-list-item-content>
          </template>
        </a-autocomplete>

        <a-autocomplete
          v-if="field.dataTypeId === 7 || field.dataTypeId === 10"
          :variant="filled ? 'filled' : 'text'"
          attach
          :required="required"
          multiple
          placeholder=" "
          v-model="field.intArrayValue"
          :hide-no-data="field.lazyLoadValues"
          :search-input="search"
          :items="getListOfValues()"
          item-disabled="archived"
          :clearable="!readonly"
          :readonly="readonly"
          :disabled="readonly"
          :class="classesAsString"
          :rules="rules"
          :label="getFieldName()"
          :hide-details="hideDetails"
          :hint="hint"
          item-value="id"
          item-title="name"
          @input="handleInput"
          autocomplete="off"
        >
          <template #item="{ item }">
            <v-list-item-content>
              <v-list-item-title v-text="item.name" />
              <v-list-item-subtitle
                v-if="item.description"
                v-text="item.description"
              />
            </v-list-item-content>
          </template>
        </a-autocomplete>

        <a-autocomplete
          v-if="field.dataTypeId === 8 && !field.systemReadonly"
          v-model="field.intValue"
          :variant="filled ? 'filled' : 'text'"
          attach
          :required="required"
          :search-input="search"
          :hide-no-data="field.lazyLoadValues"
          :clearable="!readonly"
          item-disabled="archived"
          :readonly="readonly"
          :disabled="readonly"
          :class="classesAsString"
          :items="getListOfValues()"
          :label="getFieldName()"
          :hide-details="hideDetails"
          :hint="hint"
          :rules="rules"
          placeholder=" "
          item-value="id"
          item-title="name"
          @input="handleInput"
          autocomplete="off"
        >
          <template #item="{ item }">
            <v-list-item-content>
              <v-list-item-title v-text="item.name" />
              <v-list-item-subtitle
                v-if="item.description"
                v-text="item.description"
              />
            </v-list-item-content>
          </template>
        </a-autocomplete>

        <a-autocomplete
          v-if="field.dataTypeId === 9"
          v-model="field.intValue"
          :search-input="search"
          :hide-no-data="field.lazyLoadValues"
          :variant="filled ? 'filled' : 'text'"
          attach
          :required="required"
          :clearable="!readonly"
          item-disabled="archived"
          :items="getListOfValues()"
          :label="getFieldName()"
          :hide-details="hideDetails"
          :readonly="readonly"
          :disabled="readonly"
          :class="classesAsString"
          :rules="rules"
          :hint="hint"
          placeholder=" "
          item-value="id"
          item-title="name"
          @input="handleInput"
          autocomplete="off"
        >
          <template
            v-slot:prepend
            v-if="
              field.allowSelectSelf &&
              !field.ancillaryCustomFieldGroupAssignmentId
            "
          >
            <v-tooltip top small>
              <template v-slot:activator="{ on, attrs }">
                <v-icon
                  @click="selectSelf"
                  class="clickable"
                  color="primary"
                  v-bind="attrs"
                  v-on="on"
                  >mdi-account-arrow-right-outline</v-icon
                >
              </template>
              <span class="albatross-body-3">Select Me</span>
            </v-tooltip>
          </template>
          <template #item="{ item }">
            <v-list-item-content>
              <v-list-item-title v-text="item.name" />
              <v-list-item-subtitle
                v-if="item.description"
                v-text="item.description"
              />
            </v-list-item-content>
          </template>
        </a-autocomplete>

        <div v-if="field.dataTypeId === 13" class="one-hunned">
          <!-- this hidden text field makes the form's required fields validation work -->
          <a-text-field
            style="display: none"
            v-model="field.richTextValue"
            :required="required"
            :rules="rules"
          >
          </a-text-field>
          <div
            class="albatross-body-1 default-text-color d-flex align-baseline mb-2 pa-1"
            v-if="!hideLabel && !showFieldName"
          >
            {{ getFieldName() }}
            <v-icon
              v-if="locked && lockFeature"
              @click="locked = false"
              small
              color="primary"
              class="ml-3"
            >
              mdi-lock
            </v-icon>
            <v-icon
              v-if="!locked && lockFeature"
              @click="locked = true"
              small
              color="primary"
              class="ml-3"
            >
              mdi-lock-open
            </v-icon>
            <v-icon
              v-if="copyFeature"
              @click="copyToClipBoard(field.textValue)"
              small
              color="primary"
              class="ml-3"
            >
              mdi-content-copy
            </v-icon>
          </div>
          <quill-editor
            :options="toolbarOptions"
            class="cvi-rich-text-editor albatross-body-2"
            :class="[
              {
                'cvi-rich-text-editor-required':
                  required && !field.richTextValue,
                'cvi-rich-text-editor-readonly':
                  readonly || (locked && lockFeature)
              },
              customClass
            ]"
            :readonly="readonly"
            :disabled="readonly || (locked && lockFeature)"
            @change="(q) => doRichTextFieldCallback(field, q)"
            v-model="field.richTextValue"
          />
          <div
            class="cvi-rich-text-label error--text"
            v-if="required && !field.richTextValue"
          >
            Field is required
          </div>
        </div>
      </v-col>
    </v-row>
    <v-row v-if="field.lazyLoadValues && field.values">
      <v-col />
      <v-col> Current Value(s): {{ field | fieldValues }} </v-col>
    </v-row>
  </div>
</template>

<script setup>
import debounce from 'lodash.debounce'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import constants from '@/helpers/constants'
import 'quill/dist/quill.snow.css'
import { quillEditor } from 'vue-quill-editor'
import { getRequestWithParams } from '@/helpers/helpers'

import { toRefs, computed, ref, watch } from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const userStore = useUserStore()

const props = defineProps({
  apiPath: {
    type: String,
    default: 'flow'
  },
  required: {
    type: Boolean,
    default: false
  },
  readonly: {
    type: Boolean,
    default: false
  },
  field: Object,
  useFieldAncillaryName: {
    type: Boolean,
    default: false
  },
  showFieldName: {
    type: Boolean,
    default: true
  },
  hideLabel: {
    type: Boolean,
    default: false
  },
  hideDetails: {
    type: Boolean,
    default: false
  },
  lockFeature: {
    type: Boolean,
    default: false
  },
  copyFeature: {
    type: Boolean,
    default: false
  },
  listOfValueFilter: {
    type: Function,
    required: false
  },
  hint: {
    type: String,
    required: false
  },
  minDate: String,
  maxDate: String,
  variant: String,
  callback: Function,
  customClass: String,
  appendIcon: String,
  appendCallback: Function
})
const {
  apiPath,
  required,
  readonly,
  field,
  useFieldAncillaryName,
  showFieldName,
  hideLabel,
  hideDetails,
  lockFeature,
  copyFeature,
  listOfValueFilter,
  hint,
  minDate,
  maxDate,
  variant,
  customClass,
  appendIcon
} = toRefs(props)

const search = ref('')
const isLoading = ref(false)
const toolbarOptions = ref({
  modules: {
    toolbar: [
      ['bold', 'italic', 'underline', 'blockquote'], //toggled buttons
      //without the color array then black = false which just un-sets color. in our case our default is navy blue, so unsetting the color goes back to navy blue and not to black.  by setting the black value to #000000 it fixes this issue.  when our default color changes to black then we could just remove the colors in this array to use the defaults from quill
      [
        {
          color: [
            '#000000',
            '#e60000',
            '#ff9900',
            '#ffff00',
            '#008a00',
            '#0066cc',
            '#9933ff',
            '#ffffff',
            '#facccc',
            '#ffebcc',
            '#ffffcc',
            '#cce8cc',
            '#cce0f5',
            '#ebd6ff',
            '#bbbbbb',
            '#f06666',
            '#ffc266',
            '#ffff66',
            '#66b966',
            '#66a3e0',
            '#c285ff',
            '#888888',
            '#a10000',
            '#b26b00',
            '#b2b200',
            '#006100',
            '#0047b2',
            '#6b24b2',
            '#444444',
            '#5c0000',
            '#663d00',
            '#666600',
            '#003700',
            '#002966',
            '#3d1466'
          ]
        },
        { background: [] }
      ], // dropdown with defaults from theme
      [{ size: ['small', false, 'large', 'huge'] }], // custom dropdown
      ['clean'] // remove all formatting button
    ]
  }
})
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
const arrayRequiredRules = ref(constants.BASIC_ARRAY_REQUIRED_RULE)
const locked = ref(true)

const filled = computed(() => {
  //this is temporary until all v-components are converted to us variant
  return variant.value === 'filled'
})

const currentUserId = computed(() => {
  return userStore.details.id
})

const timezone = computed(() => {
  return userStore.timezone.value
})
//before this was a computed value it wasn't updating the ui for all field types when they were required
const rules = computed(() => {
  let rules = []
  //handle required rule
  if (required.value && [7, 10].includes(field.value.dataTypeId)) {
    //dont do push here cuz arrayRequiredRules is already an array
    rules = arrayRequiredRules.value
  } else if (required.value) {
    //dont do push here cuz requiredRules is already an array
    rules = requiredRules.value
  }

  //handle min/max validation (currently only used in brs - proposal design fields
  if (field.value.minValue) {
    // v => (!v || (v && (v.length <= 35))) || 'Must be 35 characters or less',
    rules.push(
      (v) =>
        (!v && v !== 0) ||
        v >= field.value.minValue ||
        `Value must be greater than or equal to ${field.value.minValue}`
    )
  }

  if (field.value.maxValue) {
    rules.push(
      (v) =>
        (!v && v !== 0) ||
        v <= field.value.maxValue ||
        `Value must be less than or equal to ${field.value.maxValue}`
    )
  }
  // rules.value = rules
  return rules
})
const fieldAncillaryName = computed(() => {
  if (field.value.ancillaryCustomFieldHint) {
    return field.value.fieldName + ' ' + field.value.ancillaryCustomFieldHint
  } else if (field.value.useParentData) {
    return field.value.fieldName + ' (Parent)'
  } else if (field.value.ancillaryCustomFieldGroupAssignmentId) {
    return field.value.fieldName + ' (Ancillary)'
  } else {
    return field.value.fieldName
  }
})

const classesAsString = computed(() => {
  let extraClasses = ''
  if (readonly.value || required.value) {
    extraClasses += ' error--text'
  }
  return customClass.value + extraClasses
})

watch(search, (val) => {
  if (field.value.lazyLoadValues) {
    getItems(val)
  }
})

const copyToClipBoard = (textValue) => {
  navigator.clipboard.writeText(textValue)
  appStore.showSnack('SUCCESS', 'Copied text to clipboard')
}
const doRichTextFieldCallback = (field, quill) => {
  field.textValue = quill?.text || null
  props.callback(field)
}
const getFieldName = () => {
  return hideLabel.value
    ? null
    : useFieldAncillaryName.value
    ? fieldAncillaryName.value
    : field.value.fieldName
}

const getItems = debounce(async (query = '') => {
  try {
    if (query) {
      isLoading.value = false
      const { data = [] } = await getRequestWithParams(
        `/customField/${field.value.id}/values`,
        { params: { query } },
        apiPath.value,
        []
      )
      field.value.listOfValues = [...data]
    }
  } finally {
    isLoading.value = false
  }
}, 250)

const getListOfValues = () => {
  if (listOfValueFilter.value) {
    return field.value?.listOfValues?.filter(listOfValueFilter.value)
  }
  return field.value?.listOfValues || []
}
const handleInput = (val) => {
  if (props.callback) {
    props.callback(field.value, val === null)
  }
}
const selectSelf = () => {
  switch (field.value.companySystemListId) {
    case 1: //Users by Organization
    case 2: //Users by Position
      //a field with System List Type "Users by Position" or "Users by Organization" returns a distinct list of user positions (so a user can appear more than once)
      //and uses the userPositionId as the value.id
      // if a user appears more than once, we want to use their primary position, so we get the position id of their primary position to find them in the list,
      let currentUserPrimaryPositionId = userStore.details.userPositions.find(
        (position) => position.primaryFlag === true
      )?.id
      let currentUserValues = getListOfValues().filter(
        (value) => value.id && value.id === currentUserPrimaryPositionId
      )
      if (currentUserValues.length > 0) {
        //select the primary position
        field.value.intValue = currentUserValues[0].id
      } else {
        // if their primary position is not in the list, get the newest position in the list
        let positions = userStore.details.userPositions
          .filter((position) => position.primaryFlag === false)
          .sort((position1, position2) => {
            //sort newest to oldest position
            if (position1.startDate < position2.startDate) {
              return 1
            }
            if (position1.startDate > position2.startDate) {
              return -1
            }
            return 0
          })
        for (let alternateUserPosition of positions) {
          currentUserValues = getListOfValues().filter(
            (value) => value.id && value.id === alternateUserPosition.id
          )
          if (currentUserValues.length > 0) {
            //the first in the list of positions that also appears in the listOfValues is the newest position,
            // so select it and get out of the loop
            field.value.intValue = currentUserValues[0].id
            break
          }
        }
      }
      break
    case 4: //All Active Users
    default: //(just using this for the default case because it's simplest)
      //a field with System List Type of “All Active Users” returns a distinct list of users and uses the userId as the value.id
      let currentUserPosition = getListOfValues().find(
        (value) => value.id && value.id === currentUserId.value
      )
      if (currentUserPosition) {
        field.value.intValue = currentUserPosition.id
      }
      break
  }
  //if the current user is not found in the list, do nothing
  if (field.value.intValue) {
    handleInput(field.value.intValue)
  }
}
</script>

<style lang="scss">
.cvi-rich-text-editor-readonly .ql-container {
  //border-top: solid 1px #ccc !important;
  border: none;
  border-radius: 0.25em;
  background-color: var(--v-grey-lighten3);
  padding: 16px;
}

.cvi-rich-text-editor .ql-container {
  height: auto !important;
  width: 100%;
  color: rgba(0, 0, 0, 0.87); //default-text-color
  font-size: 1rem; //body-large
  font-weight: 400;
  font-family: lato;
  line-height: 1.6;
}

.cvi-rich-text-editor-readonly .ql-toolbar {
  display: none;
}

.cvi-rich-text-editor-required {
  border: solid 2px red !important;
}

.cvi-rich-text-label {
  font-size: 11px;
  font-family: Lato, sans-serif;
}
</style>

<style scoped lang="scss">
.ancillary {
  font-size: 12px;
}

.field-picker {
  border-bottom: solid 1px rgba(0, 0, 0, 0.4);
  height: 27px;
  min-width: 100%;
}
</style>
