<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat>
          <v-toolbar-title>Part Master</v-toolbar-title>
          <v-spacer/>
          <v-toolbar-items>
            <a-btn
              variant="text"
              text="Create New Version"
              @click=""
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider class="divider"></v-divider>
        <v-data-table
          :headers="headers"
        ></v-data-table>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
  import { ref } from 'vue'
  import {postRequest} from "@/helpers/helpers.js";

  const headers = ref([
    { text: 'Version', value: 'version', show: true },
    { text: 'Modified On', value: 'dateModified', show: true },
    { text: 'Modified By', value: 'dateBy', show: true },
    { text: 'Description', value: 'description', show: true }
  ])

  const versions = ref([])
  const create = async () => {
    const { data } = await postRequest('/partsMaster/versions', {}, 'blueraven')
    versions.value.push({ ...data })
    await router.push({ name: 'partsMasterDetails', params: { id: data.id } })
  }
</script>

<style scoped lang="scss">

.divider {
  border-width: 1px;
}
</style>
