<template>
  <div class="announcement-container">
    <v-dialog persistent v-model="showModal" :max-width="765"
              content-class="modal-content">
      <AnnouncementModal :announcement="selectedAnnouncement"
                         :close-callback="closeModal">
      </AnnouncementModal>
    </v-dialog>
    <v-alert v-for="(a, idx) in unseenAnnouncements"
             elevation="1"
             :max-width="465"
             :min-width="465"
        class="announcement-alert pr-0"
        color="white"
    >
      <div class="d-inline-block">
        {{ a.alertText }}
      </div>

      <div class="d-inline-block"
        :style="{'min-width': a.expandable ? '150px' : '50px'}">
        <a v-if="a.expandable" @click="[ markAnnouncement(a, true, true), openModal(a)]">Learn More</a>
        <v-btn text
               @click="[ markAnnouncement(a, false, true) ]">
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

  export default {
    name: 'AnnouncementAlert',
    components: {AnnouncementModal},
    props: {
    },
    data() {
      return {
        announcementAlert: {},
        showModal: false,
        selectedAnnouncement: {}
      }
    },
    computed: {
      unseenAnnouncements() {
        return this.$store.state.app.announcements?.filter(a => !a.seen &&
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
      openModal(item) {
        this.selectedAnnouncement = item
        this.menuOpen = false
        this.showModal = true
      },
      async markAnnouncement(item, read, seen) {
        if(!item.seen) {
          try {
            let params = {
              seen,
              read
            }
            item.seen = seen
            item.read = read
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
</style>
