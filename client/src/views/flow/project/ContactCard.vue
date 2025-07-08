<template>
  <div>
    <v-card flat class="contact-snippet albatross-body-1">
      {{ project.firstName }} {{ project.lastName }}
      <div class="albatross-body-3 contact-object-category">{{project.contactObjectCategory}}</div>
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

      <div class="change-contact">
        <a-btn
        @click="getChildProjectsInfo"
        class="change-contact-padding"
       size="small"
      text="Change Contact"
      ></a-btn>
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
    </div>
    </v-card>
    <a-btn
        v-if="showResetButton"
        color="primary"
        class="ml-7 mb-3"
        @click="showResetContactModal = true"
        text="Reset Contact"
    ></a-btn>
    <ConfirmationDialog :open-dialog="showResetContactModal" @confirm="resetContact"
                        @close-dialog="showResetContactModal=false">
      <template v-slot:title class="albatross-body-1"> Confirm </template>
      <template v-slot:yes class="albatross-body-1"> Confirm </template>
      Are you sure you want to reset the contact on this project back to the same contact that is assigned to the parent?
    </ConfirmationDialog>
    <v-dialog
        v-if="project.contactId === project.parentProject?.contactId"
        v-model="showChangeContactModal"
        content-class="square-card"
        width="500">
      <template v-slot:activator="{ on }">
        <a-btn
            :activation-handler="on"
            class="ml-7 mb-3"
            size="small"
            text="Change Contact"
        ></a-btn>
      </template>
      <v-card flat color="white" class="square-card">
        <v-card-title v-if="contactSelectionType === 2">
          New Contact
        </v-card-title>
        <v-card-text class="pt-3">
          <div class="d-flex flex-column" v-if="contactSelectionType == null">
            <a-btn
                class="ml-7 mb-3"
                size="small"
                @click="[newContact = {}, selectedExistingContact = {}, contactSelectionType = 1]"
                text="Select Existing Contact"
            ></a-btn>
            <a-btn
                class="ml-7 mb-3"
                size="small"
                @click="[getAvailableContactCategories(), selectedExistingContact = {}, contactSelectionType = 2]"
                text="Create New Contact"
            ></a-btn>
          </div>
          <div id="existing-contacts-container"
               v-if="contactSelectionType === 1">
          <a-text-field
              class="body-large mb-3"
              label="Search for contact..."
              hide-details
              density="compact"
              prepend-inner-icon="search"
              clearable
              v-model="search"
              placeholder=" "
              @input="debounceGetContacts"></a-text-field>

            <v-data-table
                :headers="headers"
                :items="existingContacts"
                :fixed-header="true"
                ref="pageableTable"
                :page.sync="page"
                :options.sync="options"
                disable-sort
                :mobile-breakpoint="0"
                :footer-props="footerProps"
                :loading="dataLoading"
                :server-items-length="totalContacts"
                class="elevation-1 fix-column-width-bug contact-table body-small"
            >
              <template #no-data>
                <div class="default-text-color">No available contacts</div>
              </template>

              <template #no-results>
                <div class="default-text-color">No available contacts</div>
              </template>

              <template #item="{ item, index }">

                <tr class="clickable" :class="{'primary lighten-9': index % 2,
                    'selected-row': selectedExistingContact === item}"
                  @click="selectedExistingContact = item">
                  <td class="text-left">
                      {{item.fullName}}
                  </td>
                  <td class="text-left">
                      {{item.state}}
                  </td>
                  <td class="text-left">
                      {{item.dateCreated | formatDate('timestamp', 'MM/DD/YYYY')}}
                  </td>
                </tr>
              </template>
            </v-data-table>
          </div>
          <div  v-if="contactSelectionType === 2">
            <v-form ref="newContactForm">
              <a-select v-model="newContact.objectCategoryId"
                        :items="contactCategories"
                        label="Object Category"
                        :rules="requiredRules"
                        item-title="name"
                        item-value="id"
              ></a-select>
              <a-text-field
                  id="qa-first-name-field"
                  density="compact"
                  v-model="newContact.firstName"
                  :rules="requiredRules"
                  label="First Name"
                  class="body-large"
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
              :disabled="!selectedExistingContact.id"
              @click="assignContact"
              :text="selectedExistingContact.fullName ? `Save and Assign: ${selectedExistingContact.fullName}` : `Save and Assign`"
          ></a-btn>
          <a-btn
              color="primary"
              class=""
              v-if="contactSelectionType === 2"
              @click="validateNewContact"
              text="Save and Assign"
          ></a-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog max-width="800" v-model="showChildProjectsPopup" >
       <v-card class="square-card contact-popup"  >
         <h3>Step 1 to 2 Select Child Projects</h3>
         <p>Choose child projects from the same contact (builder) to update in bulk</p>
          <v-card-title class="contact-search ">
            <a-text-field v-model="searchChildProjects" @input="debounceGetChildProjects" prepend-inner-icon="search"
              label="Search" single-line clearable hide-details></a-text-field>
          </v-card-title>

            <v-data-table  id="custom-fields-table" :headers="headersChildProjects" :items="filterChildProjectsFields"
            :fixed-header="true" :server-items-length="totalChildProjects" :loading="ChildProjectsDataLoading"
            :options.sync="childProjectsOptions" :footer-props="footerPropsChildProjects"
            class="elevation-1 mt-1  table-striped">
     
              <template #no-data>
                <span class="default-text-color">No active users currently assigned this Position.</span>
              </template>
              <template #no-results>
                <span class="default-text-color">No available fields</span>
              </template>
              <template #item="{ item, index }" >
             <tr>
              <td class="text-left clickable field-name-col">
            <v-checkbox
                v-model="item.select"   
                color="primary"
                hide-details
                dense
                @change="onCheckboxChange(item, index)"
              />
             </td>
               <td class="text-left clickable field-name-col">
                       {{ item.projectName }} 
               </td> 
               <td class="text-left clickable field-name-col">
              {{ item.ownerName }} 
              </td> 
              <td class="text-left clickable field-name-col">
              {{ item.objectCategory }} 
              </td> 
             </tr>
           </template>
         </v-data-table>
         <div class="d-flex align-center justify-end contact-gap">
             <span class="close sys-hover" @click="closeChildProjectsPopup" >Close</span>
          <a-btn
          @click="getContactInfo"
          class="change-contact-padding"
          size="medium"
          text="Continue"
          :disabled="ChildProjectsSelectList.length === 0"
          ></a-btn>
         </div>
     </v-card>
    </v-dialog>



    <v-dialog max-width="800" v-model="showContactPopup" >
       <v-card class="square-card contact-popup"  >
         <h3>Step 2 to 2:Assign Contact</h3>
         <p>Updating the Community Project and 20 Selected Child Projects</p>
          <v-card-title class="contact-search ">
            <a-text-field v-model="searchContact" @input="debounceGetContact" prepend-inner-icon="search"
              label="Search" single-line clearable hide-details></a-text-field>
              <a-btn
              variant="outlined"
              size="medium"
              custom-classes="label-medium text-transform-unset px-3 py-1"
              text=" + Create New Contact"
              >
              + Go to contact
              </a-btn>


          </v-card-title>

            <v-data-table  id="custom-fields-table" :headers="headersContact" :items="filterContactFields"
            :fixed-header="true" :server-items-length="totalContact" :loading="ContactDataLoading"
            :options.sync="ContactOptions" :footer-props="footerPropsContact"
            class="elevation-1 mt-1  table-striped">
     
              <template #no-data>
                <span class="default-text-color">No active users currently assigned this Position.</span>
              </template>
              <template #no-results>
                <span class="default-text-color">No available fields</span>
              </template>
              <template #item="{ item, index }" >
             <tr>
              <td class="text-left clickable field-name-col">
              {{ item.fullName }} 
              </td> 

               <td class="text-left clickable field-name-col">
                       {{ item.state }} 
               </td> 
               <td class="text-left clickable field-name-col">
              {{ item.dateCreated | formatDate('timestamp', 'MM/DD/YYYY')}} 
              </td> 
              <td class="text-left clickable field-name-col">
              {{ item.objectCategory }} 
              </td> 
             </tr>
           </template>
         </v-data-table>
         <div class="d-flex align-center justify-end contact-gap">
             <span class="close sys-hover" @click="closeContactPreviousPopup" >Previous</span>
          <a-btn
          @click="closeContactPopup"
          class="change-contact-padding"
          size="medium"
          text="Continue"
          ></a-btn>
         </div>
     </v-card>
    </v-dialog>






  </div>
