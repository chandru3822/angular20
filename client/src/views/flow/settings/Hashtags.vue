<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Topic Hashtags</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton
              variant="text"
              color="primary"
              @click="[addNew = !addNew, newTag = {}]"
              v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')"
              :hide-text-on-mobile="constants.IS_MOBILE"
              :text="!addNew ? 'Add Topic' : 'Cancel'"
              :prepend-icon="addNew ? '' : 'add'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card v-if="addNew" flat color="transparent">
            <v-form ref="hashtagForm">
              <div class="flex-display">
                <v-icon size="14" class="mr-2">mdi-pound</v-icon>
                <v-text-field v-model="newTag.hashtag"
                              counter
                              required
                              :rules="hashtagRules"
                              :maxlength="tagMaxChars"
                              placeholder="Hashtag"
                              @input="validateNew"
                              label="Add Topic Hashtag">
                </v-text-field>
              </div>
              <AlbatrossButton
                variant="text"
                color="primary"
                class="mt-4"
                @click="[addNew = !addNew, newTag = {}]"
                text="Cancel"
              />

              <AlbatrossButton
                color="primary"
                class="mt-4"
                :disabled="!newTag.hashtag || !formValid"
                @click="saveTag(newTag, true)"
                text="Save"
              />
            </v-form>
          </v-card>
          <v-card class="square-card">
            <v-card-title class="pt-0">
              <v-text-field
                  v-model="search"
                  prepend-inner-icon="search"
                  label="Search"
                  single-line
                  hide-details
                  clearable
              ></v-text-field>
            </v-card-title>
            <v-data-table
              :headers="headers"
              :items="filteredHashtags"
              :fixed-header="true"
              :items-per-page="-1"
              :search="search"
              :mobile-breakpoint="0"
              hide-default-footer
              class="elevation-1 org-type-table"
            >
              <template #no-data>
                <span class="default-text-color">NO DATA HERE!</span>
              </template>

              <template #no-results>
                <span class="default-text-color">NO DATA HERE!</span>
              </template>

              <template #item="{ item }">
                <tr class="text-left" :class="{'shaded-row': tags.indexOf(item) % 2}">
                  <td class="text-left">
                    <div class="flex-display">
                      <v-icon size="14" class="mr-2">mdi-pound</v-icon>
                      <v-form :ref="`editForm${item.id}`" v-if="selectedTagId === item.id">
                        <v-text-field
                          class="one-hunned"
                          label="Hashtag"
                          counter
                          required
                          :rules="hashtagRules"
                          :maxlength="tagMaxChars"
                          v-model="item.hashtag">
                        </v-text-field>
                      </v-form>
                      <div v-else>
                        {{ item.hashtag }}
                      </div>
                    </div>
                  </td>
                  <td>
                    {{ item.hashtagType }}
                  </td>
                  <td class="text-right">
                    <AlbatrossButton
                      variant="text"
                      color="primary"
                      v-if="selectedTagId === item.id"
                      :disabled="!item.hashtag"
                      @click="tagToSave=item; showSaveDialog = true"
                      prepend-icon="save"
                    />
                    <albatross-button
                      variant="text"
                      color="primary"
                      v-else-if="item.hashtagTypeId !== 1"
                      @click="selectedTagId = item.id"
                      prepend-icon="edit"
                      class="pr-2"
                    />
                    <AlbatrossButton
                      variant="text"
                      color="primary"
                      v-if="selectedTagId === item.id"
                      @click="selectedTagId = null"
                      prepend-icon="close"
                    />

                    <AlbatrossButton
                      size="small"
                      variant="text"
                      color="primary"
                      v-if="item.hashtagTypeId !== 1 && userStore.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                      @click="tagToDelete=item"
                      prepend-icon="delete"
                    />

                    <v-tooltip
                      content-class="full-opacity-tooltip"
                      :max-width="300"
                      top
                    >
                      <template v-slot:activator="{ on, attrs }">
                        <AlbatrossButton
                          variant="text"
                          size="small"
                          color="primary"
                          class="d-inline-block"
                          v-bind="attrs"
                          :activation-handler="on"
                          prepend-icon="mdi-information"
                        />
                      </template>
                      <span>Hashtag ID: {{ item.id }}</span>
                    </v-tooltip>
                  </td>
                </tr>
              </template>

            </v-data-table>
          </v-card>
          <ConfirmationDialog :open-dialog="showSaveDialog" @confirm="validateExisting(tagToSave)" @close-dialog="closeSaveDialog">
            This action will edit the topic in pre-existing notes that are using the original topic hashtag. Are you sure you want to edit the topic?
            <template v-slot:title>Confirm</template>
            <template v-slot:yes>Save Changes</template>
          </ConfirmationDialog>
          <ConfirmationDialog :open-dialog="!!tagToDelete" @confirm="deleteTag" @close-dialog="tagToDelete=null">
            Are you sure you want to delete this topic: <strong>#{{ tagToDeleteValue }}</strong>?
          </ConfirmationDialog>
        </v-container>
      </v-col>

    </v-row>
  </v-container>
