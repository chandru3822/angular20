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
            <AlbatrossButton variant="text"
                             color="primary"
                             @click="[addNew = !addNew, newSchedule = {}]"
                             :text="addNew ? 'CANCEL' : 'ADD NEW'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-card color="transparent" flat v-if="addNew" class="mb-2 pa-5">
          <v-text-field
            label="New Schedule Name"
            v-model="newSchedule.scheduleName"
          ></v-text-field>
          <AlbatrossButton :disabled="!newSchedule.scheduleName"
                           @click="saveSchedule(newSchedule)"
                           text="SAVE"
          />
        </v-card>
        <v-data-table
          :headers="headers"
          :items="filterSchedules"
          :fixed-header="true"
          :items-per-page="-1"
          single-expand
          :mobile-breakpoint="0"
          :expanded.sync="expanded"
          hide-default-footer
          class="elevation-1 org-type-table"
        >
          <template #no-data>
            <span class="default-text-color">NO DATA HERE!</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available data</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': slotSchedules.indexOf(item) % 2}">
              <h3>Edit Schedule</h3>
              <v-text-field
                v-model="item.scheduleName"
                label="Schedule Name"
              />
              <div class="mb-3">
                <AlbatrossButton
                  color="primary"
                  class="mb-2"
                  dark @click="item.slotTimes.push({id: null, startTime: null, endTime: null, archived: false})"
                  text="ADD SLOT"
                />
                <v-list v-for="(st, index) in item.slotTimes.filter(a => !a.archived)"
                        :key="index"  class="pa-0">
                  <v-list-item :class="{'shaded-row': index % 2}">
                    <v-list-item-content class="text-left">
                      <ZonelessTimePickerInput
                        v-model="st.startTime"
                        :change="() => {}"
                        :allowed-minutes="allowedMinutesStep"
                        :hide-details="true"
                        label="Start Time"
                      />
                      <ZonelessTimePickerInput
                        v-model="st.endTime"
                        :change="() => {}"
                        :allowed-minutes="allowedMinutesStep"
                        :hide-details="true"
                        label="End Time"
                      />
                    </v-list-item-content>
                    <v-list-item-action>
                      <AlbatrossButton variant="text" @click="st.archived = true" prepend-icon="delete"/>
                    </v-list-item-action>
                  </v-list-item>
                </v-list>
              </div>
              <div class="error-text mb-2" v-if="saveError">
                {{saveErrorMsg}}
              </div>
              <AlbatrossButton color="primary" class="white--text mr-2"
                               @click="saveSchedule(item)"
                               text="SAVE"
              />
            </td>
          </template>

          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': slotSchedules.indexOf(item) % 2}">
              <td class="text-left">{{ item.scheduleName }}</td>
              <td class="text-right">
                <AlbatrossButton size="small" variant="text" color="primary"
                                 v-if="userCanEdit && !expanded.includes(item)"
                                 @click="expanded = [item]" prepend-icon="edit"
                />
                <AlbatrossButton size="small" variant="text" color="primary"
                                 v-if="userCanEdit && expanded.includes(item)"
                                 @click="expanded = []" text="CANCEL"
                />
                <AlbatrossButton size="small" variant="text" color="primary" v-if="userCanDelete"
                                 @click="[itemToDelete = item, showDeleteDialog = true]" prepend-icon="delete"
                />
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog"
                                 @confirm="deleteSchedule"
                                 @close-dialog="closeDeleteDialog"
    >Are you sure you want to delete this schedule: <strong>{{itemToDeleteName}}</strong></ConfirmationDialog>
  </v-container>
</template>

