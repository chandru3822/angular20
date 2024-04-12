<template>
  <v-container id="roles-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">
            <span v-if="roleId">Update Role</span>
            <span v-else>New Role</span>
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                :disabled="!role.roleName"
                @click="saveRole"
                color="primary"
                prepend-icon="save"
                text="Save"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="mt-2 pa-5">
          <a-text-field v-model="role.roleName"
                        placeholder="Enter a value"
                        required
                        label="Role Name">
          </a-text-field>
          <h3>Access Control</h3>
          <v-data-table
              :headers="headers"
              :items="role.companyFeatures"
              :fixed-header="true"
              :items-per-page="-1"
              hide-default-footer
              disable-sort
              class="elevation-1 mt-1"
          >
            <template #no-data>
              <span class="default-text-color">No available fields</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No available fields</span>
            </template>

            <template #item="{ item, index }">
              <tr :class="{ 'shaded-row': index % 2 }">
                <td class="text-left">{{ item.featureName }}</td>
                <td v-for="acl in item.accessControl">
                  <input type="checkbox" v-model="acl.enabled">
                </td>
              </tr>
            </template>

          </v-data-table>
        </v-card>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>

  import {handleHidingGlobalLoader, getRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import {getCurrentInstance, onMounted, ref, computed, watch} from "vue";

  import {useRouter} from "vue-router/composables"
  import { useAppStore } from '@/stores/AppStore.js'
  const appStore = useAppStore()
  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const store = vueInstance.$store
  const router = useRouter()

  const role = ref({})
  const features = ref([])
  const accessControlList = ref([])
  const headers = ref([
    { text: 'Feature', value: 'featureName', show: true },
  ])

  const roleId = computed(() => {
    return route.params.id
  })

  onMounted(() =>{
    if(roleId.value) {
      getRole()
    } else {
      getFeatures()
    }
  })
  const saveRole = async () => {
    appStore.loading = true
    try {
      if(roleId.value) {
        const {status} = await putRequest(`/role/`, role.value)
        router.push({name: 'role', params: {id: roleId.value}})
        handleHidingGlobalLoader(status)
      } else {
        const {data, status} = await postRequest(`/role/`, role.value)
        roleId.value = data.id
        router.push({name: 'role', params: {id: roleId.value}})
        handleHidingGlobalLoader(status)
      }
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Saving Role')
      appStore.loading = false
    }

  }
  const populateHeaders = () => {
    //todo. not my favorite
    role.value.companyFeatures[0]?.accessControl?.forEach(acl => {
      headers.value.push({
        text: acl.accessLevel,
        value: acl.accessCode,
        show: true
      })
    })
  }
  const getFeatures = async () => {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/feature/withAccess`)
      role.value.companyFeatures = data
      populateHeaders()
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Features')
      appStore.loading = false
    }
  }
  const getRole = async () => {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/role/${roleId.value}`)
      role.value = data
      populateHeaders()
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Role')
      appStore.loading = false
    }
  }

</script>

<style lang="scss">
  #roles-container .v-data-table__wrapper {
    height: calc(100vh - 400px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  #roles-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }

  .roles-table {
    margin-top: 2px;
  }

</style>

