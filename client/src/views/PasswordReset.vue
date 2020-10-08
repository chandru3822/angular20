<template>
  <v-content>
    <v-container class="fill-height" v-if="!requestValidating && !requestValid">
      <v-row>
        <v-col cols="12">
          <v-card color="secondaryMaster" class="elevation-12">
            <v-toolbar dark color="red">
              <v-toolbar-title>Password Reset Error</v-toolbar-title>
            </v-toolbar>
            <v-card-text class="login-card-text">
              This request has either expired or has already been used.
            </v-card-text>
            <v-card-actions>
              <router-link :to="'/login'" title="Login">
                Back to Login
              </router-link>
            </v-card-actions>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
    <v-container class="fill-height" v-if="requestValid">
      <v-row>
        <v-col cols="12">
          <v-card color="secondaryMaster" class="elevation-12">
            <v-toolbar dark color="primaryCustom">
              <v-toolbar-title>Password Reset</v-toolbar-title>
            </v-toolbar>
            <v-card-text class="login-card-text">
              <v-form ref="resetNewForm">
                <h3 class="error--text mb-3" v-if="!passwordsMatch">PASSWORDS MUST MATCH</h3>
                <v-text-field color="primaryCustom"
                              v-model="newPassword"
                              required
                              type="password"
                              :rules="requiredRules"
                              name="newPass"
                              label="New Password"></v-text-field>
                <v-text-field color="primaryCustom"
                              v-model="newPasswordAgain"
                              type="password"
                              required
                              :rules="requiredRules"
                              name="newPassAgain"
                              label="Re-enter New Password"></v-text-field>
                <v-card-actions>
                  <router-link :to="'/login'" title="Login">
                    Cancel
                  </router-link>
                  <v-spacer></v-spacer>
                  <v-btn color="primaryButton" @click="validateForm" dark>Submit</v-btn>
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
    name: 'PasswordReset',
    components: {
      Snackbar
    },
    data () {
      return {
        snackbar: {},
        passwordsMatch: true,
        requestValid: false,
        requestValidating: true,
        newPassword: null,
        newPasswordAgain: null,
        requiredRules: constants.BASIC_REQUIRED_RULE,
        uuid: this.$route.params.uuid
      }
    },
    created () {
      this.validateResetRequest()
    },
    methods: {
      async validateResetRequest () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/user/forgotPassword/reset/${this.uuid}`)
          this.user = data
          this.requestValidating = false
          this.requestValid = this.user?.id
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          this.requestValidating = false
          this.requestValid = false
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Validating This Request')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async validateForm () {
        if (this.$refs.resetNewForm.validate()) {
          if(this.newPassword === this.newPasswordAgain) {
            this.passwordsMatch = true
            this.$store.commit(AppMutations.SET_LOADING, true)
            try {
              let params = {
                newPassword: this.newPassword,
                newPasswordAgain: this.newPasswordAgain,
                userId: this.user.id
              }
              await postRequest(`/user/forgotPassword/change/password`, params)
              this.$store.commit(AppMutations.SET_LOADING, false)
              this.snackbar = getSnackbar('SUCCESS', 'Your password has been changed.')
              this.$router.push('/login')
            } catch (e) {
              console.error('*** ERROR ***', e)
              let msg = e?.data?.message ?? 'Error Retrieving Account Details'
              this.snackbar = getSnackbar('ERROR', msg)
              this.$store.commit(AppMutations.SET_LOADING, false)
            }
          } else {
            this.passwordsMatch = false
          }
        }
      },

    }
  }
</script>

<style scoped lang="scss">

</style>
