<template>
  <v-main>
    <v-container>
      <v-row class="">
        <v-col cols="6">
          <div class="header">
            <h3 class="">Paste the File here</h3>
            <v-checkbox dense hide-details label="Auto copy to clipboard?" v-model="autoCopyToClipboard"></v-checkbox>
          </div>
        </v-col>
        <v-col cols="6">
          <div class="header">
            <div class="d-flex">
              <h3 class="">Updated Code</h3>
              <AlbatrossButton icon class="ml-5" color="primary" size="small"
                               v-if="compositionValue"
                               @click="copyToClipboard" prepend-icon="mdi-content-copy"></AlbatrossButton>
            </div>
          </div>
        </v-col>
      </v-row>
      <v-row class="data-container">
        <v-col cols="6">
          <v-textarea v-model="optionsValue" outlined @input="optionsValueInput()"
                      ref="inputField" auto-grow
                      label="File Value" />
        </v-col>
        <v-col cols="6" class="">
          <v-textarea outlined v-model="compositionValue" auto-grow>
          </v-textarea>
        </v-col>
      </v-row>
      <v-row class="py-3">
        <v-col cols="12">
          <AlbatrossButton
              :disabled="!optionsValue"
              @click="processBtn" text="Submit"></AlbatrossButton>
          <AlbatrossButton class="ml-4" variant="text"
                           @click="doClear" text="Clear"></AlbatrossButton>
        </v-col>
      </v-row>
    </v-container>
  </v-main>
</template>

<script setup>
import {getCurrentInstance, onMounted, ref} from 'vue'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
import {getSnackbar, handleHidingGlobalLoader} from "@/helpers/helpers.js";

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const router = vueInstance.$router
const snackbar = vueInstance.$snackbar

const optionsValue = ref(null)
const compositionValue = ref(null)
const inputField = ref(null)
const autoCopyToClipboard = ref(true)
const replacements = [
  { oldValue: 'this.$store.commit(AppMutations.SET_LOADING, true)', newValue: 'appStore.loading = true'},
  { oldValue: 'this.$store.commit(AppMutations.SET_LOADING, false)', newValue: 'appStore.loading = false'},
  { oldValue: 'this.snackbar = getSnackbar(', newValue: 'snackbar('},
  { oldValue: 'this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)', newValue: ''},
  { oldValue: 'handleHidingGlobalLoader(this,', newValue: 'handleHidingGlobalLoader('},
  { oldValue: 'import {AppMutations} from \'@/stores/AppStore\'', newValue: ''},
  { oldValue: 'import { AppMutations } from \'@/stores/AppStore\'', newValue: ''},
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

]


onMounted(() => {
})


const processBtn = async () => {
  let text = optionsValue.value

  replacements.forEach(r => {
    text = text.replaceAll(r.oldValue, r.newValue)
  })

  compositionValue.value = text
  if(autoCopyToClipboard.value) {
    copyToClipboard()
  }
}


const optionsValueInput = () => {
  compositionValue.value = null
}

const doClear = () => {
  optionsValue.value = null
  compositionValue.value = null
  inputField.value.focus()
}

const copyToClipboard = () => {
  navigator.clipboard.writeText(compositionValue.value);
  snackbar('SUCCESS', `Copied to clipboard`)
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
