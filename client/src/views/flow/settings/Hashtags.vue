<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Topic Hashtags</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary"
                   @click="[addNew = !addNew, newTag = {}]"
                   v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else-if="!addNew"><v-icon>mdi-plus</v-icon>Add Topic</span>
              <span v-else>Cancel</span>
            </v-btn>
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
              <v-btn text color="primary" class="mt-4"
                     @click="[addNew = !addNew, newTag = {}]">
                <span>Cancel</span>
              </v-btn>
              <v-btn color="primary" class="mt-4" :disabled="!newTag.hashtag || !formValid"
                     @click="saveTag(newTag, true)">Save
              </v-btn>
            </v-form>
          </v-card>
          <div>
            <v-data-table
              :headers="headers"
              :items="filteredHashtags"
              :fixed-header="true"
              :items-per-page="-1"
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
                    <v-btn text color="primary" v-if="selectedTagId === item.id" :disabled="!item.hashtag"
                           @click="tagToSave=item; showSaveDialog = true">
                      <v-icon>save</v-icon>
                    </v-btn>
                    <v-icon v-else-if="item.hashtagTypeId !== 1" color="primary" @click="selectedTagId = item.id">
                      edit
                    </v-icon>
                    <v-btn text color="primary" v-if="selectedTagId === item.id" @click="selectedTagId = null">
                      <v-icon>close</v-icon>
                    </v-btn>
                    <v-btn small text color="primary"
                           v-if="item.hashtagTypeId !== 1 && $store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                           @click="tagToDelete=item">
                      <v-icon>delete</v-icon>
                    </v-btn>
                    <v-tooltip
                      content-class="full-opacity-tooltip"
                      :max-width="300"
                      top
                    >
                      <template v-slot:activator="{ on, attrs }">
                        <v-btn
                          text small
                          color="primary"
                          class="d-inline-block"
                          v-bind="attrs"
                          v-on="on"
                        >
                          <v-icon color="primary" v-on="on">
                            mdi-information
                          </v-icon>
                        </v-btn>
                      </template>
                      <span>Hashtag ID: {{ item.id }}</span>
                    </v-tooltip>
                  </td>
                </tr>
              </template>

            </v-data-table>
          </div>
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


<script>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import orderBy from 'lodash.orderby'
import { getHashtags } from "@/services/activityService"
import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
  getSnackbar
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from "@/components/ConfirmationDialog";

export default {
  name: 'Tags',
  components: {ConfirmationDialog},
  mixins: [Vue2Filters.mixin],

  data() {
    return {
      snackbar: {},
      constants,
      tags: [],
      addNew: false,
      showSaveDialog: false,
      tagMaxChars: 255,
      newTag: {},
      selectedTagId: null,
      userId: this.$store.state.user.details.id,
      companyId: this.$store.state.user.details.companyId,
      tagToDelete: null,
      tagToSave: null,
      headers: [
        {text: 'Hashtag', value: 'hashtag', show: true},
        {text: 'Type', value: 'hashtagType', show: true},
        {text: '', value: 'icons', show: true},
      ],
      hashtagRules: [
        v => !!v || 'Field is required',
        v => /^[a-z\-]+$/.test(v) || 'Hashtag must only contain lowercase letters and hyphens',
        v => /^[a-z].*$/.test(v) || 'Hashtag must start with a lowercase letter',
        v => /.*[^-]$/.test(v) || 'Hashtag must end with a lowercase letter',
        v => /^(?!.*--).*$/.test(v) || 'Hashtag cannot have 2 consecutive hyphens',

      ],
      formValid: false
    }
  },
  computed: {
    tagToDeleteValue() {
      return this.tagToDelete ? this.tagToDelete.hashtag : ''
    },
    filteredHashtags() {
      return this.tags.filter(t => !t.archived)
    },
  },
  methods: {
    validateNew() {
      this.formValid = this.$refs.hashtagForm.validate()
    },
    async validateExisting(item) {
      let ref = this.$refs[`editForm${item.id}`]
      if (ref && ref.validate()) {
        await this.saveTag(item, false)
      }
    },
    async getTags() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getHashtags()
        this.tags = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteTag() {
      const tag = this.tagToDelete
      const hashtagId = this.tagToDelete.id
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await deleteRequest(`/hashtag/${hashtagId}`)
        this.snackbar = getSnackbar('SUCCESS', 'Hashtag Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        tag.archived = true
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Tag')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.tagToDelete = null
    },
    async saveTag(hashtag, isNew) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //yes this is hardcoded. im just trying to prep for future requests
        hashtag.hashtagTypeId = 2  //2 = Notes, this is the only type they can add for now
        const {data, status} = await putRequest(`/hashtag`, hashtag, null)
        if (isNew) {
          this.addNew = false
          this.newTag = {}
          this.tags.push(data)
          this.tags = orderBy(this.tags, [a => a.hashtag.toLowerCase()])
        } else {
          this.selectedTagId = null
        }
        this.snackbar = getSnackbar('SUCCESS', 'Hashtag Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Hashtag')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    closeSaveDialog() {
      this.showSaveDialog = false;
      this.tagToSave = null;
    },
  },
  async created() {
    this.getTags()
  }
}
</script>

