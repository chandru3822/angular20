<template>
  <v-container class="pa-0 mobile-background">
    <SidePanelExpansionPanel header="Overview" :is-disabled="!props.isExpandable" :section-expanded="opened">
      <template v-slot:tool-btn>
        <a-btn
            id="qa-page-overview-edit"
            size="small"
            class="mx-2"
            variant="text"
            custom-classes="px-0"
            html-style="max-width: 34px"
            @click.native.stop="$emit('clickEdit')"
            v-if="props.showEditBtn">
          <template v-slot:default>
            <v-icon :size="20">edit</v-icon>
          </template>
        </a-btn>
      </template>
      <template v-slot:expanded-content>
        <div v-for="detail in props.details">
          <div v-if="!detail.type || detail.type === constants.OVERVIEW_FIELD_TYPES.DEFAULT" class="mb-2">
            <span class="detail-label label-small">{{ detail.label }}: </span>
            <div v-if="detail.value" @click="detail.clickable ? $emit(`click-detail`, detail) : null"
                 class="detail-item body-medium body-medium"
                 :class="{'clickable underline anchor':detail.clickable}">
              {{ detail.value }}
            </div>
            <div v-else class="detail-item body-medium body-medium">N/A</div>
          </div>
          <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.DATE" class="mb-4">
            <span class="detail-label label-small">{{ detail.label }}: </span><br/>
            <span v-if="detail.value" class="detail-item body-medium">{{ formatDate(detail.value) }}</span>
            <span v-else class="d-inline-block detail-item body-medium">N/A</span>
          </div>
          <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.STATUS" :class="{'mb-4': !props.dense, 'mb-0': props.dense}">
            <span class="vertical-top detail-label label-small">{{ detail.label }}: </span><br/>
            <span class="d-inline-block detail-item vertical-top body-medium"
                  v-if="detail.value"
                  :class="[getStatusColorClass(detail.statusTypeId), {'status-active': detail.active && !detail.statusTypeId,'status-cancelled': !detail.active && !detail.statusTypeId}]">
        {{ detail.value }}
        <span v-if="detail.statusType">({{ detail.statusType }})</span>
        </span>
          </div>
          <div v-if="!detail.type || detail.type === constants.OVERVIEW_FIELD_TYPES.ID"
               class="flex-display mb-2 clickable" @click="copyToClipBoard(detail.value, detail.label)">
            <span class="detail-label label-small pr-2"><v-icon small>mdi-information</v-icon></span>
            <span v-if="detail.value" class="detail-item body-medium body-medium">
          {{ detail.value }}
          <v-tooltip right>
            <template v-slot:activator="{on, attrs}">
              <v-icon small color="primary" v-bind="attrs" v-on="on">mdi-content-copy</v-icon>
            </template>
            <span>Copy</span>
          </v-tooltip>
        </span>
          </div>
          <div v-if="!detail.type || detail.type === constants.OVERVIEW_FIELD_TYPES.EMAIL" class="flex-display mb-2"
               :class="{'clickable':!!detail.value}" @click="copyToClipBoard(detail.value, detail.label)">
            <span class="detail-label label-small pr-2"><v-icon small>mdi-email</v-icon></span>
            <span v-if="detail.value" @click="detail.clickable ? $emit(`click-detail`, detail) : null"
                  class="detail-item body-medium body-medium"
                  :class="{'clickable underline anchor':detail.clickable}">
          {{ detail.value }}
        </span>
            <span v-else class="d-inline-block detail-item body-medium">N/A</span>
          </div>

          <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.ADDRESS" class="flex-display mb-2"
               :class="{'clickable':!!detail.value}"
               @click="copyToClipBoard(`${detail.value.street} ${detail.value.city}, ${detail.value.state} ${detail.value.zip}`, detail.label)">
            <span class="detail-label label-small pr-2"><v-icon small>mdi-map-marker</v-icon></span>
            <div
                v-if="detail.value && (detail.value.street || detail.value.city || detail.value.state || detail.value.zip)"
                class="d-inline-block vertical-top detail-item body-medium">
              <span>{{ detail.value.street }}</span><br/>
              <span>{{ detail.value.city }}, {{ detail.value.state }} {{ detail.value.zip }}</span>
            </div>
            <span v-else class="d-inline-block detail-item body-medium">N/A</span>
          </div>
          <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.PHONE" class="flex-display mb-2"
               :class="{'clickable':!!detail.value}"
               @click="copyToClipBoard(cleanPhoneNumberForCopying(detail.value), detail.label)">
            <span class="detail-label label-small pr-2"><v-icon small>mdi-phone</v-icon></span>
            <span v-if="detail.value" class="detail-item body-medium">{{ formatPhoneNumber(detail.value) }}</span>
            <span v-else class="d-inline-block detail-item body-medium">N/A</span>
          </div>
          <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.EXTENSION" class="flex-display mb-2"
               :class="{'clickable':!!detail.value}" @click="copyToClipBoard(detail.value, detail.label)">
        <span class="detail-label label-small pr-2">
          <v-tooltip top>
            <template v-slot:activator="{on, attrs}">
              <v-icon small v-bind="attrs" v-on="on">mdi-pound</v-icon>
            </template>
            <span>phone extension</span>
          </v-tooltip>
        </span>
            <span v-if="detail.value" class="detail-item body-medium">{{ detail.value }}</span>
            <span v-else class="d-inline-block detail-item body-medium">N/A</span>
          </div>
          <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.MOBILE_PHONE" class="flex-display mb-2"
               :class="{'clickable':!!detail.value}"
               @click="copyToClipBoard(cleanPhoneNumberForCopying(detail.value), detail.label)">
        <span class="detail-label label-small pr-2">
          <v-icon small>mdi-cellphone</v-icon>
        </span>
            <span v-if="detail.value" class="detail-item body-medium">{{ formatPhoneNumber(detail.value) }}</span>
            <span v-else class="d-inline-block detail-item body-medium">N/A</span>
          </div>
          <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.BUTTON" class="mb-4">
            <div class="mt-3">
              <a-btn variant="outlined" size="small"
                               custom-classes="label-medium text-transform-unset px-3 py-1"
                               :to="`/contact/${detail.value}`" target="_blank">
                <template v-slot:default>
                  Go to contact
                  <v-icon small class="pl-2">mdi-open-in-new</v-icon>
                </template>
              </a-btn>
            </div>
          </div>
          <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.OWNER" :class="{'flex-display': !detail.value}">
            <div class="detail-label label-small">{{ detail.label }}:</div>
            <div v-if="detail.value" class="d-inline-block detail-item body-medium" @dblclick="selectValue">
                <span :class="{'error-text': !detail.value.hasAccess}">{{
                    detail.value.fullName
                  }} - {{ detail.value.position }} <br/></span>
              <span v-if="detail.value.hasAccess && detail.value.phoneNumber"
                    :class="{'clickable':!!detail.value.phoneNumber}"
                    @click="copyToClipBoard(cleanPhoneNumberForCopying(detail.value.phoneNumber), `${detail.label} Phone Number`)">
             <span class="detail-label label-small pr-2"><v-icon
                 small>mdi-phone</v-icon></span>{{ formatPhoneNumber(detail.value.phoneNumber) }}<br/>
          </span>
              <div class="mt-3">
                <a-btn
                    v-if="teamsAssociatedToUser.length > 0 && userCanViewSms"
                    variant="outlined"
                    size="small"
                    :color="!detail.value.hasSmsAccess || !detail.value.hasAccess ? 'grey' : 'primary'"
                    custom-classes="label-medium text-transform-unset py-1"
                    @click="openSendMessageDialogue(detail.value)"
                    target="_blank"
                >
                  <template v-slot:default>
                    Send message
                    <v-icon small class="pl-2">mdi-forum</v-icon>

                    <NewMessageDialog class="pa-0"
                                      :show-new-message-dialog.sync="showNewMessageDialog"
                                      :is-inbox="false"
                                      :owner-user-id="detail.value.userId"/>
                  </template>
                </a-btn>
              </div>
            </div>
            <span v-else class="d-inline-block detail-item body-medium pl-2">N/A</span>
          </div>
        </div>

      </template>
    </SidePanelExpansionPanel>
  </v-container>
