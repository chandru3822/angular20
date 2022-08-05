<template>
<v-menu
  v-model="menu"
  :close-on-content-click="false"
  transition="scale-transition"
  offset-y
  content-class="qa-date-menu"
  max-width="290px"
  min-width="290px"
>
  <template #activator="{on}">
    <v-text-field
      :class="[customClass, {'no-icon-click': !allowNow}]"
      :value="value | formatDate(type, format, type === 'time' ? 'HH:mm' : null)"
      :label="label"
      :placeholder="placeholder"
      :rules="getRequiredRule()"
      :prepend-icon="hidePrependIcon ? '' : 'event'"
      :append-icon="showAppendIcon ? 'event' : ''"
      readonly
      class="datetime-picker-input"
      clear-icon="mdi-close-circle"
      :clearable="!readonly"
      :disabled="readonly"
      v-on="!readonly && on"
      @click:clear="clearInput"
      @click:append="setNow"
      @click:prepend="setNow"
      :hide-details="hideDetails"
      :dense="dense"
      :outlined="outlined"
    />
  </template>
  <v-date-picker
    v-if="showDate"
    v-model="date"
    class="qa-date-picker"
    :min="minDate"
    :max="maxDate"
    @click:date="saveDate()"
  >
    <v-spacer></v-spacer>
    <v-btn text color="primary" @click="cancel()">Cancel</v-btn>
    <v-btn text color="primary" @click="saveDate()">OK</v-btn>
  </v-date-picker>

  <v-time-picker
    v-model="localTime"
    v-if="showTime"
    class="qa-time-picker"
    :allowed-minutes="allowedMinutes !== undefined ? allowedMinutes : m => m % minuteIncrement === 0"
    :ampm-in-title="true"
  >
    <v-spacer></v-spacer>
    <v-btn text color="primary" class="qa-date-cancel" @click="cancel()">Cancel</v-btn>
    <v-btn text color="primary" class="qa-date-ok" @click="saveTime()">OK</v-btn>
  </v-time-picker>
</v-menu>
</template>
<script>

import {DateTime} from 'luxon'
import moment from 'moment'
import constants from '@/helpers/constants'

