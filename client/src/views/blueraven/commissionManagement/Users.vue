<template>
  <v-container class="pa-0" id="commission-closers-container">
    <v-row>
      <v-col>
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
              :items="users"
              :fixed-header="true"
              :items-per-page="50"
              :loading="dataLoading"
              :search="search"
              :footer-props="footerProps"
              class="elevation-1"
          >
            <template #no-data>
              <div class="black--text">No available users</div>
            </template>

            <template #no-results>
              <div class="black--text">No available users</div>
            </template>

            <template #item="{ item, index }">
              <tr class="vertical-top" :class="{'shaded-row': index % 2}">
                <td class="text-left pt-1" >
                  <a-btn
                      variant="text"
                      class="anchor"
                      :to="`/commissionManagement/users/${item.id}`"
                      color="unset"
                      :text="item.name"
                  ></a-btn>
                </td>
                <td class="text-left pt-1" >
                  {{ item.orgName }}
                </td>
                <td class="text-left pt-1">
                  <a v-if="item.commissionPlan !== null" @click="goToDetails(item, 1)">
                    {{item.commissionPlan}}:<br/>
                    {{item.commissionDescription}}
                  </a>
                  <div v-else class="pt-2">--</div>
                </td>
                <td class="text-left pt-1">
                  <a v-if="item.overridePlan !== null" @click="goToDetails(item, 2)">
                    {{item.overridePlan}}:<br/>
                    {{item.overrideDescription}}
                  </a>
                  <div v-else class="pt-2">--</div>
                </td>
                <td class="text-left pt-1">
                  <span v-if="item.receivingPlans && item.receivingPlans.length > 0">
                    <div v-for="rp in item.receivingPlans">
                      <a @click="goToDetails(rp, 3)">
                        {{rp.receivingPlan}}:<br/>
                        {{rp.receivingDescription}}
                      </a>
                    </div>
                  </span>
                  <div v-else  class="pt-2">--</div>
                </td>
                <td class="text-left pt-3">{{item.hasCommissionPlanGap ? 'Yes' : 'No'}}</td>
              </tr>
            </template>
          </v-data-table>
        </v-card>
      </v-col>
    </v-row>


  </v-container>
</template>

<script setup>

import {handleHidingGlobalLoader, getRequest, } from '@/helpers/helpers'
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import { useBrsStore } from '@/stores/BrsStore.js'
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
  getUsers()
})

const dataLoading = ref(true)
const search = ref('')
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 1000]})
const headers = ref([
  {text: 'User', value: 'name', show: true},
  {text: 'Office', value: 'orgName', show: true},
  {text: 'Commissions Assigned To', value: 'commissionPlan', show: true},
  {text: 'Overrides Assigned To', value: 'overridePlan', show: true},
  {text: 'Receiving Overrides From', value: 'receivingPlan', show: true},
  {text: 'Has Commission Plan Gap', value: 'hasCommissionPlanGap', show: true},
])
const users = ref([])

watch(commissionPositionId, () => {
  getUsers()
})


const getUsers = async () => {
  appStore.loading = true
  try {
    let url = commissionPositionId.value === 1 ? '/commissionManagement/closers' : '/commissionManagement/setters'
    const {data, status} = await getRequest(url, 'blueraven', [])
    users.value = data.filter(d => d.isActiveUser)
    dataLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Users')

    appStore.loading = false
  }
}
const goToDetails = async(item, planType) => {
  // 1 = commission, 2 = override, 3 = receiving
  let name = planType === 1 ? 'commission' : 'override'
  let id = planType === 1 ? item.commissionPlanId : planType === 2 ? item.overridePlanId : item.receivingPlanId
  await router.push({name, params: {id}})
}
</script>

<style lang="scss">
#commission-closers-container .v-data-table__wrapper {
  height: calc(100vh - 350px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}
</style>