</template>
<script setup>
import {toRefs, computed, ref,watch } from 'vue'
import {
  cleanPhoneNumberForCopying,
  formatPhoneNumber,
  getRequest,
  postRequest,
  handleHidingGlobalLoader,
  logError, getRequestWithParams
} from '@/helpers/helpers'
import {useProjectStore} from '@/stores/ProjectStore.js'
import { useAppStore } from '@/stores/AppStore.js'
import { useUserStore } from '@/stores/UserStore.js'
import {useRouter} from 'vue-router/composables'
import constants from "@/helpers/constants.js"
import debounce from "lodash.debounce";

import axios from "axios";
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
import { activitiesData } from '@/helpers//activitiesData.js' 

const projectStore = useProjectStore()
const appStore = useAppStore()
const userStore = useUserStore()
const router = useRouter()

const props = defineProps({
  project: Object
})
const {project} = toRefs(props)
const newContact = ref({})
const dataLoading = ref(false)
const totalContacts = ref(0)
const contactCategories = ref([])
const contactSelectionType = ref(null) //1 = existing, 2 = new
const search = ref('')
const source = ref(null)
const page = ref(1)
const options = ref({itemsPerPage: 100})
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 1000],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const existingContacts = ref([])
const newContactForm = ref(null)
const selectedExistingContact = ref(null)
const showChangeContactModal = ref(false)
const showResetContactModal = ref(false)
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
const contactPhoneRule = ref([() => (newContact.value.phone != null && newContact.value.phone !== '') || "Phone is required",v => (!v || (v && (v.length <= 20))) || 'Must be 20 characters or less',v => (!v || (/^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$/.test(v))) || "Please reformat the Phone field with a valid phone number"])
const emailRules = ref(constants.EMAIL_RULES)
const postalCodeRules = ref(constants.POSTAL_CODE_RULES)
const headers = ref([
  { text: 'Contact Name', value: 'fullName', show: true },
  { text: 'State', value: 'state', show: true },
  { text: 'Date Created', value: 'dateCreated', show: true },
])


