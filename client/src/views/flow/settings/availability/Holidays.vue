<script setup>
import {ref, onMounted, getCurrentInstance} from 'vue'
import {
  deleteRequest,
  getRequest,
  putRequest
} from "@/helpers/helpers.js";
import {useAppStore} from "@/stores/AppStore.js";

const appStore = useAppStore()
const vueInstance = getCurrentInstance().proxy
const date = ref('2024-07-29')
const holidayName = ref('')
const addNew = ref(false)
const editExisting = ref(false)
const companyHolidays = ref([])
const expanded = ref([])

const orgs = ref([])
const orgsLoading = ref(false)

const headers = ref([
  {text: 'Holiday Name', value: 'name', show: true },
  {text: 'Date', value: 'date', show: true},
  {text: '', value: 'actions', show: true},
])

onMounted(async () => {
  await getHolidays()
})


const getHolidays = async () => {
  try {
    const {data, status} = await getRequest(`/availability/companyHolidays`)
    companyHolidays.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Company Holidays')
    appStore.loading = false
  }
}

const addHoliday = async () => {
  if (!isValidHoliday()) {
    appStore.showSnack('ERROR', 'Error: Holiday already exists on this day')
  } else {
    try {
      let params = {
        id: null,
        name: holidayName.value,
        date: new Date(date.value)
      }
      const {data, status} = await putRequest(`/availability/companyHolidays`, params)
      addNew.value = false
      appStore.showSnack('SUCCESS', 'Created New Holiday')
      await getHolidays()
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Creating Company Holiday')
      appStore.loading = false
    }
  }
  holidayName.value = ''
  date.value = null
}

const editHoliday = (holiday) => {
  expanded.value = [holiday]
  const hd = new Date(holiday.date);
  const year = hd.getUTCFullYear();
  const month = String(hd.getUTCMonth() + 1).padStart(2, '0');
  const day = String(hd.getUTCDate()).padStart(2, '0');

  date.value = `${year}-${month}-${day}`
  holidayName.value = holiday.name

  editExisting.value = true
}

const saveHoliday = async (item) => {
  try {
    let params = {
      id: item.id,
      name: holidayName.value,
      date: new Date(date.value)
    }
    await putRequest(`/availability/companyHolidays`, params)
    editExisting.value = false
    appStore.showSnack('SUCCESS', 'Updated Holiday')
    await getHolidays()
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Updating Company Holiday')
    appStore.loading = false
  }
  holidayName.value = ''
  date.value = null
}

const archiveHoliday = async (holidayId) => {
  try {
    await deleteRequest(`/availability/companyHolidays/${holidayId}`)
    appStore.showSnack('SUCCESS', 'Company Holiday has been Archived')
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving Company Holiday')
    appStore.loading = false
  }
  await getHolidays()
}

const isValidHoliday = () => {
  let validator = (a) => {
    const hd = new Date(a.date);
    const year = hd.getUTCFullYear();
    const month = String(hd.getUTCMonth() + 1).padStart(2, '0');
    const day = String(hd.getUTCDate()).padStart(2, '0');
    const existingDate = `${year}-${month}-${day}`
    return existingDate === date.value
  }
  const isValid = !companyHolidays.value.some(validator)
  return isValid
}


</script>

<template>
<v-container>
<v-row  class="pt-0">
  <v-col cols="12"  class="pt-0">
    <v-toolbar flat dense>
      <v-toolbar-title>
        Company Holidays
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <a-btn variant="text"
               color="primary"
               @click="[addNew = !addNew]"
               :text="addNew ? 'Cancel' : 'Add New'"
        />
      </v-toolbar-items>
    </v-toolbar>
    <v-card color="transparent" flat v-if="addNew" class="mb-2 pa-5">
      <div>
        <span class="title-large">Create Holiday</span>
      </div>
      <a-text-field
        label="New Holiday Name"
        v-model="holidayName"
      ></a-text-field>
      <v-date-picker
        v-model="date"
      ></v-date-picker>
      <v-divider/>
      <v-card-actions>
        <a-btn
          text="Save"
          @click="addHoliday"
        />
      </v-card-actions>

    </v-card>
    <v-data-table
      v-if="!addNew"
      :headers="headers"
      :items="companyHolidays"
      :fixed-header="true"
      :items-per-page="-1"
      single-expand
      :mobile-breakpoint="0"
      hide-default-footer
      :expanded.sync="expanded"
      class="elevation-1 org-type-table"
      ref="myDataTable"
    >
      <template #no-data>
        <span class="default-text-color">No Company Holidays :(</span>
      </template>

      <template #no-results>
        <span class="default-text-color">Couldn't find any holidays :(</span>
      </template>

      <template #expanded-item="{ headers, item }">
        <td :colspan="headers.length" class="pa-4" v-if="editExisting">
          <div>
            <span class="title-large">Edit Holiday</span>
          </div>
          <div class="mb-3">
            <v-card color="transparent" flat class="mb-2 pa-5">
              <a-text-field
                label="Holiday Name"
                v-model="holidayName"
              ></a-text-field>
              <v-date-picker
                v-model="date"
              ></v-date-picker>
              <v-card-actions>
                <a-btn
                  text="Save"
                  @click="saveHoliday(item)"
                />
              </v-card-actions>
            </v-card>
          </div>
        </td>
      </template>

      <template #item="{ item }">
        <tr :class="{'shaded-row': companyHolidays.indexOf(item) % 2}">
          <td class="text-left" >{{ item.name }}</td>
          <td class="text-left">{{ item.date | formatDate('date')}}</td>
          <td class="text-right">
            <a-btn variant="text" prepend-icon="edit" v-if="!expanded.includes(item)" @click="editHoliday(item)"></a-btn>
            <a-btn text="Cancel" v-if="expanded.includes(item)" @click="expanded = []"></a-btn>
            <a-btn variant="text" prepend-icon="delete" v-if="!expanded.includes(item)" @click="archiveHoliday(item.id)" />
          </td>
        </tr>
      </template>
    </v-data-table>
  </v-col>
</v-row>
</v-container>
</template>

<style scoped lang="scss">

</style>
