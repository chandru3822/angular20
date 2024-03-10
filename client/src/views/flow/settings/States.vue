<template>
  <v-container id="states-settings">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">States</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton variant="text" color="primary" v-if="userCanAdd" @click="[addNew = !addNew, selectedState = {}]"
                             :hide-text-on-mobile="constants.IS_MOBILE"
                             :prepend-icon="constants.IS_MOBILE ? 'add' : ''" :text="addNew ? 'CANCEL' : 'ADD NEW'"
            />

          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat >
          <h3>Add State to Company</h3>
          <div class="mb-3">
            <v-autocomplete
                v-model="selectedState"
                :items="states"
                label="Select a state to use"
                item-text="state"
                item-value="id"
                return-object
                attach
            ></v-autocomplete>
          </div>
          <AlbatrossButton :disabled="!selectedState || !selectedState.id"
                 color="primary" class="white--text mr-2"
                 @click="saveCompanyState(selectedState, true)" text="SAVE"/>
          <AlbatrossButton variant="text" color="primary" @click="[addNew = !addNew, selectedState = {}]" text="CANCEL"/>
        </v-card>
        <v-data-table
            id="states-settings-table"
            :headers="headers"
            :items="filterStates"
            :fixed-header="true"
            :items-per-page="-1"
            single-expand
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1 org-type-table table-striped"
        >
          <template #no-data>
            <span class="default-text-color">NO DATA HERE!</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No parameters exist for this function</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': filterStates.indexOf(item) % 2}">
              <h3>Edit State</h3>
              <div class="mb-3">
                <v-text-field text v-model="item.mapLatitude"
                              label="Map Latitude" />
                <v-text-field text v-model="item.mapLongitude"
                              label="Map Longitude" />
                <v-text-field text v-model="item.mapZoom"
                              label="Map Zoom" />
                <label>Active:</label>
                <input class="ml-3" type="checkbox" v-model="item.active">
              </div>
              <AlbatrossButton :disabled="!item.mapLatitude || !item.mapLongitude || !item.mapZoom"
                     color="primary" class="white--text mr-2"
                     @click="saveCompanyState(item, false)" text="SAVE"/>
            </td>
          </template>
          <template #item.active="{ item }">
            <input type="checkbox" v-model="item.active" disabled readonly>
          </template>
          <template #item.icons="{ item}">
            <AlbatrossButton size="small" icon variant="text" :large="vuetify.breakpoint.smAndDown" color="primary"
                             v-if="userCanEdit && !expanded.includes(item)" @click="expanded = [item]"
                             prepend-icon="edit"/>
            <AlbatrossButton size="small" icon :large="vuetify.breakpoint.smAndDown" color="primary"
                             v-if="userCanEdit && expanded.includes(item)"
                             @click="expanded = []" text="CANCEL"/>
            <AlbatrossButton size="small" icon variant="text" :large="vuetify.breakpoint.smAndDown" color="primary"
                             v-if="userCanDelete" @click="stateToDelete=item" prepend-icon="delete"/>
          </template>

        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!stateToDelete" @confirm="deleteCompanyState" @close-dialog="stateToDelete=null">
      Are you sure you want to delete this state: <strong>{{stateToDeleteName}}</strong>
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
  import {AppMutations} from '@/stores/AppStore'

  import {getAvailableStates} from '@/services/stateService'
  import {handleHidingGlobalLoader, getRequest, deleteRequest, putRequest} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import orderBy from "lodash.orderby";
  import ConfirmationDialog from "@/components/ConfirmationDialog";

  import {getCurrentInstance, onMounted, ref, computed, watch} from "vue";
  import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
  import { useUserStore } from '@/stores/UserStorePinia.js'

  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const vuetify = vueInstance.$vuetify
  const store = vueInstance.$store
  const userStore = useUserStore()

  const addNew = ref(false)
  const levels = ref([])
  const companyStates = ref([])
  const selectedState = ref({})
  const states = ref([])
  const selectedCompanyStateId = ref(null)
  const headers = ref([
    { text: 'State', value: 'state', show: true },
    { text: 'Abbreviation', value: 'abbreviation', show: true },
    { text: 'Active', value: 'active', show: true },
    { text: null, value: 'icons', show: true, sortable: false }
  ])
  const expanded = ref([])
  const stateToDelete = ref(null)
  const stateToDeleteName = computed(() => {
    return stateToDelete.value ? stateToDelete.value.state : ''
  })
  const filterStates = computed(() => {
    return orderBy(companyStates.value.filter(cs => { return !cs.archived}), [cs => cs.state.toLowerCase()])
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
  const companyId = computed(() => {
    return userStore.details.companyId
  })
  const userId = computed(() => {
    return userStore.details.id
  })

  onMounted(async () =>{
    getCompanyStates()
    await getStates()
  })
  const saveCompanyState = async (ol, isNew) => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      let params = {
        ...ol
      }
      params.stateId = ol.id
      params.id = isNew ? null : params.id
      const {data, status} = await putRequest(`/state/saveCompanyState`, params)
      if(isNew){
        companyStates.value.push(data)
        addNew.value = false
        selectedState.value = {}
        snackbar('SUCCESS', 'State Added')
      } else {
        expanded.value = []
        snackbar('SUCCESS', 'State Updated')
      }
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', isNew ? 'Error Adding State' : 'Error Updating State')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const getCompanyStates = async () => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await getRequest(`/state/company`)
      companyStates.value = data
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Loading Company States')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const getStates = async () => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await getAvailableStates()
      states.value = data
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Loading States')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const deleteCompanyState = async () => {
    const companyState = stateToDelete.value
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {status} = await deleteRequest(`/state/companyState/${companyState.id}`)
      companyState.archived = true
      snackbar('SUCCESS', 'State Deleted')
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Deleting State')
      store.commit(AppMutations.SET_LOADING, false)
    }
    stateToDelete.value = null
  }
</script>
<style scoped lang="scss">
@media (max-width: 960px) {
  //increase the size of checkbox on mobile
  input[type='checkbox'] {
    width: 25px;
    height: 25px;
  }

}
</style>
<style lang="scss">
//keeps the arrow icon on the sort chip (mobile dropdown) from having a light blue background
#states-settings-table > div > table > thead > tr > th > div > div > div > div > div.v-select__slot > div.v-select__selections > span > span > div {
  background-color: inherit !important;
}


@media (max-width: 960px) {
  @import "@/styles/main.scss"; //yes this import has to be inside the media query b/c you can't @extend across media-queries ¯\_(ツ)_/¯
  //increase state name size on mobile so it looks better
  #states-settings-table > div > table > tbody > tr > td:nth-child(1) > div.v-data-table__mobile-row__cell {
    @extend .body-large;
  }

  #states-settings {
    margin-bottom: 24px;
  }
}
</style>
