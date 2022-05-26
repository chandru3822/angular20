<template>
  <v-main>
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
            <v-toolbar dark color="primary">
              <v-toolbar-title>Password Reset</v-toolbar-title>
            </v-toolbar>
            <v-card-text class="login-card-text">
              <v-form ref="resetNewForm" v-model="validForm" @submit.prevent="onSubmit()">
<!--                <h3 class="error&#45;&#45;text mb-3" v-if="!passwordsMatch">PASSWORDS MUST MATCH</h3>-->
                <v-text-field color="primary"
                              v-model="newPassword"
                              required
                              type="password"
                              :rules="[passwordRule]"
                              name="newPass"
                              label="New Password"></v-text-field>
                <v-text-field color="primary"
                              v-model="newPasswordAgain"
                              type="password"
                              required
                              :rules="[passwordRule]"
                              name="newPassAgain"
                              label="Re-enter New Password"></v-text-field>
                <v-card-actions>
                  <router-link :to="'/login'" title="Login">
                    Cancel
                  </router-link>
                  <v-spacer></v-spacer>
                  <v-btn color="primaryButton" :loading="savingPassword" type="submit" dark>Submit</v-btn>
                </v-card-actions>
              </v-form>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>

    </v-container>
  </v-main>
</template>

<script>
  import constants from '@/helpers/constants'
  import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  import {AppMutations} from '@/stores/AppStore'

  export default {
    name: 'ForgotPasswordReset',

    data () {
      return {
        snackbar: {},
        validForm: false,
        passwordsMatch: true,
        savingPassword: false,
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
      passwordRule (value) {
        if (value && value.length < 8) {
          return 'Password must be at least 8 characters'
        } else if (!value) {
          return 'Field is Required'
        } else if (value && this.newPasswordAgain && this.newPassword !== this.newPasswordAgain) {
          return 'Both fields must match'
        }  else {
          return true
        }
      },
      async validateResetRequest () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/user/forgotPassword/reset/${this.uuid}`)
          this.user = data
          this.requestValidating = false
          this.requestValid = this.user?.id
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          this.requestValidating = false
          this.requestValid = false
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Validating This Request')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async onSubmit () {
        this.savingPassword = true
        if (this.$refs.resetNewForm.validate()) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            let params = {
              newPassword: this.newPassword,
              newPasswordAgain: this.newPasswordAgain,
              userId: this.user.id
            }
            const {status} = await postRequest(`/user/forgotPassword/change/password`, params)
            handleHidingGlobalLoader(this, status)
            this.snackbar = getSnackbar('SUCCESS', 'Your password has been changed.')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$router.push('/login')
          } catch (e) {
            console.error('*** ERROR ***', e)
            let msg = e?.data?.message ?? 'Error Retrieving Account Details'
            this.snackbar = getSnackbar('ERROR', msg)
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } else {
          this.savingPassword = false
        }
      },

    }
  }
</script>
