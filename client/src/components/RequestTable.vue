<template>
  <v-container class="pa-0">
    <v-toolbar color="white" class="elevation-1 mt-3">
      <v-text-field
          class="mt-5 pay-search"
          prepend-inner-icon="search"
          text
          label="Search projects..."
          v-model="searchQuery"
          @input="debounceFilterProjects"
      ></v-text-field>
    </v-toolbar>
    <v-col cols="12">
      <v-data-table
          :headers="headers"
          :items="projects"
          :fixed-header="true"
          :search="projectsSearch"
          :options.sync="options"
          :footer-props="footerProps"
          :items-per-page="50"
          :server-items-length="totalItems"
          :loading="dataLoading"
          dense
          class="elevation-1"
      >

        <template #no-data>
          No requests found
        </template>

        <template #no-results>
          No requests found
        </template>

        <template #body="{ items }">
          <tr
              v-for="(it, index) in items"
              :key="it.id"
              :class="['text-sm-left', 'row-hover', { 'shaded-row': !(index % 2) }, {'clickable' : userStore.userHasFeatureAccessLevel(featureCode, 'ADD')}]"
              @click="submitRequest(it)"
          >
            <td class="text-left pl-4">
              {{ it.customer_name ? it.customer_name : '' }}
            </td>
            <!--            need to check permissions if we turn this on-->
            <!--            <td class="text-left pl-4"><a target="_blank" :href="`/project/${it.project_id}/details`">{{ it.project_id }}</a></td>-->
            <td class="text-left pl-4">{{ it.project_id }}</td>
            <td class="text-left pl-4">{{ it.address ? it.address : '' }}</td>
          </tr>
        </template>
      </v-data-table>

      <v-dialog v-model="requestDialog" max-width="700px">
        <v-card>
          <slot name="dialogContent"></slot>
          <v-card-actions>
            <v-spacer></v-spacer>
            <AlbatrossButton
                @click="closeDialog"
                color="primary"
                variant="text"
                class="text-capitalize mr-2 mb-2"
                text="cancel"
            ></AlbatrossButton>
            <AlbatrossButton
                @click="[$emit('submitRequest'), closeDialog()]"
                color="primary"
                class="elevation-2 text-capitalize mr-2 mb-2"
                text="Submit"
            ></AlbatrossButton>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </v-col>
  </v-container>
</template>


<script setup>
import constants from "@/helpers/constants";
import debounce from "lodash.debounce";
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const props = defineProps({
  headers: Array, // format {text: '', value: '', show: boolean}
  projects: Array,
  totalItems: Number,
  featureCode:String,
  isLoading: Boolean
})
const { headers, projects, totalItems, featureCode, isLoading } = toRefs(props)

const emit = defineEmits(['clearSearch', 'searchInput', 'openRequest'])

const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const options = ref({itemsPerPage: 100})
const pagination = ref({})
const projectsSearch = ref('')
const searchQuery = ref('')
const requestDialog = ref(false)

const dataLoading = computed(() => {
  return isLoading.value
  //computed so that it updates when the value changes on the parent
})

const changeSort = (column) => {
  //todo: make sort actually work
  if (pagination.value.sortBy === column) {
    pagination.value.descending = !pagination.value.descending
  } else {
    pagination.value.sortBy = column
    pagination.value.descending = false
  }
}
const closeDialog = () => {
  requestDialog.value = false
}

const debounceFilterProjects = debounce((query) => {
  if(searchQuery.value == ''){
    emit('clearSearch')
  }
  emit('searchInput', searchQuery.value)
}, 500)


const submitRequest = (item) => {
  if(userStore.userHasFeatureAccessLevel(featureCode.value, 'ADD')){
    emit('openRequest', item)
    requestDialog.value = true
  }
}
</script>

<style scoped>

</style>
