<template>
  <v-container id="all-smartlists">
    <v-row>
      <v-col cols="12">
        <v-card flat class="square-card pb-3 px-3" color="white">
          <v-text-field
            v-model="search"
            prepend-inner-icon="mdi-magnify"
            label="Search"
            single-line
            hide-details
          ></v-text-field>
        </v-card>
        <v-divider></v-divider>
        <v-data-table
          class="elevation-1"
          :headers="headers"
          :items="smartlists"
          fixed-header
          multi-sort
          :search="search"
          :items-per-page="25"
          :footer-props="footerProps"
          :loading="isLoading"
        >
          <template #no-data>
            <span class="default-text-color">No available smartlists</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available smartlists</span>
          </template>

          <template #item="{item: smartlist}">
            <tr class="clickable" @click="$router.push({name: 'smartlistEditor', params: {smartlistId: smartlist.id}})">
              <td class="text-left">{{ smartlist.name }}</td>
              <td class="text-left">{{ smartlist.owner }}</td>
              <td>
                <smartlist-copy
                  :smartlist="smartlist"
                  @copied="(newSmartlist) => smartlists = [newSmartlist, ...smartlists]"
                />
              </td>
              <td>
                <smartlist-share :smartlist="smartlist" />
              </td>
              <td>
                <smartlist-export :smartlist="smartlist" />
              </td>
              <td>
                <smartlist-delete
                  :smartlist-id="smartlist.id"
                  @deleted="smartlists = smartlists.filter(s => s.id !== smartlist.id)"
                />
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import { ref, onMounted, getCurrentInstance } from 'vue'
import { getRequest, logError } from '@/helpers/helpers'
import SmartlistExport from '@/views/flow/smartlist/SmartlistExport.vue'
import SmartlistCopy from '@/views/flow/smartlist/SmartlistCopy.vue'
import SmartlistDelete from '@/views/flow/smartlist/SmartlistDelete.vue'
import SmartlistShare from '@/views/flow/smartlist/SmartlistShare.vue'

const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500]
})

const headers = ref([
  {text: 'Name', value: 'name'},
  {text: 'Owner', value: 'owner'},
  {text: 'Duplicate'},
  {text: 'Share'},
  {text: 'Export'},
  {text: 'Delete'}
])

const search = ref('')
const isLoading = ref(false)

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

let smartlists = ref([])

onMounted(async () => await getSmartlists())

let getSmartlists = async () => {
  try {
    isLoading.value = true
    const {data} = await getRequest(`/smartlist/all`)
    smartlists.value = data
  } catch (e) {
    logError(e)
  } finally {
    isLoading.value = false
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/main.scss";

::v-deep {
  .v-data-table__wrapper {
    height: calc(100vh - 350px);
    min-height: 300px;
  }
}

tr:nth-of-type(even) {
  @extend .shaded-row;
}
</style>