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
            v-if="userStore.userHasFeatureAccessLevel('COMMISSIONS', 'ADD')"
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
          </v-card-title>
          <v-divider></v-divider>
          <v-data-table
              :headers="headers"
              :items="overridePlans"
              :fixed-header="true"
              :items-per-page="-1"
              :search="search"
              :loading="dataLoading"
              hide-default-footer
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
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import {useAppStore} from '@/stores/AppStorePinia.js'
import {useBrsStore} from '@/stores/BrsStorePinia.js'
import { storeToRefs } from 'pinia'

const brsStore = useBrsStore()
const { commissionPositionId } = storeToRefs(brsStore)
const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

onMounted(() => {
  getOverridePlans()
})

watch(commissionPositionId, () => {
  getOverridePlans()
})

const dataLoading = ref(true)
const search = ref('')
const headers = ref([
  {text: 'Name', value: 'name', show: true},
  {text: 'Description', value: 'description', show: true},
  {text: 'Status', value: 'status', show: true},
  {text: 'Total', value: 'total', show: true},
  {text: 'Active Assigned Users', value: 'activeAssignedUsers', show: true}
])
const overridePlans = ref([])

const getOverridePlans = async () => {
  try {
    dataLoading.value = true
    const {data, status} = await getRequest(`/commissionManagement/overrides/plans/${commissionPositionId.value}`, 'blueraven', [])
    overridePlans.value = data || []
    dataLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Override Plans')
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
</style>

