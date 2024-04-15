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
        <a-btn
            class="account-menu-button label-medium"
            :class="{'announcement-adjust-for-badge': hasUnalertedAnnouncements}"
            :color="constants.ENV_COLOR"
            :activation-handler="on">
          <template #default>
            <v-icon>mdi-bell</v-icon>
            <v-badge dot class="alert-badge" v-if="hasUnalertedAnnouncements" color="error lighten-1" ></v-badge>
          </template>
        </a-btn>
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
                  <a-btn
                      variant="text"
                      color="primary"
                      class="learn-more-btn text-transform-unset"
                      @click="[ item.read = true, openModal(item)]"
                      text="Learn More"
                  ></a-btn>
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

<script setup>
import constants from '@/helpers/constants'

import SpinnerInline from '@/components/SpinnerInline'
import {getRequestWithParams, } from '@/helpers/helpers'

import AnnouncementModal from "@/components/AnnouncementModal.vue";
import { useFileStore } from '@/stores/FileStore.js'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const showModal = ref(false)
const headerColor = ref(constants.ENV_COLOR)
const menuOpen = ref(false)
const selectedAnnouncement = ref({})
const loadComplete = ref(false)
const loadingAgain = ref(true)

watch(menuOpen, (newValue, oldValue) => {
  if(newValue) {
    getActiveAnnouncementsAgain()
  }
})

const userId = computed(() => {
  return userStore.details.id
})
const menuWidth = computed(() => {
  return constants.IS_MOBILE ? 320 : 400
})
const hasUnalertedAnnouncements = computed(() => {
  return appStore.announcements?.filter(a => !a.alerted)?.length > 0 || false
})

//we reload them again here in case something changes
const getActiveAnnouncementsAgain = async() => {
  try {
    loadingAgain.value = true
    let params = {
      doUpdate: true //we do this every time in case something changed behind the scenes
    }
    const {data, status} = await getRequestWithParams(`/announcements/active`, {params})
    appStore.announcements = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')

  } finally {
    loadingAgain.value = false
  }
}
const openModal = async(item) => {
  menuOpen.value = false
  showModal.value = true
  loadComplete.value = false
  await getAttachment(item)
  selectedAnnouncement.value = item
}
const getAttachment = async(item) => {
  try {
    await fileStore.getOne({
      attachmentTypeId: 990,
      sourceId: item.id,
      callback: async (img) => {
        item.presignedUrl = img.presignedUrl
        item.attachmentId = img.id
        loadComplete.value = true
      }
    })
  } catch(e) {
    console.error('*** ERROR ***', e)
    loadComplete.value = true
  }
}
const closeModal = () => {
  showModal.value = false
  selectedAnnouncement.value = {}
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
