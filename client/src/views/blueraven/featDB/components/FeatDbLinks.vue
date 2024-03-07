<!-- suppress CssInvalidPseudoSelector -->
<template id="feat-db-links">
  <FeatDbCard
      :title="title"
      :expanded-all="expandedAll"
      :edit-mode="editMode"
      show-add show-expanded
      :user-can-edit="userCanEdit"
      :add-btn-disabled="!linkInfoEntered"
      @hide-ctrls="hideCtrls"
      @save-new="saveLink(true)"
      @save-update="saveLink(false)"
      @delete-item="deleteLink"
      @toggle-collapse-expand="$emit('toggle-collapse-expand', $event)"
  >
    <template v-slot:addOrEdit>
    <v-form
            ref="linkForm">
      <v-text-field v-model="link.name" required label="Name" filled></v-text-field>
      <v-text-field v-model="link.link" required type="url"
                    :rules="[urlRule]" label="URL" filled></v-text-field>
      <v-text-field v-model="link.username" label="Username" filled></v-text-field>
      <v-text-field v-model="link.password" label="Password" filled></v-text-field>
      <v-textarea label="Notes" auto-grow filled
                  style="margin: 15px 0 -15px 0"
                  v-model="link.notes">
      </v-textarea>
    </v-form>
    </template>
    <v-list v-show="links.length > 0" v-for="(link, index) of links"
            :key="link.id" class="px-2" :style="{'border-radius': index === links.length - 1 ? '5px !important' : '',
                                                 'border': index === links.length - 1 ? 'none !important' : ''}">
      <v-list-item :title="link.name">
        <v-list-item-content class="flex-row-center">
          <v-list-item-action @click="editLink(link)" v-if="userCanEdit">
            <v-icon small color="primary">edit</v-icon>
          </v-list-item-action>
          <v-list-item-title :style="[{'font-size': isNested ? '0.95em !important' : '0.85em !important'}, {'text-align': 'left'}]">
            <a :href="link.link" target="_blank" class="list-link">{{ link.name }}</a>
          </v-list-item-title>
        </v-list-item-content>
      </v-list-item>
    </v-list>
    <div class="empty-list" v-show="links.length < 1"
         :style="{'font-size': isNested ? '0.95em !important' : '0.85em !important'}">
      No links found
    </div>
  </FeatDbCard>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'

  import { AppMutations } from '@/stores/AppStore'
  import { putRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import {CollapseExpandEnum} from "@/views/blueraven/featDB/FeatDbConstants";
  import FeatDbCard from "@/views/blueraven/featDB/components/FeatDbCard.vue";
  import { mapStores } from 'pinia'
  import { useAppStore } from '@/stores/AppStorePinia.js'

  export default {
    name: "FeatDbinks",
    components: {FeatDbCard},
    props: {
      title:  String,
      linkTypeId: Number,
      userCanEdit: Boolean,
      itemId: Number,
      itemType: String,
      ahjId: Number,
      links: {
        type: Array,
        default: () => []
      },
      isNested: {
        type: Boolean,
        default: false
      },
      showExpanded: {
        type: Boolean,
        default: false
      },
      expandedAll: CollapseExpandEnum
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
        editMode: false,
        validUrl: false,
        linksCopy: this.links,
      }
    },
    computed: {
      ...mapStores(useAppStore),
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
        this.$refs.linkForm.reset()
        this.editMode = false
      },
      editLink(link) {
        this.editMode = true
        this.link = Object.assign({}, link)
      },
      async saveLink(newLink) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.link.linkTypeId = this.linkTypeId

        if (newLink) {
          try {
            let res = null
            //changed to not require updates when a new feat_db gets added
            if (['permit', 'inspection', 'design'].includes(this.itemType)) {
              res = await postRequest(`/featDb/ahj/${this.ahjId}/${this.itemType}/${this.itemId}/links`, this.link, 'blueraven')
            } else {
              res = await postRequest(`/featDb/${this.itemType}/${this.itemId}/links`, this.link, 'blueraven')
            }

            this.linksCopy.push(cloneDeep(res.data))
            this.snackbar = getSnackbar('SUCCESS', 'Link added')
            this.appStore.showSnack(this.snackbar)
            this.$refs.linkForm.reset()
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error adding link')
            this.appStore.showSnack(this.snackbar)
          }
        } else {
          try {
            let res = null
            //changed to not require updates when a new feat_db gets added
            if (['permit', 'inspection', 'design'].includes(this.itemType)) {
              res = await putRequest(`/featDb/ahj/${this.ahjId}/${this.itemType}/${this.itemId}/links/${this.link.id}`, this.link, 'blueraven')
            } else {
              res = await putRequest(`/featDb/${this.itemType}/${this.itemId}/links/${this.link.id}`, this.link, 'blueraven')
            }

            let updatedLinkIndex = this.linksCopy.findIndex(i => i.id === res.data.id)
            this.linksCopy[updatedLinkIndex].name = res.data.name
            this.linksCopy[updatedLinkIndex].link = res.data.link
            this.linksCopy[updatedLinkIndex].username = res.data.username
            this.linksCopy[updatedLinkIndex].password = res.data.password
            this.linksCopy[updatedLinkIndex].notes = res.data.notes
            this.snackbar = getSnackbar('SUCCESS', 'Link updated')
            this.appStore.showSnack(this.snackbar)
            this.$refs.linkForm.reset()
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error adding link')
            this.appStore.showSnack(this.snackbar)
          }
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      async deleteLink() {
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          //changed to not require updates when a new feat_db gets added
          if (['permit', 'inspection', 'design'].includes(this.itemType)) {
            await putRequest(`/featDb/ahj/${this.ahjId}/${this.itemType}/${this.itemId}/links/${this.link.id}/archive`, null, 'blueraven')
          } else {
            await putRequest(`/featDb/${this.itemType}/links/${this.link.id}/archive`, null, 'blueraven')
          }

          let deletedLinkIndex = this.linksCopy.findIndex(i => i.id === this.link.id)
          this.linksCopy.splice(deletedLinkIndex, 1)
          this.snackbar = getSnackbar('SUCCESS', 'Link deleted')
          this.appStore.showSnack(this.snackbar)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error deleting link')
          this.appStore.showSnack(this.snackbar)
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
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
    border-bottom: 1px solid var(--v-primary-base) !important;
    border-radius: 0;
  }
  .v-list__item__title {
    font-size: 0.8em !important;
  }
  .v-list-item__action {
    margin: 0 10px 0 0 !important;
    max-width: 30px;
    height: 30px;
    border: 1px solid var(--v-primary-base) !important;
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
