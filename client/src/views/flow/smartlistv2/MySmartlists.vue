<template>
  <v-container id="my-smartlists">
    <v-row>
      <v-col cols="12">
        <v-card flat class="square-card pb-3 px-3" color="white">
          <v-text-field
            v-model="search"
            append-icon="mdi-magnify"
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
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getRequest, logError } from '@/helpers/helpers'

const search = ref('')
const isLoading = ref(false)

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

let smartlists = ref([])

onMounted(async () => await getSmartlists())

let getSmartlists = async () => {
  try {
    isLoading.value = true
    const {data} = await getRequest(`/smartlist`)
    smartlists.value = data
  } catch (e) {
    logError(e)
  } finally {
    isLoading.value = false
  }
}
</script>

<style scoped lang="scss">

</style>