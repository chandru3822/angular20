<template id="account-menu">
  <v-menu data-app left
          offset-y
          :max-height="`calc(100vh - 20px)`"
          v-model="menuOpen"
          class="account-menu"
          :close-on-content-click="false">
    <template v-slot:activator="{ on }">
      <a-btn
          class="account-menu-button"
          :color="headerColor"
          :activation-handler="on">
        <template #default>
          <v-avatar :tile="false" :size="35" color="grey lighten-4"
                    class="account-img" :class="{'mx-0 mr-n5':constants.IS_MOBILE}">
            <v-img name="accountImg" v-if="loadComplete && userImage && userImage.presignedUrl"
                   :src="userImage.presignedUrl"></v-img>
            <img name="accountImg" v-else src="../assets/flow/user_img_placeholder.png">
          </v-avatar>
        </template>
      </a-btn>
    </template>
    <div>
      <v-list two-line>
        <v-list-group no-action>
          <template v-slot:activator>
            <v-list-item-content>
              <v-list-item-title>Current Timezone</v-list-item-title>
              <v-list-item-subtitle>{{timezone.friendlyValue}}</v-list-item-subtitle>
            </v-list-item-content>
          </template>

          <v-list-item v-for="(tz, index) in timezones"
                       :key="index"
                       @click="changeTimezone(tz)">
            <v-list-item-content>
              <v-list-item-title v-text="tz.friendlyValue"></v-list-item-title>
            </v-list-item-content>
          </v-list-item>
        </v-list-group>
      </v-list>
      <v-divider class="hr-non-transparent"></v-divider>
      <v-list>
        <v-list-item v-for="(item, index) in filteredMenuItems" :key="index" @click="menuOpen = false" :to="item.path">
          <v-list-item-title>{{item.title}}</v-list-item-title>
          <v-list-item-action class="account-menu-icon">
            <v-icon>{{item.icon}}</v-icon>
          </v-list-item-action>
        </v-list-item>
      </v-list>
      <v-divider class="hr-non-transparent"></v-divider>
      <v-list>
        <v-list-item @click="logout()">
          <v-list-item-title>Logout</v-list-item-title>
          <v-list-item-action class="account-menu-icon">
            <v-icon>exit_to_app</v-icon>
          </v-list-item-action>
        </v-list-item>
      </v-list>
    </div>
  </v-menu>
</template>

<script setup>
import constants from '@/helpers/constants'
import { useFileStore } from '@/stores/FileStore.js'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";

const route = useRoute()
const router = useRouter()
const fileStore = useFileStore()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const props = defineProps({
  showImage: Boolean
})
const { showImage } = toRefs(props)

// With the move to Pinia, the `userImage` property is now computed. Which means this watcher is no
// longer required. Keeping the code around for now in case of unknown breakage.
// watch: {
//   // whenever userImage changes, this function will run
//   'userStore.userImage': function () {
//     // reset the user image in the account menu when a new one is added or one is deleted
//     this.userImage = userStore.userImage
//   }
// },

const loadComplete = ref(false)
const attachmentTypeId = ref(9)
const headerColor = ref(constants.ENV_COLOR)
const menuOpen = ref(false)
const timezones = ref([
  { friendlyValue: 'US/Pacific', value: 'America/Los_Angeles'},
  { friendlyValue: 'US/Alaska', value: 'America/Anchorage'},
  { friendlyValue: 'US/Arizona', value: 'America/Phoenix'},
  { friendlyValue: 'US/Central', value: 'America/Chicago'},
  { friendlyValue: 'US/Hawaii', value: 'Pacific/Honolulu'},
  { friendlyValue: 'US/Eastern', value: 'America/New_York'},
  { friendlyValue: 'US/Mountain', value: 'America/Denver'}
])

const userImage = computed(() => {
  return  userStore.userImage
})
const userId = computed(() => {
  return  userStore.details.id
})
const timezone = computed(() => {
  return  userStore.timezone
})
const menuItems = computed(() => {
  return [
    {
      path: '/settings/userProfile',
      title: 'Settings',
      icon: 'settings',
      show: true
    }, {
      path: '/users',
      title: 'Users',
      icon: 'people',
      show: userStore.userHasFeature('USERS')
    }, {
      path: '/orgs',
      title: 'Organizations',
      icon: 'list',
      show: userStore.userHasFeature('ORGS')
    }, {
      path: '/admin',
      title: 'Admin',
      icon: 'mdi-cogs',
      show: userStore.isSystemAdmin
    }
  ]
})
const filteredMenuItems = computed(() => {
  return  menuItems.value.filter(m => m.show)
})
onMounted(() => {
  getUserImage()
})

const changeRoute = (path) => {
  router.push({ name: path })
}
const changeTimezone = async (tz) => {
  userStore.details.timezone = tz
  //todo: actually save it to the DB
  // i dont think we have to refresh, the filter should do that for us
  // window.location.reload()
}
const getUserImage = async () => {
  if(userId.value) {
    try {
      await fileStore.getOne({
        attachmentTypeId: attachmentTypeId.value,
        sourceId: userId.value,
        callback: async (img) => {
          userStore.userImage = img
          loadComplete.value = true
        }
      })
    } catch(e) {
      console.error('*** ERROR ***', e)
      loadComplete.value = true
    }
  }
}
const logout = () => {
  menuOpen.value = false
  userStore.logout()
  router.push('/login')
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}

.account-img{
  margin-left: 10px;
}
.account-menu-button{
  text-transform: capitalize;
  box-shadow: none !important;
  -webkit-box-shadow: none !important;
  border: none !important;
  padding-left: 0 !important;
  padding-right: 10px !important;
}
.account-menu-icon{
  justify-content: center;
  align-content: center;
}
</style>
