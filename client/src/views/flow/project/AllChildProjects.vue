<template>
  <v-row no-gutters id="project-details-container" class="py-0 relative height-one-hunned overflow-y-auto">
    <v-col cols="12" lg="12" class="text-left pt-0">
      <v-expand-transition>
        <v-col>
          <v-row>
            <v-col cols="12">
              <v-row class="justify-space-around align-center">
                <v-col class="text-left pb-0">
                  <h3>All Child Projects</h3>
                </v-col>
              </v-row>
              <v-row>
                <v-col cols="12" class="pt-0">
                  <v-divider/>
                </v-col>
              </v-row>
            </v-col>

            <v-col cols="12" v-if="isChildProjectsLoading">
              <SpinnerInline :size="20" color="primary"/>
            </v-col>

            <v-col cols="12" class="pt-0" v-else>
              <a-text-field placeholder="Filter..."
                            hide-details
                            variant="outlined"
                            type="search"
                            class="mb-4"
                            v-model="projectSearch"></a-text-field>


              <v-data-table
                  :headers="headers"
                  :items="childProjects"
                  :fixed-header="true"
                  :search="projectSearch"
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

                <template #item="{ item, index }">
                  <tr class="clickable" :class="{'shaded-row': index % 2}" @click="goToProject(item.id)">
                    <td class="text-left pl-4">
                      {{ item.projectName }}
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

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const defaultProjectPage = ref(getProjectPath().pathSuffix)

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
  {text: 'Project Name', value: 'projectName', show: true, width: '125px'},
])

onMounted(() => {
  getChildProjects()
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROJECTS', 'EDIT')
})

const companyId = computed(() => {
  return userStore.details.companyId
})

const goToProject = (pId) => {
  let path = `/project/${pId}/${defaultProjectPage.value}`
  let routerData = router.resolve({path})
  window.open(routerData.href, '_blank')
}


const getChildProjects = async () => {
  try {
    isChildProjectsLoading.value = true
    const {data} = await getRequest(`/project/${projectId.value}/children`)
    childProjects.value = data
    window.document.title = `${project.value.projectName} - Child Projects`
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
.process-step-toolbar .v-toolbar__content {
  padding-left: 10px !important;
}
.manage-btn {

  margin-left: 12px;

}
</style>
