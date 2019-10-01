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
                  :size="40"
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
            <v-list-item-subtitle>{{timezone}}</v-list-item-subtitle>
          </v-list-item-content>
        </template>

        <v-list-item v-for="tz in timezones"
                     :key="tz"
                     @click="changeTimezone(tz)">
          <v-list-item-content>
            <v-list-item-title v-text="tz"></v-list-item-title>
          </v-list-item-content>
        </v-list-item>
      </v-list-group>
    </v-list>
    <v-divider></v-divider>
    <v-list>
      <v-list-item :to="'/settings/userProfile'">
        <v-list-item-title>Settings</v-list-item-title>
        <v-list-item-action class="account-menu-icon">
          <v-icon>settings</v-icon>
        </v-list-item-action>
      </v-list-item>
    </v-list>
    <v-divider></v-divider>
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

  export default {
    name: 'AccountMenu',
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
        timezones: [
          'US/Pacific',
          'US/Alaska',
          'US/Arizona',
          'US/Central',
          'US/Hawaii',
          'US/Eastern',
          'US/Mountain'
        ]
      }
    },
    created () {
      this.getUserImage()
      if(this.$store.state.user.details.timezone === null) {
        console.log('ttt', moment.tz.guess())
        this.timezone = moment.tz.guess()
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
