<template>
  <v-container id="roles-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Roles</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
              variant="text"
              to="/settings/role"
              color="primary"
              prepend-icon="add"
              text="ADD ROLE"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="filteredRoles"
            :fixed-header="true"
            disable-sort
            :items-per-page="-1"
            hide-default-footer
            :loading="dataLoading"
            class="elevation-1 fix-column-width-bug roles-table"
        >
          <template #no-data>
            <span class="default-text-color">No available roles</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available roles</span>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.roleName}}</td>
              <!-- icon column -->
              <td class="text-right">
                <a-btn
                  variant="text"
                  color="primary"
                  @click="clickRow(item.id)"
                  prepend-icon="edit"
                />
                <v-dialog
                    v-model="item.deleteConfirm"
                    width="500">
                  <template v-slot:activator="{ on }">
                    <a-btn
                      variant="text"
                      activation-handler="on"
                      prepend-icon="delete"
                    />
                  </template>
                  <v-card>
                    <v-card-title
                        class="text-h5 grey lighten-2"
                        primary-title
                    >
                      Confirm
                    </v-card-title>

                    <v-card-text>
                      Are you sure you want to delete this role: <strong>{{ item.roleName }}</strong>?
                    </v-card-text>

                    <v-divider></v-divider>

                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <a-btn
                          @click="item.deleteConfirm = false"
                          text="NO"
                      />
                      <a-btn
                          color="primary"
                          variant="text"
                          @click="[item.archived = true, deleteRole(item.id)]"
                          text="YES"
                      />
                    </v-card-actions>
                  </v-card>
                </v-dialog>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>

  import {handleHidingGlobalLoader, getRequest, deleteRequest, getSnackbar} from '@/helpers/helpers'

  import {getCurrentInstance, onMounted, ref, computed, watch} from "vue";

  import {useRouter} from "vue-router/composables"
  import { useAppStore } from '@/stores/AppStore.js'
  const appStore = useAppStore()
  const vueInstance = getCurrentInstance().proxy

  const store = vueInstance.$store
  const router = useRouter()

  const delay = ref(500)
  const dialog = ref(false)
  const roles = ref([])
  const descending = ref(true)
  const dataLoading = ref(true)
  const headers = ref([
    { text: 'Role Name', value: 'roleName', show: true},
    { text: null, value: 'icons', show: true }
  ])
  const filteredRoles = computed(() => {
    return roles.value.filter(r => { return !r.archived})
  })

  onMounted(() => {
    getRoles()
  })
  const clickRow = (id) => {
    router.push({name: 'role', params: {id: id}})
  }
  const getRoles = async () => {
    try {
      const {data, status} = await getRequest(`/role`)
      roles.value = data
      dataLoading.value = false
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Roles')
      appStore.loading = false
    }
  }
  const deleteRole = async (id) => {
    appStore.loading = true
    try {
      const {status} = await deleteRequest(`/role/${id}`)
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Deleting Role')
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

