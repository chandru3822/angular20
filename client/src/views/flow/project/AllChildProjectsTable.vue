<template>
  <v-row no-gutters id="project-children-container" class="py-0 relative height-one-hunned overflow-y-auto">
    <v-col cols="12" lg="12" class="text-left pt-0">
      <v-expand-transition>
        <v-col>
          <v-row>
            <v-col cols="12">
              <v-row class="justify-space-around align-center">
                <v-col class="text-left pb-0">
                  <v-toolbar color="white" class="elevation-1">
                    <v-toolbar-title class="app-title">All Child Projects</v-toolbar-title>
                    <v-spacer></v-spacer>
                    <v-toolbar-items>
<!--                      <a-btn text="Batch Edit in Table View" :to="`/projectChildrenEdit/${projectId}`"></a-btn>-->
                    </v-toolbar-items>
                  </v-toolbar>
                </v-col>
              </v-row>
            </v-col>

            <v-col cols="12" v-if="isChildProjectsLoading">
              <SpinnerInline :size="20" color="primary"/>
            </v-col>

            <v-col cols="12" class="pt-0" v-else>
              <v-data-table
                  :headers="headers"
                  :items="childProjects"
                  :fixed-header="true"
                  :options.sync="options"
                  :footer-props="footerProps"
                  :items-per-page="-1"
                  :loading="isChildProjectsLoading"
                  dense
                  class="elevation-1"
              >

                <template #no-data>
                  No child projects found
                </template>

                <template #no-results>
                  No child projects found
                </template>

                <template #item="{ item, index }" v-if="">
                  <tr :class="{'shaded-row': index % 2}">
                    <td><v-checkbox v-model="item.selected" @change=""></v-checkbox></td>
                    <td class="text-left pl-4">{{item.projectName}}</td>
                    <td class="text-left pl-4" v-for="h in headers.filter(h => h.showInLoop)">
<!--                      {{rowHasValue(item, h)}}-->
<!--                      {{getField(item, h)}}-->
                      <CustomValueInput :key="item.projectId"
                                        hide-details
                                        hide-label
                                        hide-prepend-icon
                                        :show-field-name="false"
                                        :callback="populateDirtyCfvs"
                                        :field="getField(item, h)"
                      ></CustomValueInput>
                    </td>
                  </tr>
                </template>
              </v-data-table>

            </v-col>

          </v-row>
        </v-col>
      </v-expand-transition>
    </v-col>

  </v-row>
</template>

<script setup>

import {getRequest, logError, getProjectPath} from '@/helpers/helpers'
import SpinnerInline from '@/components/SpinnerInline'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import constants from "@/helpers/constants.js";
import CustomValueInput from "@/views/flow/components/CustomValueInput.vue";

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const defaultProjectPage = ref(getProjectPath().pathSuffix)
let count = ref(0)
const props = defineProps({
  project: Object
})
const { project } = toRefs(props)

const projectId = computed(() => {
  return parseInt(route.params.projectId)
})

const childProjects = ref([])
const projectSearch = ref('')
const menuOpen = ref(false)
const isChildProjectsLoading = ref(false)
const options = ref({itemsPerPage: 100})
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const headers = ref([
  { text: '', value: 'selectBox', selectFilter:true, showInLoop: false, width: '50px' },
  {text: 'Project Name', value: 'projectName', showInLoop: false, width: '125px'},
])

onMounted(() => {
  getChildProjectHeaders()
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROJECTS', 'EDIT')
})

const companyId = computed(() => {
  return userStore.details.companyId
})

// const goToProject = (pId) => {
//   let path = `/project/${pId}/${defaultProjectPage.value}`
//   let routerData = router.resolve({path})
//   window.open(routerData.href, '_blank')
// }

const getChildProjectHeaders = async () => {
  try {
    // const {data} = await getRequest(`/project/childrenHeaders`)
    const data = constants.RANDA_TEST
    data.forEach(d => {
      let header = { ...d,
        text: d.fieldName,
        value: 'get value field name via data type here',
        showInLoop: true,
        width: getColumnWidth(d.dataTypeId)
      }
      headers.value.push(header)
    })
    await getChildProjects()
  } catch (e) {
    logError(e)
  }
}

const getColumnWidth = (dataTypeId) => {
  switch (dataTypeId) {
    case 1: return 230
    case 2: return 270
    case 8:
    case 9:
    case 10:
      return 200
    default: return 100
  }
}

const rowHasValue = (item, header) => {
  let match = item.customFieldValues.find(cfv => cfv.customFieldGroupAssignmentId === header.customFieldGroupAssignmentId)
  return match !== undefined && match?.id !== null
}

const getField = (item, header) => {
  let value = item.customFieldValues.find(cfv => cfv.customFieldGroupAssignmentId === header.customFieldGroupAssignmentId)
  value = value?.id ? value : {}
  // console.log('randalogger',header)
  let field = { ...value, ...header }
  // if(count.value === 0) {
  //   console.log('item', item)
  //   console.log('header', header)
  //   console.log('randalogger',value)
  //   count.value++
  // }
  return field
}

const populateDirtyCfvs = (value) => {
  console.log('pop dirty val', value)
}

const getChildProjects = async () => {
  try {
    isChildProjectsLoading.value = true
    const {data} = await getRequest(`/project/${projectId.value}/children/details`)
    childProjects.value = data
  } catch (e) {
    logError(e)
  } finally {
    isChildProjectsLoading.value = false
  }
}
</script>

<style lang="scss" scoped>
#project-details-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}

.project-header {
  border-bottom: solid 1px #EAEAF4
}

.project-title {
  font-size: 20px;
}
.project-subtitle {
  font-size: 15px;
}

.work-type-header {
  &:not(:first-child) {
    padding-top: 20px;
  }
}
</style>

<style lang="scss">
#project-children-container .v-data-table__wrapper {
  height: calc(100vh - 230px);
  min-height: 300px;
}

.process-step-toolbar .v-toolbar__content {
  padding-left: 10px !important;
}
.manage-btn {

  margin-left: 12px;

}
</style>
