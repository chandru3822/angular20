<template>
<v-container id="hierarchy-container">
  <v-row class="fill-height" align="center" justify="start">
    <v-col class="shrink" cols="12">
      <div class="search-header">
        <a-text-field
          v-if="!showAddNew"
          v-model="search"
          class="mb-2 px-4 py-2 d-inline-block"
          prepend-inner-icon="search"
          label="Search"
          single-line
          hide-details
        ></a-text-field>
        <a-btn
          variant="text"
          color="primary"
          class="d-inline-block"
          v-if="!showAddNew"
          @click="[showAddNew = !showAddNew]"
          :text="!showAddNew ? 'Add New Partner' : 'Cancel'"
          :prepend-icon="showAddNew ? 'close' : 'add'"
        />
      </div>
      <v-card
        v-if="showAddNew"
        flat
        class="text-left pa-5 mb-3"
        >
        <h3>Add Partner</h3>
        <div class="mb-3">
          <v-form ref="newPartnerForm">
            <a-text-field
              v-model="newPartner.name"
              :rules="requiredRules"
              label="Name"
            />
            <a-text-field
              v-model="newPartner.code"
              hint="lowercase, only contain letters and numbers, and '_'"
              persistent-hint
              :rules="requiredRules"
              label="Slug"
            />
          </v-form>
          <a-btn
            color="primary"
            class="white--text mr-2"
            text="Save"
            @click="addPartner"
          />

          <a-btn
            variant="text"
            color="primary"
            text="Cancel"
            @click="[newPartner = {}, showAddNew = false]"
          />
        </div>
      </v-card>
      <v-data-table
        :headers="headers"
        :items="partners"
        :fixed-header="true"
        :items-per-page="-1"
        single-expand
        :expanded.sync="expanded"
        hide-default-footer
        class="elevation-1 table-striped"
      >
        <template #no-data>
          <span class="default-text-color">NO DATA HERE!</span>
        </template>

        <template #no-results>
            <span class="default-text-color">
              No parameters exist for this function
            </span>
        </template>

        <template #item.name="{ item }" class="text-left">{{ item.name }} - ({{ item.id }})</template>
        <template #item.icons="{item}" class="text-right d-flex">
          <a-btn
            v-if="!expanded.includes(item)"
            size="small"
            variant="text"
            color="primary"
            @click="[expanded = [item]]"
            prepend-icon="edit"
          />
          <a-btn
            v-if="expanded.includes(item)"
            size="small"
            variant="text"
            color="primary"
            @click="expanded = []"
            text="Cancel"
            prepend-icon="close"
          />
        </template>

        <template #expanded-item="{item}">
         <div
           class="pa-4"
         >
           <v-row class="align-center">
             <v-col cols="2">
               <h3>Keys</h3>
             </v-col>
             <v-col>
               <a-btn
                 @click="addKey(item)"
               >
                 Add
               </a-btn>
             </v-col>
           </v-row>
           <v-list>
             <template
               v-for="key in item.keys"
             >
               <v-list-item
                 v-if="!key.validUntil || new Date(key.validUntil) > new Date()"
                 @click="copyToClipboard(key.key)"
               >
                 <v-row>
                   <v-col>
                     {{key.description}}
                   </v-col>
                   <v-col>
                     <a-btn @click="deleteKey(key)">
                       Delete
                     </a-btn>
                   </v-col>
                 </v-row>
               </v-list-item>

             </template>
           </v-list>

         </div>
        </template>
      </v-data-table>
    </v-col>
  </v-row>
</v-container>
</template>

<script setup>
import {ref} from 'vue'
import { deleteRequest, getRequest, handleHidingGlobalLoader, logError, postRequest } from '@/helpers/helpers.js'
import { onMounted } from 'vue'
import constants from '@/helpers/constants.js'
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()

const headers = ref([
  { text: 'Partner', value: 'name', show: true },
  { text: null, value: 'icons', show: true, sortable: false }
])
const expanded = ref([])
const showAddNew = ref(false)
const search = ref('')
const newPartnerForm = ref(null)
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)

const partners = ref([])
const newPartner = ref({})

onMounted(() => {
  getPartners()
})

const getPartners = async () => {
  const {data} = await getRequest('/apiManagement/partner', 'blueraven')
  partners.value = data
}

const addPartner = async () => {
  let valid = newPartnerForm.value?.validate()

  // todo: need validation if partner exists

  if (valid) {
    try {
      appStore.loading = true
      const {data, status} = await postRequest(`/apiManagement/partner`, newPartner.value, 'blueraven')
      partners.value.push(data)
      newPartner.value = {}
      showAddNew.value = false
      appStore.showSnack('SUCCESS', 'New Partner Added')
      handleHidingGlobalLoader(status)
    } catch (e) {
      logError(e)
      appStore.showSnack('ERROR', 'Error Adding Partner')
      appStore.loading = false
    }
  }
}

const addKey = async (partner) => {
  const now = new Date()
  const newKey = {
    partnerId: partner.id,
    description: `${partner.name} API KEY - ${now.getHours()}${now.getMinutes()}${now.getSeconds()}`
  }

  try {
    appStore.loading = true
    const {data, status} = await postRequest(`/apiManagement/partner/${partner.id}/key`, newKey, 'blueraven')
    partner.keys.push(data)
    appStore.showSnack('SUCCESS', 'New Key Added')
    handleHidingGlobalLoader(status)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error Adding Key')
    appStore.loading = false
  }
}

const deleteKey = async (key) => {
  try {
    appStore.loading = true
    const {status} = await deleteRequest(`/apiManagement/partner/${key.partnerId}/key/${key.id}`, 'blueraven')
    key.validUntil = new Date()
    appStore.showSnack('SUCCESS', 'Key Deleted')
    handleHidingGlobalLoader(status)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error Deleting Key')
    appStore.loading = false
  }
}

const copyToClipboard = (key) => {
  navigator.clipboard.writeText(key)
  appStore.showSnack('SUCCESS', 'Copied to clipboard')
}

</script>

<style scoped lang="scss">
.search-header {
  width: 100%;
  display: flex;
  align-items: center;
}
</style>