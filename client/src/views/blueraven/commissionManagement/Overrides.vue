<template>
  <v-container class="pa-0" id="commission-overrides-container">
    <v-divider></v-divider>
    <v-toolbar flat color="white">
      <v-toolbar-title>
        Override Plans
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <a-btn
            variant="text"
            color="primary"
            @click="goToDetails({})"
            v-if="userStore.userHasFeatureAccessLevel('COMMISSIONS_CLOSER', 'ADD')"
            prepend-icon="add"
        ></a-btn>
      </v-toolbar-items>
    </v-toolbar>
    <v-divider></v-divider>
    <v-row>
      <v-col class="pt-0">
        <v-card>
          <v-card-title class="pt-0">
            <a-text-field
                v-model="search"
                prepend-inner-icon="search"
                label="Search"
                single-line
                hide-details
            ></a-text-field>
            <v-spacer></v-spacer>
            <div class="d-flex hide-inactive-switch-container align-items-center">
              <v-label class="hide-inactive-label">Hide Inactive Plans</v-label>
              <v-switch hide-details v-model="hideInactivePlans" class="hide-inactive-switch"></v-switch>
            </div>
          </v-card-title>
          <v-divider></v-divider>
          <v-data-table
              :headers="headers"
              :items="filteredPlans"
              :fixed-header="true"
              :footer-props="footerProps"
              :items-per-page="100"
              :search="search"
              :loading="dataLoading"
              class="elevation-1"
          >
            <template #no-data>
              No available override plans
            </template>

            <template #no-results>
              No available override plans
            </template>

            <template #item="{ item, index }">
              <tr class="clickable" @click="goToDetails(item)" :class="{'shaded-row': index % 2}">
                <td class="text-left">{{ item.name }}</td>
                <td class="text-left">{{ item.description }}</td>
                <td class="text-left">{{ item.status }}</td>
                <td class="text-left">{{ item.total }}</td>
                <td class="text-left">{{ item.activeAssignedUsers }}</td>
              </tr>
            </template>
          </v-data-table>
        </v-card>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>

import { getRequest } from '@/helpers/helpers'
import {getCurrentInstance, computed, ref, onMounted, watch} from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import {useAppStore} from '@/stores/AppStore.js'
import {useBrsStore} from '@/stores/BrsStore.js'
import { storeToRefs } from 'pinia'
import constants from "@/helpers/constants.js";

const brsStore = useBrsStore()
const { commissionPositionId } = storeToRefs(brsStore)
const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

onMounted(() => {
  getOverridePlans()
})

watch(commissionPositionId, () => {
  getOverridePlans()
})

const dataLoading = ref(true)
const search = ref('')
const hideInactivePlans = ref(true)
const footerProps = ref({
  'items-per-page-options': [25, 50, 100],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const headers = ref([
  {text: 'Name', value: 'name', show: true},
  {text: 'Description', value: 'description', show: true},
  {text: 'Status', value: 'status', show: true},
  {text: 'Total', value: 'total', show: true},
  {text: 'Active Assigned Users', value: 'activeAssignedUsers', show: true}
])
const overridePlans = ref([])

const filteredPlans = computed(() => {
  return overridePlans.value?.filter(p => {
    return hideInactivePlans.value ? p.statusId !== 3 : true
  })
})

const getOverridePlans = async () => {
  try {
    dataLoading.value = true
    const {data, status} = await getRequest(`/commissionManagement/overrides/plans/${commissionPositionId.value}`, 'blueraven', [])
    overridePlans.value = data || []
    dataLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Loading Override Plans')
    dataLoading.value = false
  }
}
const goToDetails = async (item) => {
  await router.push({name: 'override', params: {id: item.id}})
}
</script>

<style lang="scss">
#commission-overrides-container .v-data-table__wrapper {
  height: calc(100vh - 350px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}

.hide-inactive-label{
  margin-right: 16px;
  margin-top: 23px;
  letter-spacing: normal;
}
.hide-inactive-switch-container{
  width: 200px;
}
.hide-inactive-switch{
  //margin-right: 8px;
  //margin-bottom: 6px;
  //margin-top: -4px;
}
</style>

