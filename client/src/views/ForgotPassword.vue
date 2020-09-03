<template>
  <v-content>
    <v-container class="fill-height">
      <v-row>
        <v-col cols="12">
          <v-card color="secondaryMaster" class="elevation-12">
            <v-toolbar dark color="primary">
              <v-toolbar-title>Password Assistance</v-toolbar-title>
            </v-toolbar>
            <v-card-text class="login-card-text">
              <h3 class="mb-3">Enter the email address or username associated with your account.</h3>
              <h3 class="mb-3">A link will be sent to your email. Please click on the link in the email to change your password.</h3>
              <h3 class="mb-5">The link to reset your password will expire in 24 hours!</h3>
              <v-form ref="resetForm">
                <v-text-field color="primary"
                              v-model="email"
                              required
                              :rules="requiredRules"
                              name="login"
                              label="Email or Username"></v-text-field>
                <v-card-actions>
                  <router-link :to="'/login'" title="Login">
                    Cancel
                  </router-link>
                  <v-spacer></v-spacer>
                  <v-btn color="primaryButton" @click="validate" dark>Submit</v-btn>
                </v-card-actions>
              </v-form>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
    </v-container>
  </v-content>
</template>

<script>
  import constants from '@/helpers/constants'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import Snackbar from '@/components/Snackbar.vue'
  import {AppMutations} from '@/stores/AppStore'

  export default {
    name: 'ForgotPassword',
    components: {
      Snackbar
    },
    data () {
      return {
        snackbar: {},
        email: null,
        requiredRules: constants.BASIC_REQUIRED_RULE,
      }
    },
    methods: {
      async validate () {
        if (this.$refs.resetForm.validate()) {
            this.$store.commit(AppMutations.SET_LOADING, true)
            try {
              let params = {
                usernameOrEmail: this.email
              }
              await postRequest(`/user/forgotPassword`, params)
              this.email = null
              this.$store.commit(AppMutations.SET_LOADING, false)
              this.snackbar = getSnackbar('SUCCESS', 'An email has been sent.')
              this.$router.push('/login')
            } catch (e) {
              console.error('*** ERROR ***', e)
              let msg = e?.data?.message ?? 'Error Retrieving Account Details'
              this.snackbar = getSnackbar('ERROR', msg)
              this.$store.commit(AppMutations.SET_LOADING, false)
            }
        }
      },

    }
  }
</script>

<style scoped lang="scss">

</style>
