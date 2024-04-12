<template>
  <v-container class="mt-4">
    <v-card class="px-3">
      <SpinnerInline/>
      {{ myDynamicObject }}
      {{ myStaticObject }}
    </v-card>

  </v-container>
</template>

<script setup>
import SpinnerInline from "@/components/SpinnerInline.vue";
import {getCurrentInstance, ref, watch, computed, onMounted} from 'vue'
import { onBeforeRouteLeave } from 'vue-router/composables'
import { useUserStore } from '@/stores/UserStorePinia.js'

//FYI: Vue2 w/composition API requires some additional definitions that Vue 3 might not (vueInstance...for example)
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
const router = vueInstance.$router

const emit = defineEmits(['clearSearch'])

const props = defineProps({
  pageName: String
})

watch(watchedValue, () => {
  //do stuff
})


const myDynamicObject = ref({})
const myStaticObject = {}
const myDynamicBoolean = ref(false)
const projectId = vueInstance.$route.params?.projectId
const userCanAdd = userStore.userHasFeatureAccessLevel('PROJECTS', 'ADD')

const canAdd = computed(() => {
  return myDynamicBoolean.value
})

onBeforeRouteLeave(async (to, from, next) => {
  //do stuff
  next()
})

//todo beforeRouteEnter(to, from, next)

onMounted(() => {
 myMethod()
})

let myMethod = async () => {

  //set a dynamic value
  myDynamicObject.value = { id: 1 }
  //static values cannot be changed


  await router.push('/login')
  emit('clearSearch')
}
</script>

<style lang="scss">
#title-container :deep(.v-toolbar__content) {
  width: 100%;
}
</style>

<style scoped lang="scss">

</style>
