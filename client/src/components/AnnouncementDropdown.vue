<template>
  <div class="flex-align-items-center"  id="announcement-dropdown">
    <v-dialog persistent v-model="showModal" :max-width="765"
              content-class="modal-content">
      <AnnouncementModal :announcement="selectedAnnouncement"
                         :close-callback="closeModal">
      </AnnouncementModal>
    </v-dialog>
  <v-menu data-app left
          offset-y
          :max-height="`calc(100vh - 20px)`"
          :max-width="400"
          :min-width="300"
          v-model="menuOpen"
          class="account-menu"
          :close-on-content-click="false">
    <template v-slot:activator="{ on }">
      <v-btn class="account-menu-button label-medium"
             dark
             :color="constants.ENV_COLOR"
             v-on="on"
      >
        <v-icon>mdi-bell</v-icon>
        <v-badge dot class="alert-badge" v-if="hasUnreadAnnouncements"
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
      <v-list v-else-if="$store.state.app.announcements?.length > 0">
        <template  v-for="(item, index) in $store.state.app.announcements">
        <v-list-item class="pr-1"
                     :key="item.id">
          <v-list-item-icon v-if="!item.read" class="mr-2">
            <v-icon small v-if="item.expandable"
                    tool
                    color="error lighten-1">mdi-circle</v-icon>
            <v-tooltip v-else bottom class="randa-test">
              <template v-slot:activator="{on, attrs}">
                <v-icon small v-bind="attrs" v-on="on"
                        @click="markAsRead(item)"
                        color="error lighten-1">mdi-circle</v-icon>
              </template>
              <span>Mark as Read</span>
            </v-tooltip>

          </v-list-item-icon>
          <v-list-item-content class="">
              {{item.title}}
          </v-list-item-content>
          <v-list-item-action v-if="item.expandable"
                              class="announcement-action">
            <v-list-item-action-text>
              <a @click="[ markAsRead(item), openModal(item)]">Learn More</a>
            </v-list-item-action-text>
          </v-list-item-action>
          </v-list-item>
        <v-divider
            v-if="index < $store.state.app.announcements.length - 1"
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
  import {getRequest, postRequestWithRequestParams, getSnackbar, handleHidingGlobalLoader} from '@/helpers/helpers'
  const { VITE_ENV } =  import.meta.env
  import { AppMutations } from '@/stores/AppStore'
  import AnnouncementModal from "@/components/AnnouncementModal.vue";
  import {Actions} from "@/store.js";
  import {UserMutations} from "@/stores/UserStore.js";

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
        console.log('old',oldValue)
        console.log('new',newValue)
        if(newValue) {
          this.getActiveAnnouncementsAgain()
        }
      }
    },
    data () {
      return {
        constants,
        showModal: false,
        userId: this.$store.state.user.details.id,
        headerColor: constants.ENV_COLOR,
        menuOpen: false,
        selectedAnnouncement: {},
        loadComplete: false,
        loadingAgain: true
      }
    },
    computed: {
      hasUnreadAnnouncements () {
        return this.$store.state.app.announcements?.filter(a => !a.read)?.length > 0 || false
      }
    },
    created () {
    },
    methods: {
      //we reload them again here in case something changes
      async getActiveAnnouncementsAgain() {
        try {
          this.loadingAgain = true
          const {data, status} = await getRequest(`/announcements/active`)
          this.$store.commit(AppMutations.SET_ANNOUNCEMENTS, data)
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
          await this.$store.dispatch(Actions.FILE_GET_ONE, {
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
      async markAsRead(item) {
        if( !item.read) {
          try {
            item.read = true
            let params = {
              read: true,
              seen: true
            }
            await postRequestWithRequestParams(`/announcements/${item.id}/mark`, {}, params)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Marking Announcement As Read')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
        }
      },
    }
  }
</script>

<style lang="scss">

</style>
<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.announcement-action {
  width: 100px;
  justify-content: center;
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

.randa-test {
  position: absolute;
  z-index: 1000000;

}
</style>
