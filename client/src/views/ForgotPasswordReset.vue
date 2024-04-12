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
                <a-text-field color="primary"
                              v-model="newPassword"
                              required
                              type="password"
                              :rules="[passwordRule]"
                              name="newPass"
                              label="New Password"></a-text-field>
                <a-text-field color="primary"
                              v-model="newPasswordAgain"
                              type="password"
                              required
                              :rules="[passwordRule]"
                              name="newPassAgain"
                              label="Re-enter New Password"></a-text-field>
                <v-card-actions>
                  <router-link :to="'/login'" title="Login">
                    Cancel
                  </router-link>
                  <v-spacer></v-spacer>
                  <a-btn :loading="savingPassword" type="submit" text="Submit"></a-btn>
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
  import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  import {getCurrentInstance, computed, onMounted, ref} from 'vue'

  import {useRouter, useRoute} from "vue-router/composables"
  import { useAppStore } from '@/stores/AppStore.js'
  const appStore = useAppStore()

  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store
  const route = useRoute()
  const router = useRouter()
  const snackbar = vueInstance.$snackbar

  const validForm = ref(false)
  const passwordsMatch = ref(true)
  const savingPassword = ref(false)
  const requestValid = ref(false)
  const user = ref({})
  const requestValidating = ref(true)
  const newPassword = ref(null)
  const newPasswordAgain = ref(null)
  const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
  const resetNewForm = ref(null)

  const uuid = computed(() => {
    return route.params.uuid
  })

  onMounted(() => {
      validateResetRequest()
    })
    
      const passwordRule = (value) => {
        if (value && value.length < 8) {
          return 'Password must be at least 8 characters'
        } else if (!value) {
          return 'Field is Required'
        } else if (value && newPasswordAgain.value && newPassword.value !== newPasswordAgain.value) {
          return 'Both fields must match'
        }  else {
          return true
        }
      }
      const validateResetRequest = async () => {
        appStore.loading = true
        try {
          const {data, status} = await getRequest(`/user/forgotPassword/reset/${uuid.value}`)
          user.value = data
          requestValidating.value = false
          requestValid.value = user.value?.id
          handleHidingGlobalLoader( vueInstance, status)
        } catch (e) {
          requestValidating.value = false
          requestValid.value = false
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Validating This Request')
          appStore.loading = false
        }
      }
      const onSubmit = async () => {
        savingPassword.value = true
        if (resetNewForm.value.validate()) {
          appStore.loading = true
          try {
            let params = {
              newPassword: newPassword.value,
              newPasswordAgain: newPasswordAgain.value,
              userId: user.value.id
            }
            const {status} = await postRequest(`/user/forgotPassword/change/password`, params)
            handleHidingGlobalLoader(status)
            snackbar('SUCCESS', 'Your password has been changed.')
            await router.push('/login')
          } catch (e) {
            console.error('*** ERROR ***', e)
            let msg = e?.data?.message ?? 'Error Retrieving Account Details'
            snackbar('ERROR', msg)
            appStore.loading = false
          }
        } else {
          savingPassword.value = false
        }
      }

    
  
</script>
