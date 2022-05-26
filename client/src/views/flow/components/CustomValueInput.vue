<template>
  <div>
    <v-row class="d-flex justify-space-between align-center">
      <v-col v-if="showFieldName">
        {{ field.fieldName }}
        <span class="ancillary" v-if="field.ancillaryCustomFieldHint">{{ field.ancillaryCustomFieldHint }}</span>
        <span class="ancillary" v-else-if="field.useParentData">(Parent)</span>
        <span class="ancillary" v-else-if="field.ancillaryCustomFieldGroupAssignmentId">(Primary)</span>
      </v-col>

      <v-col class="d-flex justify-start align-self-start py-0">
        <DatetimePickerInput
          v-if="field.dataTypeId === 1"
          v-model="field.dateValue"
          :timezone="this.timezone"
          :type="'date'"
          :allow-now="field.allowNow"
          :required="required"
          :min-date="minDate"
          :max-date="maxDate"
          :filled="filledStyle"
          :format="'MMMM DD, YYYY'"
          :label="getFieldName()"
          :hide-details="hideDetails"
          :readonly="readonly"
          :custom-class="readonly ? 'error--text' : ''"
          @input="callback(field)"
        />

        <DatetimePickerInput
          v-if="field.dataTypeId === 2"
          v-model="field.timestampValue"
          :timezone="this.timezone"
          type="timestamp"
          :allow-now="field.allowNow"
          :filled="filledStyle"
          :required="required"
          :format="'MMMM DD, YYYY, h:mm A'"
          :label="getFieldName()"
          :hide-details="hideDetails"
          :readonly="readonly"
          :custom-class="readonly ? 'error--text' : ''"
          @input="callback(field)"
        />

        <v-checkbox
          v-if="field.dataTypeId === 3"
          v-model="field.booleanValue"
          :required="required"
          :label="getFieldName()"
          :hide-details="hideDetails"
          :rules="getRequiredRule()"
          :filled="filledStyle"
          :disabled="readonly"
          :readonly="readonly"
          :class="{'error--text': readonly}"
          :ripple="false"
          @change="callback(field)"
        />

        <v-text-field
          v-if="field.dataTypeId === 4"
          text
          :required="required"
          :readonly="readonly"
          :disabled="readonly"
          :class="{'error--text': readonly}"
          placeholder=" "
          :rules="getRequiredRule()"
          :filled="filledStyle"
          :label="getFieldName()"
          :hide-details="hideDetails"
          type="number"
          v-model.number="field.numericValue"
          @change="callback(field)"
          autocomplete="off"
        />

