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
            <v-spacer></v-spacer>
            <v-switch
                v-model="includeInactive"
                class=""
                label="Include Inactive"
                @change="getUsers()"
            />
            <a-btn
                color="primary"
                class="ml-3"
                @click="exportData()"
                text="Export"
            ></a-btn>
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
                      :to="`/commissionManagement/users/${item.userId}`"
                      color="unset"
                      :text="item.name"
                  ></a-btn>
                </td>
                <td class="text-left pt-1" >
                  {{ item.orgName }}
                </td>
                <td class="text-left pt-1" >
                  {{ item.availableCommissionStrategies }}
                </td>
                <td class="text-left pt-1">
                  <a v-if="item.commissionPlan !== null" @click="goToDetails(item.commissionPlanId, 1)">
                    {{item.commissionPlan}}:<br/>
                    {{item.commissionDescription}}
                  </a>
                  <div v-else class="pt-2">--</div>
                </td>
                <td class="text-left pt-1">
                  <a v-if="item.overridePlan !== null" @click="goToDetails(item.overridePlanId, 2)">
                    {{item.overridePlan}}:<br/>
                    {{item.overrideDescription}}
                  </a>
                  <div v-else class="pt-2">--</div>
                </td>
                <td class="text-left pt-1">
                  <a v-if="item.residualPlan !== null" @click="goToDetails(item.residualPlanId, 3)">
                    {{item.residualPlan}}:<br/>
                    {{item.residualPlan}}
                  </a>
                  <div v-else class="pt-2">--</div>
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

import {handleHidingGlobalLoader, getRequestWithParams, } from '@/helpers/helpers'
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import { useBrsStore } from '@/stores/BrsStore.js'
import { storeToRefs } from 'pinia'
import { saveAs } from 'file-saver'

const brsStore = useBrsStore()
const { commissionPositionId } = storeToRefs(brsStore)

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

onMounted(() => {
  getUsers()
})

const dataLoading = ref(true)
const includeInactive = ref(false)
const search = ref('')
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 1000]})
const headers = ref([
  {text: 'User', value: 'name', show: true},
  {text: 'Office', value: 'orgName', show: true},
  {text: 'Available Commission Strategies', value: 'availableCommissionStrategies', show: true},
  {text: 'Commission Plan', value: 'commissionPlan', show: true},
  {text: 'Override Plan', value: 'overridePlan', show: true},
  {text: 'Residual Plan', value: 'residualPlan', show: true},
  {text: 'Has Commission Plan Gap', value: 'hasCommissionPlanGap', show: true},
])
const users = ref([])

watch(commissionPositionId, () => {
  getUsers()
})


const getUsers = async () => {
  appStore.loading = true
  try {
    let params = {
      includeInactive: includeInactive.value
    }
    let url = commissionPositionId.value === 1 ? '/commissionManagement/closers' : '/commissionManagement/setters'
    const {data, status} = await getRequestWithParams(url, { params }, 'blueraven', [])
    users.value = data
    dataLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Loading Users')

    appStore.loading = false
  }
}
const goToDetails = async(planId, planType) => {
  // 1 = commission, 2 = override, 3 = residual
  let pathName
  switch(planType) {
    case 1:
      pathName = 'commission'
      break
    case 2:
      pathName = 'override'
      break
    case 3:
      pathName = 'residualPlan'
      break
    default:
      pathName = null
  }
  await router.push({name: pathName, params: { id: planId}})
}

const exportData = async () => {
  appStore.loading = true
  try {
    let filename = `Commission_Users.csv`;

    let csvData = 'User ID, User Name, User Employee ID, Primary Position, Office, Available Commission Strategies, Commission Plan Start Date, Commission Plan, Override Plan Start Date, Override Plan, Residual Plan Start Date, Residual Plan';
      csvData += '\n'

      users.value.forEach(p => {
        csvData +=
            p.userId + ',' +
            '"' + p.name + '",' +
            p.employeeId + ',' +
            p.primaryPosition + ',' +
            '"' + p.orgName + '",' +
            '"' + p.availableCommissionStrategies + '",' +
            (p.commissionPlanStart || '') + ',' +
            (p.commissionPlan || '') + ',' +
            (p.overridePlanStart || '') + ',' +
            (p.overridePlan || '') + ',' +
            (p.residualPlanStart || '') + ',' +
            (p.residualPlan || '')

        csvData += '\n';
      })

    let blob = new Blob([csvData], {
      type: 'text/csv;charset=utf-8'
    });

    saveAs(blob, filename);
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Exporting Data')

    appStore.loading = false
  }
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

