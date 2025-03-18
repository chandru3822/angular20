<template>
  <v-container class="pa-0" id="commissions-container">
    <v-divider />
    <v-toolbar flat color="white">
      <v-toolbar-title>
        Commission Plans
      </v-toolbar-title>
      <v-spacer />
      <v-toolbar-items>
        <a-btn
          variant="text"
          color="primary"
          @click="goToDetails({})"
          v-if="userCanAdd"
          prepend-icon="add"
        />
      </v-toolbar-items>
    </v-toolbar>
    <v-divider />
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
            />
          </v-card-title>
          <v-divider />
          <v-data-table
            :headers="headers"
            :items="commissions"
            :fixed-header="true"
            :items-per-page="-1"
            :search="search"
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
          >
            <template #no-data>
              <span class="default-text-color">No available commissions</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No available commissions</span>
            </template>

            <template #item="{ item, index }">
              <tr class="clickable" :class="{'shaded-row': index % 2}" @click="goToDetails(item)">
                <td class="text-left">{{item.name}}</td>
                <td class="text-left">{{item.description}}</td>
                <td class="text-left">
                  <status-chip :status="item.statusType" />
                </td>
                <td class="text-left">{{item.activeUsers}}</td>
              </tr>
            </template>
          </v-data-table>
        </v-card>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>
  import { handleHidingGlobalLoader } from '@/helpers/helpers.js'
  import { computed, getCurrentInstance, onMounted, ref, watch } from 'vue'
  import { useUserStore } from '@/stores/UserStore.js'
  import { getCommissionPlans } from '@/services/commissionService.js'
  import { useRouter } from 'vue-router/composables'
  import { useBrsStore } from '@/stores/BrsStore.js'
  import { useAppStore } from '@/stores/AppStore.js'
  import { storeToRefs } from 'pinia'
  import StatusChip from '@/components/StatusChip.vue'

  const router = useRouter()
  const appStore = useAppStore()
  const brsStore = useBrsStore()
  const userStore = useUserStore()
  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store
  const { commissionPositionId } = storeToRefs(brsStore)

  onMounted(() => {
    getCommissions()
  })

  watch(commissionPositionId, () => {
    getCommissions()
  })

  const dataLoading = ref(true)
  const search = ref('')
  const commissions = ref([])


  const fourthColumnText = computed(() => {
    return [1, 4].includes(commissionPositionId.value) ? 'Active Users' : 'Assigned Orgs'
  })

  const headers = ref([
    {text: 'Plan Name', value: 'name', show: true},
    {text: 'Description', value: 'description', show: true},
    {text: 'Status', value: 'statusType', show: true},
    {text: 'Active Users', value: 'activeUsers', show: true},
  ])

  // Update the header text when commissionPositionId changes
  watch(commissionPositionId, (newVal) => {
    headers.value[3].text = [1, 4].includes(newVal) ? 'Active Users' : 'Assigned Orgs'
  }, { immediate: true })

  const getCommissions = async () => {
    appStore.loading = true
    try {
      const {data, status} = await getCommissionPlans(commissionPositionId.value)
      commissions.value = data
      dataLoading.value = false
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Loading Commissions')
      appStore.loading = false
    }
  }
  const goToDetails = (item) => {
    router.push({name: 'commission', params: {id: item.id}})
  }

  // todo: place below items into a helpers file or default store state
  const positions = ref([
    {
      id: 1,
      label: 'Closer',
      code: 'COMMISSIONS_CLOSER',
      path: '/commissionManagement/users'
    },
    {
      id: 4,
      label: 'Setter',
      code: 'COMMISSIONS_SETTER',
      path: '/commissionManagement/users'
    },
    {
      id: 743,
      label: 'Dealer',
      code: 'COMMISSIONS_DEALER',
      path: '/commissionManagement/commissions'
    },
    {
      id: 828,
      label: 'Installation Partner',
      code: 'COMMISSIONS_INSTALLATION_PARTNER',
      path: '/commissionManagement/commissions'
    },
  ])


  const commissionPositionData = computed(() => {
    // Evaluate the position that the commission returns, not the one the user sets
    return positions.value.find(pos => pos.id === commissionPositionId.value);
  });

  const userCanAdd = computed(() => {
    return userStore.userHasFeatureAccessLevel(commissionPositionData.value.code, 'ADD') ||
      userStore.userHasFeatureAccessLevel(commissionPositionData.value.code, 'EDIT') ||
      userStore.userHasFeatureAccessLevel(commissionPositionData.value.code, 'ADMIN')
  })

</script>

<style lang="scss">
  #commissions-container .v-data-table__wrapper {
    height: calc(100vh - 350px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  .v-data-table {
    border-radius: 0;
  }
</style>
