<template>
  <v-container class="px-0 py-2" id="postal-code-container">
    <v-breadcrumbs :items="breadcrumbs" class="pl-3 pt-1 pb-3 back-link"></v-breadcrumbs>
    <v-app-bar color="white" tabs flat class="elevation-1 call-group-bar">
      <v-toolbar-title class="pt-2">
        <div v-if="editGroup" style="margin-top:30px">
          <a-text-field  class="d-inline-block mt-4 edit-text"
                        type="text"
                        label="Name"
                        tabindex=1
                        v-model="group.callGroupName">
          </a-text-field>
          <a-btn variant="text" color="primary" @click="saveGroupInfo()" prepend-icon="save"/>
        </div>
        <div v-else style="margin-top: 30px">
          <b>Call Group Name:</b> {{group.callGroupName}}
        </div>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items style="margin-top: 30px">
        <a-btn
          variant="text" color="primary"
          v-if="userCanEdit" @click="editGroup = !editGroup" :prepend-icon="editGroup ? 'close' : 'edit'"
        />
      </v-toolbar-items>
      <v-tabs :optional="false" color="primary"
              v-slot:extension
              class="hello"
              dense
              background-color="white" v-model="model" slider-color="primary" style="margin-top: 60px">
        <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path">
          {{tab.label}}
        </v-tab>
      </v-tabs>
    </v-app-bar>
    <router-view class="mt-1 pt-0"/>
  </v-container>
</template>

<script setup>

  import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  import {getCurrentInstance, computed, onMounted, ref} from "vue";
  import { useUserStore } from '@/stores/UserStore.js'
  import {useRoute} from "vue-router/composables"
  import { useAppStore } from '@/stores/AppStore.js'
  const appStore = useAppStore()

  const vueInstance = getCurrentInstance().proxy

  const store = vueInstance.$store
  const userStore = useUserStore()
  const route = useRoute()

  const model = ref('')
  const tabs = ref([
    {
      label: 'Phone Numbers',
      path: `/settings/callGroup/${route.params.id}/numbers`,
      display: true
    },
    {
      label: 'Postal Codes',
      path: `/settings/callGroup/${route.params.id}/codes`,
      display: true
    }
  ])
  const editGroup = ref(false)
  const group = ref({})
  const dataLoading = ref(true)
  const breadcrumbs = ref([
    {
      text: 'Back to Call Groups',
      disabled: false,
      exact: true,
      to: `/settings/callGroups`
    },
  ])

  const callGroupId = computed(() => {
    return route.params.id
  })
  const userCanEdit = computed(() => {
    return userStore.userHasFeatureAccessLevel('CALL_GROUPS', 'EDIT')
  })

  onMounted(() => {
    getCallGroupDetails()
  })
      const saveGroupInfo = async () => {
        appStore.loading = true
        try {
          const {data, status} = await postRequest(`/callGroup`, group.value, 'blueraven')
          group.value = data
          editGroup.value = false
          appStore.showSnack('SUCCESS', 'Call Group saved')

          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          appStore.showSnack('ERROR', 'Error Saving Call Group')

          appStore.loading = false
        }
      }
      const getCallGroupDetails = async () => {
        appStore.loading = true
        try {
          const {data, status} = await getRequest(`/callGroup/${callGroupId.value}`, 'blueraven')
          group.value = data
          dataLoading.value = false
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          appStore.showSnack('ERROR', 'Error Retrieving Data')
          appStore.loading = false
        }
      }
</script>

<style lang="scss" scoped>
  .dtf {
    font-size: 14px;
  }
  .call-group-bar {
    min-height: 150px;
  }
  .edit-text {
    margin-left: 25px;
  }
  .back-link
  {
    margin-bottom: 15px;
  }
</style>

