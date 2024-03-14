<template>
  <v-card flat color="transparent">
    <h4 class="mb-3">{{rruleText}}</h4>
    <v-select attach v-model="rruleRef.frequency"
              :items="rruleConfig.frequencies"
              label="Repeats"
              item-text="label"
              return-object
              :readonly="readonly"
              :disabled="readonly"
              @input="updateRecurrenceString"
              autocomplete="off">
    </v-select>
    <v-text-field text
                  type="number"
                  label="Repeat every (add here)"
                  placeholder=" "
                  :readonly="readonly"
                  :disabled="readonly"
                  @input="updateRecurrenceString"
                  v-model="rruleRef.interval"></v-text-field>
    <v-select attach v-model="rruleRef.months"
              :items="rruleConfig.months"
              label="By Month"
              item-text="label"
              return-object
              multiple
              clearable
              :readonly="readonly"
              :disabled="readonly"
              @input="updateRecurrenceString"
              autocomplete="off">
    </v-select>
    <v-select attach v-model="rruleRef.daysOfWeek"
              :items="rruleConfig.daysOfWeek"
              label="By Day of Week"
              item-text="label"
              return-object
              clearable
              :readonly="readonly"
              :disabled="readonly"
              @input="updateRecurrenceString"
              multiple
              autocomplete="off">
    </v-select>

    <label>Ends</label>
    <v-radio-group :readonly="readonly"
                   :disabled="readonly"
                   v-model="rruleRef.endsType" @change="updateRecurrenceString">
      <v-radio label="Never" :value="0"></v-radio>
      <div class="flex-display align-center">
        <v-radio class="mb-0" value="fixed"></v-radio>
        After
        <v-text-field text
                      type="number"
                      label=""
                      solo
                      :readonly="readonly"
                      :disabled="readonly"
                      @input="updateRecurrenceString"
                      hide-details
                      class="mx-2 shrink"
                      placeholder=" "
                      v-model="rruleRef.count"></v-text-field>
        occurrences
      </div>
      <div class="flex-display align-center">
        <v-radio class="mb-0" value="date"></v-radio>
        On
        <DatetimePickerInput
            v-model="rruleRef.endDate"
            :min-date="minDate"
            :max-date="maxDate"
            :hide-prepend-icon="true"
            :show-append-icon="true"
            custom-class="shrink ml-2"
            :readonly="readonly"
            :change-callback="updateRecurrenceString"
            :input-format="'YYYY-MM-DD'"
            :type="'date'"
            :format="'MM/DD/YYYY'"
        />
      </div>

    </v-radio-group>

  </v-card>
</template>

<script setup>
import { RRule } from 'rrule'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import moment from 'moment-timezone'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"
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
  recurrence: String,
  itemId: Number,
  recurrenceCallback: Function,
  readonly: Boolean
})
const { recurrence, itemId, readonly } = toRefs(props)

const minDate = ref(moment().format('YYYY-MM-DDTHH:mm:ssZ'))
const maxDate = ref(moment().add(1, 'y').add(1, 'd').format('YYYY-MM-DDTHH:mm:ssZ'))
const rruleRef = ref({})
const rruleText = ref('')
const rruleEnd = ref('')
const rruleString = ref('')
const rruleSubString = ref('')
const rruleConfig = ref({
  frequencies: [
    {label: 'Daily', unit: 'days', id: RRule.DAILY},
    {label: 'Weekly', unit: 'weeks', id: RRule.WEEKLY},
    {label: 'Monthly', unit: 'months', id: RRule.MONTHLY},
    {label: 'Yearly', unit: 'years', id: RRule.YEARLY}
  ],
  months: [
    {label: 'January', id: 1},
    {label: 'February', id: 2},
    {label: 'March', id: 3},
    {label: 'April', id: 4},
    {label: 'May', id: 5},
    {label: 'June', id: 6},
    {label: 'July', id: 7},
    {label: 'August', id: 8},
    {label: 'September', id: 9},
    {label: 'October', id: 10},
    {label: 'November', id: 11},
    {label: 'December', id: 12}
  ],
  daysOfWeek: [
    {label: 'Sunday', id: RRule.SU},
    {label: 'Monday', id: RRule.MO},
    {label: 'Tuesday', id: RRule.TU},
    {label: 'Wednesday', id: RRule.WE},
    {label: 'Thursday', id: RRule.TH},
    {label: 'Friday', id: RRule.FR},
    {label: 'Saturday', id: RRule.SA}
  ]
})
watch(itemId, async() => {
  //have to re-init when they click a different appointment in a data table
  initRecurrence()
})


