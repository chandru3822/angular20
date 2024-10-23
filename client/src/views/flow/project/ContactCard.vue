<template>
  <div>
    <v-card flat class="contact-snippet albatross-body-1">
      {{ project.firstName }} {{ project.lastName }}
      <div
          class="flex-display mb-2"
          :class="{ clickable: !!project.phone }"
          @click="
                copyToClipBoard(
                  cleanPhoneNumberForCopying(project.phone),
                  'Phone Number'
                )
              "
      >
              <span class="detail-label label-small pr-2">
                <v-icon small>mdi-phone</v-icon>
              </span>
        <span v-if="project.phone" class="detail-item body-medium">
                {{ formatPhoneNumber(project.phone) }}
              </span>
        <span v-else class="d-inline-block detail-item body-medium"
        >N/A</span
        >
      </div>
      <div
          class="flex-display mb-2"
          :class="{ clickable: !!project.mobile }"
          @click="
                copyToClipBoard(
                  cleanPhoneNumberForCopying(project.mobile),
                  'Mobile Phone'
                )
              "
      >
              <span class="detail-label label-small pr-2">
                <v-icon small>mdi-cellphone</v-icon>
              </span>
        <span v-if="project.mobile" class="detail-item body-medium">
                {{ formatPhoneNumber(project.mobile) }}
              </span>
        <span v-else class="d-inline-block detail-item body-medium"
        >N/A</span
        >
      </div>
      <div
          class="flex-display mb-2 overview-contact-email"
          :class="{ clickable: !!project.email }"
          @click="copyToClipBoard(project.email, 'Email address')"
      >
              <span class="detail-label label-small pr-2">
                <v-icon small>mdi-email</v-icon>
              </span>
        <span
            v-if="project.email"
            class="detail-item body-medium body-medium"
        >
                {{ project.email }}
              </span>
        <span v-else class="d-inline-block detail-item body-medium">
                N/A
              </span>
      </div>
      <a-btn
          variant="outlined"
          size="small"
          custom-classes="label-medium text-transform-unset px-3 py-1"
          :to="`/contact/${project.contactId}`"
          target="_blank"
      >
        <template v-slot:default>
          Go to contact
          <v-icon small class="pl-2">mdi-open-in-new</v-icon>
        </template>
      </a-btn>
    </v-card>
    <v-menu
        v-if="project.contactId === project.parentProject?.contactId"
        v-model="showChangeContactModal"
        content-class="square-card"
        :close-on-content-click="false"
        min-width="500">
      <template v-slot:activator="{ on }">
        <a-btn
            :activation-handler="on"
            class="ml-7 mb-3"
            size="small"
            text="Change Contact"
        ></a-btn>
      </template>
      <v-card flat color="white" class="square-card">
        <v-card-text class="pt-3">
          <div class="d-flex flex-column" v-if="contactSelectionType == null">
            <a-btn
                class="ml-7 mb-3"
                size="small"
                @click="[newContact = {}, contactSelectionType = 1]"
                text="Select Existing Contact"
            ></a-btn>
            <a-btn
                class="ml-7 mb-3"
                size="small"
                @click="[contactSelectionType = 2]"
                text="Create New Contact"
            ></a-btn>
          </div>
          <a-text-field  v-if="contactSelectionType === 1"
              class="body-large mb-3"
              label="Search for contact (WIP)..."
              hide-details
              density="compact"
              placeholder=" "></a-text-field>

          <div  v-if="contactSelectionType === 2">
            New Contact
            <v-form ref="newContactForm">
              <a-text-field
                  id="qa-first-name-field"
                  density="compact"
                  v-model="newContact.firstName"
                  :rules="requiredRules"
                  label="First Name"
                  class="body-large mt-4"
              ></a-text-field>
              <a-text-field
                  class="body-large"
                  id="qa-last-name-field"
                  density="compact"
                  v-model="newContact.lastName"
                  :rules="requiredRules"
                  label="Last Name"
              ></a-text-field>
              <a-text-field
                  class="body-large"
                  label="Phone"
                  density="compact"
                  placeholder=" "
                  id="qa-phone-field"
                  :rules="contactPhoneRule"
                  v-model="newContact.phone"></a-text-field>
              <a-text-field
                  class="body-large"
                  label="E-Mail"
                  density="compact"
                  id="qa-email-field"
                  placeholder=" "
                  :rules="emailRules"
                  v-model="newContact.email"></a-text-field>
              <a-text-field
                  class="body-large"
                  type="text"
                  density="compact"
                  v-model="newContact.postalCode"
                  counter
                  id="qa-zip-field"
                  :maxlength="10"
                  :rules="requiredRules.concat(postalCodeRules)"
                  label="Postal Code"
              ></a-text-field>
            </v-form>
          </div>
        </v-card-text>

        <v-card-actions v-if="contactSelectionType != null">
          <v-spacer></v-spacer>
          <a-btn
              @click="[showChangeContactModal = false, contactSelectionType = null]"
              color="unset"
              text="Cancel"
          ></a-btn>
          <a-btn
              color="primary"
              class=""
              v-if="contactSelectionType === 1"
              @click="assignContact"
              text="Save and Assign (e)"
          ></a-btn>
          <a-btn
              color="primary"
              class=""
              v-if="contactSelectionType === 2"
              @click="validateNewContact"
              text="Save and Assign (n)"
          ></a-btn>
        </v-card-actions>
      </v-card>
    </v-menu>
  </div>
</template>
<script setup>
import {toRefs, computed, ref} from 'vue'
import {
  cleanPhoneNumberForCopying,
  formatPhoneNumber,
  getRequest,
    postRequest,
  handleHidingGlobalLoader,
  logError
} from '@/helpers/helpers'
import {useProjectStore} from '@/stores/ProjectStore.js'
import { useAppStore } from '@/stores/AppStore.js'
import {useRouter} from 'vue-router/composables'
import constants from "@/helpers/constants.js"

const projectStore = useProjectStore()
const appStore = useAppStore()
const router = useRouter()

const props = defineProps({
  project: Object
})
const {project} = toRefs(props)
const newContact = ref({})
const contactSelectionType = ref(null) //1 = existing, 2 = new
const newContactForm = ref(null)
const showChangeContactModal = ref(false)
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
const contactPhoneRule = ref([() => (newContact.value.phone != null && newContact.value.phone !== '') || "Phone is required",v => (!v || (v && (v.length <= 20))) || 'Must be 20 characters or less',v => (!v || (/^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$/.test(v))) || "Please reformat the Phone field with a valid phone number"])
const emailRules = ref(constants.EMAIL_RULES)
const postalCodeRules = ref(constants.POSTAL_CODE_RULES)

const copyToClipBoard = (textValue, label) => {
  if (textValue) {
    if (!label) {
      label = 'text'
    }
    navigator.clipboard.writeText(textValue)
    appStore.showSnack('MINOR', `Copied ${label.toLowerCase()} to clipboard`)
  }
}

const validateNewContact = async () => {
  if(newContactForm.value.validate()) {
    await assignContact()
  }
}

const assignContact = async () => {
  appStore.loading = true
  try {
    let params = {
      ...newContact.value
    }
    await postRequest(`/contact/createFromProject/${project.value.id}`, params)

    window.location.reload()
  } catch (e) {
    appStore.loading = false
    logError(e)
  } finally {
    newContact.value = {}
  }
}

</script>

<style lang="scss" scoped>
.contact-snippet {
  border: solid 1px var(--v-grey-lighten1);
  padding: 10px;
  margin: 0 23px 10px 23px;
}
</style>

