<!-- suppress CssInvalidPseudoSelector -->
<template id="feat-db-contacts">
  <v-card class="mb-3">
    <v-toolbar class="primary mb-2" @click="toggleCollapseExpand">
      <v-toolbar-title class="white--text font-weight-bold" :title="title">
        {{ title }}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <a-btn
          icon
          color="#ddd"
          html-style="border-radius: 3px"
          v-if="userCanEdit"
          @click.native.stop="handleAddBtnClick(!addMode && !editMode)"
          :prepend-icon="!addMode && !editMode ? 'add' : 'remove'"
      ></a-btn>
      <a-btn
          icon
          color="#ddd"
          html-style="border-radius: 3px"
          v-if="showExpanded"
          :prepend-icon="expanded ? 'mdi-chevron-up' : 'mdi-chevron-down'"
      ></a-btn>
    </v-toolbar>
    <v-card-text v-if="expanded">
      <v-form v-show="addMode || editMode"
              ref="contactForm" class="pa-3">
        <a-text-field v-model="selectedContact.name" required filled
                      :label="contactTypeId === 7 ? 'Store Name' : 'Name'"
        ></a-text-field>
        <a-text-field v-model="selectedContact.title" filled
                      :label="contactTypeId === 7 ? 'Store Number' : 'Title'"
        ></a-text-field>
        <a-text-field v-model="selectedContact.phoneNumber" label="Phone" filled></a-text-field>
        <a-text-field v-model="selectedContact.email" label="Email" type="email" filled></a-text-field>
        <a-text-field v-model="selectedContact.hours" label="Hours" filled></a-text-field>
        <a-textarea label="Address" auto-grow
                    variant="filled"
                    v-model="selectedContact.address">
        </a-textarea>
        <a-textarea label="Notes" auto-grow
                    variant="filled"
                    v-model="selectedContact.notes">
        </a-textarea>
        <div class="contact-btns">
          <a-btn
              color="primary"
              variant="text"
              @click="hideCtrls"
              class="cancel-link"
              text="Cancel"
          ></a-btn>
          <a-btn
              v-show="editMode"
              v-if="userCanEdit"
              @click="deleteContact"
              class="error"
              color="unset"
              text="Delete"
          ></a-btn>
          <a-btn
              @click="saveContact"
              color="primary"
              :disabled="selectedContact.name === ''"
              :text="addMode ? 'Add' : 'Update'"
          ></a-btn>
        </div>
      </v-form>
      <div v-for="(contact, index) in contacts" :key="contact.id"
           v-show="contacts.length > 0" class="px-3">
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
            <a-btn
                size="small"
                color="primary"
                v-if="userCanEdit && !(addMode || editMode)"
                @click="editContact(contact)"
                class="pa-0 mx-0 mt-2 text-capitalize"
                text="Edit"
            ></a-btn>
          </dd>
        </dl>
        <v-spacer v-if="index !== contacts.length - 1"
                  class="mt-2" style="border-bottom: 1px solid #ccc"></v-spacer>
      </div>
      <div class="py-3 px-5 empty-list" v-show="contacts.length < 1"
           :style="{'font-size': isNested ? '0.95em !important' : '0.85em !important'}">
        {{ contactTypeId === 7 ? 'No locations found' : 'No contacts found' }}
      </div>
    </v-card-text>
  </v-card>
</template>

<script setup>
import cloneDeep from 'lodash.clonedeep'

import { putRequest, postRequest,  } from '@/helpers/helpers'
import {CollapseExpandEnum} from "@/views/blueraven/featDB/FeatDbConstants"
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'


