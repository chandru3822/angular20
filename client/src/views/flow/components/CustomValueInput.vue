<template>
<v-row class="d-flex justify-space-between align-center">
  <v-col v-if="showFieldName">
    {{field.fieldName}}
    <span class="ancillary" v-if="field.useParentData">(Parent)</span>
    <span class="ancillary" v-else-if="field.ancillaryCustomFieldGroupAssignmentId">(Primary)</span>
  </v-col>

  <v-col class="d-flex justify-start align-self-start py-0">
    <DatetimePickerInput
      v-if="field.dataTypeId === 1"
      v-model="field.dateValue"
      :timezone="this.timezone"
      :type="'date'"
      :required="required"
      :min-date="minDate"
      :max-date="maxDate"
      :filled="filledStyle"
      :format="'MMMM DD, YYYY'"
      :label="hideLabel ? null : field.fieldName"
      :hide-details="hideDetails"
      :readonly="readonly"
      @input="callback(field)"
    />

    <DatetimePickerInput
      v-if="field.dataTypeId === 2"
      v-model="field.timestampValue"
      :timezone="this.timezone"
      type="timestamp"
      :filled="filledStyle"
      :required="required"
      :format="'MMMM DD, YYYY, h:mm A'"
      :label="hideLabel ? null : field.fieldName"
      :hide-details="hideDetails"
      :readonly="readonly"
      @input="callback(field)"
    />

    <v-checkbox
      v-if="field.dataTypeId === 3"
      v-model="field.booleanValue"
      :required="required"
      :label="hideLabel ? null : field.fieldName"
      :hide-details="hideDetails"
      :rules="getRequiredRule()"
      :filled="filledStyle"
      :disabled="readonly"
      :ripple="false"
      @change="callback(field)"
    />

    <v-text-field
      v-if="field.dataTypeId === 4"
      text
      :required="required"
      :readonly="readonly"
      placeholder=" "
      :rules="getRequiredRule()"
      :filled="filledStyle"
      :label="hideLabel ? null : field.fieldName"
      :hide-details="hideDetails"
      type="number"
      v-model.number="field.numericValue"
      @change="callback(field)"
    />

    <v-textarea
      v-if="field.dataTypeId === 5"
      auto-grow
      rows="1"
      :required="required"
      :readonly="readonly"
      :disabled="readonly"
      placeholder=" "
      :rules="getRequiredRule()"
      :filled="filledStyle"
      :label="hideLabel ? null : field.fieldName"
      :hide-details="hideDetails"
      v-model="field.textValue"
      @change="callback(field)"
    />

    <v-text-field
      v-if="field.dataTypeId === 6 && !field.hasListValues"
      text
      :required="required"
      :readonly="readonly"
      :label="hideLabel ? null : field.fieldName"
      :hide-details="hideDetails"
      placeholder=" "
      :filled="filledStyle"
      :rules="getRequiredRule()"
      type="number"
      v-model.number="field.intValue"
      @change="callback(field)"
    />

    <v-autocomplete
      v-if="field.dataTypeId === 6 && field.hasListValues"
      v-model="field.intValue"
      text
      :required="required"
      :clearable="!readonly"
      :readonly="readonly"
      :disabled="readonly"
      placeholder=" "
      :filled="filledStyle"
      :rules="getRequiredRule()"
      :items="field.listOfValues"
      :label="hideLabel ? null : field.fieldName"
      :hide-details="hideDetails"
      item-value="id"
      item-text="name"
      @input="callback(field)"
   />

    <v-autocomplete
      v-if="field.dataTypeId === 7"
      text
      :required="required"
      multiple
      placeholder=" "
      :filled="filledStyle"
      :items="field.listOfValues"
      :clearable="!readonly"
      :readonly="readonly"
      :disabled="readonly"
      :rules="getRequiredRule()"
      :label="hideLabel ? null : field.fieldName"
      :hide-details="hideDetails"
      v-model="field.intArrayValue"
      item-value="id"
      item-text="name"
      @input="callback(field)"
    />

    <v-autocomplete
      v-if="field.dataTypeId === 8"
      v-model="field.intValue"
      text
      :required="required"
      :clearable="!readonly"
      :filled="filledStyle"
      :readonly="readonly"
      :disabled="readonly"
      :items="field.listOfValues"
      :label="hideLabel ? null : field.fieldName"
      :hide-details="hideDetails"
      :rules="getRequiredRule()"
      placeholder=" "
      item-value="id"
      item-text="name"
      @input="callback(field)"
    />

    <v-autocomplete
      v-if="field.dataTypeId === 9"
      v-model="field.intValue"
      text
      :filled="filledStyle"
      :required="required"
      :clearable="!readonly"
      :items="field.listOfValues"
      :label="hideLabel ? null : field.fieldName"
      :hide-details="hideDetails"
      :readonly="readonly"
      :disabled="readonly"
      :rules="getRequiredRule()"
      placeholder=" "
      item-value="id"
      item-text="name"
      @input="callback(field)"
    />
  </v-col>
</v-row>
</template>

<script>

import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import constants from '@/helpers/constants'

export default {
  name: 'CustomValueInput',
  props: {
    required: {
      type: Boolean,
      default: false
    },
    readonly: {
      type: Boolean,
      default: false
    },
    field: Object,
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
    DatetimePickerInput
  },
  data () {
    return {
      requiredRules: constants.BASIC_REQUIRED_RULE,
      timezone: this.$store.state.user.details?.timezone?.value
    }
  },
  // leaving this here in case we need to start showing the (Parent) / (Primary) stuff on the ancillary fields on the project
  // computed: {
    // displayedFieldName () {
    //   return this.field.useParentData ? this.field.fieldName + ' (Parent)' : this.field.ancillaryCustomFieldGroupAssignmentId ? this.field.fieldName + ' (Primary)' : this.field.fieldName
    // }
  // },
  methods: {
    getRequiredRule() {
      if(this.required) {
        return this.requiredRules
      }
    },
  }
}
</script>

<style scoped lang="scss">
.ancillary {
  font-size: 12px;
}
</style>

<style lang="scss">
  .field-picker {
    border-bottom: solid 1px rgba(0,0,0,0.4);
    height: 27px;
    min-width: 100%;
  }
</style>
