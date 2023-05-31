<template>
<v-container class="pa-0 mobile-background">
  <v-toolbar flat color="transparent" class="mobile-contact-header">
    <div class="headline-small hide-xs">{{pageName}} Overview</div>
    <div class=" headline-small show-xs"><v-icon class="show-xs mobile-hamburger-menu" @click="openMenu()">mdi-menu</v-icon>Overview</div>
    <v-spacer></v-spacer>
    <v-toolbar-items>
      <v-btn
        text x-small color="primary"
        @click.stop="$emit('clickEdit')"
        v-if="showEditBtn">
        <v-icon>edit</v-icon>
      </v-btn>
    </v-toolbar-items>
  </v-toolbar>
  <div class="mx-4 mobile-content-padding" v-if="details">
    <div v-for="detail in details">
      <div v-if="!detail.type || detail.type === constants.OVERVIEW_FIELD_TYPES.DEFAULT" class="mb-2">
        <span class="detail-label label-small">{{detail.label}}: </span>
        <div v-if="detail.value" @click="detail.clickable ? $emit(`click-detail`, detail) : null"
              class="detail-item body-medium body-medium"
              :class="{'clickable underline anchor':detail.clickable}" >
          {{detail.value}}
        </div>
        <div v-else class="detail-item body-medium body-medium">N/A</div>
      </div>
      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.DATE" class="mb-4">
        <span class="detail-label label-small">{{detail.label}}: </span><br/>
        <span v-if="detail.value" class="detail-item body-medium">{{formatDate(detail.value)}}</span>
        <span v-else class="d-inline-block detail-item body-medium">N/A</span>
      </div>
      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.STATUS" :class="{'mb-4': !dense, 'mb-0': dense}">
        <span class="vertical-top detail-label label-small">{{detail.label}}: </span><br/>
        <span class="d-inline-block detail-item vertical-top body-medium"
              v-if="detail.value"
              :class="[getStatusColorClass(detail.statusTypeId), {'status-active': detail.active && !detail.statusTypeId,'status-cancelled': !detail.active && !detail.statusTypeId}]">
        {{detail.value}}
        <span v-if="detail.statusType">({{detail.statusType}})</span>
        </span>
      </div>
      <div v-if="!detail.type || detail.type === constants.OVERVIEW_FIELD_TYPES.ID" class="flex-display mb-2 clickable" @click="copyToClipBoard(detail.value, detail.label)">
        <span class="detail-label label-small pr-2"><v-icon small>mdi-information</v-icon></span>
        <span v-if="detail.value" class="detail-item body-medium body-medium">
          {{detail.value}}
          <v-tooltip right>
            <template v-slot:activator="{on, attrs}">
              <v-icon small color="primary" v-bind="attrs" v-on="on">mdi-content-copy</v-icon>
            </template>
            <span>Copy</span>
          </v-tooltip>
        </span>
      </div>
      <div v-if="!detail.type || detail.type === constants.OVERVIEW_FIELD_TYPES.EMAIL" class="flex-display mb-2" :class="{'clickable':!!detail.value}" @click="copyToClipBoard(detail.value, detail.label)">
        <span class="detail-label label-small pr-2"><v-icon small>mdi-email</v-icon></span>
        <span v-if="detail.value" @click="detail.clickable ? $emit(`click-detail`, detail) : null"
              class="detail-item body-medium body-medium"
              :class="{'clickable underline anchor':detail.clickable}" >
          {{detail.value}}
        </span>
        <span v-else class="d-inline-block detail-item body-medium">N/A</span>
      </div>

      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.ADDRESS" class="flex-display mb-2" :class="{'clickable':!!detail.value}" @click="copyToClipBoard(`${detail.value.street} ${detail.value.city}, ${detail.value.state} ${detail.value.zip}`, detail.label)">
          <span class="detail-label label-small pr-2"><v-icon small>mdi-map-marker</v-icon></span>
          <div v-if="detail.value && (detail.value.street || detail.value.city || detail.value.state || detail.value.zip)" class="d-inline-block vertical-top detail-item body-medium">
            <span>{{detail.value.street}}</span><br/>
            <span>{{detail.value.city}}, {{detail.value.state}} {{detail.value.zip}}</span>
          </div>
        <span v-else class="d-inline-block detail-item body-medium">N/A</span>
      </div>
      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.PHONE" class="flex-display mb-2" :class="{'clickable':!!detail.value}" @click="copyToClipBoard(cleanPhoneNumberForCopying(detail.value), detail.label)">
        <span class="detail-label label-small pr-2"><v-icon small>mdi-phone</v-icon></span>
        <span v-if="detail.value" class="detail-item body-medium">{{formatPhoneNumber(detail.value)}}</span>
        <span v-else class="d-inline-block detail-item body-medium">N/A</span>
      </div>
      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.EXTENSION" class="flex-display mb-2" :class="{'clickable':!!detail.value}" @click="copyToClipBoard(detail.value, detail.label)">
        <span class="detail-label label-small pr-2">
          <v-tooltip top>
            <template v-slot:activator="{on, attrs}">
              <v-icon small v-bind="attrs" v-on="on">mdi-pound</v-icon>
            </template>
            <span>phone extension</span>
          </v-tooltip>
        </span>
        <span v-if="detail.value" class="detail-item body-medium">{{detail.value}}</span>
        <span v-else class="d-inline-block detail-item body-medium">N/A</span>
      </div>
      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.MOBILE_PHONE" class="flex-display mb-2" :class="{'clickable':!!detail.value}" @click="copyToClipBoard(cleanPhoneNumberForCopying(detail.value), detail.label)">
        <span class="detail-label label-small pr-2">
          <v-icon small>mdi-cellphone</v-icon>
        </span>
        <span v-if="detail.value" class="detail-item body-medium">{{formatPhoneNumber(detail.value)}}</span>
        <span v-else class="d-inline-block detail-item body-medium">N/A</span>
      </div>
      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.BUTTON" class="mb-4">
        <div class="mt-3">
          <v-btn outlined small color="primary" class="label-medium text-transform-unset px-3 py-1" :to="`/contact/${detail.value}`" target="_blank">Go to contact<v-icon small class="pl-2">mdi-open-in-new</v-icon></v-btn>
        </div>
      </div>
      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.OWNER" :class="{'flex-display': !detail.value}">
        <div class="detail-label label-small">{{detail.label}}:</div>
        <div v-if="detail.value" class="d-inline-block detail-item body-medium" @dblclick="selectValue">
                <span :class="{'error-text': !detail.value.hasAccess}">{{
                    detail.value.fullName
                  }} - {{detail.value.position }} <br/></span>
          <span v-if="detail.value.hasAccess && detail.value.phoneNumber" :class="{'clickable':!!detail.value.phoneNumber}" @click="copyToClipBoard(cleanPhoneNumberForCopying(detail.value.phoneNumber), `${detail.label} Phone Number`)">
             <span class="detail-label label-small pr-2"><v-icon small>mdi-phone</v-icon></span>{{ formatPhoneNumber(detail.value.phoneNumber) }}<br/>
          </span>
          <v-btn v-if="teamsAssociatedToUser.length > 0 && userCanViewSms" outlined small color="" :color="detail.value.hasSmsAccess ? 'primary' : 'grey'"
                 class="label-medium text-transform-unset px-3 py-1 send-message-div" @click="openSendMessageDialogue(detail.value)" target="_blank">Send message<v-icon small class="pl-2">mdi-forum</v-icon></v-btn>
          <NewMessageDialog :show-new-message-dialog.sync="showNewMessageDialog"
                            :is-inbox="false"
                            :owner-user-id="detail.value.userId"/>
        </div>
        <span v-else class="d-inline-block detail-item body-medium pl-2">N/A</span>
      </div>
    </div>
  </div>
