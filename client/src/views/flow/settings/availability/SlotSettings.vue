<template>
  <v-container>
    <v-autocomplete
      class="padded-autocomplete"
      clearable
      chips
      multiple
      label="Select Schedule"
      :items="filterSchedules"
      item-text="scheduleName"
      item-value="id"
      v-model="selectedSchedules"
    />

    <v-btn
      v-if="props.userId"
      color="primary"
      class="pl-2 mb-3"
      style="text-transform: none; margin: 10px;"
      @click.prevent="submitSlotMapping"
    >
      Save
    </v-btn>
  </v-container>
</template>

<script setup>
import { onMounted, ref, computed, watch } from 'vue';
import { getRequest, postRequest, handleHidingGlobalLoader } from '@/helpers/helpers';
import { useAppStore } from '@/stores/AppStore.js';

const appStore = useAppStore();


const slotSchedules = ref([]);
const selectedSchedules = ref([]);

const props = defineProps({
  orgId: Number,
  userId: Number,
  useSlotSchedule: Boolean
});

// Fetch all schedules
const getSchedules = async () => {
  appStore.loading = true;
  try {
    const { data, status } = await getRequest(`/availability/slotSchedules`, null, []);
    slotSchedules.value = data;
    handleHidingGlobalLoader(status);
  } catch (e) {
    appStore.showSnack('ERROR', 'Error Loading Slot Schedules');
  } finally {
    appStore.loading = false;
  }
};

// Fetch user's assigned schedules and preselect them
const getSchedulesuser = async () => {
  try {
    const { data, status } = await getRequest(`/availability/slotSchedulesUser/${props.userId}`, null, []);
    const userScheduleIds = data.map(s => s.id);

    // Match with loaded schedules and set selected IDs
    selectedSchedules.value = slotSchedules.value
      .filter(s => userScheduleIds.includes(s.id))
      .map(s => s.id);

    handleHidingGlobalLoader(status);
  } catch (e) {
    appStore.showSnack('ERROR', 'Error Loading User Slot Schedules');
  }
};

// Computed schedules for dropdown
const filterSchedules = computed(() =>
  slotSchedules.value
    .filter(s => !s.archived)
    .map(s => ({
      ...s,
      scheduleName: s.scheduleName || 'Unnamed'
    }))
);

// React when userId changes (load schedules + preselect)
watch(
  () => props.userId,
  async (newVal) => {
    if (newVal) {
      await getSchedules();
      await getSchedulesuser();
    }
  },
  { immediate: true }
);

// Submit selected schedules
const submitSlotMapping = async () => {
  try {
    const payload = {

      positionid: props.userId,
      scheduleId: selectedSchedules.value
    };

    const response = await postRequest(`/availability/availabilitySlotSchedule`, payload);
    if(response){
       appStore.showSnack('SUCCESS', 'slot has been added to the user.')
    }

  } catch (error) {

  }
};
</script>

<style scoped>
.padded-autocomplete {
  padding-left: 15px;
  padding-right: 15px;
}
</style>