<!--        12 is the new SYSTEM_readonly field. but i think we can use this same field as id=10 will ALWAYS be readonly and (never required i think)-->
        <v-textarea
          v-if="field.dataTypeId === 5 || field.dataTypeId === 12"
          auto-grow
          rows="1"
          :required="required"
          :readonly="readonly"
          :disabled="readonly"
          :class="{'error--text': readonly}"
          placeholder=" "
          :rules="getRequiredRule()"
          :filled="filledStyle"
          :label="getFieldName()"
          :hide-details="hideDetails"
          v-model="field.textValue"
          @change="callback(field)"
          autocomplete="off"
        />

        <v-text-field
          v-if="field.dataTypeId === 6 && !field.hasListValues"
          text
          :required="required"
          :readonly="readonly"
          :disabled="readonly"
          :class="{'error--text': readonly}"
          :label="getFieldName()"
          :hide-details="hideDetails"
          placeholder=" "
          :filled="filledStyle"
          :rules="getRequiredRule()"
          type="number"
          v-model.number="field.intValue"
          @change="callback(field)"
          autocomplete="off"
        />

        <v-autocomplete
          v-if="field.dataTypeId === 6 && field.hasListValues"
          v-model="field.intValue"
          text
          :hide-no-data="field.lazyLoadValues"
          :required="required"
          :clearable="!readonly"
          :readonly="readonly"
          :disabled="readonly"
          :class="{'error--text': readonly}"
          :loading="isLoading"
          placeholder=" "
          :filled="filledStyle"
          item-disabled="archived"
          :rules="getRequiredRule()"
          :items="field.listOfValues"
          :label="getFieldName()"
          :hide-details="hideDetails"
          item-value="id"
          item-text="name"
          @input="callback(field)"
          autocomplete="off"
        >
          <template #item="{ item }">
            <v-list-item-content>
              <v-list-item-title v-text="item.name"/>
              <v-list-item-subtitle v-if="item.description" v-text="item.description"/>
            </v-list-item-content>
          </template>
        </v-autocomplete>

        <v-autocomplete
          v-if="field.dataTypeId === 7 || field.dataTypeId === 10"
          text
          :required="required"
          multiple
          placeholder=" "
          v-model="field.intArrayValue"
          :hide-no-data="field.lazyLoadValues"
          :search-input.sync="search"
          :filled="filledStyle"
          :items="field.listOfValues"
          item-disabled="archived"
          :clearable="!readonly"
          :readonly="readonly"
          :disabled="readonly"
          :class="{'error--text': readonly}"
          :rules="getRequiredRule(field.dataTypeId)"
          :label="getFieldName()"
          :hide-details="hideDetails"
          item-value="id"
          item-text="name"
          @input="callback(field)"
          autocomplete="off"
        >
          <template #item="{ item }">
            <v-list-item-content>
              <v-list-item-title v-text="item.name"/>
              <v-list-item-subtitle v-if="item.description" v-text="item.description"/>
            </v-list-item-content>
          </template>
        </v-autocomplete>

        <v-autocomplete
          v-if="field.dataTypeId === 8"
          v-model="field.intValue"
          text
          :required="required"
          :search-input.sync="search"
          :hide-no-data="field.lazyLoadValues"
          :clearable="!readonly"
          :filled="filledStyle"
          item-disabled="archived"
          :readonly="readonly"
          :disabled="readonly"
          :class="{'error--text': readonly}"
          :items="field.listOfValues"
          :label="getFieldName()"
          :hide-details="hideDetails"
          :rules="getRequiredRule()"
          placeholder=" "
          item-value="id"
          item-text="name"
          @input="callback(field)"
          autocomplete="off"
        >
          <template #item="{ item }">
            <v-list-item-content>
              <v-list-item-title v-text="item.name"/>
              <v-list-item-subtitle v-if="item.description" v-text="item.description"/>
            </v-list-item-content>
          </template>
        </v-autocomplete>

        <v-autocomplete
          v-if="field.dataTypeId === 9"
          v-model="field.intValue"
          :search-input.sync="search"
          :hide-no-data="field.lazyLoadValues"
          text
          :filled="filledStyle"
          :required="required"
          :clearable="!readonly"
          item-disabled="archived"
          :items="field.listOfValues"
          :label="getFieldName()"
          :hide-details="hideDetails"
          :readonly="readonly"
          :disabled="readonly"
          :class="{'error--text': readonly}"
          :rules="getRequiredRule()"
          placeholder=" "
          item-value="id"
          item-text="name"
          @input="callback(field)"
          autocomplete="off"
        >
          <template #item="{ item }">
            <v-list-item-content>
              <v-list-item-title v-text="item.name"/>
              <v-list-item-subtitle v-if="item.description" v-text="item.description"/>
            </v-list-item-content>
          </template>
        </v-autocomplete>

        <div v-if="field.dataTypeId === 13">
          <!-- this hidden text field makes the form's required fields validation work -->
          <v-text-field style="display: none;" v-model="field.richTextValue" :required="required" :rules="getRequiredRule()">
          </v-text-field>
          <div class="rich-text-label" v-if="!hideLabel && !showFieldName">
            {{ getFieldName() }}
          </div>
          <quill-editor
            :options="toolbarOptions"
            class="rich-text-editor"
            :class="{'rich-text-editor-required': required && !field.richTextValue,
                     'rich-text-editor-readonly': readonly}"
            :readonly="readonly"
            :disabled="readonly"
            @change="(q) => doRichTextFieldCallback(field, q)"
            v-model="field.richTextValue"
          />
          <div class="rich-text-label error--text" v-if="required && !field.richTextValue">
            Field is required
          </div>
        </div>

      </v-col>
    </v-row>
    <v-row v-if="field.lazyLoadValues && field.values">
      <v-col/>
      <v-col>
        Current Value(s): {{ field | fieldValues }}
      </v-col>
    </v-row>
  </div>
