<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-breadcrumbs :items="breadcrumbs"></v-breadcrumbs>
        <v-toolbar class="elevation-1 testing">
          <v-toolbar-title class="app-title">{{ details.companyFunctionName }}</v-toolbar-title>
        </v-toolbar>
        <v-card class="square-card pa-4 elevation-1" v-if="details.description">
          <strong>Description:</strong> <br/>
          {{details.description}}
        </v-card>

        <v-data-table
            :headers="headers"
            :items="details.companyFunctionParams"
            :items-per-page="-1"
            single-expand
            :mobile-breakpoint="0"
            item-key="dbFunctionParamId"
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            <span class="default-text-color">NO DATA HERE!</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No parameters exist for this function</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': details.companyFunctionParams.indexOf(item) % 2}">
<!--              they should not be able to edit system value types-->
<!--              <a-select attach v-if="item.parameterTypeId === 1"-->
<!--                          v-model="item.systemValueId"-->
<!--                          :items="systemValues"-->
<!--                          label="System Value"-->
<!--                          item-title="systemValue"-->
<!--                          item-value="id"></v-select>-->
              <div v-if="item.parameterTypeId === 3">
                <a-select attach v-model="item.processStepId"
                          :items="parentObjects"
                          label="Parent Object"
                          item-title="processStepName"
                          item-value="id"
                          @input="loadFieldsByParent(item.processStepId, item.dataTypeId)"
                ></a-select>
                <a-select attach v-if="item.processStepId"
                          v-model="item.customFieldGroupAssignmentId"
                          :items="availableCustomFields"
                          label="Custom Field"
                          item-title="fieldName"
                          item-value="customFieldGroupAssignmentId"
                ></a-select>
              </div>
              <a-btn
                @click="saveParam(item)"
                prepend-icon="save"
                text="Save">
              </a-btn>
            </td>
          </template>


          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': details.companyFunctionParams.indexOf(item) % 2}">
              <td class="text-left">{{ item.parameterName }}</td>
              <!-- customTypeColumn -->
              <td class="text-left" v-if="item.parameterTypeId === 3">
                {{ item.processStepName || 'Custom Field'}}
              </td>
              <td class="text-left" v-else-if="item.parameterTypeId === 1">
                System
              </td>
              <td class="text-left" v-else-if="item.parameterTypeId === 2">
                Dynamic
              </td>
              <!-- customValueColumn -->
              <td class="text-left" v-if="item.customFieldGroupAssignmentId !== null">
                {{item.fieldName}}
              </td>
              <td class="text-left" v-else-if="item.systemValueId !== null">
                {{item.systemValue}}
              </td>
              <td class="text-left" v-else-if="item.dynamicValue !== null">
                {{item.dynamicValue}}
              </td>
              <td class="text-left" v-else-if="item.customFieldGroupAssignmentId === null && item.systemValueId === null && item.dynamicValue === null">
                n/a
              </td>
              <!-- icon column -->
              <td>
                <a-btn
                  variant="text"
                  color="primary"
                  v-if="userCanEdit && item.parameterTypeId === 3 && !expanded.includes(item)"
                  @click="handleExpand(item, true)"
                  prepend-icon="edit"
                />
                <a-btn
                  variant="text"
                  v-if="item.parameterTypeId === 3 && expanded.includes(item)"
                  @click="handleExpand(item, false)"
                  text="cancel"
                />
              </td>
            </tr>
          </template>

          <template #item.customTypeColumn="{ item }">

          </template>
          <template #item.customValueColumn="{ item }">
            <span v-if="item.customFieldGroupAssignmentId !== null">{{item.fieldName}}</span>
            <span v-else-if="item.systemValueId !== null">{{item.systemValue}}</span>
            <span v-else-if="item.dynamicValue !== null">{{item.dynamicValue}}</span>
            <span v-else-if="item.customFieldGroupAssignmentId === null && item.systemValueId === null && item.dynamicValue === null">n/a</span>
          </template>
        </v-data-table>


      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
  import { handleHidingGlobalLoader, getRequest, postRequest } from '@/helpers/helpers'


  import {getCurrentInstance, computed, onMounted, ref} from "vue";
  import { useUserStore } from '@/stores/UserStore.js'
  import {useRoute} from "vue-router/composables"
  import { useAppStore } from '@/stores/AppStore.js'

  const vueInstance = getCurrentInstance().proxy

  const store = vueInstance.$store
  const userStore = useUserStore()
  const appStore = useAppStore()
  const route = useRoute()

  const headers = ref([
    { text: 'Parameter Name', value: 'parameterName', show: true },
    { text: 'Type', value: 'customTypeColumn', show: true },
    { text: 'Value', value: 'customValueColumn', show: true},
    { text: null, value: 'icons', show: true }
  ])

  const breadcrumbs = ref([
    {
      text: 'Back',
      disabled: false,
      exact: true,
      to: `/settings/functions`
    },
  ])
  const systemValues = ref([])
  const details = ref({})
  const parentObjects = ref([])
  const availableCustomFields = ref([])
  const selectedField = ref({})
  const expanded = ref([])

  const functionId = computed(() => {
    return route.params.id
  })
  const userCanEdit = computed(() => {
    return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
  })
  const companyId = computed(() => {
    return userStore.details.companyId
  })
  const userId = computed(() => {
    return userStore.details.id
  })

  const getFunctionDetails = async () => {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/function/${functionId.value}`)
      details.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.loading = false
    }
  }

  const loadParentObjects = async () => {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/processStep/getParentObjects`)
      parentObjects.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.loading = false
    }
  }
  const loadFieldsByParent = async (id, dataTypeId) => {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/customField/getByParentProcessStep/${id}`)
      availableCustomFields.value = data.filter(d => {
        return d.dataTypeId === dataTypeId
      })
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Data')
      appStore.loading = false
    }
  }
  const handleExpand = async (item, expand) => {
    if(expand) {
      expanded.value = [item]
      if(item.processStepId) {
        loadFieldsByParent(item.processStepId)
      }
    } else {
      expanded.value = []
    }
  }
  const saveParam = async (item) => {

    try {
      appStore.loading = true
      const {data, status} = await postRequest(`/function/${functionId.value}/param`, item)
      if(item.parameterTypeId === 3) {
        item.fieldName = data.fieldName
        item.processStepName = data.processStepName
      }
      expanded.value = []
      handleHidingGlobalLoader(status)
      appStore.showSnack('SUCCESS', 'Parameter Updated')

    } catch (e) {
      appStore.loading = false
      appStore.showSnack('ERROR', 'Error Saving Parameter')
    }

  }

  onMounted(() => {
    getFunctionDetails()
    loadParentObjects()
  })

</script>

<style scoped lang="scss">
.testing {
  margin-bottom: 2px;
}
</style>
