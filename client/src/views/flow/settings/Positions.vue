<template>
  <v-container id="positions-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Positions</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
              variant="text"
              to="/settings/position"
              color="primary"
              v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')"
              prepend-icon="add"
              text="ADD POSITION"
            />
          </v-toolbar-items>
        </v-toolbar>
        <div class="pa-4">
          <a-text-field
            v-model="search"
            prepend-inner-icon="search"
            label="Search"
            single-line
            hide-details
          ></a-text-field>
        </div>
        <v-data-table
            :headers="headers"
            :items="filterPositions"
            :fixed-header="true"
            :search="search"
            disable-sort
            :items-per-page="-1"
            hide-default-footer
            :loading="dataLoading"
            class="elevation-1 fix-column-width-bug positions-table"
        >
          <template #no-data>
            <span class="default-text-color">No available positions</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available positions</span>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left" @click="clickRow(item.id)">
                <router-link :to="`/settings/position/${item.id}`" class="router-link-td">
                  {{item.position}}
                </router-link>
              </td>
              <td class="text-left" @click="clickRow(item.id)">
                <router-link :to="`/settings/position/${item.id}`" class="router-link-td">
                  {{item.orgType}}
                </router-link>
              </td>
              <td class="px-0">
                <a-btn
                  size="small"
                  variant="text"
                  color="primary"
                  @click="clickRow(item.id)"
                  prepend-icon="edit"
                  custom-classes="pa-0"
                />
                <a-btn
                  size="small"
                  :disabled="!userCanDelete"
                  variant="text"
                  color="primary"
                  @click="positionToDelete=item"
                  prepend-icon="delete"
                  custom-classes="pa-0"
                />
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!positionToDelete" @confirm="deletePosition" @close-dialog="positionToDelete=null">
      Are you sure you want to delete this position <strong>{{positionToDeleteName}}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
  import {handleHidingGlobalLoader, getRequest, deleteRequest, getSnackbar} from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";



  import {getCurrentInstance, onMounted, ref, computed} from "vue";
  import { useUserStore } from '@/stores/UserStore.js'
  import {useRouter} from "vue-router/composables"
  import { useAppStore } from '@/stores/AppStorePinia.js'
  const appStore = useAppStore()

  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const store = vueInstance.$store
  const userStore = useUserStore()
  const vuetify = vueInstance.$vuetify
  const router = useRouter()


  const delay = ref(500)
  const addNew = ref(false)
  const positions = ref([])
  const descending = ref(true)
  const dataLoading = ref(true)
  const search = ref('')
  const positionToDelete = ref(null)
  const headers = ref([
    {text: 'Position Name', value: 'position', show: true},
    {text: 'Org Type', value: 'orgType', show: true},
    {text: '', value: 'icons', show: false, width: '100px'},
  ])
  const positionToDeleteName = computed(() =>{
    return positionToDelete.value ? positionToDelete.value.position : ''
  })

  const functionId = computed(() => {
    return route.params.id
  })
  const userCanAdd = computed(() => {
    return userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')
  })
  const userCanEdit = computed(() => {
    return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
  })
  const userCanDelete = computed(() => {
    return userStore.userHasFeatureAccessLevel('SETTINGS', 'DELETE')
  })

  const filterPositions = computed(() =>{
    return positions.value?.filter(p => { return !p.archived})
  })

  onMounted(() => {
    getPositions()
  })
  const clickRow = (id) => {
    router.push({name: 'position', params: {id: id}})
  }
  const getPositions = async () => {
    try {
      const {data, status} = await getRequest(`/position`)
      positions.value = data
      dataLoading.value = false
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Positions')

      appStore.loading = false
    }
  }
  const deletePosition = async () => {
    const p = positionToDelete.value
    appStore.loading = true
    try {
      const {status} = await deleteRequest(`/position/${p.id}`)
      p.archived = true
      snackbar('SUCCESS', 'Position Deleted')

      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Deleting Position')
      appStore.loading = false
    }
  }

</script>

<style lang="scss">
  #positions-container .v-data-table__wrapper {
    height: calc(100vh - 300px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  #positions-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }

  .positions-table {
    margin-top: 2px;
  }

</style>

