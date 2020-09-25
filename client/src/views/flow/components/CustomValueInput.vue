<template>
<v-row class="d-flex justify-space-between align-center">
  <v-col v-if="showFieldName">
    {{field.fieldName}}
    <span class="ancillary" v-if="field.ancillaryCustomFieldGroupAssignmentId">(Ancillary)</span>
  </v-col>

  <v-col class="d-flex justify-start align-self-start py-0">

    <DatetimePickerInput
      v-if="field.dataTypeId === 1"
      v-model="field.dateValue"
      :timezone="this.timezone"
      :type="'date'"
      :format="'MMMM DD, YYYY'"
      :label="field.fieldName"
      :readonly="readonly"
      @input="callback(field)"
    />

    <DatetimePickerInput
      v-if="field.dataTypeId === 2"
      v-model="field.timestampValue"
      :timezone="this.timezone"
      type="timestamp"
      :format="'MMMM DD, YYYY, h:mm A'"
      :label="field.fieldName"
      :readonly="readonly"
      @input="callback(field)"
    />

    <v-checkbox
      v-if="field.dataTypeId === 3"
      v-model="field.booleanValue"
      :label="field.fieldName"
      :disabled="readonly"
      :ripple="false"
      @change="callback(field)"
    />

    <v-text-field
      v-if="field.dataTypeId === 4"
      text
      :readonly="readonly"
      placeholder=" "
      :label="field.fieldName"
      type="number"
      v-model.number="field.numericValue"
      @change="callback(field)"
    />

    <v-text-field
      v-if="field.dataTypeId === 5 && !field.multiLine"
      text
      :readonly="readonly"
      placeholder=" "
      :label="field.fieldName"
      v-model="field.textValue"
      @change="callback(field)"
    />

    <v-textarea
      v-if="field.dataTypeId === 5 && field.multiLine"
      auto-grow
      rows="1"
      :readonly="readonly"
      placeholder=" "
      :label="field.fieldName"
      v-model="field.textValue"
      @change="callback(field)"
    />

    <v-text-field
      v-if="field.dataTypeId === 6 && !field.hasListValues"
      text
      :readonly="readonly"
      :label="field.fieldName"
      placeholder=" "
      type="number"
      v-model.number="field.intValue"
      @change="callback(field)"
    />

    <v-autocomplete
      v-if="field.dataTypeId === 6 && field.hasListValues"
      v-model="field.intValue"
      text
      :clearable="!readonly"
      :readonly="readonly"
      :disabled="readonly"
      placeholder=" "
      :items="field.listOfValues"
      :label="field.fieldName"
      item-value="id"
      item-text="name"
      @input="callback(field)"
   />

    <v-autocomplete
      v-if="field.dataTypeId === 7"
      text
      multiple
      placeholder=" "
      :items="field.listOfValues"
      :clearable="!readonly"
      :readonly="readonly"
      :disabled="readonly"
      :label="field.fieldName"
      v-model="field.intArrayValue"
      item-value="id"
      item-text="name"
      @input="callback(field)"
    />

    <v-autocomplete
      v-if="field.dataTypeId === 8"
      v-model="field.intValue"
      text
      :clearable="!readonly"
      :readonly="readonly"
      :disabled="readonly"
      :items="field.listOfValues"
      :label="field.fieldName"
      placeholder=" "
      item-value="id"
      item-text="name"
      @input="callback(field)"
    />

    <v-autocomplete
      v-if="field.dataTypeId === 9"
      v-model="field.intValue"
      text
      :clearable="!readonly"
      :items="field.listOfValues"
      :label="field.fieldName"
      :readonly="readonly"
      :disabled="readonly"
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

export default {
  name: 'CustomValueInput',
  props: {
    readonly: {
      type: Boolean,
      default: false
    },
    field: Object,
    showFieldName: {
      type: Boolean,
      default: true
    },
    callback: Function
  },
  components: {
    DatetimePickerInput
  },
  data () {
    return {
      timezone: this.$store.state.user.details.timezone.value
    }
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
