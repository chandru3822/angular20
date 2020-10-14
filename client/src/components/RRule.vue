<template>
  <v-card flat color="transparent">
    <h4 class="mb-3">{{rruleText}}</h4>
    <v-select v-model="rrule.frequency"
              :items="rruleConfig.frequencies"
              label="Repeats"
              item-text="label"
              return-object
              @input="updateRecurrenceString"
              autocomplete="off">
    </v-select>
    <v-text-field text
                  type="number"
                  label="Repeat every (add here)"
                  placeholder=" "
                  @input="updateRecurrenceString"
                  v-model="rrule.interval"></v-text-field>
    <v-select v-model="rrule.months"
              :items="rruleConfig.months"
              label="By Month"
              item-text="label"
              return-object
              multiple
              @input="updateRecurrenceString"
              autocomplete="off">
    </v-select>
    <v-select v-model="rrule.daysOfWeek"
              :items="rruleConfig.daysOfWeek"
              label="By Day of Week"
              item-text="label"
              return-object
              @input="updateRecurrenceString"
              multiple
              autocomplete="off">
    </v-select>

    <label>Ends</label>
    <v-radio-group v-model="rrule.endsType" @change="updateRecurrenceString">
      <v-radio label="Never" :value="0"></v-radio>
      <div class="flex-display align-center">
        <v-radio class="mb-0" value="fixed"></v-radio>
        After
        <v-text-field text
                      type="number"
                      label=""
                      solo
                      @input="updateRecurrenceString"
                      hide-details
                      class="mx-2 shrink"
                      placeholder=" "
                      v-model="rrule.count"></v-text-field>
        occurrences
      </div>
      <div class="flex-display align-center">
        <v-radio class="mb-0" value="date"></v-radio>
        On
        <DatetimePickerInput
          v-model="rrule.endDate"
          :hide-prepend-icon="true"
          :show-append-icon="true"
          custom-class="shrink ml-2"
          :change-callback="updateRecurrenceString"
          :input-format="'YYYY-MM-DD'"
          :type="'date'"
          :format="'MM/DD/YYYY'"
        />
      </div>

    </v-radio-group>

  </v-card>
</template>

<script>
  import { RRule, RRuleSet, rrulestr } from 'rrule'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'

  const { VUE_APP_ENV } = process.env

  export default {
    name: 'RRule',
    components: {
      DatetimePickerInput
    },
    props: {
      recurrence: String,
      itemId: Number,
      recurrenceCallback: Function,
    },
    watch: {
      recurrence: function () {
        //have to re-init when they click a different appointment in a data table
        this.initRecurrence()
      }
    },
    data () {
      return {
        rrule: {},
        rruleText: '',
        rruleEnd: '',
        rruleString: '',
        rruleSubString: '',
        rruleConfig: {
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
        },
      }
    },
    created () {
      this.initRecurrence()
    },
    methods: {
      initRecurrence() {
        if (this.recurrence) {
          this.initRule()
        } else {
          this.rrule = {
            frequency: this.rruleConfig.frequencies[0],
            //endsType is supposed to be an empty string but vuetify radio buttons dont work with empty string as the value. it sets the value to 0 instead. will handle later
            endsType: 0,
            count: 1,
            interval: 1,
            months: [],
            daysOfWeek: []
          }
          // let rrule = RRule.fromString(this.rru)
          this.updateRecurrenceString(this.rrule)
        }
      },
      populateRecurrenceString(rrule) {
        this.rruleText = rrule.toText()
        this.rruleString = rrule.toString()
        this.rruleSubString = this.rruleString.substring(6)

        this.recurrenceCallback(this.rruleSubString, this.itemId, this.rrule.endDate)
      },
      async initRule() {
        let rrule = RRule.fromString(this.recurrence)
        this.populateRecurrenceString(rrule)

        if (rrule.options.freq) {
          this.rrule.frequency = this.rruleConfig.frequencies.filter(x => x.id === rrule.options.freq)[0]
        }

        this.rrule.interval = rrule.options.interval || 1

        if (rrule.options.count) {
          this.rrule.endsType = 'fixed';
          this.rrule.count = rrule.options.count;
        } else if (rrule.options.until) {
          this.rrule.endsType = 'date';
          this.rrule.endDate = rrule.options.until;
        } else {
          this.rrule.endsType = 0
        }

        if (rrule.options.byweekday && rrule.options.byweekday.length) {
          this.rrule.daysOfWeek = this.rruleConfig.daysOfWeek.filter(d => rrule.options.byweekday.indexOf(d.id.weekday) > -1)
        }

        if (rrule.options.bymonth && rrule.options.bymonth.length) {
          this.rrule.months = this.rruleConfig.months.filter(m => rrule.options.bymonth.indexOf(m.id) > -1)
        }
      },
      updateRecurrenceString() {
        let weekdays = this.rrule.daysOfWeek?.map(d => d.id)
        let months = this.rrule.months?.map(m => m.id)
        let opts = {
          freq: this.rrule.frequency.id,
          interval: this.rrule.interval
        }

        if (this.rrule.endsType === 'fixed') {
          opts.count = this.rrule.count
        } else {
          //unset if not fixed
          delete opts.count
        }

        if (this.rrule.endsType === 'date' && this.rrule.endDate) {
          opts.until = new Date(this.rrule.endDate)
        } else {
          //unset if not date
          delete this.rrule.until
          delete this.rrule.endDate
        }

        if (weekdays?.length) {
          opts.byweekday = weekdays
        }

        if (months?.length) {
          opts.bymonth = months
        }

        let rrule = new RRule(opts)
        this.populateRecurrenceString(rrule)
      }
    }
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