</template>

<script setup>
import {formatPhoneNumber, cleanPhoneNumberForCopying, getRequest} from "@/helpers/helpers";
import constants from '@/helpers/constants'
import {getStatusColorClass} from "@/services/projectStatusTypeService";
import NewMessageDialog from "./settings/inbox/NewMessageDialog";
import SidePanelExpansionPanel from "@/components/SidePanelExpansionPanel.vue";

import {getCurrentInstance, onMounted, ref, defineProps} from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
import { useProjectStore } from '@/stores/ProjectStore.js'
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
const projectStore = useProjectStore()
const router = vueInstance.$router
const snackbar = vueInstance.$snackbar
const filters = vueInstance.$filters

const showNewMessageDialog = ref(false)
const teamsAssociatedToUser = ref([])
const userCanViewSms = ref(userStore.userHasFeatureAccessLevel('SMS_INBOX', 'VIEW'))
const opened = ref(true) //opens this expansion panel by default

const props = defineProps({
  pageName: String,
  isExpandable: {
    type: Boolean,
    default: true
  },
  showEditBtn: Boolean,
  dense: {
    type: Boolean,
    default: false
  },
  details: Array,
  owner: Object
})

onMounted(() => {
  fetchTeamsForUser()
})
const formatDate = (value) => {
  return filters.formatDate(value, 'date')
}
const getValue = (type) => {
  return props.details.find(d => d.type === type)?.value || null
}
const copyToClipBoard = (textValue, label) => {
  if (textValue) {
    if (!label) {
      label = 'text'
    }
    navigator.clipboard.writeText(textValue);
    snackbar('SUCCESS', `Copied ${label} to clipboard`)
  }
}
const selectValue = () => {

}
const openMenu = () => {
  projectStore.leftSideSplit = false;
}
const openSendMessageDialogue = (owner) => {
  if (!owner.hasSmsAccess) {
    snackbar('ERROR', 'Message cannot be sent to a user that does not have SMS access')
  } else if (!owner.hasAccess) {
    snackbar('ERROR', 'Message cannot be sent to a user that is no longer active')
  } else {
    showNewMessageDialog.value = true
  }
}
const fetchTeamsForUser = async () => {
  try {
    const {data, status} = await getRequest(`/smsTeam/getTeamsForUser`)
    teamsAssociatedToUser.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error fetching SMS Teams')
  }
}
</script>

<style lang="scss" scoped>
.detail-label {
  color: var(--v-grey-darken1);
}

.detail-item {
  //font-size: 0.875rem;
  //margin-left: 5px;
  //overflow-wrap: break-word;
  overflow-wrap: anywhere;
}

.vertical-top {
  margin-top: -2px;
}

@media (max-width: 960px) {
  .mobile-background {
    background-color: white;
  }

  .mobile-hamburger-menu {
    padding-left: 16px;
    padding-right: 28px;
  }

  .mobile-contact-header {
    padding-right: 24px;
    padding-top: 12px;
  }

  .mobile-content-padding {
    padding-top: 8px;
    padding-left: 16px;
  }
}

</style>
