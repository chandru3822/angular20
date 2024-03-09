<template>
  <div>
    <v-data-table
      :headers="headers"
      :items="companyFeatureList"
      :fixed-header="true"
      :items-per-page="-1"
      v-model="selectedRows"
      hide-default-footer
      disable-sort
      show-select
      class="elevation-1 mt-1"
    >
      <template #no-data>
        <span class="default-text-color">No available fields</span>
      </template>

      <template #no-results>
        <span class="default-text-color">No available fields</span>
      </template>

      <template v-slot:header.MODIFY-ME="{ header, on, props }">
        <a class="primary--text" @click="alterEnabledFlagForColumns(header)">{{header.text}}</a>
      </template>

      <template v-slot:header.data-table-select="{ on, props }">
        <v-simple-checkbox color="primary" v-bind="props" :ripple="false" v-on="on"
                           v-if="userCanEdit" @input="dirtyFieldsCallback()"></v-simple-checkbox>
      </template>

      <template #item="{ item, index, isSelected, select }">
        <tr :class="{ 'shaded-row': index % 2 }">
          <td class="text-center">
            <v-simple-checkbox color="primary" v-if="userCanEdit" :ripple="false" :value="isSelected" @input="[select($event), dirtyFieldsCallback()]"></v-simple-checkbox>
          </td>
          <td class="text-left">
            {{ item.featureName }}
          </td>
          <td v-for="acl in item.accessControl">
            <div v-if="acl.usedByFeature">
              <input type="checkbox" :readonly="!userCanEdit" color="primary"
                     :disabled="!userCanEdit" v-model="acl.enabled" @input="[acl.dirty = true, item.dirty = true, callback(companyFeatureList), dirtyFieldsCallback()]">

              <v-icon class="ml-2 mb-1" small color="grey darken-1"
                      v-if="secondaryFeatureAccess.length > 0 && secondaryHasAccess(item, acl)">
                mdi-alpha-p-box-outline
              </v-icon>
            </div>
          </td>
        </tr>
      </template>

    </v-data-table>
  </div>
</template>

<script setup>
import {AppMutations} from '@/stores/AppStore'

import cloneDeep from 'lodash.clonedeep'
import {handleHidingGlobalLoader, getRequest, getRequestWithParams, getSnackbar} from '@/helpers/helpers'

import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
import {getCurrentInstance, onMounted, ref, toRefs, computed, watch} from "vue";
import { useUserStore } from '@/stores/UserStorePinia.js'
import {useRoute} from "vue-router/composables"

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const store = vueInstance.$store
const userStore = useUserStore()
const route = useRoute()

const props = defineProps({
  companyFeatures: {type: Array},
  callback: Function,
  dirtyFieldsCallback: Function,
  userCanEdit: Boolean,
  showSecondary: Boolean
})

const { showSecondary, userCanEdit } = toRefs(props)

const selectedRows = ref([])
const companyFeatureList = ref(cloneDeep(props.companyFeatures))
const features = ref([])
const secondaryFeatureAccess = ref([])
const accessControlList = ref([])
const parentId = ref(userStore.details.parentCompanyId)
const headers = ref([
  { text: 'Feature', value: 'featureName', show: true },
])

const userId = computed(() => {
  return route.params.id
})

watch(selectedRows, (newVal, oldVal, blah) => {
  alterEnabledFlagForRows(newVal, oldVal, blah)
})

onMounted(() => {
  getFeatures()
  if (showSecondary.value) {
    loadSecondary()
  }
})

const loadSecondary = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequestWithParams(`/feature/access/allUserPositions`, { params: {
        userId: userId.value
      }})
    secondaryFeatureAccess.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Features')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const secondaryHasAccess = (item, acl) => {
  let matchingAccessLevel = secondaryFeatureAccess.value.find(ac => { return ac.featureId === item.featureId && ac.accessCode === acl.accessCode })
  return matchingAccessLevel?.enabled ?? false
}
const populateHeaders = () => {
  //todo. not my favorite
  if(companyFeatureList.value?.length > 0) {
    companyFeatureList.value[0]?.accessControl?.forEach(acl => {
      headers.value.push({
        text: acl.accessLevel,
        value: 'MODIFY-ME',
        custom: acl.accessCode,
        accessControlId: acl.accessControlId,
        show: true
      })
    })
  }
}
const populateSelectedRows = () => {
  // this determines if the checkbox for selecting the row should be checked or not on page load
  if(companyFeatureList.value?.length > 0) {
    companyFeatureList.value.forEach(cfl => {
      let countAccessControlLevels = cfl?.accessControl?.filter(ac => ac.usedByFeature).length
      let countEnabled = 0
      cfl.accessControl?.forEach(acl => {
        if(acl.usedByFeature && acl.enabled) {
          countEnabled++
        }
      })
      if(countEnabled === countAccessControlLevels) {
        selectedRows.value.push(cfl)
      }
    })
  }
}
const alterEnabledFlagForColumns = (header) => {
  if(userCanEdit.value) {
    header.selectAll = !header.selectAll
    companyFeatureList.value.forEach(cf => {
      cf.accessControl.forEach(acl => {
        if(acl.usedByFeature && header.accessControlId === acl.accessControlId) {
          if(acl.enabled !== header.selectAll) {
            acl.dirty = true
            cf.dirty = true
          }
          acl.enabled = header.selectAll
        }
      })
    })
    if(props.callback) {
      props.callback(companyFeatureList.value)
    }
  }
}
const alterEnabledFlagForRows = (newList, oldList) => {
  // filter the new list and remove everything that was in old list.  this is the row that was clicked
  if(companyFeatureList.value.length === newList?.length) {
    // select all
    companyFeatureList.value.forEach(cfl => {
      cfl.accessControl.forEach(ac => {
        if(ac.usedByFeature) {
          //if ac was not enabled, set dirty value to true
          if (!ac.enabled) {
            ac.dirty = true
            cfl.dirty = true
          }
          ac.enabled = true
        }
      })
    })
  } else if (newList?.length === 0 && companyFeatureList.value.length === oldList?.length) {
    // deselect all
    companyFeatureList.value.forEach(cfl => {
      cfl.accessControl.forEach(ac => {
        if(ac.usedByFeature) {
          //if ac was already enabled, set dirty value to true
          if(ac.enabled) {
            ac.dirty = true
            cfl.dirty = true
          }
          ac.enabled = false
        }
      })
    })
  } else {
    let selectedRow, enable
    if(newList?.length > oldList?.length) {
      selectedRow = newList?.filter(e => !oldList?.includes(e))[0]
      enable = true
    } else {
      selectedRow = oldList?.filter(e => !newList?.includes(e))[0]
      enable = false
    }
    let selectedCfl = companyFeatureList.value.find(cfl => { return cfl?.featureId === selectedRow?.featureId})
    selectedCfl?.accessControl?.forEach(acl => {
      if(acl.usedByFeature) {
        if (acl.enabled !== enable) {
          acl.dirty = true
          selectedCfl.dirty = true
        }
        acl.enabled = enable
      }
    })
  }
  if(props.callback) {
    props.callback(companyFeatureList.value)
  }
}
const getFeatures = async () => {
  if (companyFeatureList.value?.length === 0) {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await getRequest(`/feature/withAccess`)
      companyFeatureList.value = data
      populateHeaders()
      populateSelectedRows()
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Features')

      store.commit(AppMutations.SET_LOADING, false)
    }
  } else {
    populateHeaders()
    populateSelectedRows()
  }
}

</script>
<style lang="scss" scoped>

</style>

