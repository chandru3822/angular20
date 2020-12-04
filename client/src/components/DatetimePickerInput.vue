<template>
<v-menu
  v-model="menu"
  :close-on-content-click="false"
  transition="scale-transition"
  offset-y
  max-width="290px"
  min-width="290px"
>
  <template #activator="{on}">
    <v-text-field
      :class="customClass"
      :value="value | formatDate(type, format, type === 'time' ? 'HH:mm' : null)"
      :label="label"
      :prepend-icon="hidePrependIcon ? '' : 'event'"
      :append-icon="showAppendIcon ? 'event' : ''"
      readonly
      clear-icon="mdi-close-circle"
      :clearable="!readonly"
      :disabled="readonly"
      v-on="!readonly && on"
      @click:clear="clearInput"
      :hide-details="hideDetails"
      :dense="dense"
      :outlined="outlined"
    />
  </template>
  <v-date-picker
    v-if="showDate"
    v-model="date"
    :min="minDate"
    :max="maxDate"
    @click:date="saveDate()"
  >
    <v-spacer></v-spacer>
    <v-btn text color="primaryCustom" @click="cancel()">Cancel</v-btn>
    <v-btn text color="primaryCustom" @click="saveDate()">OK</v-btn>
  </v-date-picker>

  <v-time-picker
    v-model="localTime"
    v-if="showTime"
    :allowed-minutes="allowedMinutes"
    :ampm-in-title="true"
  >
    <v-spacer></v-spacer>
    <v-btn text color="primaryCustom" @click="cancel()">Cancel</v-btn>
    <v-btn text color="primaryCustom" @click="saveTime()">OK</v-btn>
  </v-time-picker>
</v-menu>
</template>


<script>

import {DateTime} from 'luxon'
import moment from 'moment'

export default {
  name: 'DatetimePickerInput',
  props: {
    value: String,
    timezone: String,
    type: String,
    label: String,
    format: String,
    inputFormat: String,
    minDate: String,
    maxDate: String,
    hidePrependIcon: Boolean,
    hideDetails: Boolean,
    dense: String,
    outlined: String,
    customClass: String,
    //if this is empty it shows all minutes
    allowedMinutes: Function,
    showAppendIcon: Boolean,
    changeCallback: Function,
    readonly: {
      type: Boolean,
      default: false
    },
  },
  data: () => ({
    date: null,
    utcDate: null,
    time: null,
    menu: false,
    showDate: false,
    showTime: false,
    //i'm not sure what the default here will be for normal timestamps. i'm guessing 'YYYY-MM-DD HH:mm:ss' but feel free to change it if that is not the case
    defaultTimeFormat: 'YYYY-MM-DD HH:mm:ss'
  }),
  created() {
    this.init()
  },
  computed: {
    localTime: {
      get: function() {
        return this.$props.value
          ? moment.utc(this.$props.value, (this.inputFormat ?? this.defaultTimeFormat)).tz(this.timezone).format('HH:mm')
          : moment().startOf('hour').format('HH:mm')
      },
      set: function (date) {
        this.time = moment.tz(date, 'HH:mm', this.timezone).utc().format('HH:mm')
        // this date will be used in case the time selected pushes the utc date to the next day
        this.utcDate = moment(this.date + ' ' + date).utc().format('yyyy-MM-DD')
        return date
      }
    }
  },
  methods: {
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
        this.showDate = false
        this.showTime = true
      }
      this.changeHandler()
    },
    saveTime () {
      if (this.type === 'timestamp') {
        const date = this.utcDate ? DateTime.fromFormat(this.utcDate, 'yyyy-MM-dd', {zone: 'utc'})
          : DateTime.fromFormat(this.date, 'yyyy-MM-dd', {zone: 'utc'})
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
    init () {
      // let value = DateTime.fromFormat(this.$props.value, 'HH:mm')
      let value = DateTime.fromISO(this.$props.value, { zone: 'utc'})

      // if (['timestamp', 'time'].includes(this.type)) {
      //   value = value.setZone(this.timezone)
      // }

      const now = DateTime.local().setZone('utc')
      this.dateToUse = (value.isValid) ? value : now
      this.date = this.dateToUse.toFormat('yyyy-MM-dd')
      this.time = this.dateToUse.startOf('hour').toFormat('HH:mm')

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
    }
  }
}
</script>

<style scoped lang="scss">
</style>
