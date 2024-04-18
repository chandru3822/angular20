<template>
  <v-container id="smartlists-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Smartlists</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                to="/smartlistv1/null"
                color="primary"
                id="qa-add-smartlist"
                prepend-icon="add"
                text="Add Smartlist"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
      </v-col>

      <v-col cols="12">
        <v-card flat class="square-card pb-3 px-3" color="white">
          <a-text-field
              v-model="search"
              append-inner-icon="mdi-magnify"
              label="Search"
              single-line
              hide-details
          ></a-text-field>
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
            :loading="isSmartlistsLoading"
        >
          <template #no-data>
            <span class="default-text-color">No available smartlists</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available smartlists</span>
          </template>

          <template #item="{item: smartlist}">
            <tr class="clickable" @click="router.push({name: 'smartlistEditor', params: {smartlistId: smartlist.id}})">
              <td class="text-left">
                <router-link class="router-link-td" :to="{name: 'smartlistEditor', params: {smartlistId: smartlist.id}}">
                  {{smartlist.name}}
                </router-link>
              </td>
              <td class="text-left">
                <router-link class="router-link-td" :to="{name: 'smartlistEditor', params: {smartlistId: smartlist.id}}">
                  {{smartlist.viewObjectType}}
                </router-link>
              </td>
              <td class="text-left">
                <router-link class="router-link-td" :to="{name: 'smartlistEditor', params: {smartlistId: smartlist.id}}">
                  {{smartlist.owner}}
                </router-link>
              </td>
              <td class="text-left">
                <router-link class="router-link-td" :to="{name: 'smartlistEditor', params: {smartlistId: smartlist.id}}">
                  {{smartlist.shared ? 'Yes' : 'No'}}
                </router-link>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>

import {getRequest, logError} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'

import {useRouter} from "vue-router/composables";

const router = useRouter()


const isSmartlistsLoading = ref(false)
const snackbar = ref({})
const search = ref('')
const smartlists = ref([])
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500]})
const headers = ref([
  {text: 'Name', value: 'name'},
  {text: 'Table Display View', value: 'objectType'},
  {text: 'Owner', value: 'owner'},
  {text: 'Public', value: 'shared'}
])

onMounted(() => {
  getSmartlists()
})

const getSmartlists = async () => {
  try {
    const {data} = await getRequest(`/smartlistv1`)
    smartlists.value = data
  } catch (e) {
    logError(e)
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/main.scss";

::v-deep {
  .v-data-table__wrapper {
    height: calc(100vh - 290px);
    min-height: 300px;
  }
}

tr:nth-of-type(even) {
  @extend .shaded-row;
}
</style>
