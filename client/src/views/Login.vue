<template>
  <v-content>
    <v-container class="fill-height">
      <v-row align="center" justify="center">
        <v-col cols="12" sm="8">
          <v-card color="secondaryMaster" class="elevation-12">
            <v-toolbar dark color="primaryCustom">
              <v-toolbar-title>Albatross</v-toolbar-title>
            </v-toolbar>
            <v-card-text class="login-card-text">
              <h2 class="error" v-if="$store.state.user.loginError">{{$store.state.user.loginError}}</h2>
              <v-form ref="login" @submit.prevent="onSubmit()">
                <v-text-field required color="primaryCustom" v-model="form.email" prepend-icon="person" name="login" label="Login" type="email"></v-text-field>
                <v-text-field required color="primaryCustom" v-model="form.password" prepend-icon="lock" name="password" label="Password" id="password" type="password"></v-text-field>
                <v-card-actions>
                  <router-link :to="'/forgotPassword'" title="Forgot Password">
                    Forgot Password
                  </router-link>
                  <v-spacer></v-spacer>
                  <v-btn :loading="loginLoading" type="submit" color="primaryButton" dark>Login</v-btn>
                </v-card-actions>
              </v-form>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </v-content>
</template>

<script>
  import { UserActions, UserMutations } from '@/stores/UserStore'
  import constants from '@/helpers/constants'
  import axios from 'axios'

  export default {
    name: 'Login',
    data () {
      return {
        form: {
          email: '',
          password: ''
        },
        loginLoading: false
      }
    },
    methods: {
      async onSubmit () {
        this.loginLoading = true
        if (this.$refs.login.validate()) {
          try {
            const params = {
              username: this.form.email,
              password: this.form.password
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
            let msg = e && e.data && e.data.includes('account is locked') ? 'Account Locked' : 'Invalid Username/Password.'
            this.$store.commit(
              UserMutations.LOGIN_ERROR,
              msg
            )
          }
        } else {
          this.loginLoading = false
        }
      },
      async loginSuccess (details) {
        await this.$store.dispatch(UserActions.LOGIN_SUCCESS, details)
        this.$router.push({name: 'home'})
      }
    }
  }
</script>

<style scoped lang="scss">
  .logo{
    max-width: 100%;
  }

  @media (min-width: 769px) {
    .login-card-text {
      padding: 65px;
    }
  }
</style>