const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const props = defineProps({
  title: {
    type: String
  },
  contactTypeId: {
    type: Number
  },
  itemId: {
    type: Number
  },
  userCanEdit: {
    type: Boolean
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
})

const { title, contactTypeId, itemId, userCanEdit, itemType, ahjId, contacts, isNested, showExpanded, expandedAll } = toRefs(props)

const selectedContact = ref({id: null,address: null,contactTypeId: null,email: null,hours: null,name: null,notes: null,phoneNumber: null,title: null})
const addMode = ref(false)
const editMode = ref(false)
const contactsCopy = ref(contacts.value)
const expanded = ref(true)
const contactForm = ref(null)

const emit = defineEmits(['toggle-collapse-expand'])


watch(expandedAll, () => {
  if(expandedAll.value === CollapseExpandEnum.EXPANDED && expanded.value !== true) {
    expanded.value = true
  } else if(expandedAll.value === CollapseExpandEnum.COLLAPSED && expanded.value === true){
    expanded.value = false
  }
})

const handleAddBtnClick = (add)  => {
  //without this method it would only show the "add" section if you clicked right on the icon and not if you were inside the button but outside the icon. was causing issues
  if(add) {
    addContact()
  } else {
    hideCtrls()
  }
}
const hideCtrls = ()  => {
  contactForm.value.reset()
  addMode.value = false
  editMode.value = false
}
const addContact = ()  => {
  if(!expanded.value){
    toggleCollapseExpand()
  }
  editMode.value = false
  addMode.value = true
}
const editContact = (contact)  => {
  addMode.value = false
  editMode.value = true
  selectedContact.value = Object.assign({}, contact)
}
const saveContact = async() => {
  appStore.loading = true
  selectedContact.value.contactTypeId = contactTypeId.value

  if (addMode.value) {
    try {
      let res = null

      //changed to not require updates when a new feat_db gets added
      if (['permit', 'inspection', 'design'].includes(itemType.value)) {
        res = await postRequest(`/featDb/ahj/${ahjId.value}/${itemType.value}/${itemId.value}/contacts`, selectedContact.value, 'blueraven')
      } else {
        res = await postRequest(`/featDb/${itemType.value}/${itemId.value}/contacts`, selectedContact.value, 'blueraven')
      }

      contactsCopy.value.push(cloneDeep(res.data))
      snackbar('SUCCESS', 'Contact added')

      contactForm.value.reset()
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error adding contact')

    }
    addMode.value = false
  } else {
    try {
      let res = null
      //changed to not require updates when a new feat_db gets added
      if (['permit', 'inspection', 'design'].includes(itemType.value)) {
        res = await putRequest(`/featDb/ahj/${ahjId.value}/${itemType.value}/${itemId.value}/contacts/${selectedContact.value.id}`, selectedContact.value, 'blueraven')
      } else {
        res = await putRequest(`/featDb/${itemType.value}/${itemId.value}/contacts/${selectedContact.value.id}`, selectedContact.value, 'blueraven')
      }

      let updatedContactIndex = contactsCopy.value.findIndex(i => i.id === res.data.id)
      contactsCopy.value[updatedContactIndex].name = res.data.name
      contactsCopy.value[updatedContactIndex].title = res.data.title
      contactsCopy.value[updatedContactIndex].phoneNumber = res.data.phoneNumber
      contactsCopy.value[updatedContactIndex].email = res.data.email
      contactsCopy.value[updatedContactIndex].hours = res.data.hours
      contactsCopy.value[updatedContactIndex].address = res.data.address
      contactsCopy.value[updatedContactIndex].notes = res.data.notes
      snackbar('SUCCESS', 'Contact updated')

      contactForm.value.reset()
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error adding contact')

    }
    editMode.value = false
  }
  appStore.loading = false
}
const deleteContact = async() => {
  appStore.loading = true

  try {
    //changed to not require updates when a new feat_db gets added
    if (['permit', 'inspection', 'design'].includes(itemType.value)) {
      await putRequest(`/featDb/ahj/${ahjId.value}/${itemType.value}/${itemId.value}/contacts/${selectedContact.value.id}/archive`, null, 'blueraven')
    } else {
      await putRequest(`/featDb/${itemType.value}/contacts/${selectedContact.value.id}/archive`, null, 'blueraven')
    }

    let deletedContactIndex = contactsCopy.value.findIndex(i => i.id === selectedContact.value.id)
    contactsCopy.value.splice(deletedContactIndex, 1)
    snackbar('SUCCESS', 'Contact deleted')

  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error deleting contact')

  }
  editMode.value = false
  appStore.loading = false
}
const toggleCollapseExpand = () => {
  if(expanded.value && (addMode.value || editMode.value)){
    hideCtrls()
  }
  expanded.value = !expanded.value
  emit('toggle-collapse-expand', expanded.value)
}
</script>

<style scoped lang="scss">
.cancel-link {
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
.empty-list {
  text-align: left;
  font-size: 0.95em;
}
.nested-list {
  font-size: 0.85em !important;
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
  text-align: left !important;
}
/*End definition list styles*/
</style>
