<template id="account-menu">
  <v-menu data-app left
          offset-y
          :max-height="`calc(100vh - 20px)`"
          v-model="menuOpen"
          class="account-menu"
          :close-on-content-click="false">
    <template v-slot:activator="{ on }">
      <v-btn class="account-menu-button"
             :color="headerColor"
             dark
             v-on="on"
      >
        <v-avatar :tile="false"
                  :size="35"
                  color="grey lighten-4"
                  class="account-img"
                  :class="{'mx-0 mr-n5':constants.IS_MOBILE}"
        >
          <v-img name="accountImg" v-if="loadComplete && userImage && userImage.presignedUrl" :src="userImage.presignedUrl"></v-img>
          <img name="accountImg" v-else src="../assets/flow/user_img_placeholder.png">
        </v-avatar>
      </v-btn>
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
        <v-list-item v-for="(item, index) in filterBy(menuItems, true, 'show')" :key="index" @click="menuOpen = false" :to="item.path">
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

<script>
  import { Actions } from '@/store'
  import constants from '@/helpers/constants'
  import Vue2Filters from "vue2-filters"
  import { useUserStore } from '@/stores/UserStorePinia.js'
  import { mapStores } from 'pinia'

  export default {
    name: 'AccountMenu',
    mixins: [Vue2Filters.mixin],
    props: {
      showImage: Boolean
    },
    // With the move to Pinia, the `userImage` property is now computed. Which means this watcher is no
    // longer required. Keeping the code around for now in case of unknown breakage.
    // watch: {
    //   // whenever userImage changes, this function will run
    //   'userStore.userImage': function () {
    //     // reset the user image in the account menu when a new one is added or one is deleted
    //     this.userImage = this.userStore.userImage
    //   }
    // },
    data () {
      return {
        constants,
        loadComplete: false,
        attachmentTypeId: 9,
        headerColor: constants.ENV_COLOR,
        menuOpen: false,
        timezones: [
          { friendlyValue: 'US/Pacific', value: 'America/Los_Angeles'},
          { friendlyValue: 'US/Alaska', value: 'America/Anchorage'},
          { friendlyValue: 'US/Arizona', value: 'America/Phoenix'},
          { friendlyValue: 'US/Central', value: 'America/Chicago'},
          { friendlyValue: 'US/Hawaii', value: 'Pacific/Honolulu'},
          { friendlyValue: 'US/Eastern', value: 'America/New_York'},
          { friendlyValue: 'US/Mountain', value: 'America/Denver'}
        ],
      }
    },
    computed: {
      ...mapStores(useUserStore),
      userImage() {
        return  this.userStore.userImage
      },
      userId() {
        return  this.userStore.details.id
      },
      timezone() {
        return  this.userStore.details.timezone || {}
      },
      menuItems() {
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
            show: this.userStore.userHasFeature('USERS')
          }, {
            path: '/orgs',
            title: 'Organizations',
            icon: 'list',
            show: this.userStore.userHasFeature('ORGS')
          }, {
            path: '/admin',
            title: 'Admin',
            icon: 'mdi-cogs',
            show: this.userStore.isSystemAdmin
          }
        ]
      }
    },
    created () {
      this.getUserImage()
    },
    updated () {
      if(this.timezone === null || Object.keys(this.timezone).length === 0) {
        this.userStore.guessTimeZone()
      }
    },
    methods: {
      changeRoute (path) {
        this.$router.push({ name: path })
      },
      async changeTimezone (tz) {
        this.userStore.details.timezone = tz
        this.timezone = tz
        //todo: actually save it to the DB
        // i dont think we have to refresh, the filter should do that for us
        // window.location.reload()
      },
      async getUserImage () {
        if(this.userId) {
          try {
            await this.$store.dispatch(Actions.FILE_GET_ONE, {
              attachmentTypeId: this.attachmentTypeId,
              sourceId: this.userId,
              callback: async (img) => {
                this.userStore.userImage = img
                this.loadComplete = true
              }
            })
          } catch(e) {
            console.error('*** ERROR ***', e)
            this.loadComplete = true
          }
        }
      },
      logout () {
        this.menuOpen = false
        this.userStore.logout()
        this.$router.push('/login')
      }
    }
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
