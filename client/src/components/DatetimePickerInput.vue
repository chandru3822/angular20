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
      :value="value | formatDate(type, format, type === 'time' ? 'HH:mm' : null)"
      :label="label"
      prepend-icon="event"
      readonly
      clear-icon="mdi-close-circle"
      :clearable="!readonly"
      :disabled="readonly"
      v-on="!readonly && on"
    />
  </template>
  <v-date-picker
    v-if="showDate"
    v-model="date"
  >
    <v-spacer></v-spacer>
    <v-btn text color="primary" @click="cancel()">Cancel</v-btn>
    <v-btn text color="primary" @click="saveDate()">OK</v-btn>
  </v-date-picker>

  <v-time-picker
    v-model="time"
    v-if="showTime"
    :ampm-in-title="true"
  >
    <v-spacer></v-spacer>
    <v-btn text color="primary" @click="cancel()">Cancel</v-btn>
    <v-btn text color="primary" @click="saveTime()">OK</v-btn>
  </v-time-picker>
</v-menu>
</template>


<script>

import {DateTime} from 'luxon'

export default {
  name: 'DatetimePickerInput',
  props: {
    value: String,
    timezone: String,
    type: String,
    label: String,
    format: String,
    readonly: {
      type: Boolean,
      default: false
    },
  },
  data: () => ({
    date: null,
    time: null,
    menu: false,
    showDate: false,
    showTime: false
  }),
  created() {
    this.init()
  },
  methods: {
    saveDate () {
      if (this.type === 'date') {
        DateTime.local()
        this.$emit('input', DateTime.fromFormat(this.date, 'yyyy-MM-dd').toISODate())
        this.menu = false
      } else {
        this.showDate = false
        this.showTime = true
      }
    },
    saveTime () {
      if (this.type === 'timestamp') {
        const date = DateTime.fromFormat(this.date, 'yyyy-MM-dd', {zone: this.timezone})
        let time = DateTime.fromISO(this.time, {zone: this.timezone})
        const datetime = time.set({
          year: date.year,
          month: date.month,
          day: date.day
        })
        this.$emit('input', datetime.toISO())
        this.showDate = true
        this.showTime = false
      } else {
        this.$emit('input', DateTime.fromISO(this.time, {zone: this.timezone}).toISOTime())
      }
      this.menu = false
    },
    cancel () {
      this.menu = false
      this.init()
    },
    init () {
      let value = DateTime.fromISO(this.$props.value)

      if (['timestamp', 'time'].includes(this.type)) {
        value = value.setZone(this.timezone)
      }

      const now = DateTime.local().setZone(this.timezone)
      const dateToUse = (value.isValid) ? value : now
      this.date = dateToUse.toFormat('yyyy-MM-dd')
      this.time = dateToUse.toFormat('HH:mm')

      if (['timestamp', 'date'].includes(this.type)) {
        this.showDate = true
        this.showTime = false
      } else {
        this.showDate = false
        this.showTime = true
      }
    }
  }
}
</script>

<style scoped lang="scss">
</style>