onMounted(() => {
  initRecurrence()
})

const initRecurrence = () => {
  if (recurrence.value) {
    initRule()
  } else {
    rruleRef.value = {
      frequency: rruleConfig.value.frequencies[0],
      //endsType is supposed to be an empty string but vuetify radio buttons dont work with empty string as the value. it sets the value to 0 instead. will handle later
      endsType: 0,
      count: 1,
      interval: 1,
      months: [],
      daysOfWeek: []
    }
    // let rrule = RRule.fromString(rru.value)
    updateRecurrenceString(rruleRef.value)
  }
}
const populateRecurrenceString = (rrule) => {
  rruleText.value = rrule.toText()
  rruleString.value = rrule.toString()
  rruleSubString.value = rruleString.value.substring(6)

  props.recurrenceCallback(rruleSubString.value, rruleRef.value.endDate, rruleRef.value.count, rruleRef.value.endsType)
}
const initRule = async() => {
  let rrule = RRule.fromString(recurrence.value)
  populateRecurrenceString(rrule)

  if (rrule.options.freq) {
    rruleRef.value.frequency = rruleConfig.value.frequencies.filter(x => x.id === rrule.options.freq)[0]
  }

  rruleRef.value.interval = rrule.options.interval || 1

  if (rrule.options.count) {
    rruleRef.value.endsType = 'fixed';
    rruleRef.value.count = rrule.options.count;
  } else if (rrule.options.until) {
    rruleRef.value.endsType = 'date';
    rruleRef.value.endDate = rrule.options.until;
  } else {
    rruleRef.value.endsType = 0
  }

  if (rrule.options.byweekday && rrule.options.byweekday.length) {
    rruleRef.value.daysOfWeek = rruleConfig.value.daysOfWeek.filter(d => rrule.options.byweekday.indexOf(d.id.weekday) > -1)
  }

  if (rrule.options.bymonth && rrule.options.bymonth.length) {
    rruleRef.value.months = rruleConfig.value.months.filter(m => rrule.options.bymonth.indexOf(m.id) > -1)
  }
}
const updateRecurrenceString = () => {
  let weekdays = rruleRef.value.daysOfWeek?.map(d => d.id)
  let months = rruleRef.value.months?.map(m => m.id)
  let opts = {
    freq: rruleRef.value.frequency.id,
    interval: rruleRef.value.interval
  }

  if (rruleRef.value.endsType === 'fixed') {
    opts.count = rruleRef.value.count
  } else {
    //unset if not fixed
    delete opts.count
  }

  if (rruleRef.value.endsType === 'date' && null != rruleRef.value.endDate) {
    opts.until = new Date(rruleRef.value.endDate)
  } else if(rruleRef.value.endsType !== 'date') {
    //unset if not date
    delete rruleRef.value.until
    delete rruleRef.value.endDate
  }

  if (weekdays?.length) {
    opts.byweekday = weekdays
  }

  if (months?.length) {
    opts.bymonth = months
  }

  let rrule = new RRule(opts)
  populateRecurrenceString(rrule)
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
.account-img{
  margin-left: 10px;
}
.account-menu-button{
  text-transform: capitalize;
  box-shadow: none !important;
  -webkit-box-shadow: none !important;
  border: none !important;
}
.account-menu-icon{
  justify-content: center;
  align-content: center;
}
</style>
