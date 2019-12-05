<!-- suppress CssInvalidPseudoSelector -->
<template id="ahj-contacts">
  <v-card class="pb-2 mb-3">
    <v-toolbar class="primaryCustom mb-2">
      <v-toolbar-title class="white--text font-weight-bold" :title="title">
        {{ title }}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn icon color="#ddd" style="border-radius: 3px">
        <v-icon v-show="!addMode && !editMode" @click="addContact" class="white--text">add</v-icon>
        <v-icon v-show="addMode || editMode"
                @click="hideCtrls" class="white--text">remove</v-icon>
      </v-btn>
    </v-toolbar>
    <v-form v-show="addMode || editMode"
            ref="contactForm" class="pa-3">
      <v-text-field v-model="contact.name" required filled
                    :label="contactTypeId === 7 ? 'Store Name' : 'Name'"
      ></v-text-field>
      <v-text-field v-model="contact.title" filled
                    :label="contactTypeId === 7 ? 'Store Number' : 'Title'"
      ></v-text-field>
      <v-text-field v-model="contact.phoneNumber" label="Phone" filled></v-text-field>
      <v-text-field v-model="contact.email" label="Email" type="email" filled></v-text-field>
      <v-text-field v-model="contact.hours" label="Hours" filled></v-text-field>
      <v-textarea label="Address" auto-grow filled
                  v-model="contact.address">
      </v-textarea>
      <v-textarea label="Notes" auto-grow filled
                  v-model="contact.notes">
      </v-textarea>
      <div class="contact-btns">
        <a @click="hideCtrls"
           class="cancel-link">Cancel</a>
        <v-btn v-show="editMode" dark
               @click="deleteContact" class="error">
          Delete
        </v-btn>
        <v-btn @click="saveContact" color="primaryButton" class="white--text"
               :disabled="contact.name === ''">
          {{ addMode ? 'Add' : 'Update' }}
        </v-btn>
      </div>
    </v-form>
    <div v-for="(contact, index) in contacts" :key="contact.id"
         v-show="contacts.length > 0" class="px-3 py-1">
      <dl class="horizontal-dl"
          :style="{'font-size': isNested ? '0.95em !important' : '0.85em !important'}">
        <dt v-if="contact.name" class="font-weight-bold">Name</dt>
        <dd v-if="contact.name">{{contact.name}}</dd>
        <dt v-if="contact.title" class="font-weight-bold">Title</dt>
        <dd v-if="contact.title">{{contact.title}}</dd>
        <dt v-if="contact.phoneNumber" class="font-weight-bold">Phone</dt>
        <dd v-if="contact.phoneNumber">{{contact.phoneNumber}}</dd>
        <dt v-if="contact.email" class="font-weight-bold">Email</dt>
        <dd v-if="contact.email">{{contact.email}}</dd>
        <dt v-if="contact.hours" class="font-weight-bold">Hours</dt>
        <dd v-if="contact.hours">{{contact.hours}}</dd>
        <dt v-if="contact.address" class="font-weight-bold">Address</dt>
        <dd v-if="contact.address">{{contact.address}}</dd>
        <dt v-if="contact.notes"></dt>
        <dd v-if="contact.notes" class="pa-2" style="background-color: #eee">{{contact.notes}}</dd>
        <dt></dt>
        <dd>
          <v-btn small color="primaryButton"
                 @click="editContact(contact)"
                 class="pa-0 mx-0 mt-2 text-capitalize white--text">Edit</v-btn>
        </dd>
      </dl>
      <v-spacer v-if="index !== contacts.length - 1"
                class="mt-2" style="border-bottom: 1px solid #ccc"></v-spacer>
    </div>
    <div class="py-3 px-5" v-show="contacts.length < 1"
         :style="{'font-size': isNested ? '0.95em !important' : '0.85em !important'}">
      {{ contactTypeId === 7 ? 'No locations found' : 'No contacts found' }}
    </div>
  </v-card>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import { deleteRequest, putRequest, postRequest } from '@/helpers/helpers'

  export default {
    name: "AhjContact",
    props: {
      title: {
        type: String
      },
      contactTypeId: {
        type: Number
      },
      isNested: {
        type: Boolean,
        default: false
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
      contacts: {
        type: Array,
        default: () => []
      }
    },
    data () {
      return {
        contact: {
          id: null,
          address: null,
          contactTypeId: null,
          email: null,
          hours: null,
          name: null,
          notes: null,
          phoneNumber: null,
          title: null
        },
        addMode: false,
        editMode: false,
        contactsCopy: this.contacts
      }
    },
    methods: {
      hideCtrls() {
        this.addMode = false
        this.editMode = false
      },
      addContact() {
        this.editMode = false
        this.addMode = true
        this.$refs.contactForm.reset()
      },
      editContact(contact) {
        this.addMode = false
        this.editMode = true
        this.contact = Object.assign({}, contact)
      },
      async saveContact() {
        this.contact.contactTypeId = this.contactTypeId

        if (this.addMode) {
          const {data} = await postRequest(`/ahj/${this.ahjId}/${this.itemType}/${this.itemId}/contacts`, this.contact, 'blueraven')
          this.contactsCopy.push(cloneDeep(data))
          this.addMode = false
        } else {
          const {data} = await putRequest(`/ahj/${this.ahjId}/${this.itemType}/${this.itemId}/contacts/${this.contact.id}`, this.contact, 'blueraven')
          let updatedContactIndex = this.contactsCopy.findIndex(i => i.id === data.id)
          this.contactsCopy[updatedContactIndex].name = data.name
          this.contactsCopy[updatedContactIndex].title = data.title
          this.contactsCopy[updatedContactIndex].phoneNumber = data.phoneNumber
          this.contactsCopy[updatedContactIndex].email = data.email
          this.contactsCopy[updatedContactIndex].hours = data.hours
          this.contactsCopy[updatedContactIndex].address = data.address
          this.contactsCopy[updatedContactIndex].notes = data.notes
          this.editMode = false
        }
      },
      async deleteContact() {
        await deleteRequest(`/ahj/${this.ahjId}/${this.itemType}/${this.itemId}/contacts/${this.contact.id}`, 'blueraven')
        let deletedContactIndex = this.contactsCopy.findIndex(i => i.id === this.contact.id)
        this.contactsCopy.splice([deletedContactIndex], 1)
        this.editMode = false
      }
    }
  }
</script>

<style scoped lang="scss">
  .cancel-link {
    font-size: 0.85em !important;
    text-decoration: none;
  }
  .cancel-link:hover {
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
  .v-list-item__action {
    margin: 0 !important;
    max-width: 24px;
  }
  .contact-btns {
    display: flex;
    flex-flow: row nowrap;
    justify-content: flex-end;
    align-items: center;
    button {
      margin: 0 0 0 7px;
    }
  }
  /*Definition list styles*/
  .horizontal-dl {
    display: flex;
    flex-flow: row wrap;
    justify-content: space-between;
    width: 100%;
  }
  .horizontal-dl dt {
    text-align: right;
    width: 30%;
  }
  .horizontal-dl dd {
    width: 65%;
  }
  /*End definition list styles*/
</style>
