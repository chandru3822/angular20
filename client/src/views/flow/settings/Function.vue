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
<!--              <v-select attach v-if="item.parameterTypeId === 1"-->
<!--                          v-model="item.systemValueId"-->
<!--                          :items="systemValues"-->
<!--                          label="System Value"-->
<!--                          item-text="systemValue"-->
<!--                          item-value="id"></v-select>-->
              <div v-if="item.parameterTypeId === 3">
                <v-select attach v-model="item.processStepId"
                          :items="parentObjects"
                          label="Parent Object"
                          item-text="processStepName"
                          item-value="id"
                          @input="loadFieldsByParent(item.processStepId, item.dataTypeId)"
                ></v-select>
                <v-select attach v-if="item.processStepId"
                          v-model="item.customFieldGroupAssignmentId"
                          :items="availableCustomFields"
                          label="Custom Field"
                          item-text="fieldName"
                          item-value="customFieldGroupAssignmentId"
                ></v-select>
              </div>
              <AlbatrossButton @click="saveParam(item)" prepend-icon="save" text="Save">
              </AlbatrossButton>
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
                <AlbatrossButton text color="primary" v-if="userCanEdit && item.parameterTypeId === 3 && !expanded.includes(item)" @click="handleExpand(item, true)">
                  <v-icon>edit</v-icon>
                </AlbatrossButton>
                <AlbatrossButton text v-if="item.parameterTypeId === 3 && expanded.includes(item)" @click="handleExpand(item, false)">cancel</AlbatrossButton>
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
  import {AppMutations} from '@/stores/AppStore'
  import { handleHidingGlobalLoader, getRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";

  import {getCurrentInstance, onMounted, ref} from "vue";

  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const store = vueInstance.$store
  const router = vueInstance.$route

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
  const userCanEdit = ref(store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'))
  const companyId = ref(store.state.user.details.companyId)
  const functionId = ref(vueInstance.$route.params.id)
  const userId = ref(store.state.user.details.id)
  const systemValues = ref([])
  const details = ref({})
  const parentObjects = ref([])
  const availableCustomFields = ref([])
  const selectedField = ref({})
  const expanded = ref([])

  const getFunctionDetails = async () => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await getRequest(`/function/${functionId.value}`)
      details.value = data
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      store.commit(AppMutations.SET_LOADING, false)
    }
  }

  const loadParentObjects = async () => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await getRequest(`/processStep/getParentObjects`)
      parentObjects.value = data
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const loadFieldsByParent = async (id, dataTypeId) => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await getRequest(`/customField/getByParentProcessStep/${id}`)
      availableCustomFields.value = data.filter(d => {
        return d.dataTypeId === dataTypeId
      })
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')
      store.commit(AppMutations.SET_LOADING, false)
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
      store.commit(AppMutations.SET_LOADING, true)
      const {data, status} = await postRequest(`/function/${functionId.value}/param`, item)
      if(item.parameterTypeId === 3) {
        item.fieldName = data.fieldName
        item.processStepName = data.processStepName
      }
      expanded.value = []
      handleHidingGlobalLoader(vueInstance, status)
      snackbar('SUCCESS', 'Parameter Updated')

    } catch (e) {
      store.commit(AppMutations.SET_LOADING, false)
      snackbar('ERROR', 'Error Saving Parameter')
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