export default {
  name: 'DatetimePickerInput',
  props: {
    value: String,
    timezone: String,
    type: String,
    label: String,
    placeholder: String,
    format: String,
    inputFormat: String,
    minDate: String,
    maxDate: String,
    hidePrependIcon: Boolean,
    hideDetails: Boolean,
    dense: String,
    outlined: String,
    customClass: String,
    //if this is empty it uses the company minute increment setting, if that is null then it shows all minutes
    allowedMinutes: Function,
    showAppendIcon: Boolean,
    changeCallback: Function,
    allowNow: Boolean,
    required: {
      type: Boolean,
      default: false
    },
    readonly: {
      type: Boolean,
      default: false
    },
  },
  data () {
    return {
      date: null,
      utcDate: null,
      time: null,
      menu: false,
      //if the company has set a default minute increment, use that. otherwise use 1
      minuteIncrement: this.$store.state.user.details.minuteIncrement || 1,
      requiredRules: constants.BASIC_REQUIRED_RULE,
      showDate: false,
      showTime: false,
      //i'm not sure what the default here will be for normal timestamps. i'm guessing 'YYYY-MM-DD HH:mm:ss' but feel free to change it if that is not the case
      defaultTimeFormat: 'YYYY-MM-DD HH:mm:ss'
    }
  },
  created() {
    this.init()
  },
  watch: {
    '$props.value': function () {
      if(null == this.$props.value) {
        //re-init if the field ever gets nulled out
        this.init()
      }
    }
  },
  computed: {
    localTime: {
      get: function() {
        return this.$props.value
          ? moment.utc(this.$props.value, (this.inputFormat ?? this.defaultTimeFormat)).tz(this.timezone).format('HH:mm')
          : moment().startOf('hour').format('HH:mm')
      },
      set: function (date) {
        return this.setFunction(date)
      }
    }
  },
  methods: {
    getRequiredRule() {
      if(this.required) {
        return this.requiredRules
      }
    },
    setFunction(date) {
      //date in this context = the current time in non-utc time
      //we have to combine the selected date with the current time in non-utc in case they have selected date with a different daylight savings time than "NOW"
      let combined = this.date + ' ' + date
      this.time = moment.tz(combined, 'yyyy-MM-DD HH:mm', this.timezone).utc().format('HH:mm')

      // this.time = moment.tz(date, 'HH:mm', this.timezone).utc().format('HH:mm')
      // ^^ this is the old way, in case i broke something

      // this date will be used in case the time selected pushes the utc date to the next day
      this.utcDate = moment(this.date + ' ' + date).utc().format('yyyy-MM-DD')

      return date
    },
    changeHandler () {
      //@humes hopefully this doesn't break anything. if no changeCallback is passed in it shouldn't do anything
      if(this.changeCallback) {
        this.changeCallback()
      }
    },
    saveDate () {

      if (this.type === 'date') {
        DateTime.local()
        this.$emit('input', DateTime.fromFormat(this.date, 'yyyy-MM-dd').toISODate())
        this.menu = false
      } else {
        //the localDate setter was doing exactly what was needed to the date but we need to convert this.time to the "this.timezone"
        //value before sending everything to the setFunction because this is what the date picker does
        this.setFunction(moment.utc(this.time, 'HH:mm').tz(this.timezone).format('HH:mm'))
        // this.setFunction(moment.utc(this.date))
        this.showDate = false
        this.showTime = true
      }
      this.changeHandler()
    },
    saveTime () {
      if (this.type === 'timestamp') {
        // if(!this.utcDate) {
        //   let test = moment
        //   let dateTime = DateTime
        //   this.utcDate = moment(this.date + ' ' + this.time).format('yyyy-MM-DD')
        // }
        const date = DateTime.fromFormat(this.utcDate, 'yyyy-MM-dd', {zone: 'utc'})
        // const date = this.utcDate ? DateTime.fromFormat(this.utcDate, 'yyyy-MM-dd', {zone: 'utc'})
          // : DateTime.fromFormat(this.date, 'yyyy-MM-dd', {zone: 'utc'})
        let time = DateTime.fromISO(this.time, {zone: 'utc'})

        const datetime = time.set({
          year: date.year,
          month: date.month,
          day: date.day
        })
        this.$emit('input', datetime.toISO())
        this.showDate = true
        this.showTime = false
      } else {
        this.$emit('input', DateTime.fromISO(this.time, {zone: 'utc'}).toISOTime())
      }
      this.menu = false
      this.changeHandler()
    },
    cancel () {
      this.menu = false
      this.init()
      this.changeHandler()
    },
    init (overrideWithNow) {
      let value
      if(!overrideWithNow) {
        // let value = DateTime.fromFormat(this.$props.value, 'HH:mm')
        value = DateTime.fromISO(this.$props.value, { zone: 'utc'})
      }

      // if (['timestamp', 'time'].includes(this.type)) {
      //   value = value.setZone(this.timezone)
      // }

      const now = DateTime.local()
      this.dateToUse = !overrideWithNow && (value.isValid) ? value : now
      this.date = this.dateToUse.toFormat('yyyy-MM-dd')
      if(overrideWithNow) {
        this.time = this.dateToUse.toFormat('HH:mm')
        this.setFunction(this.time)
        this.saveDate()
        if(this.type === 'timestamp') {
          this.saveTime()
        }
      } else if(this.$props.value == null) {
        //if not previous value, set the time to the beginning of the current hour and do the setFunction thing that i dont even remember what it does now
        this.time = this.dateToUse.startOf('hour').toFormat('HH:mm')
        this.setFunction(this.time)
      } else {
        //if previous value, use that and dont do the setFunction thing
        this.time = this.dateToUse.toFormat('HH:mm')
      }

      if (['timestamp', 'date'].includes(this.type)) {
        this.showDate = true
        this.showTime = false
      } else {
        this.showDate = false
        this.showTime = true
      }
    },
    clearInput () {
        this.$emit('input', null)
        this.changeHandler()
    },
    setNow() {
      if(this.allowNow) {
        this.init(true)
      }
    }
  }
}
</script>

<style lang="scss">
.datetime-picker-input label, .datetime-picker-input input {
  z-index: 0;
}

.no-icon-click .v-icon--link {
  cursor: default !important;
}
</style>
