<template>
  <v-main>
    <v-container>
      <v-row class="">
        <v-col cols="6">
          <div class="header">
            <h3 class="">Paste the File here</h3>
            <v-checkbox dense hide-details label="Auto copy to clipboard?" v-model="autoCopyToClipboard"></v-checkbox>
            <v-checkbox dense hide-details label="Reset and Refocus on Paste?" v-model="resetFieldsOnPaste"></v-checkbox>
          </div>
        </v-col>
        <v-col cols="6">
          <div class="header">
            <div class="d-flex">
              <h3 class="">Updated Code</h3>
              <a-btn icon class="ml-5" color="primary" size="small"
                               v-if="compositionValue"
                               @click="copyToClipboard" prepend-icon="mdi-content-copy"></a-btn>
            </div>
          </div>
        </v-col>
      </v-row>
      <v-row class="data-container">
        <v-col cols="6">
          <a-textarea v-model="optionsValue" variant="outlined" @input="optionsValueInput()"
                      ref="inputField" auto-grow
                      label="File Value" />
        </v-col>
        <v-col cols="6" class="">
          <a-textarea variant="outlined" v-model="compositionValue" auto-grow>
          </a-textarea>
        </v-col>
      </v-row>
      <v-row class="py-3">
        <v-col cols="6">
          <a-btn
              :disabled="!optionsValue"
              @click="processBtn" text="Submit"></a-btn>
          <a-btn class="ml-4" variant="text"
                           @click="doClear" text="Clear"></a-btn>
        </v-col>
        <v-col cols="6">
          <div v-if="hasError" class="error--text" style="font-size: 20px;">
            Error: {{ errorMsg }}
          </div>
        </v-col>
      </v-row>
    </v-container>
  </v-main>
</template>

<script setup>
import {getCurrentInstance, onMounted, ref} from 'vue'

import {getSnackbar, handleHidingGlobalLoader} from "@/helpers/helpers.js";

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const router = vueInstance.$router

const optionsValue = ref(null)
const compositionValue = ref(null)
const inputField = ref(null)
const autoCopyToClipboard = ref(true)
const resetFieldsOnPaste = ref(true)
const hasError = ref(false)
const errorMsg = ref('')
const errorTexts = [
    'this.$ref', 'this.$filter', 'filterBy', 'this.$emit', 'this.$vuetify', 'this.$root', 'this.$', 'this.constants'
]
const replacements = [
  { oldValue: 'this.$store.commit(AppMutations.SET_LOADING, true)', newValue: 'appStore.loading = true'},
  { oldValue: 'this.$store.commit(AppMutations.SET_LOADING, false)', newValue: 'appStore.loading = false'},
  { oldValue: 'this.snackbar = getSnackbar(', newValue: 'snackbar('},
  { oldValue: 'this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)', newValue: ''},
  { oldValue: 'handleHidingGlobalLoader(this,', newValue: 'handleHidingGlobalLoader('},
  { oldValue: 'import {AppMutations} from \'@/stores/AppStore\';', newValue: ''},
  { oldValue: 'import {AppMutations} from \"@/stores/AppStore\";', newValue: ''},
  { oldValue: 'import {AppMutations} from \'@/stores/AppStore\'', newValue: ''},
  { oldValue: 'import {AppMutations} from \"@/stores/AppStore\"', newValue: ''},
  { oldValue: 'import { AppMutations } from \'@/stores/AppStore\'', newValue: ''},
  { oldValue: 'import { AppMutations } from \"@/stores/AppStore\"', newValue: ''},
  { oldValue: 'this.userStore', newValue: 'userStore'},
  { oldValue: 'this.$store.state.brs', newValue: 'brsStore'},
  { oldValue: 'this.$route', newValue: 'route'},
  { oldValue: 'this.$router', newValue: 'router'},
  { oldValue: '$router', newValue: 'router'},
  { oldValue: 'import Vue2Filters from "vue2-filters"', newValue: ''},
  { oldValue: '<script>', newValue: '<script setup>'},
  { oldValue: 'getSnackbar,', newValue: ''},
  { oldValue: 'getSnackbar', newValue: ''},
  { oldValue: 'import {} from \'@/helpers/helpers\'', newValue: ''},
  { oldValue: 'import { } from \'@/helpers/helpers\'', newValue: ''},
  { oldValue: 'this.timezone', newValue: 'timezone'},
  { oldValue: 'this.fileStore', newValue: 'fileStore'},
  { oldValue: 'this.projectStore', newValue: 'projectStore'},
  { oldValue: 'this.notificationStore', newValue: 'notificationStore'},
  { oldValue: 'this.appStore.showSnack(this.snackbar)', newValue: ''},
  { oldValue: 'this.appStore', newValue: 'appStore'},
]


onMounted(() => {
})


const processBtn = async () => {
  hasError.value = false
  errorMsg.value = ''

  let text = optionsValue.value

  replacements.forEach(r => {
    text = text.replaceAll(r.oldValue, r.newValue)
  })

  //remove `this.` from anything that is `this. + any alphanumerics + (`
  // ...like this.validateForm() will turn into validateForm()
  let matches = text.match(/this\.[^\s()\W]+\(/g)
  matches?.forEach(s => {
    text = text.replaceAll(s, s.substring(5, s.length))
  })

  let errorString = ''
  errorTexts.forEach(e => {
    if(text.includes(e)) {
      errorString = errorString + ` ${e}`
      hasError.value = true
    }
  })

  errorMsg.value = hasError.value ? `You have issues to handle with: ${errorString}` : ''

  compositionValue.value = text
  if(autoCopyToClipboard.value) {
    copyToClipboard()
  }
}


const optionsValueInput = () => {
  compositionValue.value = null
  if(resetFieldsOnPaste.value) {
    processBtn()
  }
}

const doClear = () => {
  optionsValue.value = null
  compositionValue.value = null
  inputField.value.focus()
}

const copyToClipboard = () => {
  navigator.clipboard.writeText(compositionValue.value);
  appStore.showSnack('SUCCESS', `Copied to clipboard`)
}

</script>

<style scoped lang="scss">
.header {
  height: 75px;
  //background: blue;
}

.data-container {
  max-height: calc(100vh - 345px);
  overflow: auto;
}
</style>
