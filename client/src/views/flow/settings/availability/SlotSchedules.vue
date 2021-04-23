<template>
  <v-container>
    <v-row  class="pt-0">
      <v-col cols="12"  class="pt-0">
        <v-toolbar flat dense>
          <v-toolbar-title>
            Slot Schedules
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newSchedule = {}]" color="primaryCustom">
              {{ addNew ? 'Cancel' : 'Add New'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card color="transparent" flat v-if="addNew" class="mb-2 pa-5">
          <v-text-field
            label="New Schedule Name"
            v-model="newSchedule.scheduleName"
          ></v-text-field>
          <v-btn :disabled="!newSchedule.scheduleName"
                 @click="saveSchedule(newSchedule)">
            Save
          </v-btn>
        </v-card>
        <v-data-table
          :headers="headers"
          :items="filterSchedules()"
          :fixed-header="true"
          :items-per-page="-1"
          single-expand
          :mobile-breakpoint="0"
          :expanded.sync="expanded"
          hide-default-footer
          class="elevation-1 org-type-table"
        >
          <template #no-data>
            NO DATA HERE!
          </template>

          <template #no-results>
            No available data
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': slotSchedules.indexOf(item) % 2}">
              <h3>Edit Schedule</h3>
              <v-text-field
                v-model="item.scheduleName"
                label="Schedule Name"
              />
              <div class="mb-3">
                <v-btn color="primary" class="mb-2" dark @click="item.slotTimes.push({id: null, startTime: null, endTime: null, archived: false})">
                  Add Slot
                </v-btn>
                <v-list v-for="(st, index) in filterBy(item.slotTimes, false, 'archived')"
                        :key="index"  class="pa-0">
                  <v-list-item :class="{'shaded-row': index % 2}">
                    <v-list-item-content class="text-left">
                      <ZonelessTimePickerInput
                        v-model="st.startTime"
                        :allowed-minutes="allowedMinutesStep"
                        :hide-details="true"
                        label="Start Time"
                      />
                      <ZonelessTimePickerInput
                        v-model="st.endTime"
                        :allowed-minutes="allowedMinutesStep"
                        :hide-details="true"
                        label="End Time"
                      />
                    </v-list-item-content>
                    <v-list-item-action>
                      <v-btn text @click="st.archived = true">
                        <v-icon>delete</v-icon>
                      </v-btn>
                    </v-list-item-action>
                  </v-list-item>
                </v-list>
              </div>
              <div class="error-text mb-2" v-if="saveError">
                {{saveErrorMsg}}
              </div>
              <v-btn color="primaryCustom" class="white--text mr-2"
                     @click="saveSchedule(item)">
                Save
              </v-btn>
            </td>
          </template>

          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': slotSchedules.indexOf(item) % 2}">
              <td class="text-left">{{ item.scheduleName }}</td>
              <td class="text-right">
                <v-btn small text v-if="userCanEdit && !expanded.includes(item)" @click="expanded = [item]">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text v-if="userCanEdit && expanded.includes(item)" @click="expanded = []">cancel</v-btn>
                <v-dialog
                  v-if="userCanDelete"
                  v-model="item.deleteConfirm"
                  width="500">
                  <template #activator="{ on }">
                    <v-btn small text v-on="on">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title
                      class="headline grey lighten-2"
                      primary-title>
                      Confirm
                    </v-card-title>

                    <v-card-text class="pt-4">
                      Are you sure you want to delete this schedule: {{ item.scheduleName }}?
                    </v-card-text>

                    <v-divider></v-divider>

                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn
                        @click="item.deleteConfirm = false">
                        No
                      </v-btn>
                      <v-btn
                        color="primaryCustom"
                        text
                        @click="deleteSchedule(item)">
                        Yes
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-dialog>
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {getRequest, getRequestWithParams, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import Vue2Filters from 'vue2-filters'
  import moment from 'moment'
  import ZonelessTimePickerInput from "./ZonelessTimePickerInput";

  export default {
    name: 'SlotSchedules',
    mixins: [Vue2Filters.mixin],
    computed: {
    },
    components: {
      ZonelessTimePickerInput
    },
    data() {
      return {
        snackbar: {},
        addNew: false,
        showTime: false,
        newSchedule: {},
        saveError: false,
        saveErrorMsg: '',
        selectedSlotId: null,
        allowedMinutesStep: m => m % 5 === 0,
        slotSchedules: [],
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'EDIT'),
        userCanDelete: this.$store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'DELETE'),
        headers: [
          {text: 'Schedule Name', value: 'scheduleName', show: true },
          {text: '', value: 'icons', show: true},
        ],
        expanded: []
      }
    },
    created() {
      this.getSchedules()
    },
    methods: {
      clearInput () {
        this.$emit('input', null)
      },
      filterSchedules () {
        return this.slotSchedules.filter(s => { return !s.archived})
      },
      async saveSchedule (schedule) {
        try {
          this.saveError = false
          this.saveErrorMsg = ''

          schedule.slotTimes?.forEach((st, stIdx) => {
            //verify that no slot start time is >= the slot end time
            if(!st.archived && (!st.startTime || !st.endTime)) {
              this.saveError = true
              this.saveErrorMsg = 'Slot Start and End Times cannot be empty'
            } else if(moment(st.startTime, 'HH:mm').isSameOrAfter(moment(st.endTime, 'HH:mm'))) {
              this.saveError = true
              this.saveErrorMsg = 'Slot Start Time Cannot Be Before End Time'
            } else {
              //verify that no slots overlap
              schedule.slotTimes?.forEach((st2, st2Idx) => {
                if (stIdx !== st2Idx && (moment(st.startTime, 'HH:mm').isBetween(moment(st2.startTime, 'HH:mm'), moment(st2.endTime, 'HH:mm'))
                  || moment(st.endTime, 'HH:mm').isBetween(moment(st2.startTime, 'HH:mm'), moment(st2.endTime, 'HH:mm')))) {
                  this.saveError = true
                  this.saveErrorMsg = 'Slots Cannot Overlap'
                }
              })
            }
          })
          if(!this.saveError) {
            this.$store.commit(AppMutations.SET_LOADING, true)
            const {data} = await putRequest(`/availability/slotSchedule`, schedule)
            if(!schedule.id) {
              this.newSchedule = {}
              this.addNew = false
              this.slotSchedules.push(data)
            }
            this.snackbar = getSnackbar('SUCCESS', 'Schedule Saved')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Schedule')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getSchedules() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/availability/slotSchedules`)
          this.slotSchedules = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Slot Schedules')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteSchedule(schedule) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/availability/slotSchedule/${schedule.id}`)
          schedule.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'Schedule Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Schedule')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>
.schedule-wrap {

}
</style>

