<template id="account-menu">
  <v-menu data-app left
          offset-y
          v-model="menuOpen"
          class="account-menu"
          :close-on-content-click="false">
    <template v-slot:activator="{ on }">
      <v-btn class="account-menu-button"
             color="primaryCustom"
             dark
             v-on="on"
      >
        <span v-if="!IS_MOBILE">{{userFirstName}} Account</span>
        <v-avatar :tile="false"
                  :size="35"
                  color="grey lighten-4"
                  class="account-img"
        >
          <v-img name="accountImg" v-if="loadComplete && userImage && userImage.url" :src="userImage.url"></v-img>
          <img name="accountImg" v-else src="../assets/user_img_placeholder.png">
        </v-avatar>
      </v-btn>
    </template>
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
  </v-menu>
</template>

<script>
  import { Actions } from '@/store'
  import { UserMutations } from '@/stores/UserStore'
  import { IS_MOBILE } from '@/helpers/helpers'
  import { UserActions } from '@/stores/UserStore'
  import moment from 'moment-timezone'
  import Vue2Filters from "vue2-filters"

  export default {
    name: 'AccountMenu',
    mixins: [Vue2Filters.mixin],
    props: {
      showImage: Boolean
    },
    watch: {
      // whenever userImage changes, this function will run
      '$store.state.user.userImage': function () {
        // reset the user image in the account menu when a new one is added or one is deleted
        this.userImage = this.$store.state.user.userImage
      }
    },
    data () {
      return {
        IS_MOBILE,
        loadComplete: false,
        userImage: this.$store.state.user.userImage,
        attachmentTypeId: 9,
        userId: this.$store.state.user.details.id,
        userFirstName: this.getFirstName(),
        menuOpen: false,
        timezone: null,
        highestCompanyId: this.$store.state.user.details.highestCompanyId,
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
            show: true
          }, {
            path: '/orgs',
            title: 'Organizations',
            icon: 'list',
            show: true
          }, {
            path: '/admin',
            title: 'Admin',
            icon: 'mdi-cogs',
            show: this.$store.getters.isSystemAdmin(this.highestCompanyId)
          },

        ]
      }
    },
    created () {
      this.getUserImage()
      if(this.$store.state.user.details.timezone === null) {
        console.log('ttt', moment.tz.guess())
        this.timezone = {
          friendlyValue: moment.tz.guess(),
          value: moment.tz.guess()
        }
        this.$store.dispatch(UserActions.CHANGE_TIMEZONE, this.timezone)
      } else {
        this.timezone = this.$store.state.user.details.timezone
      }
    },
    methods: {
      changeRoute (path) {
        this.$router.push({ name: path })
      },
      async changeTimezone (tz) {
        console.log('will change timezone', tz)
        await this.$store.dispatch(UserActions.CHANGE_TIMEZONE, tz)
        this.timezone = tz
        //todo: actually save it to the DB
        // i dont think we have to refresh, the filter should do that for us
        // window.location.reload()
      },
      async getUserImage () {
        try {
          await this.$store.dispatch(Actions.FILE_GET_ONE, {
            attachmentTypeId: this.attachmentTypeId,
            sourceId: this.userId,
            callback: async (img) => {
              this.$store.commit(UserMutations.SET_USER_IMAGE, img)
              this.loadComplete = true
            }
          })
        } catch(e) {
          console.error('*** ERROR ***', e)
          this.loadComplete = true
        }
      },
      getFirstName () {
        if (this.$store.state.user.details) {
          const firstName = this.$store.state.user.details.firstName
          return firstName.substring(firstName.length - 1).toLowerCase() === 's' ? firstName + '\'' : firstName + '\'s'
        } else {
          return 'Unknown'
        }
      },
      logout () {
        this.menuOpen = false
        this.$store.dispatch(UserActions.LOGOUT)
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
  }
  .account-menu-icon{
    justify-content: center;
    align-content: center;
  }
</style>
