<template>
  <v-main>
    <v-container class="fill-height">
      <v-row align="center" justify="center">
        <v-col cols="12" sm="8">
          <v-card color="secondaryMaster" class="elevation-12">
            <v-toolbar dark color="primary">
              <v-toolbar-title>Albatross</v-toolbar-title>
            </v-toolbar>
            <v-card-text class="login-card-text">
              <h2 class="error--text" v-if="userStore.loginError">{{ userStore.loginError }}</h2>
              <v-form ref="login" v-model="validForm" @submit.prevent="onSubmit()">
                <v-text-field required color="primary"
                              :rules="requiredRules"
                              v-model="form.email" prepend-icon="person" name="login"
                              label="Login" type="email"></v-text-field>
                <v-text-field required color="primary"
                              :rules="requiredRules"
                              v-model="form.password" prepend-icon="lock" name="password"
                              label="Password" id="password" type="password"></v-text-field>
                <v-card-actions>
                  <router-link :to="'/forgotPassword'" title="Forgot Password">
                    Forgot Password
                  </router-link>
                  <v-spacer></v-spacer>
                  <a-btn :loading="loginLoading" type="submit" text="Login" />
                </v-card-actions>
              </v-form>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </v-main>
</template>

<script setup>
import constants from '@/helpers/constants'
import axios from 'axios'
import {getCurrentInstance, onMounted, ref} from 'vue'

import { useUserStore } from '@/stores/UserStorePinia.js'
import {useRouter} from "vue-router/composables"

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const router = useRouter()
const snackbar = vueInstance.$snackbar
const userStore = useUserStore()

const validForm = ref(false)
const form = ref({
  email: null,
  password: null
})
const loginLoading = ref(false)
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
const login = ref(null)

onMounted(() => {
  userStore.loginError = ''
})

  const onSubmit = async() => {
      loginLoading.value = true
      if (login.value.validate()) {
        try {
          const params = {
            username: form.value.email,
            password: form.value.password
          }
          const {data} = await axios.post(`${constants.VUE_APP_BASE_API}/auth/login`, params)
          const {token, details} = data
          if (token) {
            userStore.jwt = token
            loginSuccess(details)
          } else {
            loginLoading.value = false
            userStore.loginError = 'Invalid Username or Password.'
          }
        } catch (e) {
          loginLoading.value = false
          userStore.loginError = e.data

          if(e?.status === 406) {
            //this means the user tried to login with the company default password. redirect to the reset password screen
              router.push({path: `/resetPassword`})
          }

        }
      } else {
        loginLoading.value = false
      }
    }
    const loginSuccess = async(details) => {
      await userStore.login(details)

      //this code handles redirecting them back to the page they were trying to get to after they login
      let rt = { name: 'home'}
      if(vueInstance.$route.query?.redirect) {
        rt = { path: vueInstance.$route.query?.redirect}
      }
      await router.push(rt)
    }
</script>

<style scoped lang="scss">
.logo {
  max-width: 100%;
}

@media (min-width: 769px) {
  .login-card-text {
    padding: 65px;
  }
}
</style>
