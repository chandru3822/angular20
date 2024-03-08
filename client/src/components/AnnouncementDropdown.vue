<template>
  <div class="flex-align-items-center"  id="announcement-dropdown">
    <v-dialog v-model="showModal" :max-width="765"
              content-class="modal-content">
      <AnnouncementModal :announcement="selectedAnnouncement"
                         :close-callback="closeModal">
      </AnnouncementModal>
    </v-dialog>
  <v-menu data-app
          left
          offset-y
          :max-height="`calc(100vh - 75px)`"
          :max-width="menuWidth"
          :min-width="menuWidth"
          v-model="menuOpen"
          class="account-menu"
          :close-on-content-click="false">
    <template v-slot:activator="{ on }">
      <v-btn class="account-menu-button label-medium"
             dark
             :class="{'announcement-adjust-for-badge': hasUnalertedAnnouncements}"
             :color="constants.ENV_COLOR"
             v-on="on"
      >
        <v-icon>mdi-bell</v-icon>
        <v-badge dot class="alert-badge" v-if="hasUnalertedAnnouncements"
            color="error lighten-1"
        ></v-badge>
      </v-btn>
    </template>
    <div>
      <v-list v-if="loadingAgain">
        <v-list-item class="pr-1">
          <v-list-item-icon>
            <SpinnerInline :size="20" color="primary"/>
          </v-list-item-icon>
          <v-list-item-content class="">
            Loading
          </v-list-item-content>
        </v-list-item>
      </v-list>
      <v-list v-else-if="appStore.announcements?.length === 0">
          <v-list-item class="pr-1">
            <v-list-item-content class="">
              You don't have any notifications
            </v-list-item-content>
          </v-list-item>
      </v-list>
      <v-list v-else-if="appStore.announcements?.length > 0">
        <template  v-for="(item, index) in appStore.announcements">
        <v-list-item class="pr-1"
                     :key="item.id">
          <v-list-item-icon v-if="!item.read" class="mr-2">
            <v-icon small tool
                    color="error lighten-1">mdi-circle</v-icon>
          </v-list-item-icon>
          <v-list-item-content class="pr-2">
              {{item.alertText}}
          </v-list-item-content>
          <v-list-item-action v-if="item.expandable"
                              class="announcement-action pr-4">
            <v-list-item-action-text>
              <v-btn text color="primary" class="learn-more-btn text-transform-unset" @click="[ item.read = true, openModal(item)]">Learn More</v-btn>
            </v-list-item-action-text>
          </v-list-item-action>
          </v-list-item>
        <v-divider
            v-if="index < appStore.announcements.length - 1"
        ></v-divider>
        </template>
      </v-list>

    </div>
  </v-menu>
  </div>
</template>

<script>
  import constants from '@/helpers/constants'
  import Vue2Filters from "vue2-filters"
  import SpinnerInline from '@/components/SpinnerInline'
  import {getRequestWithParams, getSnackbar} from '@/helpers/helpers'
  import { AppMutations } from '@/stores/AppStore'
  import AnnouncementModal from "@/components/AnnouncementModal.vue";
  import { mapStores } from 'pinia'
  import { useUserStore } from '@/stores/UserStorePinia.js'
  import { useAppStore } from '@/stores/AppStorePinia.js'
  import { useFileStore } from '@/stores/FileStore.js'

  export default {
    name: 'AnnouncementDropdown',
    components: {
      SpinnerInline,
      AnnouncementModal
    },
    mixins: [Vue2Filters.mixin],
    props: {
    },
    watch: {
      menuOpen(newValue, oldValue) {
        if(newValue) {
          this.getActiveAnnouncementsAgain()

          // if(this.hasUnseenAnnouncements) {
          //   //if there are unseen announcements handle those here
          //   console.log('there are popups')
          //   this.$store.dispatch(AppActions.MARK_SEEN_AND_ALERTED_ANNOUNCEMENTS)
          // }
        }
      }
    },
    data () {
      return {
        constants,
        showModal: false,
        headerColor: constants.ENV_COLOR,
        menuOpen: false,
        selectedAnnouncement: {},
        loadComplete: false,
        loadingAgain: true
      }
    },
    computed: {
      ...mapStores(useUserStore, useAppStore, useFileStore),
      userId() {
        return this.userStore.details.id
      },
      menuWidth() {
        return this.constants.IS_MOBILE ? 320 : 400
      },
      hasUnalertedAnnouncements () {
        return this.appStore.announcements?.filter(a => !a.alerted)?.length > 0 || false
      },
    },
    created () {
    },
    methods: {
      //we reload them again here in case something changes
      async getActiveAnnouncementsAgain() {
        try {
          this.loadingAgain = true
          let params = {
            doUpdate: true //we do this every time in case something changed behind the scenes
          }
          const {data, status} = await getRequestWithParams(`/announcements/active`, {params})
          this.appStore.announcements = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } finally {
          this.loadingAgain = false
        }
      },
      async openModal(item) {
        this.menuOpen = false
        this.showModal = true
        this.loadComplete = false
        await this.getAttachment(item)
        this.selectedAnnouncement = item
      },
      async getAttachment(item) {
        try {
          await this.fileStore.getOne({
            attachmentTypeId: 990,
            sourceId: item.id,
            callback: async (img) => {
              item.presignedUrl = img.presignedUrl
              item.attachmentId = img.id
              this.loadComplete = true
            }
          })
        } catch(e) {
          console.error('*** ERROR ***', e)
          this.loadComplete = true
        }
      },
      closeModal() {
        this.showModal = false
        this.selectedAnnouncement = {}
      },
    }
  }
</script>

<style lang="scss">
.announcement-adjust-for-badge .v-btn__content {
  padding-right: 8px;
}
</style>
<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.announcement-action {
  width: 100px;
  justify-content: center;
  margin: 0 !important;
}

.account-menu-button{
  text-transform: capitalize;
  box-shadow: none !important;
  -webkit-box-shadow: none !important;
  border: none !important;
}

.alert-badge {
  margin-left: -8px;
  margin-bottom: 4px;
}

.learn-more-btn {
  padding-left: 4px !important;
  padding-right: 4px !important;
}

</style>
