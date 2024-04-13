<template>
  <v-main>
    <v-container class="fill-height">
      <v-row>
        <v-col cols="12">
          <v-card color="secondaryMaster" class="elevation-12">
            <v-toolbar dark color="primary">
              <v-toolbar-title>Password Assistance</v-toolbar-title>
            </v-toolbar>
            <v-card-text class="login-card-text">
              <h3 class="mb-3">Enter the email address or username associated with your account.</h3>
              <h3 class="mb-3">A link will be sent to your email. Please click on the link in the email to change your
                password.</h3>
              <h3 class="mb-5">The link to reset your password will expire in 24 hours!</h3>
              <v-form ref="resetForm">
                <a-text-field color="primary"
                              v-model="email"
                              required
                              :rules="requiredRules"
                              name="login"
                              label="Email or Username"></a-text-field>
                <v-card-actions>
                  <router-link :to="'/login'" title="Login">
                    Cancel
                  </router-link>
                  <v-spacer></v-spacer>
                  <a-btn @click="validate" text="Submit"></a-btn>
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
import {handleHidingGlobalLoader, postRequest} from '@/helpers/helpers'
import {getCurrentInstance, onMounted, ref} from 'vue'
import {useRouter} from "vue-router/composables";

import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const router = useRouter()


const email = ref(null)
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
const resetForm = ref(null)

const validate = async () => {
  if (resetForm.value.validate()) {
    appStore.loading = true
    try {
      let params = {
        usernameOrEmail: email.value
      }
      const {status} = await postRequest(`/user/forgotPassword`, params)
      email.value = null
      handleHidingGlobalLoader(status)
      appStore.showSnack('SUCCESS', 'An email has been sent.')
      await router.push('/login')
    } catch (e) {
      console.error('*** ERROR ***', e)
      let msg = e?.data?.message ?? 'Error Retrieving Account Details'
      appStore.showSnack('ERROR', msg)
      appStore.loading = false
    }
  }
}
</script>
