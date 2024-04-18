<template>
  <v-menu
      v-model="menu"
      :close-on-content-click="false"
      transition="scale-transition"
      offset-y
      :content-class="contentClass"
      max-width="290px"
      min-width="290px"
  >
    <template #activator="{on}">
      <a-text-field
          :class="[customClass, {'no-icon-click': !allowNow}]"
          :value="value | formatDate(type, format, type === 'time' ? 'HH:mm' : null)"
          :label="label"
          :placeholder="placeholder"
          :rules="getRequiredRule()"
          :prepend-icon="hidePrependIcon ? '' : 'event'"
          :append-inner-icon="showAppendIcon ? 'event' : ''"
          readonly
          color="primary"
          class="datetime-picker-input"
          clear-icon="mdi-close-circle"
          :clearable="!readonly"
          :disabled="readonly"
          v-on="!readonly && on"
          @click:clear="clearInput"
          @click:append="setNow"
          @click:prepend="setNow"
          :hide-details="hideDetails"
          :density="dense ? 'compact' : 'default'"
          :variant="outlined ? 'outlined' : variant || 'plain'"
      />
    </template>
    <v-date-picker
        v-if="showDate"
        v-model="dateRef"
        class="qa-date-picker"
        :min="minDate"
        :max="maxDate"
        @click:date="saveDate()"
    >
      <v-spacer></v-spacer>
      <a-btn
          variant="text"
          color="primary"
          @click="cancel()"
          text="Cancel"
      ></a-btn>
      <a-btn
          variant="text"
          color="primary"
          @click="saveDate()"
          text="Ok"
      ></a-btn>
    </v-date-picker>

    <v-time-picker
        v-model="localTime"
        v-if="showTime"
        class="qa-time-picker"
        :allowed-minutes="props.allowedMinutes !== undefined ? props.allowedMinutes : m => m % minuteIncrement === 0"
        :ampm-in-title="true"
    >
      <v-spacer></v-spacer>
      <a-btn
          variant="text"
          color="primary"
          class="qa-date-cancel"
          @click="cancel()"
          text="Cancel"
      ></a-btn>
      <a-btn
          variant="text"
          color="primary"
          class="qa-date-ok"
          @click="saveTime()"
          text="OK"
      ></a-btn>
    </v-time-picker>
  </v-menu>
</template>
<script setup>

import {DateTime} from 'luxon'
import moment from 'moment'
import constants from '@/helpers/constants'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const emit = defineEmits(['input'])

const props = defineProps({
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
  variant: String, //eventually this should only be using variant but i am only working on v-text-fields for now
  outlined: String,
  customClass: String,
  customContentClass: String,
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
})
const { value: propsValue, timezone, type, label, placeholder, format, inputFormat, minDate, maxDate,
  hidePrependIcon, hideDetails, dense, outlined, customClass, customContentClass, showAppendIcon, allowNow, required, readonly } = toRefs(props)

const dateToUse = ref(null)
const dateRef = ref(null)
const utcDate = ref(null)
const time = ref(null)
const menu = ref(false)
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
const showDate = ref(false)
const showTime = ref(false)
//i'm not sure what the default here will be for normal timestamps. i'm guessing 'YYYY-MM-DD HH:mm:ss' but feel free to change it if that is not the case
const defaultTimeFormat = ref('YYYY-MM-DD HH:mm:ss')

onMounted(() => {
  init()
})
watch(propsValue, async() => {
  if(null == propsValue.value) {
    //re-init if the field ever gets nulled out
    init()
  }
})

//if the company has set a default minute increment, use that. otherwise use 1
const minuteIncrement = computed(() => {
  return userStore.details.minuteIncrement || 1
})

const contentClass = computed(() => {
  return 'qa-date-menu ' + customContentClass.value
})

const localTime = computed({
  get() {
    return propsValue.value
        ? moment.utc(propsValue.value, (inputFormat.value ?? defaultTimeFormat.value)).tz(timezone.value).format('HH:mm')
        : moment().startOf('hour').format('HH:mm')
  },
  set(date) {
    return setFunction(date)
  }
})

