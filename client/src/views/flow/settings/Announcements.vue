<template>
  <v-container>
    <v-row  class="pt-0">
      <v-col cols="12"  class="pt-0">
        <v-toolbar flat>
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Announcements</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                @click="goToPath()"
                v-if="userCanAdd"
                prepend-icon="add"
                :text="addNew ? 'Cancel' : 'Add New'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-tabs class="tabs-bar" id="default-settings-tabs">
          <v-tab v-for="(tab, index) in displayedTabs" :key="index" :to="tab.path"
                 class="text-capitalize ma-0 label-medium"
                 :style="{'margin-left': (index === 0 && vueInstance.$vuetify.breakpoint.smAndDown) ? '12px !important' : '0'}">
            {{ tab.label }}
          </v-tab>
        </v-tabs>
        <v-data-table
            :headers="headers"
            :items="filteredAnnouncements"
            :fixed-header="true"
            :items-per-page="-1"
            :options.sync="options"
            :loading="announcementsLoading"
            disable-sort
            :server-items-length="filteredAnnouncements.length"
            class="elevation-1"
        >
          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td>
                <router-link :to="`/settings/announcement/${item.id}`" class="router-link-td">
                  {{item.title}}
                </router-link>
              </td>
              <td>
                <router-link :to="`/settings/announcement/${item.id}`" class="router-link-td">
                  {{item.startTime  | formatDate('timestamp', 'MM/DD/YYYY h:mm a')}}
                </router-link>
              </td>
              <td>
                <router-link :to="`/settings/announcement/${item.id}`" class="router-link-td">
                  {{item.endTime  | formatDate('timestamp', 'MM/DD/YYYY h:mm a')}}
                </router-link>
              </td>
              <td>
                <span v-if="item.showOnWeb && item.showOnMobile">Web, Mobile</span>
                <span v-else-if="item.showOnWeb">Web</span>
                <span v-else-if="item.showOnMobile">Mobile</span>
              </td>
              <td>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="goToPath(item.id)"
                    prepend-icon="edit"
                ></a-btn>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    v-if="current && userStore.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                    @click.native.stop="[itemToDelete=item, showDeleteDialog=true]"
                    prepend-icon="delete"
                ></a-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
        <ConfirmationDialog :open-dialog="showDeleteDialog"
                            @confirm="deleteAnnouncement"
                            @close-dialog="closeDeleteDialog"
        >
          Are you sure you want to delete this announcement: <strong>{{itemToDelete?.title}}</strong>?

        </ConfirmationDialog>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>
import constants from '@/helpers/constants'

import {deleteRequest, getRequestWithParams, handleHidingGlobalLoader} from "@/helpers/helpers";
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
import {getCurrentInstance, ref, computed, onMounted, watch} from "vue";
import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStore.js'
import {useRoute, useRouter} from "vue-router/composables";


const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
const appStore = useAppStore()
 const router = useRouter()
const route = useRoute()


const current = computed(() => {
  return route.path.includes('current')
})

const options = ref({
  itemsPerPage: 100
})

const addNew = ref(false)
const showDeleteDialog = ref(false)
const itemToDelete = ref(null)
const announcementsLoading =ref(true)
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 1000],
    'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const announcements = ref([])
const fieldsInUse = ref([])
const headers = ref([
  { text: 'Title', value: 'title', show: true },
  { text: 'Start Time', value: 'startTime', show: true },
  { text: 'End Time', value: 'endTime', show: true },
  { text: 'Platform', value: 'platform', show: true },
  { text: null, value: 'icons', show: true, sortable: false }
])
const tabs = ref([
  {
    label: 'Current',
    path: '/settings/announcements/current',
    display: userStore.userHasFeature('SETTINGS')
  },
  {
    label: 'Past',
    path: '/settings/announcements/past',
    display: userStore.userHasFeature('SETTINGS')
  },
])

const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})

const displayedTabs = computed(() => {
  return tabs.value.filter(tab => tab.display)
})
const filteredAnnouncements = computed(() => {
  return announcements.value?.filter(a => { return !a.archived}) || []
})

onMounted(() => {
  getAnnouncements()
})

watch(current, () => {
  announcements.value = []
  getAnnouncements()
})
const goToPath = (id) => {
  let path = id ? `/settings/announcement/${id}` : `/settings/announcement`
  router.push(path)
}
const getAnnouncements = async () => {
  announcementsLoading.value = true
  try {
    const { page, itemsPerPage } = options.value
    let url = current.value ? `/announcements/current` : `/announcements/past`
    const {data, status} = await getRequestWithParams(url, { params: {
        page: page - 1 || 0,
        size: itemsPerPage
      }})
    announcements.value = data.content
    handleHidingGlobalLoader(status)

  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.loading = false
    appStore.showSnack('ERROR', 'Error Loading Announcements')
  } finally {
    announcementsLoading.value = false
  }
}
const closeDeleteDialog = () => {
  showDeleteDialog.value = false
  itemToDelete.value = null
}
const deleteAnnouncement = async () => {
  const item = itemToDelete.value
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/announcements/${item.id}`)
    item.archived = true
    announcements.value = announcements.value.filter(a => a.id !== item.id)
    appStore.showSnack('SUCCESS', 'Announcement Deleted')
    handleHidingGlobalLoader(status)
  } catch (e) {
    if (e.status === 400) {
      deleteError.value = true;
      fieldsInUse.value = e.data;
      appStore.showSnack("ERROR", "Error Deleting Announcement");
      appStore.loading = false
    } else {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Deleting Status')
      appStore.loading = false
    }
  }
  closeDeleteDialog()
}
</script>

<style lang="scss">
@media (max-width: 959px) {
  #default-settings-tabs > div > div.v-slide-group__wrapper > div {
    justify-content: center;
  }
  #default-settings-tabs > div > div.v-slide-group__prev.v-slide-group__prev--disabled {
    display: none;
  }
}
</style>