const showResetButton = computed(() => {
  //this is a temporary solution so that kevin can fix some data instead of me. will add a better solution when they define it.
  return  project.value?.parentProject && project.value?.parentProject?.id !== null && project.value?.contactId !== project.value?.parentProject?.contactId
            && (userStore.isSystemAdmin || userStore.details.id === 2415534)
})

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

const debounceGetContacts = debounce(async() => {
  dataLoading.value = true
  //don't allow search to be null - causes issues
  search.value = search.value || ''
  getContacts()
}, 500)

const getContacts = async () => {
  const { page, itemsPerPage } = options.value

  if(source.value){
    source.value.cancel();
  }
  const CancelToken = axios.CancelToken;
  source.value = CancelToken.source();

  try {
    const {data, status} = await getRequestWithParams(`/contact/categorySearch/${project.value.objectCategoryId}`, {
      source: source.value,
      cancelToken: source.value.token,
      params: {
        query: search.value,
        page: page - 1,
        size: itemsPerPage
      }}, null, [])
    existingContacts.value = data.content || []
    totalContacts.value = data.totalElements
    dataLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Contacts')

    appStore.loading = false
  }
}

const getAvailableContactCategories = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/objectCategory/${project.value.objectCategoryId}/children`)
    contactCategories.value = data
    if(data?.length === 1) {
      newContact.value.objectCategoryId = data[0].id
    }
    handleHidingGlobalLoader(status)
  } catch (e) {
    appStore.loading = false
    logError(e)
  }
}

const assignContact = async () => {
  appStore.loading = true
  try {
    let params = {
      ...newContact.value
    }
    if(selectedExistingContact.value?.id) {
      params.id = selectedExistingContact.value.id
    }
    await postRequest(`/contact/createFromProject/${project.value.id}`, params)
    activitiesData.triggerFlag= !activitiesData.triggerFlag;
    window.location.reload()
   
  } catch (e) {
    appStore.loading = false
    logError(e)
  } finally {
    newContact.value = {}
  }
}

const resetContact = async () => {
  appStore.loading = true
  try {
    await postRequest(`/project/${project.value.id}/resetContact`, {})

    window.location.reload()
    activitiesData.triggerFlag= !activitiesData.triggerFlag;
  } catch (e) {
    appStore.loading = false
    logError(e)
  } finally {
    newContact.value = {}
  }
}

// ChildProjects start

const ChildProjectsSelectList=ref([])
const showChildProjectsPopup=ref(false)
const searchChildProjects = ref("")
const filterChildProjectsFields = ref([])
const headersChildProjects = ref([
   { text: "Select", value: "select", sortable: false },
  { text: "Child Project", value: "projectName", sortable: false },
  { text: "Contact Name", value: "ownerName", sortable: false },
  { text: "Contact Type", value: "objectCategory", sortable: false },
  
])
const footerPropsChildProjects = ref({
  'items-per-page-options': [10, 25, 50],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
})
const childProjectsOptions = ref({ itemsPerPage: 10 ,page:1})
const initialLoadChildProjects = ref(true)
const totalChildProjects = ref(0)
const ChildProjectsDataLoading = ref(true)
const debounceGetChildProjects = debounce(async () => {
//don't allow search to be null - causes issues
ChildProjectsDataLoading.value = true
searchChildProjects.value = searchChildProjects.value || ''
// localStorage.setItem('contactSearch', search.value)
getChildProjectsInfo()
}, 500)


watch(
  () => childProjectsOptions,
  (_newValue, oldValue) => {
    if (!initialLoadChildProjects.value) {
      getChildProjectsInfo();
    }
  },
  { deep: true }
)
const getChildProjectsInfo = async () => {
  try {

    const { page, itemsPerPage } = childProjectsOptions.value
    const { data } = await getRequestWithParams(
      `/project/childProject`,
      {
        params: {
          projectId:project.value.id ,
          query: searchChildProjects.value,
          page: page - 1,
          size: itemsPerPage
        }
      },
      null,
      []
    );
 
 data.content.forEach(item => {
    item.select = ChildProjectsSelectList.value.includes(item.id);
  });
    
    totalChildProjects.value = 100
    filterChildProjectsFields.value = data.content || []
    showChildProjectsPopup.value=true
    ChildProjectsDataLoading.value = false
    initialLoadChildProjects.value = false
  } catch (error) {
    console.error("Error fetching active users:", error);
  }
};



 const onCheckboxChange = (item, index) => {
      console.log(`Checkbox for ${item.id} at index ${index} is now`, item.select)
      // Your custom logic here
      if(item.select)
      {
        ChildProjectsSelectList.value?.push(item.id)
      }else{
        const removeIndex = ChildProjectsSelectList.value.findIndex(id => id === item.id)
    if (removeIndex !== -1) {
      ChildProjectsSelectList.value?.splice(removeIndex, 1)
    }
      }
    }
  const closeChildProjectsPopup=()=>{
  showChildProjectsPopup.value=false;
  ChildProjectsSelectList.value=[]
}

// ChildProjects end




// contact start


const showContactPopup=ref(false)
const searchContact= ref("")
const filterContactFields = ref([])
const headersContact = ref([
   { text: "Contact Name", value: "fullName", sortable: false },
  { text: "State", value: "state", sortable: false },
  { text: "Date Created", value: "dateCreated", sortable: false },
  { text: "Contact Type", value: "objectCategory", sortable: false },
  
])
const footerPropsContact = ref({
  'items-per-page-options': [10, 25, 50],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
})
const ContactOptions = ref({ itemsPerPage: 10 ,page:1})
const initialLoadContact = ref(true)
const totalContact = ref(0)
const ContactDataLoading = ref(true)
const debounceGetContact = debounce(async () => {
//don't allow search to be null - causes issues
ContactDataLoading.value = true
searchContact.value = searchContact.value || ''
// localStorage.setItem('contactSearch', search.value)
getContactInfo()
}, 500)


watch(
  () => ContactOptions,
  (_newValue, oldValue) => {
    if (!initialLoadContact.value) {
      getContactInfo();
    }
  },
  { deep: true }
)
const getContactInfo = async () => {
  try {
   
  if(ChildProjectsSelectList.value?.length===0)
  {
    return
  }
    const { page, itemsPerPage } = ContactOptions.value
    const { data } = await getRequestWithParams(
      `/contact/childProject/contacts`,
      {
        params: {
          projectId:project.value.id ,
          query: searchContact.value,
          page: page - 1,
          size: itemsPerPage
        }
      },
      null,
      []
    );
 
    showChildProjectsPopup.value=false
    totalContact.value = 100
    filterContactFields.value = data.content || []
    showContactPopup.value=true
    ContactDataLoading.value = false
    initialLoadContact.value = false
  } catch (error) {
    console.error("Error fetching active users:", error);
  }
};



  const closeContactPopup=()=>{
  showContactPopup.value=false;
  ChildProjectsSelectList.value=[]


}
const closeContactPreviousPopup=()=>{
  showContactPopup.value=false;
  showChildProjectsPopup.value=true;
}


// contact end






</script>

<style lang="scss" scoped>
.contact-snippet {
  border: solid 1px var(--v-grey-lighten1);
  padding: 10px;
  margin: 0 23px 10px 23px;
  max-width: 480px;
}

.overview-contact-email {
  max-width: 100%;
  overflow-wrap: anywhere;
}

.contact-object-category {
  color: var(--v-grey-darken1);
}
</style>

<style lang="scss">
#existing-contacts-container .v-data-table__wrapper {
  max-height: 500px;
  min-height: 300px;
}
#existing-contacts-container .v-data-footer__pagination {
  display: none !important;
}

#existing-contacts-container .selected-row {
  background-color: var(--v-success-lighten2) !important;
}


.contact-popup .v-data-table__wrapper{
  height: 45vh !important;
}

.change-contact{
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;

}
.change-contact-padding
{
  padding: 6px !important;

}
.contact-search 
{
  padding: 0px !important;
}
.contact-popup{
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 20px;
}
.sys-hover:hover {
    cursor: pointer !important;
}

.change-contact {
   color: #1f3c73;
}
.contact-gap{
  gap: 10px;
}
</style>

