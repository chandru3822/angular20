<template id="account-menu">
  <v-menu data-app left offset-y class="account-menu">
    <v-btn
        class="account-menu-button"
        slot="activator"
        color="primaryCustom"
        dark
    >
      <span v-if="!IS_MOBILE">{{userFirstName}} Account</span>
      <v-avatar
          :tile="false"
          :size="40"
          color="grey lighten-4"
          class="account-img"
      >
        <!-- <v-img name="accountImg" v-if="loadComplete && imageUrl" :src="imageUrl"></v-img>
        <img name="accountImg" v-else src="../assets/user_img_placeholder.png"> -->
      </v-avatar>
    </v-btn>
    <v-list>
      <!-- <v-list-tile @click="changeRoute('preferences', {})">
        <v-list-tile-title>Preferences</v-list-tile-title>
        <v-list-tile-action class="account-menu-icon">
          <v-icon>settings</v-icon>
        </v-list-tile-action>
      </v-list-tile> -->
      <v-list-tile @click="logout()">
        <v-list-tile-title>Logout</v-list-tile-title>
        <v-list-tile-action class="account-menu-icon">
          <v-icon>exit_to_app</v-icon>
        </v-list-tile-action>
      </v-list-tile>
    </v-list>
  </v-menu>
</template>

<script>
import { IS_MOBILE } from '@/helpers/helpers'
import { UserActions } from '@/stores/UserStore'
import axios from 'axios'
const { VUE_APP_BASE_API } = process.env

export default {
  name: 'AccountMenu',
  props: {
    showImage: Boolean
  },
  data () {
    return {
      IS_MOBILE,
      loadComplete: false,
      // imageUrl: 'https://i.pinimg.com/236x/55/98/e8/5598e8785b2785de9f602fe095a92d61.jpg',
      imageUrl: null,
      userFirstName: this.getFirstName()
    }
  },
  created () {
    this.getUserImage()
  },
  methods: {
    changeRoute (path) {
      this.$router.push({ name: path })
    },
    async getUserImage () {
      await axios.get(`${VUE_APP_BASE_API}/getPresignedUrl`, {
        params: {
          sourceId: this.$store.state.user.details.id,
          attachmentSourceTypeId: 9
        }
      })
        .then(({ data }) => {
          const { assetUrl } = data
          this.imageUrl = assetUrl
          this.loadComplete = true
        })
        .catch(() => {
          this.loadComplete = true
        })
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
@media (min-width: 769px) {
  .account-menu{
    border-left: solid 1px #ffffff;
  }
}
</style>
