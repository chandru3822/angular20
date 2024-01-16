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
          <v-tab v-for="(tab, index) in displayedTabs" :key="index" @click="current = tab.current"
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
                <v-btn small text color="primary" @click="goToPath(item.id)">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text color="primary" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')" @click.stop="[itemToDelete=item, showDeleteDialog=true]">
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

<script>
import constants from '@/helpers/constants'
import {deleteRequest, getRequestWithParams, getSnackbar, handleHidingGlobalLoader} from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";

  export default {
    name: 'Announcements',
    components: {ConfirmationDialog},

    computed: {
      displayedTabs () {
        return this.tabs.filter(tab => tab.display)
      },
      filteredAnnouncements () {
        return this.announcements?.filter(a => { return !a.archived}) || []
      },
    },
    data() {
      return {
        constants,
        addNew: false,
        options: {
          itemsPerPage: 100
        },
        showDeleteDialog: false,
        itemToDelete: null,
        announcementsLoading: true,
        footerProps: {
          'items-per-page-options': [25, 50, 100, 1000],
          'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
        },
        announcements: [],
        current: true,
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
        headers: [
          { text: 'Title', value: 'title', show: true },
          { text: 'Start Time', value: 'startTime', show: true },
          { text: 'End Time', value: 'endTime', show: true },
          { text: 'Platform', value: 'platform', show: true },
          { text: null, value: 'icons', show: true, sortable: false }
        ],
        tabs: [
          {
            label: 'Current',
            current: true,
            display: this.$store.getters.userHasFeature('SETTINGS')
          },
          {
            label: 'Past',
            current: false,
            display: this.$store.getters.userHasFeature('SETTINGS')
          },
        ]
      }
    },
    created() {
      this.getAnnouncements()
    },
    watch: {
      current() {
        this.announcements = []
        this.getAnnouncements()
      }
    },
    methods: {
      goToPath(id) {
        let path = id ? `/settings/announcement/${id}` : `/settings/announcement`
        this.$router.push(path)
      },
      async getAnnouncements() {
        this.announcementsLoading = true
        try {
          const { page, itemsPerPage } = this.options
          let url = this.current ? `/announcements/current` : `/announcements/past`
          const {data, status} = await getRequestWithParams(url, { params: {
              page: page - 1 || 0,
              size: itemsPerPage
            }})
          this.announcements = data.content
          handleHidingGlobalLoader(this, status)

        } catch (e) {
          console.error('*** ERROR ***', e)
          this.$store.commit(AppMutations.SET_LOADING, false)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Announcements')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } finally {
          this.announcementsLoading = false
        }
      },
      closeDeleteDialog() {
        this.showDeleteDialog = false
        this.itemToDelete = null
      },
      async deleteAnnouncement () {
        const item = this.itemToDelete
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/announcements/${item.id}`)
          item.archived = true
          this.announcements = this.announcements.filter(a => a.id !== item.id)
          this.snackbar = getSnackbar('SUCCESS', 'Announcement Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          if (e.status === 400) {
            this.deleteError = true;
            this.fieldsInUse = e.data;
            this.snackbar = getSnackbar("ERROR", "Error Deleting Announcement");
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
          else {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Deleting Status')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
        this.closeDeleteDialog()
      },
    }
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