<script setup>

  import {handleHidingGlobalLoader, getRequest, deleteRequest, putRequest, getSnackbar} from '@/helpers/helpers'
  import moment from 'moment'
  import ZonelessTimePickerInput from "./ZonelessTimePickerInput";
  import ConfirmationDialog from "@/components/ConfirmationDialog";

  import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
  import {getCurrentInstance, onMounted, ref, computed, watch, defineProps} from "vue";
  import { useUserStore } from '@/stores/UserStorePinia.js'
  import {useRoute} from "vue-router/composables"
  import { useAppStore } from '@/stores/AppStorePinia.js'
  const appStore = useAppStore()

  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const store = vueInstance.$store
  const userStore = useUserStore()
  const route = useRoute()

  const addNew = ref(false)
  const showTime = ref(false)
  const newSchedule = ref({})
  const saveError = ref(false)
  const saveErrorMsg = ref('')
  const selectedSlotId = ref(null)
  const allowedMinutesStep = ref(m => m % 5 === 0)
  const slotSchedules = ref([])
  const expanded = ref([])
  const showDeleteDialog = ref(false)
  const itemToDelete = ref(null)
  const headers = ref([
    {text: 'Schedule Name', value: 'scheduleName', show: true },
    {text: '', value: 'icons', show: true},
  ])
  const emit = defineEmits(['input'])

  const userCanEdit = computed(() => {
    return userStore.userHasFeatureAccessLevel('AVAILABILITY', 'EDIT')
  })
  const userCanDelete = computed(() => {
    return userStore.userHasFeatureAccessLevel('AVAILABILITY', 'DELETE')
  })

  const itemToDeleteName = computed(() => {
    return itemToDelete.value ? itemToDelete.value.scheduleName : ''
  })
  const clearInput = () => {
    emit('input', null)
  }
  const filterSchedules = computed(() => {
    return slotSchedules.value.filter(s => { return !s.archived})
  })

  onMounted(() => {
    getSchedules()
  })

  const saveSchedule = async  (schedule) => {
    try {
      saveError.value = false
      saveErrorMsg.value = ''

      schedule.slotTimes?.filter(st => !st.archived)?.forEach((st, stIdx) => {
        //verify that no slot start time is >= the slot end time
        if(!st.archived && (!st.startTime || !st.endTime)) {
          saveError.value = true
          saveErrorMsg.value = 'Slot Start and End Times cannot be empty'
        } else if(moment(st.startTime, 'HH:mm').isSameOrAfter(moment(st.endTime, 'HH:mm'))) {
          saveError.value = true
          saveErrorMsg.value = 'Slot Start Time Cannot Be Before End Time'
        } else {
          //verify that no slots overlap
          schedule.slotTimes?.filter(st => !st.archived)?.forEach((st2, st2Idx) => {
            if (stIdx !== st2Idx && (moment(st.startTime, 'HH:mm').isBetween(moment(st2.startTime, 'HH:mm'), moment(st2.endTime, 'HH:mm'))
              || moment(st.endTime, 'HH:mm').isBetween(moment(st2.startTime, 'HH:mm'), moment(st2.endTime, 'HH:mm')))) {
              saveError.value = true
              saveErrorMsg.value = 'Slots Cannot Overlap'
            }
          })
        }
      })
      if(!saveError.value) {
        appStore.loading = true
        const {data, status} = await putRequest(`/availability/slotSchedule`, schedule)
        if(!schedule.id) {
          newSchedule.value = {}
          addNew.value = false
          slotSchedules.value.push(data)
        }
        snackbar('SUCCESS', 'Schedule Saved')
        handleHidingGlobalLoader(status)
      }
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Saving Schedule')
      appStore.loading = false
    }
  }
  const getSchedules = async () => {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/availability/slotSchedules`, null, [])
      slotSchedules.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Loading Slot Schedules')
      appStore.loading = false
    }
  }
  const deleteSchedule = async () => {
    const schedule = itemToDelete.value
    appStore.loading = true
    try {
      const {status} = await deleteRequest(`/availability/slotSchedule/${schedule.id}`)
      schedule.archived = true
      snackbar('SUCCESS', 'Schedule Deleted')
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Deleting Schedule')
      appStore.loading = false
    }
    closeDeleteDialog()
  }
  const closeDeleteDialog = () => {
    showDeleteDialog.value = false
    itemToDelete.value = null
  }
</script>

