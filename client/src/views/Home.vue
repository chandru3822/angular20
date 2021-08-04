<template>
  <v-container v-if="logoLoaded" class="home-page home-background"
    :style="{'background-image': null != homePageLogo.presignedUrl
                  ? `url(${homePageLogo.presignedUrl})` : ''}">
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
import {Actions} from "@/store";

export default {
  name: 'home',
  components: {},
  data () {
    return {
      snackbar: {},
      logoLoaded: false,
      homePages: [],
      homePageLogo: {},
      //todo: 333 = home page logo - do this on backend?
      homePageAttachmentTypeId: 333,
      companyId: this.$store.state.user.details.companyId,
      userIsAlbatross: this.$store.state.user.details.highestCompanyId === 1,
      user: this.$store.state.user.details,

    }
  },
  created () {
    //on context switching had to turn off the spinner
    this.loadHomePageLogo()
    this.getHomePages()
    this.$store.commit(AppMutations.SET_LOADING, false)
	},
  computed: {},
  methods: {
    async saveUserHomePage () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let tempUsr = {
          homePageCompanyFeatureId: this.user.homePageCompanyFeatureId
        }
        await putRequest(`/user/homePage`, tempUsr)
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
    async loadHomePageLogo () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await this.$store.dispatch(Actions.FILE_GET_ONE, {
          attachmentTypeId: this.homePageAttachmentTypeId,
          sourceId: this.companyId,
          callback: async (img) => {
            this.homePageLogo = img
            this.logoLoaded = true
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        })
      } catch(e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Loading Background Image')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
}
</script>

<style scoped lang="scss">
.home-page {
  height: 100%;
}

.home-card {
  height: 235px;
  width: 50%;
  min-width: 300px;
  margin: auto;
  padding-top: 15px;
  margin-top: 15px;
}

.home-background {
  background-repeat: no-repeat;
  background-size: cover;
  background-position: center;
}
</style>