const getRequiredRule = () => {
  if(required.value) {
    return requiredRules.value
  }
}
const setFunction = (date) => {
  //date in this context = the current time in non-utc time
  //we have to combine the selected date with the current time in non-utc in case they have selected date with a different daylight savings time than "NOW"
  let combined = dateRef.value + ' ' + date
  time.value = moment.tz(combined, 'yyyy-MM-DD HH:mm', timezone.value).utc().format('HH:mm')

  // time.value = moment.tz(date, 'HH:mm', timezone).utc().format('HH:mm')
  // ^^ this is the old way, in case i broke something

  // this date will be used in case the time selected pushes the utc date to the next day
  utcDate.value = moment(dateRef.value + ' ' + date).utc().format('yyyy-MM-DD')

  return date
}
const changeHandler =  () => {
  //@humes hopefully this doesn't break anything. if no changeCallback is passed in it shouldn't do anything
  if(props.changeCallback) {
    props.changeCallback()
  }
}
const saveDate =  () => {

  if (type.value === 'date') {
    DateTime.local()
    emit('input', DateTime.fromFormat(dateRef.value, 'yyyy-MM-dd').toISODate())
    menu.value = false
  } else {
    //the localDate setter was doing exactly what was needed to the date but we need to convert time.value to the "timezone"
    //value before sending everything to the setFunction because this is what the date picker does
    setFunction(moment.utc(time.value, 'HH:mm').tz(timezone.value).format('HH:mm'))
    // setFunction(moment.utc(dateRef.value))
    showDate.value = false
    showTime.value = true
  }
  changeHandler()
}
const saveTime =  () => {
  if (type.value === 'timestamp') {
    // if(!utcDate.value) {
    //   let test = moment
    //   let dateTime = DateTime
    //   utcDate.value = moment(date.value + ' ' + time.value).format('yyyy-MM-DD')
    // }
    const date = DateTime.fromFormat(utcDate.value, 'yyyy-MM-dd', {zone: 'utc'})
    // const date = utcDate.value ? DateTime.fromFormat(utcDate.value, 'yyyy-MM-dd', {zone: 'utc'})
    // : DateTime.fromFormat(date.value, 'yyyy-MM-dd', {zone: 'utc'})
    let timeHere = DateTime.fromISO(time.value, {zone: 'utc'})

    const datetime = timeHere.set({
      year: date.year,
      month: date.month,
      day: date.day
    })
    emit('input', datetime.toISO())
    showDate.value = true
    showTime.value = false
  } else {
    emit('input', DateTime.fromISO(time.value, {zone: 'utc'}).toISOTime())
  }
  menu.value = false
  changeHandler()
}
const cancel =  () => {
  menu.value = false
  init()
  changeHandler()
}
const init =  (overrideWithNow) => {
  let value
  if(!overrideWithNow) {
    value = DateTime.fromISO(propsValue.value, { zone: 'utc'})
  }

  // if (['timestamp', 'time'].includes(type.value)) {
  //   value = value.setZone(timezone)
  // }

  const now = DateTime.local()
  dateToUse.value = !overrideWithNow && (value.isValid) ? value : now
  dateRef.value = dateToUse.value.toFormat('yyyy-MM-dd')
  if(overrideWithNow) {
    time.value = dateToUse.value.toFormat('HH:mm')
    setFunction(time.value)
    saveDate()
    if(type.value === 'timestamp') {
      saveTime()
    }
  } else if(propsValue.value == null) {
    //if not previous value, set the time to the beginning of the current hour and do the setFunction thing that i dont even remember what it does now
    time.value = dateToUse.value.startOf('hour').toFormat('HH:mm')
    setFunction(time.value)
  } else {
    //if previous value, use that and dont do the setFunction thing
    time.value = dateToUse.value.toFormat('HH:mm')
  }

  if (['timestamp', 'date'].includes(type.value)) {
    showDate.value = true
    showTime.value = false
  } else {
    showDate.value = false
    showTime.value = true
  }
}
const clearInput =  () => {
  emit('input', null)
  changeHandler()
}
const setNow = () => {
  if(allowNow.value) {
    init(true)
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
