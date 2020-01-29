<template>
<v-row class="d-flex justify-space-between align-center">
  <v-col v-if="showFieldName">
    {{field.fieldName}}
    <span class="ancillary" v-if="field.ancillaryCustomFieldGroupAssignmentId">(Ancillary)</span>
  </v-col>

  <v-col class="d-flex justify-end align-self-start">
    <template v-if="field.dataTypeId === 1">

      <span v-if="readonly">{{ field.dateValue | formatDate('date') }}</span>

      <datetime
        v-else
        class="text-right"
        v-model="field.dateValue"
        input-class="one-hunned"
        :zone="timezone"
        :format="{ year: 'numeric', month: 'long', day: 'numeric' }"
        :phrases="{ok: 'Ok', cancel: 'Close'}"
        auto
      />
    </template>


<!--    <template v-if="field.dataTypeId === 2">-->

<!--      <span v-if="readonly">{{field.timestampValue | formatDate('timestamp')}}</span>-->

<!--      <datetime-->
<!--        v-else-->
<!--        class="datetime-input"-->
<!--        type="datetime"-->
<!--        v-model="field.timestampValue"-->
<!--        :zone="timezone"-->
<!--        :format="{ year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: '2-digit' }"-->
<!--        :phrases="{ok: 'Ok', cancel: 'Close'}"-->
<!--        :hour-step="1"-->
<!--        :minute-step="15"-->
<!--        use12-hour-->
<!--        auto-->
<!--      />-->
<!--    </template>-->


    <DatetimePickerInput
      v-if="field.dataTypeId === 2"
      v-model="field.timestampValue"
      :timezone="this.$store.state.user.details.timezone.value"
      type="datetime"
      :label="field.fieldName"
    />

    <input
      v-if="field.dataTypeId === 3"
      type="checkbox"
      v-model="field.booleanValue"
      :disabled="readonly"
    />

    <v-text-field
      v-if="field.dataTypeId === 4"
      text
      :readonly="readonly"
      placeholder=" "
      :label="field.fieldName"
      v-model="field.numericValue"
    />

    <v-text-field
      v-if="field.dataTypeId === 5"
      text
      :readonly="readonly"
      placeholder=" "
      :label="field.fieldName"
      v-model="field.textValue"
    />

    <v-text-field
      v-if="field.dataTypeId === 6 && !field.hasListValues"
      text
      :readonly="readonly"
      :label="field.fieldName"
      placeholder=" "
      v-model="field.intValue"
    />

    <v-select
      v-if="field.dataTypeId === 6 && field.hasListValues"
      v-model="field.intValue"
      text
      :readonly="readonly"
      placeholder=" "
      :items="field.listOfValues"
      :label="field.fieldName"
      item-value="id"
      item-text="name"
   />

    <v-text-field
      v-if="field.dataTypeId === 7"
      text
      placeholder=" "
      :readonly="readonly"
      :label="field.fieldName"
      v-model="field.intArrayValue"
    />

    <v-select
      v-if="field.dataTypeId === 8"
      v-model="field.intValue"
      text
      :items="field.listOfValues"
      :label="field.fieldName"
      :readonly="readonly"
      placeholder=" "
      item-value="id"
      item-text="name"
    />

    <v-select
      v-if="field.dataTypeId === 9"
      v-model="field.intValue"
      text
      :items="field.listOfValues"

      :readonly="readonly"
      placeholder=" "
      item-value="id"
      item-text="name"
    />
  </v-col>
</v-row>
</template>

<script>

import { Datetime } from 'vue-datetime'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import moment from 'moment'

export default {
  name: 'CustomValueInput',
  props: {
    readonly: Boolean,
    field: Object,
    showFieldName: {
      type: Boolean,
      default: true
    }
  },
  components: {
    Datetime,
    DatetimePickerInput
  },
  data () {
    return {
      // todo: allow the component to pass in the format
      // todo: allow the component to pass in readonly value to config.clickOpens
      timezone: this.$store.state.user.details.timezone.value,
      config: {
        altFormat: 'F j, Y h:i K',
        altInput: true,
        altInputClass: 'field-picker',
        allowInput: false,
        time_24hr: false,
        enableTime: true,
        clickOpens: true,
        dateFormat: 'Z'
      }
    }
  },
  computed: {
    // formattedDateTime: function () {
    //   const dateTime = this.field.dateValue || this.field.timestampValue
    //   return moment(dateTime).tz(this.timezone).format('MMMM D, YYYY, H:mm A')
    // }
  }
}
</script>

<style scoped lang="scss">
.ancillary {
  font-size: 12px;
}

.datetime-input {
  width: 100%;
}
</style>

<style lang="scss">
  .field-picker {
    border-bottom: solid 1px rgba(0,0,0,0.4);
    height: 27px;
    min-width: 100%;
  }
</style>
