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
                <a-btn :loading="loginLoading" type="submit" text="Save" />
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
  import {getCurrentInstance, ref} from 'vue'

  import { useUserStore } from '@/stores/UserStorePinia.js'

  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store
  const snackbar = vueInstance.$snackbar
  const userStore = useUserStore()

  const validForm = ref(false);
  const errorMsg = 'You must reset your password. Cannot use company default.';
  const form = ref({
    email: null,
    password: null,
    newPassword: null,
    newPasswordConfirm: null
  });
  const loginLoading = ref(false);
  const requiredRules = constants.BASIC_REQUIRED_RULE;
  const resetPassword = ref(null)


      const passwordRule = (value) => {
        if (value && value.length < 8) {
          return 'Password must be at least 8 characters'
        } else if (value && form.value.newPasswordConfirm && form.value.newPassword !== form.value.newPasswordConfirm) {
          return 'New and Confirm Password Fields Must Match'
        } else if (value && form.value.newPassword && form.value.newPassword === form.value.password) {
          return 'New Password cannot be the same as Current Password'
        } else if (!value) {
          return 'Field is Required'
        } else {
          return true
        }
      }
      const onSubmit = async() => {
        loginLoading.value = true
        if (resetPassword.value.validate()) {
          try {
            const params = {
              username: form.value.email,
              password: form.value.password,
              newPassword: form.value.newPassword
            }
            const {data} = await axios.post(`${constants.VUE_APP_BASE_API}/auth/login`, params)
            const {token, details} = data
            if (token) {
              userStore.jwt = token
              await loginSuccess(details)
            } else {
              loginLoading.value = false
              userStore.loginError = 'Invalid Username or Password.'
            }
          } catch (e) {
            loginLoading.value = false
            userStore.loginError = e
          }
        } else {
          loginLoading.value = false
        }
      }
      const loginSuccess = async(details) => {
        await userStore.login(details)
        await router.push({name: 'home'})
      }

</script>
