<template>
  <v-row>
    <v-col cols="12" class="py-0">
      <v-card flat class="square-card pb-3 px-3 elevation-1" color="white">
        <a-text-field
          v-model="search"
          prepend-inner-icon="mdi-magnify"
          label="Search"
          single-line
          hide-details
        ></a-text-field>
      </v-card>
      <v-divider></v-divider>
      <v-data-table
        :headers="headers"
        :items="smartlists"
        fixed-header
        multi-sort
        :search="search"
        :items-per-page="25"
        :footer-props="footerProps"
        :loading="isLoading"
        class="elevation-1"
      >
        <template #no-data>
          <span class="default-text-color">No available smartlists</span>
        </template>

        <template #no-results>
          <span class="default-text-color">No available smartlists</span>
        </template>

        <template #item="{item: smartlist}">
          <tr class="clickable" @click="router.push({name: 'smartlistEditor', params: {smartlistId: smartlist.id}})">
            <td class="td-name">{{ smartlist.name }}</td>
            <td>{{ smartlist.owner }}</td>
            <td>{{ smartlist.dateModified | formatDate('timestamp') }}</td>
            <td class="td-action">
              <smartlist-copy
                v-if="canAdd"
                :smartlist="smartlist"
                @copied="(newSmartlist) => smartlists = [newSmartlist, ...smartlists]"
              />
            </td>
            <td class="td-action">
              <smartlist-share
                v-if="canAdd"
                :smartlist="smartlist"
                @updated-public="(isPublic) => smartlist.public = isPublic"
                @updated-owner="removeFromList(smartlist)"
              />
            </td>
            <td class="td-action">
              <smartlist-export :smartlist="smartlist" />
            </td>
            <td class="td-action">
              <smartlist-delete
                v-if="canAdd"
                :smartlist-id="smartlist.id"
                @deleted="smartlists = smartlists.filter(s => s.id !== smartlist.id)"
              />
            </td>
          </tr>
        </template>
      </v-data-table>
    </v-col>
  </v-row>
</template>

<script setup>
import { ref, onMounted, getCurrentInstance, computed } from 'vue'
import { getRequest, logError } from '@/helpers/helpers'
import SmartlistExport from '@/views/flow/smartlist/SmartlistExport.vue'
import SmartlistCopy from '@/views/flow/smartlist/SmartlistCopy.vue'
import SmartlistDelete from '@/views/flow/smartlist/SmartlistDelete.vue'
import SmartlistShare from '@/views/flow/smartlist/SmartlistShare.vue'
import constants from '@/helpers/constants'
import { useUserStore } from '@/stores/UserStorePinia.js'

const footerProps = ref({
  'items-per-page-options': [25, 50, 100],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})

const headers = ref([
  {text: 'Name', value: 'name'},
  {text: 'Owner', value: 'owner'},
  {text: 'Last Modified', value: 'dateModified'},
  {text: 'Duplicate'},
  {text: 'Share'},
  {text: 'Export'},
  {text: 'Delete'}
])

const search = ref('')
const isLoading = ref(false)

const vueInstance = getCurrentInstance().proxy
const userStore = useUserStore()

const router = vueInstance.$router
const hasAddAccess = userStore.userHasFeatureAccessLevel('SMARTLIST', 'ADD')
const hasManageAccess = userStore.userHasFeatureAccessLevel('SMARTLIST', 'MANAGE')

const smartlists = ref([])

const canAdd = computed(() => {
  return hasAddAccess || hasManageAccess
})

onMounted(async () => await getSmartlists())

const getSmartlists = async () => {
  try {
    isLoading.value = true
    const {data} = await getRequest(`/smartlist/mine`)
    smartlists.value = data
  } catch (e) {
    logError(e)
  } finally {
    isLoading.value = false
  }
}

const removeFromList = (smartlist) => {
  smartlists.value = smartlists.value.filter(i => i.id !== smartlist.id)
}
</script>

<style scoped lang="scss">

</style>
