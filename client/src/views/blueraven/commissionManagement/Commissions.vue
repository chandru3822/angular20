<template>
  <v-container class="pa-0" id="commissions-container">
    <v-divider></v-divider>
    <v-toolbar flat color="white">
      <v-toolbar-title>
        Commission Plans
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
                <td class="text-left">{{item.statusType}}</td>
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
  import {handleHidingGlobalLoader, getRequest, getSnackbar} from '@/helpers/helpers'

  import {getCurrentInstance, computed, ref, onMounted, watch} from 'vue'
  import {useUserStore} from '@/stores/UserStore.js'
  import {useRoute, useRouter} from "vue-router/composables";
  import { useBrsStore } from '@/stores/BrsStorePinia.js'
  import { useAppStore } from '@/stores/AppStorePinia.js'
  import { storeToRefs } from 'pinia'
  const route = useRoute()
  const router = useRouter()
  const appStore = useAppStore()
  const brsStore = useBrsStore()
  const userStore = useUserStore()
  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store
  const snackbar = vueInstance.$snackbar
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
        const headers = ref([
          {text: 'Plan Name', value: 'name', show: true},
          {text: 'Description', value: 'description', show: true},
          {text: 'Status', value: 'statusType', show: true},
          {text: 'Active Users', value: 'activeUsers', show: true},
        ])

      const getCommissions = async () => {
        appStore.loading = true
        try {
          const {data, status} = await getRequest(`/commissionManagement/plans/${commissionPositionId.value}`, 'blueraven')
          commissions.value = data
          dataLoading.value = false
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Loading Commissions')
          appStore.loading = false
        }
      }
      const goToDetails = (item) => {
        router.push({name: 'commission', params: {id: item.id}})
      }
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

