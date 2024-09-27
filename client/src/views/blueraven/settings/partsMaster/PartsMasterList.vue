<template>
  <v-container>
    <v-toolbar flat class="app-toolbar">
      <v-toolbar-title class="title-large">Parts Master Versions</v-toolbar-title>
      <v-spacer />
      <v-toolbar-items v-if="canCreateVersion">
        <a-btn
          class="toolbar-btn-text"
          variant="text"
          color="primary"
          @click="create"
          text="Create New Version"
        ></a-btn>
        <a-btn
          class="toolbar-btn-icon"
          icon
          size="large"
          color="primary"
          @click="create"
          prepend-icon="mdi-plus"
        ></a-btn>
      </v-toolbar-items>
    </v-toolbar>
    <v-divider />
    <v-container>
      <div v-if="!loading && !versions.length">No parts master versions available.</div>
      <v-card v-if="versions.length" class="square-card">
        <v-data-table
          id="parts-master-version-table"
          :headers="headers"
          :items="versions"
          :options.sync="options"
          :server-items-length="totalVersions"
          :footer-props="footerProps"
          class="elevation-1"
          @click:row="handleClick"
        >
          <template #item.version="{ item }"
          >Version {{ item.version }}</template
          >
          <template #item.status="{ item }">
            <v-chip
              class="ma-2"
              label
              color="grey lighten-2"
              v-if="item.status"
            >
              {{ capitalize(item.status) }}
            </v-chip>
            <v-chip
              class="ma-2 default-text-color"
              label
              color="primary lighten-9"
              v-if="item.primaryVersion"
            >
              Current
            </v-chip>
          </template>
          <template #item.dateModified="{ item }">
            <span> {{ item.dateModified | formatDate('timestamp') }}</span>
          </template>
          <template #item.actions="{ item }">
            <a-btn
              class="ma-2"
              variant="text"
              icon
              color="primary"
              @click.native.stop="showHistory(item.version)"
              prepend-icon="mdi-history"
            ></a-btn>
          </template>
        </v-data-table>

        <parts-master-version-history
          :visible.sync="history.show"
          :version="history.version"
        />
      </v-card>
    </v-container>
  </v-container>
</template>
<script setup>
import { getRequestWithParams, postRequest } from '@/helpers/helpers'
import PartsMasterVersionHistory from '@/views/blueraven/settings/partsMaster/PartsMasterVersionHistory.vue'

import { computed, ref, onMounted, watch } from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
import { useRouter } from 'vue-router/composables'
import { capitalize } from './formatters.js'

const router = useRouter()
const userStore = useUserStore()

const loading = ref(true)
const history = ref({ show: false, version: undefined })
const options = ref({ sortBy: ['version'], sortDesc: [true] })
const headers = ref([
  { text: '', value: 'status', sortable: false },
  { text: 'Version', value: 'version', sortable: false },
  { text: 'Modified on', value: 'dateModified', sortable: false },
  { text: 'Modified by', value: 'modifiedBy', sortable: false },
  { text: 'Description', value: 'notes', sortable: false },
  { text: '', value: 'actions', sortable: false }
])
const footerProps = ref({
  'items-per-page-options': [5, 10, 20, 50, 100]
})
const totalVersions = ref(-1)
const versions = ref([])

onMounted(() => {
  getPartsMasterFields()
})

const canCreateVersion = computed(() => {
  if (!userStore.userHasFeatureAccessLevel('PARTS_MASTER', 'ADMIN')) {
    return false
  }
  return !loading.value && !versions.value.some((v) => v.status === 'DRAFT')
})

watch(
  options,
  (newVal) => {
    getPartsMasterFields()
  },
  { deep: true }
)

const create = async () => {
  const { data } = await postRequest('/partsMaster/versions', {}, 'blueraven')
  versions.value.push({ ...data })
  await router.push({ name: 'partsMasterDetail', params: { id: data.id } })
}
const handleClick = (item) => {
  router.push({ name: 'partsMasterDetail', params: { id: item.id } })
}
const getPartsMasterFields = async () => {
  const { itemsPerPage, page } = options.value
  loading.value = true
  const { data } = await getRequestWithParams(
    `/partsMaster/versions?size=${itemsPerPage}&page=${page - 1}`,
    {},
    'blueraven'
  )
  totalVersions.value = data.totalElements ?? -1
  versions.value = [...data.content]
  loading.value = false
}
const showHistory = (versionId) => {
  history.value.version = versionId
  history.value.show = true
}
</script>
<style scoped lang="scss">
@import '@/styles/main.scss';

::v-deep {
  .v-data-table__wrapper {
    height: calc(100vh - 290px);
    min-height: 300px;
    overflow: auto;
  }
}

tr:nth-of-type(even) {
  @extend .shaded-row;
}

.toolbar-btn-text {
  @media (max-width: 960px) {
    display: none;
  }
}
.toolbar-btn-icon {
  @media (min-width: 961px) {
    display: none;
  }
}
</style>
<style lang="scss">
@media (max-width: 770px) {
  #parts-master-version-table {
    padding-bottom: 12px;
    div.v-data-footer {
      display: inline-block;
      width: 100%;
      padding-bottom: 12px;

      div.v-data-footer__select {
        justify-content: center;
      }

      div.v-data-footer__icons-before {
        display: inline;
        margin-left: calc(50% - 36px);
      }

      div.v-data-footer__icons-after {
        display: inline;
      }
    }
  }
}
</style>
