<template>
  <div class="announcement-container">
    <v-dialog v-model="showModal" :max-width="765"
              content-class="modal-content">
      <AnnouncementModal :announcement="selectedAnnouncement"
                         :close-callback="closeModal">
      </AnnouncementModal>
    </v-dialog>
    <v-alert v-for="(a, idx) in unseenAnnouncements"
             elevation="1"
             :max-width="320"
             :min-width="320"
        class="announcement-alert pr-0 py-3"
        color="white"
    >
      <div class="d-inline-block">
        {{ a.alertText }}
      </div>

      <div class="d-inline-block text-right pr-4"
        :style="{'min-width': a.expandable ? '150px' : '50px'}">
        <v-btn text color="primary" class="learn-more-btn text-transform-unset"
               v-if="a.expandable" @click="[ markAnnouncement(a, true, true, true), openModal(a)]">Learn More</v-btn>
        <v-btn text x-small class="px-1 close-x"
               @click="[ markAnnouncement(a, false, true, false) ]">
          <v-icon color="primary">clear</v-icon>
        </v-btn>
      </div>
    </v-alert>
  </div>
</template>

<script>
import moment from 'moment'
import {getSnackbar, postRequest, postRequestWithRequestParams} from "@/helpers/helpers.js";
import {AppMutations} from "@/stores/AppStore.js";
import AnnouncementModal from "@/components/AnnouncementModal.vue";
import {Actions} from "@/store.js";
import { mapStores } from 'pinia'
import { useAppStore } from '@/stores/AppStorePinia.js'

  export default {
    name: 'AnnouncementAlert',
    components: {AnnouncementModal},
    props: {
    },
    data() {
      return {
        announcementAlert: {},
        showModal: false,
        selectedAnnouncement: {},
        loadComplete: false,
      }
    },
    computed: {
      ...mapStores(useAppStore),
      unseenAnnouncements() {
        return this.appStore.announcements?.filter(a => !a.seen &&
            (moment().isBetween(moment(a.startTime), moment(a.endTime))
            || (moment().isAfter((moment(a.startTime))) && a.endTime == null))

        )
      }
    },
    created() {
    },
    methods: {
      closeModal() {
        this.showModal = false
        this.selectedAnnouncement = {}
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
      async markAnnouncement(item, read, seen, alerted) {
        if(!item.seen) {
          try {
            let params = {
              seen,
              read,
              alerted
            }
            item.seen = seen
            item.read = read
            item.alerted = alerted
            await postRequestWithRequestParams(`/announcements/${item.id}/mark`, {}, params)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Marking Announcement As Seen')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
        }
      },
    }
  }
</script>

<style lang="scss">
.announcement-alert .v-alert__content{
  display: flex;
  align-items: center;
  justify-content: space-between;
}
</style>
<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.announcement-alert {

}

.announcement-container {
  position: absolute;
  right: 50px;
  top: 40px;
  z-index: 999;
}

.rich-text-editor-readonly .ql-toolbar {
  display: none;
}

.rich-text-editor-readonly ul {
  padding-left: 0;
}

.rich-text-editor-readonly .ql-container {
  //border-top: solid 1px #ccc !important;
  border:none;
  border-radius: 0.25em;
  background-color: #fff;
  padding: 0;
}

.rich-text-editor-readonly .ql-editor {
  padding: 10px 0;
}

.rich-text-editor .ql-container {
  height: auto !important;
  width: 100%;
  color: rgba(0,0,0,0.87); //default-text-color
  font-size: 1rem; //body-large
  font-weight: 400;
  font-family: lato;
  line-height: 1.6;
}

.learn-more-btn {
  padding-left: 4px !important;
  padding-right: 4px !important;
}

.close-x {
  height: 36px !important;
}
</style>
