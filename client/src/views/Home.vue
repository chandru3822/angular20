<template>
  <v-container class="home-page home-background">
    <v-card color="white" class="home-card">
      <v-card-title>Welcome to Albatross!</v-card-title>
      <v-card-text>
        <v-autocomplete v-if="!userIsAlbatross"
                        v-model="user.homePageCompanyFeatureId"
                        :items="homePages"
                        label="Set a Default Home Page"
                        clearable
                        item-text="featureName"
                        item-value="id"
                        autocomplete="off"
                        persistent-hint
                        hint="* This will be used the next time you log in and can be changed at any time under Settings - User Profile"
                        type="search"
        ></v-autocomplete>
        <v-btn @click="saveUserHomePage"
               v-if="!userIsAlbatross"
               color="primaryCustom" class="mt-4 white--text">
          Save
        </v-btn>
      </v-card-text>
    </v-card>
  </v-container>
</template>

<script>

import {AppMutations} from "@/stores/AppStore";
import {getRequest, getSnackbar, putRequest} from "@/helpers/helpers";

export default {
  name: 'home',
  components: {},
  data () {
    return {
      snackbar: {},
      homePages: [],
      userIsAlbatross: this.$store.state.user.details.highestCompanyId === 1,
      user: this.$store.state.user.details,

    }
  },
  created () {
    //on context switching had to turn off the spinner
    this.getHomePages()
    this.$store.commit(AppMutations.SET_LOADING, false)
	},
  computed: {},
  methods: {
    async saveUserHomePage () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await putRequest(`/user/homePage/${this.user.homePageCompanyFeatureId}`)
        this.snackbar = getSnackbar('SUCCESS', 'Default Home Page Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Default Home Page')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getHomePages () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/feature/homePages`)
        this.homePages = data.filter(d => {
          return this.$store.getters.userHasFeature(d.featureCode)
        })
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Home Pages')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  }
}
</script>

<style lang="scss">
</style>

<style scoped lang="scss">
.home-page {
  height: 100%;
  padding-top: 0;
}

.home-card {
  height: 225px;
  width: 50%;
  margin: 50px auto;
  padding-top: 15px;
}

.home-background {
  background-image: url(../assets/home.jpg);
  background-repeat: no-repeat;
  background-size: cover;
  background-position: center;
}
</style>