</template>


<script setup>
import {AppMutations} from '@/stores/AppStore'
import orderBy from 'lodash.orderby'
import { getHashtags } from "@/services/activityService"
import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";

import { computed, getCurrentInstance, ref, onMounted } from "vue";
import { useUserStore } from '@/stores/UserStorePinia.js'

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const store = vueInstance.$store
const userStore = useUserStore()

const tags = ref([])
const addNew = ref(false)
const showSaveDialog = ref(false)
const tagMaxChars = ref(255)
const newTag = ref({})
const selectedTagId = ref(null)
const userId = ref(userStore.details.id)
const companyId = ref(userStore.details.companyId)
const tagToDelete = ref(null)
const tagToSave = ref(null)

const headers = ref([
  {text: 'Hashtag', value: 'hashtag', show: true},
  {text: 'Type', value: 'hashtagType', show: true},
  {text: '', value: 'icons', show: true},
])

const hashtagRules = ref([
  v => !!v || 'Field is required',
  v => /^[a-z\-]+$/.test(v) || 'Hashtag must only contain lowercase letters and hyphens',
  v => /^[a-z].*$/.test(v) || 'Hashtag must start with a lowercase letter',
  v => /.*[^-]$/.test(v) || 'Hashtag must end with a lowercase letter',
  v => /^(?!.*--).*$/.test(v) || 'Hashtag cannot have 2 consecutive hyphens',
])

const formValid = ref(false)
const search = ref('')

const tagToDeleteValue = computed(() => {
  return tagToDelete.value ? tagToDelete.value.hashtag : ''
})

const filteredHashtags = computed(() => {
  return tags.value.filter(t => !t.archived)
})

const validateNew = () => {
  formValid.value = vueInstance.$refs.hashtagForm.validate()
}
const validateExisting = async (item) => {
    let ref = vueInstance.$refs[`editForm${item.id}`]
    if (ref && ref.validate()) {
      await saveTag(item, false)
    }
}
const getTags = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getHashtags()
    tags.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (pe) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    store.commit(AppMutations.SET_LOADING, false)
  }
}

const deleteTag = async () =>{
  const tag = tagToDelete.value
  const hashtagId = tagToDelete.value.id
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await deleteRequest(`/hashtag/${hashtagId}`)
    snackbar('SUCCESS', 'Hashtag Deleted')
    tag.archived = true
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Tag')
    store.commit(AppMutations.SET_LOADING, false)
  }
  tagToDelete.value = null
}
const saveTag = async (hashtag, isNew) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    //yes this is hardcoded. im just trying to prep for future requests
    hashtag.hashtagTypeId = 2  //2 = Notes, this is the only type they can add for now
    const {data, status} = await putRequest(`/hashtag`, hashtag, null)
    if (isNew) {
      addNew.value = false
      newTag.value = {}
      tags.value.push(data)
      tags.value = orderBy(tags.value, [a => a.hashtag.toLowerCase()])
    } else {
      selectedTagId.value = null
    }
    snackbar('SUCCESS', 'Hashtag Saved')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Hashtag')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const closeSaveDialog = () => {
  showSaveDialog.value = false;
  tagToSave.value = null;
}

onMounted(() => {
  getTags()
})

</script>

