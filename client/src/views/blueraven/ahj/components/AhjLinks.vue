<!-- suppress CssInvalidPseudoSelector -->
<template id="ahj-links">
  <v-card class="mb-3">
    <v-toolbar class="primaryCustom">
      <v-toolbar-title class="white--text font-weight-bold" :title="title">
        {{ title }}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn icon color="#ddd" style="border-radius: 3px" v-if="userCanEdit">
        <v-icon v-show="!addMode && !editMode" @click="addLink" class="white--text">add</v-icon>
        <v-icon v-show="addMode || editMode"
                @click="hideCtrls" class="white--text">remove</v-icon>
      </v-btn>
    </v-toolbar>
    <v-form v-show="addMode || editMode"
            ref="linkForm" class="px-3 pt-4 pb-3">
      <v-text-field v-model="link.name" required label="Name" filled></v-text-field>
      <v-text-field v-model="link.link" required type="url"
                    :rules="[urlRule]" label="URL" filled></v-text-field>
      <v-text-field v-model="link.username" label="Username" filled></v-text-field>
      <v-text-field v-model="link.password" label="Password" filled></v-text-field>
      <v-textarea label="Notes" auto-grow filled
                  style="margin: 15px 0 -15px 0"
                  v-model="link.notes">
      </v-textarea>
      <div class="link-btns">
        <a @click="hideCtrls"
           class="cancel-link">Cancel</a>
        <v-btn v-show="editMode" dark v-if="userCanEdit"
               @click="deleteLink" class="error">
          Delete
        </v-btn>
        <v-btn @click="saveLink" color="primaryButton" class="white--text"
               :disabled="!linkInfoEntered">
          {{ addMode ? 'Add' : 'Update' }}
        </v-btn>
      </div>
    </v-form>
    <v-list v-show="links.length > 0" v-for="(link, index) of links"
            :key="link.id" class="px-2" :style="{'border-radius': index === links.length - 1 ? '5px !important' : '',
                                                 'border': index === links.length - 1 ? 'none !important' : ''}">
      <v-list-item :title="link.name">
        <v-list-item-content class="flex-row-center">
          <v-list-item-action @click="editLink(link)" v-if="userCanEdit">
            <v-icon small>edit</v-icon>
          </v-list-item-action>
          <v-list-item-title :style="[{'font-size': isNested ? '0.95em !important' : '0.85em !important'}, {'text-align': 'left'}]">
            <a :href="link.link" class="list-link">{{ link.name }}</a>
          </v-list-item-title>
        </v-list-item-content>
      </v-list-item>
    </v-list>
    <div class="empty-list" v-show="links.length < 1"
         :style="{'font-size': isNested ? '0.95em !important' : '0.85em !important'}">
      No links found
    </div>

    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-card>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import Snackbar from '@/components/Snackbar'
  import { AppMutations } from '@/stores/AppStore'
  import { putRequest, postRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: "AhjLinks",
    components: {
      Snackbar
    },
    props: {
      title: {
        type: String
      },
      linkTypeId: {
        type: Number
      },
      userCanEdit: {
        type: Boolean
      },
      itemId: {
        type: Number
      },
      itemType: {
        type: String
      },
      ahjId: {
        type: Number
      },
      links: {
        type: Array,
        default: () => []
      },
      isNested: {
        type: Boolean,
        default: false
      }
    },
    data () {
      return {
        snackbar: {},
        link: {
          id: null,
          linkTypeId: this.type,
          name: null,
          link: null,
          username: null,
          password: null,
          notes: null
        },
        addMode: false,
        editMode: false,
        validUrl: false,
        linksCopy: this.links
      }
    },
    computed: {
      linkInfoEntered() {
        return this.link.name && this.link.link && this.validUrl
      }
    },
    methods: {
      urlRule(url) {
        if (url && (!url.includes('http://') && !url.includes('https://')) || (url === 'http://' || url === 'https://')) {
          this.validUrl = false
          return 'Valid URL is required'
        } else {
          this.validUrl = true
          return true
        }
      },
      hideCtrls() {
        this.addMode = false
        this.editMode = false
      },
      addLink() {
        this.editMode = false
        this.addMode = true
        this.$refs.linkForm.reset()
      },
      editLink(link) {
        this.addMode = false
        this.editMode = true
        this.link = Object.assign({}, link)
      },
      async saveLink() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.link.linkTypeId = this.linkTypeId

        if (this.addMode) {
          try {
            let res = null
            if (this.itemType === 'utility') {
              res = await postRequest(`/ahjUtility/${this.itemId}/links`, this.link, 'blueraven')
            } else {
              res = await postRequest(`/ahj/${this.ahjId}/${this.itemType}/${this.itemId}/links`, this.link, 'blueraven')
            }
            this.linksCopy.push(cloneDeep(res.data))
            this.snackbar = getSnackbar('SUCCESS', 'Link added')
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error adding link')
          }
          this.addMode = false
        } else {
          try {
            let res = null
            if (this.itemType === 'utility') {
              res = await putRequest(`/ahjUtility/${this.itemId}/links/${this.link.id}`, this.link, 'blueraven')
            } else {
              res = await putRequest(`/ahj/${this.ahjId}/${this.itemType}/${this.itemId}/links/${this.link.id}`, this.link, 'blueraven')
            }
            let updatedLinkIndex = this.linksCopy.findIndex(i => i.id === res.data.id)
            this.linksCopy[updatedLinkIndex].name = res.data.name
            this.linksCopy[updatedLinkIndex].link = res.data.link
            this.linksCopy[updatedLinkIndex].username = res.data.username
            this.linksCopy[updatedLinkIndex].password = res.data.password
            this.linksCopy[updatedLinkIndex].notes = res.data.notes
            this.snackbar = getSnackbar('SUCCESS', 'Link updated')
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error adding link')
          }
          this.editMode = false
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      async deleteLink() {
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          if (this.itemType === 'utility') {
            await putRequest(`/ahjUtility/links/${this.link.id}/archive`, null, 'blueraven')
          } else {
            await putRequest(`/ahj/${this.ahjId}/${this.itemType}/${this.itemId}/links/${this.link.id}/archive`, null, 'blueraven')
          }
          let deletedLinkIndex = this.linksCopy.findIndex(i => i.id === this.link.id)
          this.linksCopy.splice(deletedLinkIndex, 1)
          this.snackbar = getSnackbar('SUCCESS', 'Link deleted')
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error deleting link')
        }
        this.editMode = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
</script>

<style scoped lang="scss">
  .flex-row-center {
    display: flex;
    flex-flow: row nowrap;
    align-items: center;
  }
  .cancel-link {
    font-size: 0.85em !important;
    text-decoration: none;
  }
  .list-link {
    text-decoration: none;
  }
  .cancel-link:hover,
  .list-link:hover {
    text-decoration: underline;
  }
  .v-card__title,
  .v-toolbar__title {
    font-size: 1em !important;
  }
  .v-text-field,
  .v-input ::v-deep label {
    font-size: 0.95em !important;
  }
  .v-list {
    border-bottom: 1px solid var(--v-primaryCustom-base) !important;
    border-radius: 0;
  }
  .v-list__item__title {
    font-size: 0.8em !important;
  }
  .v-list-item__action {
    margin: 0 10px 0 0 !important;
    max-width: 30px;
    height: 30px;
    border: 1px solid var(--v-primaryCustom-base) !important;
    border-radius: 3px;
    display: flex;
    justify-content: center;
    cursor: pointer;
  }
  .link-btns {
    display: flex;
    flex-flow: row nowrap;
    justify-content: flex-end;
    align-items: center;
    button {
      margin: 0 0 0 7px;
    }
  }
  .empty-list {
    padding: 20px;
    text-align: left;
  }
</style>
