<template>
  <v-main>
    <v-container class="fill-height">
      <v-row align="center" justify="center">
        <v-col cols="12" sm="8">
          <v-card color="secondaryMaster" class="elevation-12">
            <v-toolbar dark color="primary">
              <v-toolbar-title>Reset Password</v-toolbar-title>
            </v-toolbar>
            <v-card-text class="login-card-text">
              <div class="bold error-text">{{errorMsg}}</div>
              <v-form ref="resetPassword" v-model="validForm" @submit.prevent="onSubmit()">
                <v-text-field required color="primary"
                              :rules="requiredRules"
                              v-model="form.email" prepend-icon="person" name="login"
                              label="Username" type="email"></v-text-field>
                <v-text-field required color="primary"
                              :rules="requiredRules"
                              v-model="form.password" prepend-icon="lock" name="oldPassword"
                              label="Current Password" id="oldPassword" type="password"></v-text-field>
                <v-text-field required color="primary"
                              :rules="[passwordRule]"
                              v-model="form.newPassword" prepend-icon="lock" name="newPassword"
                              label="New Password" id="newPassword" type="password"></v-text-field>
                <v-text-field required color="primary"
                              :rules="[passwordRule]"
                              v-model="form.newPasswordConfirm" prepend-icon="lock" name="newPasswordConfirm"
                              label="Confirm New Password" id="newPasswordConfirm" type="password"></v-text-field>
                <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn :loading="loginLoading" type="submit"
                       color="primaryButton" class="white--text">Save
                </v-btn>
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
  import {UserActions, UserMutations} from '@/stores/UserStore'
  import constants from '@/helpers/constants'
  import axios from 'axios'

    //todo: make this screen work for various password reset scenarios
  export default {
    name: 'ResetPassword',

    data () {
      return {
        snackbar: {},
        validForm: false,
        errorMsg: 'You must reset your password. Cannot use company default.',
        form: {
          email: null,
          password: null,
          newPassword: null,
          newPasswordConfirm: null
        },
        loginLoading: false,
        requiredRules: constants.BASIC_REQUIRED_RULE,
      }
    },
    methods: {
      passwordRule (value) {
        if (value && value.length < 8) {
          return 'Password must be at least 8 characters'
        } else if (value && this.form.newPasswordConfirm && this.form.newPassword !== this.form.newPasswordConfirm) {
          return 'New and Confirm Password Fields Must Match'
        } else if (value && this.form.newPassword && this.form.newPassword === this.form.password) {
          return 'New Password cannot be the same as Current Password'
        } else if (!value) {
          return 'Field is Required'
        } else {
          return true
        }
      },
      async onSubmit() {
        this.loginLoading = true
        if (this.$refs.resetPassword.validate()) {
          try {
            const params = {
              username: this.form.email,
              password: this.form.password,
              newPassword: this.form.newPassword
            }
            const {data} = await axios.post(`${constants.VUE_APP_BASE_API}/auth/login`, params)
            const {token, details} = data
            if (token) {
              this.$store.commit(UserMutations.SET_JWT, token)
              this.loginSuccess(details)
            } else {
              this.loginLoading = false
              this.$store.commit(
                UserMutations.LOGIN_ERROR,
                'Invalid Username or Password.'
              )
            }
          } catch (e) {
            this.loginLoading = false
            this.$store.commit(
              UserMutations.LOGIN_ERROR,
              e
            )
          }
        } else {
          this.loginLoading = false
        }
      },
      async loginSuccess(details) {
        await this.$store.dispatch(UserActions.LOGIN_SUCCESS, details)
        this.$router.push({name: 'home'})
      }

    }
  }
</script>
