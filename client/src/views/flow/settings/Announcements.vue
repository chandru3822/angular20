<template>
  <v-container>
    <v-row  class="pt-0">
      <v-col cols="12"  class="pt-0">
        <v-toolbar flat>
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Announcements</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="goToPath()" v-if="userCanAdd">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-tabs class="tabs-bar" id="default-settings-tabs">
          <v-tab v-for="(tab, index) in displayedTabs" :key="index" :to="tab.path"
                 class="text-capitalize ma-0 label-medium"
                 :style="{'margin-left': (index === 0 && $vuetify.breakpoint.smAndDown) ? '12px !important' : '0'}">
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
              <td>{{item.title}}</td>
              <td>{{item.startTime  | formatDate('timestamp', 'MM/DD/YYYY h:mm a')}}</td>
              <td>{{item.endTime  | formatDate('timestamp', 'MM/DD/YYYY h:mm a')}}</td>
              <td>
                <span v-if="item.showOnWeb && item.showOnMobile">Web, Mobile</span>
                <span v-else-if="item.showOnWeb">Web</span>
                <span v-else-if="item.showOnMobile">Mobile</span>
              </td>
              <td>
                <v-btn small text color="primary"
                       @click="goToPath(item.id)">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text color="primary" v-if="current && $store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')" @click.stop="[itemToDelete=item, showDeleteDialog=true]">
                  <v-icon >delete</v-icon>
                </v-btn>
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
import {AppMutations} from "@/stores/AppStore";
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
import {getCurrentInstance, ref, computed, onMounted, watch} from "vue";


const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const router = vueInstance.$router

const displayedTabs = computed(() => {
  return this.tabs.filter(tab => tab.display)
})
const filteredAnnouncements = computed(() => {
  return this.announcements?.filter(a => { return !a.archived}) || []
})
const current = computed(() => {
  return this.$route.path.includes('current')
})

const options = ref({
  itemsPerPage: 100
})

const showDeleteDialog = ref(false)
const itemToDelete = ref(null)
const announcementsLoading =ref(true)
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 1000],
    'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const announcements = ref([])
const userCanAdd = ref(store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'))
const userCanEdit = ref(store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'))
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
    display: store.getters.userHasFeature('SETTINGS')
  },
  {
    label: 'Past',
    path: '/settings/announcements/past',
    display: store.getters.userHasFeature('SETTINGS')
  },
])

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
    handleHidingGlobalLoader(vueInstance, status)

  } catch (e) {
    console.error('*** ERROR ***', e)
    store.commit(AppMutations.SET_LOADING, false)
    snackbar('ERROR', 'Error Loading Announcements')
    store.commit(AppMutations.SHOW_SNACK, snackbar)
  } finally {
    announcementsLoading.value = false
  }
}
const closeDeleteDialog = () => {
  showDeleteDialog.value = false
  this.itemToDelete.value = null
}
const deleteAnnouncement = async () => {
  const item = itemToDelete.value
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await deleteRequest(`/announcements/${item.id}`)
    item.archived = true
    announcements.value = announcements.value.filter(a => a.id !== item.id)
    snackbar('SUCCESS', 'Announcement Deleted')
    store.commit(AppMutations.SHOW_SNACK, snackbar)
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    if (e.status === 400) {
      deleteError.value = true;
      fieldsInUse.value = e.data;
      snackbar("ERROR", "Error Deleting Announcement");
      store.commit(AppMutations.SHOW_SNACK, snackbar)
      store.commit(AppMutations.SET_LOADING, false)
    } else {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Deleting Status')
      store.commit(AppMutations.SHOW_SNACK, snackbar)
      store.commit(AppMutations.SET_LOADING, false)
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