</template>

<script>
import debounce from "lodash.debounce"
import DatetimePickerInput from "@/components/DatetimePickerInput.vue"
import constants from "@/helpers/constants"
import 'quill/dist/quill.snow.css'
import {quillEditor} from 'vue-quill-editor'
import {getRequestWithParams} from "@/helpers/helpers"

export default {
  name: "CustomValueInput",
  props: {
    apiPath: {
      type: String,
      default: "flow"
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
    minDate: String,
    maxDate: String,
    //had to add filledStyle to allow the AHJ screens to use the custom value input but keep its same style. that makes me super happy
    filledStyle: Boolean,
    callback: Function
  },
  components: {
    DatetimePickerInput,
    QuillEditor: quillEditor,
  },
  filters: {
    fieldValues: function (field) {
      if (Array.isArray(field.values)) {
        return field?.values?.join(', ')
      }
      return field.values
    }
  },
  computed: {
    fieldAncillaryName() {
      if (this.field.ancillaryCustomFieldHint) {
        return this.field.fieldName + ' ' + this.field.ancillaryCustomFieldHint
      } else if (this.field.useParentData) {
        return this.field.fieldName + ' (Parent)'
      } else if (this.field.ancillaryCustomFieldGroupAssignmentId) {
        return this.field.fieldName + ' (Ancillary)'
      } else {
        return this.field.fieldName
      }
    },
  },
  data() {
    return {
      search: null,
      isLoading: false,
      toolbarOptions: {
        modules: {
          toolbar: [
            ['bold', 'italic', 'underline', 'blockquote'], //toggled buttons
            [{ 'color': [] }, { 'background': [] }],          // dropdown with defaults from theme
            [{ 'size': ['small', 'normal', 'large', 'huge'] }],  // custom dropdown
            ['clean']                                         // remove all formatting button
          ],
        }
      },
      requiredRules: constants.BASIC_REQUIRED_RULE,
      arrayRequiredRules: constants.BASIC_ARRAY_REQUIRED_RULE,
      timezone: this.$store.state.user.details?.timezone?.value
    }
  },
  // leaving this here in case we need to start showing the (Parent) / (Primary) stuff on the ancillary fields on the project
  // computed: {
  // displayedFieldName () {
  //   return this.field.useParentData ? this.field.fieldName + ' (Parent)' : this.field.ancillaryCustomFieldGroupAssignmentId ? this.field.fieldName + ' (Primary)' : this.field.fieldName
  // }
  // },
  watch: {
    search(val) {
      if (this.field.lazyLoadValues) {
        this.getItems(val)
      }
    }
  },

  methods: {
    doRichTextFieldCallback(field, quill) {
      field.textValue = quill?.text || null
      this.callback(field)
    },
    getFieldName() {
      return this.hideLabel ? null : this.useFieldAncillaryName ? this.fieldAncillaryName : this.field.fieldName
    },
    getRequiredRule(dataTypeId) {
      if (this.required && [7, 10].includes(dataTypeId)) {
        return this.arrayRequiredRules
      } else if (this.required) {
        return this.requiredRules
      }
    },

    getItems: debounce(async function (query = "") {
      try {
        if (query) {
          this.isLoading = false
          const {data = []} = await getRequestWithParams(`/customField/${this.field.id}/values`, {params: {query}}, this.apiPath, [])
          this.field.listOfValues = [...data]
        }
      } finally {
        this.isLoading = false
      }
    }, 250)
  }
}
</script>

<style lang="scss">
 .rich-text-editor .ql-container {
   height: auto !important;
 }

 .rich-text-editor-readonly .ql-toolbar {
   display: none;
 }

 .rich-text-editor-readonly .ql-container {
   border-top: solid 1px #ccc !important;
 }

 .rich-text-editor-required {
   border: solid 2px red !important;
 }

 .rich-text-label {
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