</v-container>
</template>

<script>
import {formatPhoneNumber, cleanPhoneNumberForCopying, getRequest, getSnackbar} from "@/helpers/helpers";
import constants from '@/helpers/constants'
import {getStatusColorClass} from "@/services/projectStatusTypeService";
import {AppMutations} from "@/stores/AppStore";
import NewMessageDialog from "./settings/inbox/NewMessageDialog";

export default {
  name: "PageOverview",
  props: {
    pageName: String,
    showEditBtn: Boolean,
    dense: {
      type: Boolean,
      default: false
    },
    details: Array,
    owner: Object
  },
  components: {
    NewMessageDialog
  },
  data() {
    return {
      constants,
      formatPhoneNumber,
      cleanPhoneNumberForCopying,
      getStatusColorClass,
      showNewMessageDialog: false,
      teamsAssociatedToUser: [],
      userCanViewSms: this.$store.getters.userHasFeatureAccessLevel('SMS_INBOX', 'VIEW'),
    }
  },
  created() {
    this.fetchTeamsForUser()
  },
  methods: {
    formatDate(value){
      return this.$filters.formatDate(value, 'date')
    },
    getValue(type) {
      return this.details.find(d => d.type === type)?.value || null
    },
    copyToClipBoard(textValue, label){
      if(textValue) {
        if(!label){
          label = 'text'
        }
        navigator.clipboard.writeText(textValue);
        this.snackbar = getSnackbar('SUCCESS', `Copied ${label} to clipboard`)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    selectValue(){

    },
    openMenu(){
      this.$store.state.project.leftSideSplit = false;
    },
    openSendMessageDialogue(owner) {
      if (!owner.hasSmsAccess) {
        this.snackbar = getSnackbar('ERROR', 'Message cannot be sent to a user that does not have SMS access')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
      else if (!owner.hasAccess) {
        this.snackbar = getSnackbar('ERROR', 'Message cannot be sent to a user that is no longer active')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
      else {
        this.showNewMessageDialog = true
      }
    },
    async fetchTeamsForUser() {
      try {
        const { data, status } = await getRequest(`/smsTeam/getTeamsForUser/`)
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.teamsAssociatedToUser = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching SMS Teams')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.conversationIsLoading = false
      }
    },
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

  .mobile-hamburger-menu{
    padding-left: 16px;
    padding-right: 28px;
  }

  .mobile-contact-header{
    padding-right: 24px;
    padding-top: 12px;
  }

  .mobile-content-padding{
    padding-top: 8px;
    padding-left: 16px;
  }
}

</style>
