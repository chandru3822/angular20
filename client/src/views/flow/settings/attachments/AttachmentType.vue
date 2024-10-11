<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <a-btn
          variant="text"
          color="primary"
          class="pl-1 pr-2"
          :to="'/settings/attachments'"
          prepend-icon="arrow_left"
          text="BACK"
        />
        <v-row>
          <v-col cols="10" v-if="!editName">
            <div class="headline-small">
              {{ attachment.attachmentType }}
            </div>
            <span>
              {{ attachmentTypeObjectCategories }}
            </span>
          </v-col>
          <v-col cols="8" v-else>
            <a-text-field
              color="primary"
              :readonly="!userCanEdit"
              :disabled="!userCanEdit"
              v-model="attachment.attachmentType"
              hide-details
              label="Attachment Type Name"
            ></a-text-field>
            <v-select
              v-model="attachment.objectCategoryIds"
              multiple
              :items="objectCategories"
              item-text="name"
              item-value="id"
              label="Object Categories"
            >
            </v-select>
          </v-col>
          <v-spacer></v-spacer>
          <div>
            <a-btn
              variant="text"
              v-if="userCanEdit && !editName"
              color="primary"
              class=""
              @click="
                [(oldName = attachment.attachmentType), (editName = !editName)]
              "
              prepend-icon="edit"
            />
            <a-btn
              variant="text"
              color="primary"
              class=""
              v-else-if="userCanEdit"
              @click="saveAttachmentType()"
              prepend-icon="save"
            />
            <a-btn
              variant="text"
              color="primary"
              v-if="userCanEdit && editName"
              class=""
              @click="
                [(attachment.attachmentType = oldName), (editName = !editName)]
              "
              text="Cancel"
              hide-text-on-mobile
              :icon="vuetify.breakpoint.smAndDown"
              :prepend-icon="vuetify.breakpoint.smAndDown ? 'close' : ''"
            />
          </div>
        </v-row>
        <v-tabs class="tabs-bar">
          <v-tab
            :to="`/settings/attachment/${attachmentTypeId}/customFieldGroups`"
          >
            Custom Field Groups
          </v-tab>
        </v-tabs>
        <router-view />
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import {
  getRequest,
  handleHidingGlobalLoader,
  putRequest
} from '@/helpers/helpers'

import { getCurrentInstance, onMounted, ref, computed } from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
import { useRoute } from 'vue-router/composables'
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const userStore = useUserStore()
const route = useRoute()
const vuetify = vueInstance.$vuetify

const editName = ref(false)
const oldName = ref(null)
const attachment = ref({})
const objectCategories = ref([])

const attachmentTypeObjectCategories = computed(() => {
  return attachment.value?.objectCategoryIds
    ?.map((id) => {
      return objectCategories.value.find((category) => category.id === id)
    })
    ?.map((oc) => oc.name)
    ?.join(', ')
})

const attachmentTypeId = computed(() => {
  return route.params.id
})

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})

const getObjectCategories = async () => {
  try {
    const { data } = await getRequest(`/objectCategory?objectTypeId=1`)
    objectCategories.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Object Categories')
  }
}

const getAttachmentType = async () => {
  try {
    appStore.loading = true
    const { data } = await getRequest(
      `/attachmentType/type/${attachmentTypeId.value}`
    )
    attachment.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const saveAttachmentType = async () => {
  try {
    appStore.loading = true

    const { status } = await putRequest(
      `/attachmentType/type/${attachmentTypeId.value}`,
      attachment.value
    )
    editName.value = false
    appStore.showSnack('SUCCESS', 'Attachment Type Updated')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving Attachment Type')
    appStore.loading = false
  }
}

onMounted(async () => {
  await Promise.allSettled([getAttachmentType(), getObjectCategories()])
})
</script>

<style scoped lang="scss">
.name-container {
  background-color: var(--v-rowShadeCustom-base) !important;
  border-radius: 5px;
}

.tabs-bar {
  top: -12px;
  border-top: 1px solid #e6e6e6;
  border-bottom: 1px solid #e6e6e6;
  .v-tab:hover {
    color: var(--v-primary-base);
  }
}
</style>
