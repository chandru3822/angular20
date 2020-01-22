<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-breadcrumbs :items="breadcrumbs"></v-breadcrumbs>
        <v-toolbar flat class="app-toolbar">
          {{user.firstName}} {{user.lastName}}
          <v-spacer></v-spacer>
          <v-toolbar-items :slot="IS_MOBILE ? 'extension' : 'default'">
            <v-tabs>
              <v-tab :to="`/user/${userId}/details`">
                Details
              </v-tab>
              <v-tab :to="`/user/${userId}/positions`">
                Positions
              </v-tab>
              <v-tab :to="`/user/${userId}/access`">
                Access
              </v-tab>
            </v-tabs>
          </v-toolbar-items>
        </v-toolbar>
        <router-view/>
      </v-col>
      <Snackbar :snackbar="snackbar"></Snackbar>
    </v-row>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
  import NotesAndActivity from '@/views/flow/components/NotesAndActivity.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getRequestWithParams, getSnackbar, IS_MOBILE} from '@/helpers/helpers'

  export default {
    name: 'User',
    components: {
      Snackbar,
      CustomValueInput,
      NotesAndActivity
    },
    data () {
      return {
        breadcrumbs: [
          {
            text: 'Back',
            disabled: false,
            exact: true,
            to: `/users`
          },
        ],
        IS_MOBILE,
        snackbar: {},
        user: {},
        userId: this.$route.params.id,
        companyId: this.$store.state.user.details.companyId,
      }
    },
    created () {
      this.getUser()
    },
    methods: {
      async getUser () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/user/${this.userId}`)
          this.user = data

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving User')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>

<style lang="scss" scoped>

</style>

