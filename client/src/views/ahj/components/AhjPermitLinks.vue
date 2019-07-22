<!-- suppress CssInvalidPseudoSelector -->
<template id="ahj-permit-links">
  <v-card class="mb-3">
    <v-toolbar class="primaryCustom">
      <v-toolbar-title class="white--text font-weight-bold" :title="title">
        {{ title }}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn icon color="#ddd" style="border-radius: 3px">
        <v-icon v-show="!addMode" @click="addLink" class="white--text">add</v-icon>
        <v-icon v-show="addMode"
                @click="addMode=false" class="white--text">remove</v-icon>
      </v-btn>
    </v-toolbar>
    <v-form v-show="addMode || editMode"
            ref="linkForm" class="px-3 pt-4 pb-3">
      <v-text-field v-model="link.name" required label="Name" filled></v-text-field>
      <v-text-field v-model="link.url" required type="url"
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
        <v-btn v-show="editMode" dark
               @click="deleteLink" class="error">
          Delete
        </v-btn>
        <v-btn @click="saveLink" color="primaryButton" style="color: #fff !important"
               :disabled="!linkInfoEntered">
          {{ addMode ? 'Add' : 'Update' }}
        </v-btn>
      </div>
    </v-form>
    <v-list v-show="links.length > 0" v-for="link in links"
            :key="link.id" class="px-2">
      <v-list-item :title="link.name">
        <v-list-item-content class="flex-row-center">
          <v-list-item-action>
            <v-icon small @click="editLink(link)">edit</v-icon>
          </v-list-item-action>
          <v-list-item-title>
            <a :href="link.url" class="list-link">{{ link.name }}</a>
          </v-list-item-title>
        </v-list-item-content>
      </v-list-item>
    </v-list>
    <div class="empty-list" v-show="links.length < 1">
      No links found
    </div>
  </v-card>
</template>

<script>
  import { deleteRequest, putRequest, postRequest } from '@/helpers/helpers'

  export default {
    name: "AhjPermitLinks",
    props: {
      title: {
        type: String,
        default: null
      },
      typeId: {
        type: Number,
        default: null
      },
      permitId: {
        type: Number,
        default: null
      },
      links: {
        type: Array,
        default: null
      }
    },
    data () {
      return {
        link: {
          id: null,
          linkTypeId: this.type,
          name: null,
          url: null,
          username: null,
          password: null,
          notes: null
        },
        addMode: false,
        editMode: false,
        validUrl: false
      }
    },
    computed: {
      linkInfoEntered() {
        return this.link.name && this.link.url && this.validUrl
      }
    },
    methods: {
      urlRule(url) {
        if (url && (!url.includes('http://') && !url.includes('https://'))) {
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
        this.$refs.linkForm.reset()
      },
      addLink() {
        this.$refs.linkForm.reset()
        this.editMode = false
        this.addMode = true
      },
      editLink(link) {
        this.link = Object.assign({}, link)
        this.addMode = false
        this.editMode = true
      },
      async saveLink() {
        if (this.addMode) {
          await postRequest(`/api/v1/company/blueraven/ahj/${this.ahjId}/permit/${this.permitId}/links`, this.link)
          this.addMode = false
        } else {
          await putRequest(`/api/v1/company/blueraven/ahj/${this.ahjId}/permit/${this.permitId}/links/${this.link.id}`, this.link)
          this.editMode = false
        }
      },
      async deleteLink() {
        await deleteRequest(`/api/v1/company/blueraven/ahj/${this.ahjId}/permit/${this.permitId}/links/${this.link.id}`)
        this.editMode = false
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
  .cancel-link,
  .list-link {
    font-size: 0.85em !important;
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
  .v-list__item__title {
    font-size: 0.8em !important;
  }
  .v-list-item__action {
    margin: 0 !important;
    max-width: 24px;
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
    font-size: 0.85em;
  }
</style>